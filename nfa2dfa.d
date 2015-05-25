/* vim:set nu sw=2 nowrap: */
private:
import base.set;
import base.guards;
import stackext;
import std.stdio;
import std.conv: to;

import automatonext: Automat2= Automat, Node, Edge, Alphabet;
alias Automat2!( Node, Edge, Alphabet) Automaton;
alias Set!Node NodeSet;
alias Set!NodeSet NodeSetSet;


public Automaton toDfa( Automaton nfa){
  Automaton dfa;
  Edge edge;
  Set!(Edge) edges;

  NodeSetSet sccs( Automaton a){
    auto retvalOuter=new NodeSetSet;
    auto found= new NodeSet;
    uint currentNo= 0;
    uint[ Node] visitorNumber;
    uint[ Node] possibleRoot;
    auto stack= new StackExtended!Node;

    void tarjan( Node v){
      debug( tarjan) writeln( "tarjan: starting node ", v);
      auto retvalInner= new NodeSet;
      visitorNumber[ v]= currentNo;
      possibleRoot[ v]= currentNo;
      currentNo++;
      stack+= v;
      found+= v;

      foreach( e; v.edges.elements){
            debug( tarjan) writeln( "tarjan: viewing edge ", e);
        auto w= e.sink[ true];
          uint min( uint left, uint right){ return left<right?left:right;}
        if( w !in found){
          if( w !in visitorNumber){
            tarjan( w);
            auto lowLink= min( possibleRoot[ v], possibleRoot[ w]);
            possibleRoot[ v]= lowLink;
          } else {
            if( w in stack){
              auto lowLink= min( possibleRoot[ v], visitorNumber[ v]);
              possibleRoot[ v]= lowLink;
            } else {
            }
          }
        }
            debug( tarjan) writeln( "tarjan: ending node.");
      }
      if( possibleRoot[ v] == visitorNumber[ v]){
        auto w= stack.max;
        do{
          w= stack.max;
          stack--;
          retvalInner+= w;
        } while( w != v);
      }
      retvalOuter+= retvalInner;
    }
    foreach( v; a.states.states.elements){
          debug( tarjan) writeln( "tarjan: testing node ", v);
      if( v !in found){
        tarjan( v);
      }
    }
    return retvalOuter;
  }

  void dfs( Node node, ref NodeSet visited, bool dir){
    visited+= node;
    foreach( trans; node.edges.elements){
          debug( clear) debug( 999) writeln( "+++ dfs( ", trans, ")");
      {
        if( trans.sign == ""){
          if( node in nfa.states.finals[ !dir]) nfa.states.finals[ !dir]+= trans.sink[ dir];
        }
        if( !( trans.sink[ dir] in visited)) dfs( trans.sink[ dir], visited, dir);
      }
    }
  }
  const bool forward= true;
  const bool backward= false;

  // delete all states which are forward unreachable
        debug( clear) debug( 1) writeln( "// delete all states which are forward unreachable");
  auto visited= new NodeSet;
  foreach( state; nfa.states.finals[ false].elements)
    dfs( state, visited, forward);
  foreach( state; nfa.states.states.elements)
    if( !( state in visited)){
      //writeln( ".... deleting ", state, " (forward unreachable)");
      nfa-= state;
    }
  delete visited;
        debug( clear) debug( 99) writeln( "nfa: ", nfa); 

  // delete all states which are backward unreachable
        debug( clear) debug( 1) writeln( "// delete all states which are backward unreachable");
  visited= new NodeSet;
  foreach( aFinal; nfa.states.finals[ true].elements)
    dfs( aFinal, visited, backward);
  foreach( state; nfa.states.states.elements)
    if( !( state in visited)){
      //writeln( ".... deleting ", state, " (backward unreachablei)");
      nfa-= state;
    }
  delete visited;
        debug( clear) debug( 98) writeln( "nfa: ", nfa); 

  auto s= sccs( nfa);
  foreach( scc; s.elements){
    writeln( scc);
    foreach( elem; scc.elements)
      writeln( "   ", elem);
  }

    NodeSet[ int] priority;
  { // compute the out-rank
       debug( clear) debug(1) writeln( "// compute the out-rank");
    int[ Node] bucket;
    foreach( state; nfa.states.states.elements){
      bucket[ state]= 0;
    }
    foreach( state; nfa.states.states.elements){
      foreach( trans; state.edges.elements){
        //writeln( "...", trans.sink[ true]);
        //writeln( "....", bucket);
        //writeln( "....", bucket[ trans.sink[ true]]);
        if( trans.sign == ""
            && trans.sink[true] in nfa.states.states
            && bucket[ trans.sink[false]]
               <= bucket[ trans.sink[ true]]
          )
          bucket[ trans.sink[false]]= bucket[ trans.sink[ true]]+1;
      }
    }
    debug( clear) debug( 97) writeln( "bucket: ", bucket); 

    // prioritize according out-rank
        debug( clear) debug(1) writeln( "// prioritize according out-rank");
    foreach( state, value; bucket){
          debug( clear) debug( 999) writeln( state, " ", value);
      auto prio= bucket[ state];
      teach( (prio in priority) !is null, (priority[ prio]= new NodeSet), true); 
        // if( (prio in priority) is null) priority[ prio]= new StateSet;
      priority[ prio]+= state;
    }
        debug( clear) debug( 96) writeln( "priority: ", priority); 

  }

  // propagate the names and the final status 
  NodeSet[ Node] name;
  struct ToSingle{
    Node[ NodeSet] arr;
    const bool assure= true;
    Node opIndex( NodeSet index){
      teach( (index in arr) !is null, { arr[ index]= new Node;}(), assure);
      return arr[ index];
    }
  }
  ToSingle toSingle;
  debug(clear) debug(1) writeln( "// propagate the names and the final status"); 
  {
    foreach( state; nfa.states.states.elements){
      name[ state]= new NodeSet;
      name[ state]+= state;
          debug( clear) debug( 998) writeln("name: ", name[ state]);
    }
    auto prio= 1;
    while( prio in priority){
      foreach( state; priority[ prio].elements){
        foreach( trans; state.edges.elements)
          if( trans.sign == ""){
            name[ trans.sink[ false]]+= name[ trans.sink[ true]];
            if( trans.sink[ true] in nfa.states.finals[ true])
              nfa.states.finals[ true]+= trans.sink[ false];
            /*if( trans.sink[ false] in nfa.states.starts)
              nfa.states.starts+= trans.sink[ true];*/
          }
      }
      prio++;
    }
  }
      debug( clear) debug( 1) writeln( "nfa: ", nfa); 

  { // translate transitions
        debug( clear) debug(1) writeln( "// translate transitions");
    //debug( clear) debug(1) writeln( name[ nfa.states.starts]);

    dfa= new Automaton;
    edges= new Set!Edge;
    /+
    foreach( state; nfa.states.finals[ false].elements){
      auto now= name[ state];
      dfa.states.finals[ false]+= toSingle[ now];
      dfa.states.states+= toSingle[ now];
    }
    foreach( elem;  nfa.states.finals[ true].elements){
      auto now= name[ elem];
      dfa.states.finals[ true]+= toSingle[ now];
      dfa.states.states+= toSingle[ now];
    }
    +/
    foreach( trans; nfa.transitions.elements)
      if( trans.sign != ""){
        edge= new Edge(  toSingle[ name[trans.sink[ false]]], trans.sign, toSingle[ name[ trans.sink[ true]]]);
            debug( clear) debug( 997) writeln("!!> ", edge);
        dfa+= edge;
            debug( clear) debug( 997) writeln( "+++ edge added: ", dfa);
        if( trans.sink[ false] in nfa.states.finals[ false]){
          dfa.states.finals[ false]+= toSingle[ name[ trans.sink[ false]]];
        }
        if( trans.sink[ false] in nfa.states.finals[ true]){
          dfa.states.finals[ true]+= toSingle[ name[ trans.sink[ false]]];
        }
        if( trans.sink[ true] in nfa.states.finals[ true]){
          dfa.states.finals[ true]+= toSingle[ name[ trans.sink[ true]]];
        }
      }          
    if( dfa.states.states.length == 0){
      auto found= false;
      foreach( state; nfa.states.finals[ false].elements){
        found|= state in nfa.states.finals[ true];
        if ( found) break;
      }
      if( found){
        auto node= new Node;
        dfa+= node;
        dfa.states.finals[ true]+= node;
        dfa.states.finals[ false]+= node;
      }
    }
  }

      debug( toDfa){ writeln( "toDfa: ", sccs(dfa));
        auto prt= sccs(dfa);
        foreach( scc; prt.elements){
          writeln( " -> ", scc);
          foreach( node; scc.elements)
            writeln(" -->", node);
        }
      }

  return dfa;
}


unittest{
  /+
  { // one epsilontransition
    scope nfa= new Automaton;
    scope s1= new Node;
    scope s2= new Node;
    nfa.starts+= s1;
    nfa.finals+= s2;
    nfa+= new Edge( s1, "", s2);
        debug( clear) debug(1) writeln( "original: ", nfa);
    auto dfa= toDfa( nfa);
        debug( clear) debug(1) writeln( "cleared: ", dfa);
  }
  { // one transition
    scope nfa= new Automaton;
    scope s1= new Node;
    scope s2= new Node;
    nfa.starts+= s1;
    nfa.finals+= s2;
    nfa+= new Edge( s1, "a", s2);
        debug( clear) debug(1) writeln( "original: ", nfa);
    auto dfa= toDfa( nfa);
        debug( clear) debug(1) writeln( "cleared: ", dfa);
  }
  { // one + one transition
    scope nfa= new Automaton;
    scope s1= new Node;
    scope s2= new Node;
    nfa.starts+= s1;
    nfa.finals+= s2;
    nfa+= new Edge( s1, "", s2);
    nfa+= new Edge( s1, "a", s2);
        debug( clear) debug(1) writeln( "original: ", nfa);
    auto dfa= toDfa( nfa);
        debug( clear) debug(1) writeln( "cleared: ", dfa);
  }

  { // one + one transition
    scope nfa= new Automaton;
    scope s1= new Node;
    scope s2= new Node;
    scope s3= new Node;
    nfa.starts+= s1;
    nfa.finals+= s3;
    nfa+= new Edge( s1, "a", s2);
    nfa+= new Edge( s2, "b", s3);
        debug( clear) debug(0) writeln( "original: ", nfa);
    auto dfa= toDfa( nfa);
        debug( clear) debug(0) writeln( "cleared: ", dfa);
  }
  +/
  { // one + one transition
    scope nfa= new Automaton;
    scope s0= new Node;
    scope s1= new Node;
    scope s2= new Node;
    scope s3= new Node;
    scope s4= new Node;
    scope s5= new Node;
    nfa.starts+= s0;
    nfa.finals+= s3;
    nfa.finals+= s4;
    nfa+= new Edge( s0, "a", s1);
    nfa+= new Edge( s0, "", s2);
    nfa+= new Edge( s2, "", s3);
    nfa+= new Edge( s3, "", s1);
    nfa+= new Edge( s3, "a", s4);
    nfa+= new Edge( s5, "a", s1);
        debug( clear) debug(0) writeln( "original: ", nfa);
    auto dfa= toDfa( nfa);
        debug( clear) debug(0) writeln( "cleared: ", dfa);
  }
  /+ 
  +/ 
      debug(nfa2dfa) writeln( "unittest( nfa2dfa3) passed.");
}
