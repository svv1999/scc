module automaton;

import base.set;
import std.stdio;
import std.conv: to;


class Automaton( State, Transition) {

  // the states
  alias Set!( State) StateSet;
  struct NodeSome{
    StateSet states;
    StateSet[ 2] finals;
  }
  NodeSome states;

  // the transitions
  alias Set!( Transition) TransitionSet;
  struct EdgeSome{
    TransitionSet transSome;

    //void opAddAssign( Transition trans){
    void opOpAssign( string op)( Transition trans)
      if (op == "+")
    do{
      transSome+= trans;
    }

    //void opSubAssign( Transition trans){
    void opOpAssign( string op)( Transition trans)
      if (op == "-")
    do{
      transSome-= trans;
    }
    Transition[] elements(){
      return transSome.elements;
    }
    bool opIn_r( Transition trans){
      return trans in transSome;
    }
  }
  EdgeSome transitions;

  // the initialisation
  this(){
    states.states= new StateSet;
    states.finals[ false]= new StateSet;
    states.finals[ true]= new StateSet;
    transitions.transSome= new TransitionSet;
    thisNext;
  }

  // operators
  //Automaton opAddAssign(Transition trans)
  Automaton opOpAssign( string op)( Transition trans)
    if (op == "+")
  do{
    this+= trans.sink[ false];
    this+= trans.sink[ true];
    transitions+= trans;
    trans.sink[ false].edges+= trans;
    trans.sink[ true].edges+= trans;
    return this;
  }

  //Automaton opSubAssign(Transition trans)
  Automaton opOpAssign( string op)( Transition trans)
    if (op == "-")
  in{
    assert( trans in transitions);
  }
  do{
    if( trans in transitions){
      transitions-= trans;
    }
    trans.sink[ false].edges-= trans;
    trans.sink[ true].edges-= trans;
    return this;
  }

  //Automaton opAddAssign(State state)
  Automaton opOpAssign( string op)( State state)
    if (op == "+")
  do{
    foreach( trans; state.edges.elements)
      transitions+= trans;
    states.states+= state;
    return this;
  }

  //Automaton opAddAssign( StateSet set)
  Automaton opOpAssign( string op)( StateSet set)
    if (op == "+")
  do{
    foreach( state; set.elements)
      this+= state;
    return this;
  }

  //Automaton opSubAssign(State state)
  Automaton opOpAssign( string op)( State state)
    if (op == "-")
  in{
    assert( state in states.states);
    //assert( state !in states.starts);
  }
  do{
    foreach( trans; state.edges.elements)
      transitions-= trans;
    foreach( trans; state.edges.elements)
      transitions-= trans;
    states.states-= state;  
    states.finals[ true]-= state;
    states.finals[ false]-= state;
    return this;
  }

  // properties
  class Finals{
    //void opAddAssign( State state /*,int mark= 0*/){
    void opOpAssign( string op)( State state)
      if (op == "+")
    do{
      this.outer+=state;
      states.finals[ true]+= state;
      //states.finalMark[ state]= mark;
    }
    //void opSubAssign(State state){
    void opOpAssign( string op)( State state)
      if (op == "-")
    do{
      states.finals[ true]-= state;
    }
  }
  Finals finals;
  void thisNext(){
    finals= new Finals;
    thisNext2;
  }

  class Starts{
    //void opAddAssign( State state){
    void opOpAssign( string op)( State state)
      if (op == "+")
    do{
      this.outer+= state;
      states.finals[ false]+= state;
    }
    //void opSubAssign( State state){
    void opOpAssign( string op)( State state)
      if (op == "-")
    do{
      states.finals[ false]-= state;
    }
  }
  Starts starts;
  void thisNext2(){
    starts= new Starts;
  }

  //alias toString= Object.toString;
  override string toString(){
    string retval= "digraph G{\n".dup;
    foreach( state; states.states.elements){
      retval~= state.toString;
      if( state in states.finals[ false]) retval~= "[ ]";
      if( state in states.finals[ true]) retval~= "[shape=doublecircle]";
      retval~= ";\n";
    }
    foreach( trans; transitions.elements){
      retval~= trans.toString ~ ";\n";
    }
    retval~= "}\n";
    return retval;
  }
}
version(unittest){
    class Node{ Set!Edge edges= new Set!Edge;};
    class Edge{ Node[ bool] sink;
      this( Node left, Node right){
       sink[ false]= left;
      sink[true]= right;}
    };
}
unittest{
  debug(automaton) writeln( "unittest( automaton) starts.");
  { // one epsilontransition
    scope s1= new Node;
    scope s2= new Node;
    scope a= new Automaton!( Node, Edge);
    a.starts+= s1;
    a.finals+= s2;
    a+= new Edge( s1, s2);
    assert( s1 in a.states.finals[ false]); 
    assert( a.states.finals[true].length == 1); 
    assert( a.states.states.length == 2); 
    debug( dbg100) writeln( "original: ", a);
  }
  debug( automaton) writeln( "unittest( automaton) passed.");
}
