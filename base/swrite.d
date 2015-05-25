module base.swrite;

import std.format: formattedWrite;
import std.array: Appender;
/* Written in the D-Programming Language */
/***
  * Silent writing.
  
  * This is a D-version of C's sprintf.
  *
  * ---
  * buffer.take( string); // formats according to the arguments
  *                       // and remembers the string silently.
  * buffer.toString;      // peeks only.
  * buffer.give;  // return the remembered concatenated strings
  *               // and causes to forget them all.
  * buffer.empty; // returns true iff nothing is remembered
  * ---
  */
class SWrite{
  /// the internal storage
  private Appender!string retval;
  void init(){
    retval= Appender!string("");
  }
  this(){
    init();
  }

  /// formats according to the arguments and remembers the formatted string
  void take( Any...)(  Any args)
    if( Any[0].stringof == "string")
  {
    formattedWrite( retval, args);
  }
  /// peeks only
  override string toString(){
    return retval.data;
  }
  /// returns everything remembered, then forgets all
  string give(){
    auto rv= retval.data;
    init();
    return rv;
  }
  /// is it all forgotten?
  /// Datum: 17.12.2012 von Manfred Nowak, svv1999@hotmail.com
  bool empty(){
    return retval.data.length == 0;
  }
}
unittest{
  import std.stdio;
  SWrite swrite;

  swrite= new SWrite;
  string t= "Hello world!\n";
  swrite.take( t);
  string g= swrite.give;
  assert( t == g);
  debug(swrite) writeln( "SWrite: Done.");
}
