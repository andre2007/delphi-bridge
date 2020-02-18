module delphibridge.library;

import std.stdio;
import std.array;
import std.bitmanip;
import std.string : representation;

enum RequestAction : ubyte
{
	callStaticFunction
}

enum VariableType : ubyte
{
	int_
}

class Arguments
{
    private ubyte[] _data;
    private size_t _idx;
        
    typeof(this) addInt(int value)
	{
		_data ~= nativeToLittleEndian(value);
		return this;
	}
    
    int readSkip()
    {
        return _data.peek!(int, Endian.littleEndian)(&_idx);
    }
    
    private this(){}
    
    private this(ubyte[] data)
    {
        _data = data;
    }
}

class CallStaticFunctionMessage
{
	private string _functionName;
    private Arguments _arguments;

    @property Arguments arguments()
    {
        return _arguments;
    }

	this(string functionName)
	{
	    _functionName = functionName;
        _arguments = new Arguments();
	}
    
    private this(string functionName, Arguments arguments)
    {
    
    }
    
	
	
    
    static typeof(this) fromBuffer(ubyte[] buffer)
    {
        size_t idx;
        ubyte requestAction = buffer.peek!(ubyte, Endian.littleEndian)(&idx);
        assert(requestAction == RequestAction.callStaticFunction);
        
        return new CallStaticFunctionMessage("", new Arguments());
    
    }
    
	ubyte[] getData()
	{
		auto buffer = appender!(ubyte[])();
        
		buffer.append!ubyte(RequestAction.callStaticFunction);
        
		buffer.append!(long, Endian.littleEndian)(_functionName.length);
		buffer.put(cast(ubyte[]) _functionName);
		
		buffer.append!(long, Endian.littleEndian)(_arguments._data.length);
		buffer.put(_arguments._data);
        
		return buffer.data;
	}
}

mixin template exportModules(string[] modules)
{
    import std.traits;
    import std.string : startsWith;

    string[] _db_listFunctions()
    {
        string[] results;
        static foreach(moduleName; modules)
        {
            mixin ("alias moduleSymbol = " ~ moduleName ~ ";");

            foreach(name; __traits(allMembers, moduleSymbol))
            {
                mixin ("alias symbol = " ~ name ~ ";");

                static if (isFunction!symbol)
                {
                    if(name != "main" && !name.startsWith("_db_"))
                        results ~= fullyQualifiedName!symbol;
                }
            }
        }
        return results;
    } 

    extern(C) void _db_process(ubyte[] data)
    {
        static foreach(moduleName; modules)
        {
            mixin ("alias moduleSymbol = " ~ moduleName ~ ";");

            foreach(name; __traits(allMembers, moduleSymbol))
            {
                mixin ("alias symbol = " ~ name ~ ";");

                static if (isFunction!symbol)
                {
                    if (data.isStaticFunctionCall() && data.getStaticFunctionName() == fullyQualifiedName!symbol)
                    {
                        import std;
                        alias Params = Parameters!symbol;
                        Params params;

                        static foreach(i, param; params)
                        {

                        } 


                       writeln("found");
                   } 
                    
                }
            }
        }
    } 
}

bool isStaticFunctionCall(ubyte[] data){
    return data.peek!(ubyte, Endian.littleEndian)(0) == RequestAction.callStaticFunction;
} 

string getStaticFunctionName(ubyte[] data){
    long l = data.peek!(long, Endian.littleEndian)(1);
    return cast(string) data[1+long.sizeof..1+long.sizeof+cast(int)l];
}

