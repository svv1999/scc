now: all
all: automaton.d automatonext.d nfa2dfa.d stackext.d
automaton.d: Makefile
	rdmd -unittest -main automaton
automatonext.d: Makefile
	rdmd -unittest -main automatonext
nfa2dfa.d: Makefile
	rdmd -unittest -main nfa2dfa
stackext.d: Makefile
	rdmd -unittest -main stackext
