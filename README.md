# Compiler-Bison
In this project, we constructed the last part of the front end of a compiler for a subset of C language. That means it performs syntax analysis and semantic analysis with
a grammar rule containing function implementation in this assignment. To do so, we built a parser with the help of Lex (Flex) and YACC (Bison).

Our chosen subset of C language has following characteristics.
  • There can be multiple functions. No two function will have the same name. A function
need to be defined or declared before it is called. Also a function and a global variable
cannot have the same symbol.
  • There will be no pre-processing directives like include or define.
  • Variables can be declared at suitable places inside a function. Variables can also be
declared in global scope.
  • All the operators used in previous assignment are included. Precedence and associativity rules are as per standard. Although we will ignore consecutive logical operators
or consecutive relational operators like ‘a && b && c’ ‘a < b < c’.
  • No break statement and switch-case
  
  The following tasks were completed:
  
    1.Syntax Analysis
    2.Semantic Analysis
    3.Handling grammer rules for functions
    
