/**
 * Copyright: Copyright (c) 2010-2011 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 26, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module orange.util.Traits;

import orange.serialization.Serializable;
import orange.serialization.archives.Archive;
import orange.util._;

version (Tango)
{
	import Tango = tango.core.Traits;
	
	///
	alias Tango.BaseTypeTupleOf BaseTypeTupleOf;
	
	///
	alias Tango.ParameterTupleOf ParameterTupleOf;
	
	///
	alias Tango.ReturnTypeOf ReturnTypeOf;
}

else
{
	import Phobos = std.traits;
	
	///
	alias Phobos.BaseTypeTuple BaseTypeTupleOf;
	
	///
	alias Phobos.ParameterTypeTuple ParameterTupleOf;
	
	///
	alias Phobos.ReturnType ReturnTypeOf;
	
	version = Phobos;
}

import orange.core.string;

/// Evaluates to true if $(D_PARAM T) is a primitive type.
template isPrimitive (T)
{
	const bool isPrimitive = is(T == bool) ||
						is(T == byte) ||
						is(T == cdouble) ||
						//is(T == cent) ||
						is(T == cfloat) ||
						is(T == char) ||
						is(T == creal) ||
						is(T == dchar) ||
						is(T == double) ||
						is(T == float) ||
						is(T == idouble) ||
						is(T == ifloat) ||
						is(T == int) ||
						is(T == ireal) ||
						is(T == long) ||
						is(T == real) ||
						is(T == short) ||
						is(T == ubyte) ||
						//is(T == ucent) ||
						is(T == uint) ||
						is(T == ulong) ||
						is(T == ushort) ||
						is(T == wchar);
}

/// Evaluates to true if $(D_PARAM T) is a character type.
template isChar (T)
{
	const bool isChar = is(T == char) || is(T == wchar) || is(T == dchar);
}

/// Evaluates to true if $(D_PARAM T) is a floating point type.
template isFloatingPoint (T)
{
	const bool isFloatingPoint = is(T == float) || is(T == double) || is(T == real) ||
								 is(T == cfloat) || is(T == cdouble) || is(T == creal) ||
						  		 is(T == ifloat) || is(T == idouble) || is(T == ireal);
}

/// Evaluates to true if $(D_PARAM T) is class.
template isClass (T)
{
	const bool isClass = is(T == class);
}

/// Evaluates to true if $(D_PARAM T) is an interface.
template isInterface (T)
{
	const bool isInterface = is(T == interface);
}

/// Evaluates to true if $(D_PARAM T) is a class or an interface.
template isObject (T)
{
	const bool isObject = isClass!(T) || isInterface!(T);
}

/// Evaluates to true if $(D_PARAM T) is a struct.
template isStruct (T)
{
	const bool isStruct = is(T == struct);
}

/// Evaluates to true if $(D_PARAM T) is an array.
template isArray (T)
{
	static if (is(T U : U[]))
		const bool isArray = true;
	
	else
		const bool isArray = false;
}

/// Evaluates to true if $(D_PARAM T) is a string.
template isString (T)
{
	const bool isString = is(T : string) || is(T : wstring) || is(T : dstring);
}

/// Evaluates to true if $(D_PARAM T) is a an associative array.
template isAssociativeArray (T)
{
	const bool isAssociativeArray = is(typeof(T.init.values[0])[typeof(T.init.keys[0])] == T);
}

/// Evaluates to true if $(D_PARAM T) is a pointer.
template isPointer (T)
{
	static if (is(T U : U*))
		const bool isPointer = true;
	
	else
		const bool isPointer = false;
}

/// Evaluates to true if $(D_PARAM T) is a function pointer.
template isFunctionPointer (T)
{
	const bool isFunctionPointer = is(typeof(*T) == function);
}

/// Evaluates to true if $(D_PARAM T) is an enum.
template isEnum (T)
{
	const bool isEnum = is(T == enum);
}

/// Evaluates to true if $(D_PARAM T) is an object or a pointer.
template isReference (T)
{
	const bool isReference = isObject!(T) || isPointer!(T);
}

/// Evaluates to true if $(D_PARAM T) is a typedef.
template isTypedef (T)
{
	const bool isTypedef = is(T == typedef);
}

/// Evaluates to true if $(D_PARAM T) is void.
template isVoid (T)
{
	const bool isVoid = is(T == void);
}

/// Evaluates the type of the element of the array.
template ElementTypeOfArray(T : T[])
{
	alias T ElementTypeOfArray;
}

/// Evaluates to the type the pointer points to.
template BaseTypeOfPointer (T)
{
	static if (is(T U : U*))
		alias BaseTypeOfPointer!(U) BaseTypeOfPointer;
	
	else
		alias T BaseTypeOfPointer;
}

/// Evaluates to the base type of the typedef.
template BaseTypeOfTypedef (T)
{
	static if (is(T U == typedef))
		alias BaseTypeOfTypedef!(U) BaseTypeOfTypedef;
	
	else
		alias T BaseTypeOfTypedef;
}

/// Evaluates to the base type of the enum.
template BaseTypeOfEnum (T)
{
	static if (is(T U == enum))
		alias BaseTypeOfEnum!(U) BaseTypeOfEnum;
	
	else
		alias T BaseTypeOfEnum;
}

/// Evaluates to the key type of the associative array.
template KeyTypeOfAssociativeArray (T)
{
	static assert(isAssociativeArray!(T), "The type needs to be an associative array");
	alias typeof(T.init.keys[0]) KeyTypeOfAssociativeArray;
}

/// Evaluates to the value type of the associative array.
template ValueTypeOfAssociativeArray (T)
{
	static assert(isAssociativeArray!(T), "The type needs to be an associative array");
	alias typeof(T.init.values[0]) ValueTypeOfAssociativeArray;
}

/// Evaluates to true if $(D_PARAM T) is an archive.
template isArchive (T)
{
	const isArchive = is(typeof({
		alias T.DataType Foo;
	})) &&

	is(typeof(T.archive(0, TypeOfDataType!(T).init, {}))) &&
	is(typeof(T.unarchive!(int))) && 
	is(typeof(T.beginArchiving)) &&
	is(typeof(T.beginUnarchiving(TypeOfDataType!(T).init))) &&
	is(typeof(T.archiveBaseClass!(Object))) &&
	is(typeof(T.unarchiveBaseClass!(Object))) &&
	is(typeof(T.reset)) &&
	is(typeof({TypeOfDataType!(T) a = T.data;})) &&
	is(typeof(T.unarchiveAssociativeArrayVisitor!(int[string])));
	
}

/// Evaluates to the type of the data type.
template TypeOfDataType (T)
{
	alias T.DataType TypeOfDataType;
}