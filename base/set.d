module base.set;

import std.stdio;
import std.string, std.conv;
import std.traits: isBuiltinType;

  template getDepth(U){
    static if( is( U==Set!S, S))
      enum getDepth= 1+getDepth!S;
    else
      enum getDepth= 0;
  }


class Set( T){
  bool[ T] set;

  void opAddAssign( T elem){
    if( (elem in set) is null){
      set[ elem] = true;
      //theHash+= cast( hash_t) cast( void*) elem;
      theHash+= typeid(T).getHash(&elem);
    }
  }
  void opAddAssign( Set set){
    foreach( elem; set.elements)
     this+= elem;
  }
  void opSubAssign( T elem){
    if( (elem in set) !is null){
      set.remove( elem);
      //theHash-= cast( hash_t) cast( void*) elem;
      theHash-= typeid(T).getHash(&elem);
    }
  }
  bool opIn_r( T elem){
    return (elem in set) !is null;
  }
  T[] elements(){
    return set.keys;
  }
  uint length(){
    return set.length;
  }
  T single(){
    if( set.length != 1)
      //assert( false, "Wrongly assumed singleton."~std.string.toString(set.length));
      throw new Exception(
        "Wrongly assumed singleton, elements: "~to!string(set.length)
      );
    return set.keys[0];
  }
  bool subSetEQ( Set other){
    bool retval= true;
    auto keys= set.keys;
    if( keys.length != 0)
      foreach( elem; keys){
	retval&= elem in other;
	if( ! retval) break;
      }
    return retval;
  }
  bool opEquals( Set other){
    return subSetEQ( other) && other.subSetEQ( this);
  }
  //alias toString= Object.toString;
  version( all)

  override string toString(){
    string retval;
    foreach( elem; set.keys){
      retval~= std.conv.to!string( cast(hash_t) cast(void*) elem);
      //writeln( "depth is ", getDepth!T);
      if( getDepth!T != 0)
        retval~= "= "~to!string( elem)~"";
      else
        retval~= " is \""~to!string(elem)~"\"";
      retval~= ", ";
    }
    return "{"~retval~"}";
  }

  else

  override string toString(){
    string retval;
    foreach( elem; set.keys){
      retval~= std.conv.to!string( cast(hash_t) cast(void*) elem)~ ", ";
    }
    return "{"~retval~"}";
  }



  // for AA
  hash_t theHash=0;
  override hash_t toHash() { 
    return theHash;
  }
  override bool opEquals(Object o){
    return opEquals( cast(Set) o);
  }

  override int opCmp(Object o){
    version( safe){
    Set other = cast(Set) o;
    bool left= subSetEQ( other);
    bool right= other.subSetEQ( this);
    if( left & right) return 0;
    if( left) return -1;
    if( right) return 1;
    } else
      return !opEquals(o); // TODO
    assert( false, "unordered.");
  }
}
unittest{
 import std.stdio;
 class C{}
 auto c1 = new C;
 auto c2 = new C;
 auto s1= new Set!( C);
 auto s2= new Set!( C);
 assert( s1.length == 0);
 s1+= c1;
 s1+= c2;
 s2+= c2;
 s2+= c1;
 assert( s1 == s2);
 alias Set!( Set!(C)) PSet;
 auto ps1= new PSet;
 auto ps2= new PSet;
 ps1+= s1;
 ps2+= s2;
 assert( ps1 == ps2);
 debug(set) writeln( "unittest( Set) passed.");
}
