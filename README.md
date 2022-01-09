# Mini-LISP

## Features
1. **Syntax Validation**: Print “syntax error” when parsing invalid syntax
2. **Print**: Implement print-num statement
3. **Numerical Operations**: Implement all numerical operations
4. **Logical Operations**: Implement all logical operations
5. **if Expression**: Implement if expression
6. **Variable Definition**: Able to define a variable
7. **Function**: Able to declare and call an anonymous function
8. **Named Function**: Able to declare and call a named function

## Usage
### compile bison
bison -d -o y.tab.c LISP.y
gcc -c -g -I.. y.tab.c
### compile flex
flex -o lex.yy.c LISP.l
gcc -c -g -I.. lex.yy.c
### compile and link bison and flex
gcc -o LISP y.tab.o lex.yy.o -ll
### run exe
./LISP
