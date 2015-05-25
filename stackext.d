/* Written in the D-Programming Language */
/**
  * Stacking elements whithout repetitions

  * For a type T a totally ordered collection of non repeating
  * elements is maintained.
  *
  * Let c be of type StackExtended(T) and e be of type T.
  * Then
  * ---
  * c.isEmpty // yields true, iff collection c contains no elements
  * c.max     // yields the current maximum according to the ordering
  * c+= e;    // e changes the ordering so that c.max==e
  * c--;      // deletes the c.max out of c and restores previous max
  * ---
  * in addition
  * ---
  * e in c    // yields true, iff `c+= e;' is called but not followed by
  *           // a call `c--;' where `c.max' would have returned e 
  */
private import base.set, base.stack;
class StackExtended( T): Stack!T{
  Set!T stacked;
  this(){ stacked= new Set!T;}

  // push
  auto opOpAssign( string op, T)( T node){
    stacked+= node;
    return super+= node;
  }
  // pop
  auto opUnary( string op)(){
    stacked -= super.max;
    return super--;
  }
  // is existing
  bool opBinaryRight( string op, Tquote)( Tquote elem)
    if( is( Tquote:T) &&( "in"==op ))
  {
    return elem in stacked;
  }
}
import std.stdio: writeln;
import std.conv: to;
unittest{
  alias StackExtended!uint UintStack;
  auto stack= new UintStack;
  stack+= 1;
  assert( 1 in stack); // this is new
  stack--;
  assert( 1 !in stack);
      debug( stackext) writeln( "StackExtended Done.");
}
