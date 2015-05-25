module base.guards;

import std.stdio;
// MyStatements are executed only if all guards succeed
// MyStatement informs whether it is executed
bool ms( lazy void cmd, bool delegate()[] guards ...){
  bool lazyAnd= true;
    debug( guards) debug( 1) write( "ms[ ");
  foreach( c; guards) {
    if( !(lazyAnd &= c())){
        debug( guards) debug( 1) write("*");
      break;
    }
  }
  bool yn= lazyAnd;
  if( yn) cmd();
    debug( guards) debug( 1) write( "]");
  return yn;
}
// there are three guards: scout, refuser and teacher
// scouting is a lazy evaluated if, it informs about the condition detected
bool scout( lazy bool exp, lazy void thenAction, lazy void elseAction){
    debug( guards) debug( 1) write( "scout[ ");
  bool yn= exp;
  if( yn) {
	   debug( guards) debug( 1) write("+");
	 thenAction();
  } else {
	   debug( guards) debug( 1) write("-");
	  elseAction();
  }
    debug( guards) debug( 1) write( "]");
  return yn;
}
// A refuser does not know how to correct a situation if a check fails
// therefore reacts with the defined refuseAction and otherwise does nothing
// The refuser informs with false on refusal otherwise with true
bool refuse( lazy bool exp, lazy void refuseAction){
    debug( guards) debug( 1) write( "refuse: ");
  return !scout( exp, refuseAction, {}());
}
// A Teacher knows how to correct a situation if a check fails
// Therefore reacts with the predefined teaching action
// The teacher informs always with true if he returns.
// Optional is to recheck after teaching and throw exception on failure
bool teach( lazy bool check, lazy void teachAction, bool checkPost= false){
    debug( guards) debug( 1) write( "teach[ ");
  if( !check) teachAction();
  if( checkPost && !check) throw new Exception( "teach error");
    debug( guards) debug( 1) write( "]");
  return true;
}
unittest{
  int i;
  bool done;
  done= false;
  i= 2;
  ms( {
      done= true;
        debug( guards) debug( 1) writeln( "command");
    }(),
      refuse( i==2, {}()),
      teach( i!=1, i=1)
  );
  assert( !done);
  done= false;
  i= 2;
  ms( {
      done= true;
    }(),
      refuse( i==1, {}()),
      teach( i==1, i=1)
  );
  assert( i==1 && done);
  done= false;
  i= 2;
    try
  {
    ms( {
	done= true;
      }(),
	refuse( i==1, {}()),
	teach( i==1, i=2, true)
    );
  }
    catch {};
  assert( i==2 && !done);
  //assert( false);
  debug(guards) printf( "unittest( guards) passed\n");
}
