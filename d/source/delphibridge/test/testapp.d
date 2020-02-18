module test.testapp;

import std;
import delphibridge.library;

class Calculator
{
	static int add(int n1, int n2)
	{
		return n1 + n2;
	}
}
/*
unittest
{
	auto message = new CallStaticMethodMessage(
	    __traits(identifier, Calculator),
	    "add");
    message.arguments.addInt(1).addInt(2);
    auto newMessage = CallStaticMethodMessage.fromBuffer(message.getData());
}
*/