import delphibridge;

int add(int i1, int i2)
{
	return i1 + i2;
}

mixin exportModules!(["library"]);