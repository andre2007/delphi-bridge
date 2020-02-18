module delphibridge.app;
import delphibridge.library;

mixin exportModules!(["delphibridge.app"]);

int sum(int a, int b) {
    return a + b;
}

void main()
 {
      import std;
      writeln(_db_listFunctions);

      auto c = new CallStaticFunctionMessage("delphibridge.app.sum");
      c.arguments.addInt(2);
      c.arguments.addInt(3);
      _db_process(c.getData());
 }

