%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbolTable.h"
#include "AST.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
char currentScope[50]; // global or the name of the function
%}

%union {
	int number;
	char character;
	char* string;
	struct AST* ast;
}

%token <string> TYPE
%token <string> ID
%token <char> SEMICOLON
%token <char> EQ
%token <char> PLUS
%token <number> NUMBER
%token WRITE

%printer { fprintf(yyoutput, "%s", $$); } ID;
%printer { fprintf(yyoutput, "%d", $$); } NUMBER;

%type <ast> Program VarDeclList Block Type StmtList Stmt Expr Primary ExprList ExprListTail BinOp

%start Program

%%

Program: VarDeclList  { $$ = $1;}
;

VarDeclList: | VarDecl VarDeclList  { $1->left = $2;
							  		 $$ = $1;
								    } 
;


VarDecl: 	TYPE ID SEMICOLON { printf("RECOGNIZE RULE: Variable Declaration %s\n", $2)
;

// Symbol Table
									symTabAccess();
									int inSymTab = found($2, currentScope);
									//printf("looking for %s in symtab - found: %d \n", $2, inSymTab);
									
									if (inSymTab == 0) 
										addItem($2, "Var", $1,0, currentScope);
									else
										printf("SEMANTIC ERROR: Var %s is already in the symbol table", $2);
									showSymTable();
									
								  // ---- SEMANTIC ACTIONS by PARSER ----
								  //  code goes here...

								}
;

StmtList: Stmt | Stmt StmtList 
; 

Stmt: 	SEMICOLON {} 
		| Expr SEMICOLON{$$ = $1;}
		| WRITE Expr SEMICOLON{ printf("\n RECOGNIZED RULE: WRITE statement\n");
					$$ = AST_Write("write",$2,"");}
;

Expr: 	Primary{}
		| Expr BinOp Expr {}
		| ID = Expr {}
; 

Primary: ID | NUMBER
; 

ExprList: | ExprListTail {}
; 

ExprListTail: Expr {}
			| Expr , ExprListTail{}
; 

BinOp: PLUS; 



%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n##### COMPILER STARTED #####\n\n");
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}