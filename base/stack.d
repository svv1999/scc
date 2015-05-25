/* Written in the D-Programming Language */
/**
  * Stacking elements.

  * For a type T a totally ordered collection of elements is maintained.
  *
  * Let c be of type Stack(T) and e be of type T.
  * Then
  * ---
  * c.isEmpty // yields true, iff collection c contains no elements
  * c.max     // yields the current maximum according to the ordering
  * c+= e;    // e changes the ordering so that c.max==e
  * c--;      // deletes the c.max out of c and restores previous max
  * ---
  */
module base.stack;
class Stack( T){
  T[ int] data;
  static uint count= 0;
  // push
  auto opOpAssign( string op, Tquote)( Tquote node)
    if( is( Tquote:T) && "+"==op )
  {
    data[ ++count]= node;
    return this;
  }
  // pop
  auto opUnary( string op)()
    if(  "--" == op)
  {
    data.remove( count--);
    return this;
  }
  // peek
  auto max(){
    if( 0 ==count){
      assert( 0, "empty stack does not have any element");
    }
    return data[ count];
  }
  // isEmpty?
  bool isEmpty(){
    return 0 ==count;
  }
  
  override string toString(){
    return "Stack="~to!string( data)~"\n";
  }
}
import std.stdio: writeln;
import std.conv: to;
unittest{
  alias Stack!uint UintStack;
  auto stack= new UintStack;
  stack+= 1;
  assert( 1 == stack.max);
  stack--;
  assert( stack.isEmpty);
  //stack--;
  debug( stack) writeln( "stack: Done.");
}
