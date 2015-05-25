/* vim:set nu sw=2 nowrap: */
import std.stdio: writeln;
import base.set;
public import automaton;

class Automat( Node, Edge, Alphabet)
  :automaton.Automaton!( Node, Edge){
}

//alias string Alphabet;
alias Alphabet= string;
class Transition( Alphabet){
  State!Transition[ bool] sink;
  Alphabet sign;
  this( State!Transition source, Alphabet sign, State!Transition sink){
    this.sink[ false]= source;
    this.sink[ true]= sink;
    this.sign= sign;
  }
  //alias toString= Object.toString;
  override string toString(){
    return "  "  ~ sink[ false].toString 
                 ~ " -> "
                 ~ sink[ true].toString
                 ~ " [ label= \""~sign~"\"]";
  }
};

class State( Transition){
  alias Set!( Transition) TransitionSet;
  hash_t id;
  
    TransitionSet edges;
  this(){
    id= cast(hash_t) cast( void*) this;
    edges= new TransitionSet;
  }
  alias toString= Object.toString;
  override string toString(){
    return "s"~std.conv.to!string( id)~"";
  }
}
alias Transition!Alphabet Edge;
alias State!Edge Node;
unittest{
  debug(automatonext) writeln( "unittest( automatonext) starts.");
  { // one epsilontransition
    scope s1= new Node;
    scope s2= new Node;
    scope a= new Automat!( Node, Edge, Alphabet);
    a.starts+= s1;
    a.finals+= s2;
    a+= new Edge( s1, "", s2);
    assert( s1 in a.states.finals[ false]); 
    assert( a.states.finals[true].length == 1); 
    assert( a.states.states.length == 2); 
    debug(100) writeln( "original: ", a);
  }
  debug(automatonext) writeln( "unittest( automatonext) passed.");
}
