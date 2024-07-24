now: swrite.d
all: guards.d set.d stack.d
guards.d: Makefile
	rdmd -unittest guards
set.d: Makefile
	rdmd -unittest set
stack.d: Makefile
	rdmd -unittest -main stack
swrite.d: Makefile
	rdmd -unittest -main swrite
