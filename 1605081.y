%{
#include<stdio.h>	
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<typeinfo>
#include<vector>
#include"1605081.cpp"
//#define YYSTYPE Symbolinfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;
FILE *flogs=fopen("1605081_logs.txt","w");
FILE *ferrors= fopen("1605081_errors.txt","w");

extern int line_count ;
extern int error_count ;
string typeCheck = "0";

SymbolTable *table = new SymbolTable(100);

vector<Symbolinfo*> var_var_declaration;
vector<Symbolinfo*> var_func_parameter;
vector<Symbolinfo*> var_argumentlist;



void yyerror(const char *s)
{
	fprintf(flogs,"Line no %d : %s\n\n",line_count,s);
	//return;
}


%}

%union{Symbolinfo* value;}

%token IF ELSE FOR WHILE INT FLOAT DOUBLE CHAR RETURN VOID MAIN PRINTLN DO BREAK SWITCH CASE DEFAULT CONTINUE
%token <value> ADDOP MULOP INCOP RELOP LOGICOP BITOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token <value> CONST_INT CONST_FLOAT CONST_CHAR ID DECOP

%type <value> type_specifier declaration_list var_declaration unit program func_declaration variable factor unary_expression expression logic_expression rel_expression simple_expression term
%type <value> parameter_list statement statements compound_statement func_definition expression_statement arguments argument_list

%left RELOP LOGICOP
%left ADDOP
%left MULOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%error-verbose

%%

start : program {}
	;

program: program unit {fprintf(flogs,"At line no : %d program : program unit \n\n",line_count);
		
		$$ = new Symbolinfo($1->getName()+"\n\n"+$2->getName(),"program");
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
	}
	| unit {fprintf(flogs,"At line no : %d program : unit \n\n",line_count);
		
		$$ = new Symbolinfo($1->getName(),"program");
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
	}
	;
	
unit: var_declaration {fprintf(flogs,"At line no : %d unit : var_declaration \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"unit");
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 }
     | func_declaration {fprintf(flogs,"At line no : %d unit : func_declaration \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"unit");
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
	 }
     | func_definition {fprintf(flogs,"At line no : %d unit : func_definition \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"unit");
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
	 }
     ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			
			fprintf(flogs,"At line no : %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName() + " " + $2->getName()+ "(" + $4->getName() + ")"  + ";","func_declaration" );
			
			Symbolinfo* check = table->lookup($2->getName());

			if(check!=0)
			{
				if(check->vtype.compare($1->getName())!=0)
				{
					fprintf(ferrors,"Return type doesn't match error at line no : %d\n\n",line_count);
					error_count++;
					check->isfunc = false;
				}

				if(check->funcParameter.size()!=var_func_parameter.size())
				{
					fprintf(ferrors,"Parameter size doesn't match error at line no : %d\n\n",line_count);
					error_count++;
					check->isfunc = false;
				}
				else
				{
					for(int i =0;i < check->funcParameter.size();i++)
					{
						if(var_func_parameter[i]->vtype.compare(check->funcParameter[i]->vtype)!=0)
						{
							fprintf(ferrors,"Parameter type doesn't match error at line no : %d\n\n",line_count);
							error_count++;
							check->isfunc = false;
						}
						
					}
				}				
			}
			else
			{
				$2->isfunc = true;
				$2->isdefined = false;
				$2->vtype = $1->getName(); 
			
				for(int i =0;i < var_func_parameter.size();i++)
				{
					Symbolinfo *temp = var_func_parameter[i];
				
					$2->funcParameter.push_back(temp);				
				}

				table->insertItem($2);

			}

			for(int i =0;i < var_func_parameter.size();i++)
			{
				Symbolinfo *temp = var_func_parameter[i];
				
				if(temp->vtype.compare("void")==0)
				{
					fprintf(ferrors,"Parameter can't be void error at line no : %d\n\n",line_count);
					error_count++;
				}				
			}


			fprintf(flogs,"%s\n\n",$$->getName().c_str());

			var_func_parameter.clear();
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON { fprintf(flogs,"At line no : %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName() + " " + $2->getName()+ "(" + ")" + ";","func_declaration" );
			
			Symbolinfo* check = table->lookup($2->getName());

			if(check!=0)
			{
				if(check->vtype.compare($1->getName())!=0)
				{
					fprintf(ferrors,"Return type doesn't match error at line no : %d\n\n",line_count);
					error_count++;
					check->isfunc = false;
				}
				
				if(check->funcParameter.size()!=0)
				{
					fprintf(ferrors,"Parameter size doesn't match error at line no : %d\n\n",line_count);
					error_count++;
					check->isfunc = false;
				}
			}
			else
			{
				$2->isfunc = true;
				
				$2->isdefined = false;
				
				$2->vtype = $1->getName();

				table->insertItem($2);
			}

			fprintf(flogs,"%s\n\n",$$->getName().c_str());
		}
		;
		 
func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement {fprintf(flogs,"At line no : %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $6->getName() ,"func_definition");
			
			Symbolinfo* check = table->lookup($2->getName());

			if(check!=0)
			{
				if(check->isdefined==1)
				{
					fprintf(ferrors,"Multiple definition of function error at line no : %d\n\n",line_count);
					error_count++;
				}
				else
				{
					check->isdefined = true;
					if(check->vtype.compare($1->getName())!=0)
					{
						fprintf(ferrors,"Return type doesn't match error at line no : %d\n\n",line_count);
						error_count++;
						check->isdefined = false;
						//check->isfunc = false;
					}

					if(check->funcParameter.size()!=var_func_parameter.size())
					{
						fprintf(ferrors,"Parameter size doesn't match error at line no : %d\n\n",line_count);
						error_count++;
						check->isdefined = false;
						//check->isfunc = false;
					}
					else
					{
						for(int i =0;i < check->funcParameter.size();i++)
						{
							if(var_func_parameter[i]->vtype.compare(check->funcParameter[i]->vtype)!=0)
							{
								fprintf(ferrors,"Parameter type doesn't match error at line no : %d\n\n",line_count);
								error_count++;
								//check->isfunc = false;
								check->isdefined = false;
							}
						
						}
					}										
				}			
			}
			else
			{
				$2->isfunc = true;

				$2->vtype = $1->getName();

				for(int i =0;i < var_func_parameter.size();i++)
				{
					Symbolinfo *temp = var_func_parameter[i];
				
					$2->funcParameter.push_back(temp);				
				}

				$2->isdefined= true;

				table->insertItem($2);
			}

			if(typeCheck.compare($1->getName())!=0)
			{
				if(typeCheck.compare("0")!=0)
				{
					fprintf(ferrors,"Return type mismatch error at line no : %d\n\n",line_count-1);
				}
			}

			typeCheck = "0";

			for(int i =0;i < var_func_parameter.size();i++)
			{
				Symbolinfo *temp = var_func_parameter[i];
				
				if(temp->vtype.compare("void")==0)
				{
					fprintf(ferrors,"Parameter can't be void error at line no : %d\n\n",line_count);
					error_count++;
				}				
			}

			var_func_parameter.clear();
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	 	}
		| type_specifier ID LPAREN RPAREN compound_statement {fprintf(flogs,"At line no : %d func_definition : type_specifier ID LPAREN RPAREN compound_statement \n\n",line_count);
	 		

			$$ = new Symbolinfo($1->getName() + " " + $2->getName() + "(" + ")" + $5->getName() ,"func_definition");
			
			Symbolinfo* check = table->lookup($2->getName());

			if(check!=0)
			{
				if(check->isdefined==1)
				{
					fprintf(ferrors,"Multiple definition of function error at line no : %d\n\n",line_count);
					error_count++;
				}
				else
				{
					check->isdefined = true;
					if(check->vtype.compare($1->getName())!=0)
					{
						fprintf(ferrors,"Return type doesn't match error at line no : %d\n\n",line_count);
						error_count++;
						//check->isfunc = false;
						check->isdefined = false;
					}
				
					if(check->funcParameter.size()!=0)
					{
						fprintf(ferrors,"Parameter size doesn't match error at line no : %d\n\n",line_count);
						error_count++;
						//check->isfunc = false;
						check->isdefined = false;
					}
				}
			}
			else
			{
				$2->isfunc = true;

				$2->isdefined = true;

				$2->vtype = $1->getName();

				table->insertItem($2);
			}

			if(typeCheck.compare($1->getName())!=0)
			{
				if(typeCheck.compare("0")!=0)
				{
					fprintf(ferrors,"Return type mismatch error at line no : %d\n\n",line_count-1);
				}
			}

			typeCheck = "0";

			fprintf(flogs,"%s\n\n",$$->getName().c_str());

			var_func_parameter.clear();
	 	}
 		;				


parameter_list: parameter_list COMMA type_specifier ID { fprintf(flogs,"At line no : %d parameter_list : parameter_list COMMA type_specifier ID \n\n",line_count);
			
			Symbolinfo* temp = new Symbolinfo($4->getName(),"ID");
			
			temp->vtype = $3->getName();
			
			var_func_parameter.push_back(temp);

			$$ = new Symbolinfo($1->getName() + "," + $3->getName() + " " + $4->getName() ,"parameter_list");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
		}
		| parameter_list COMMA type_specifier { fprintf(flogs,"At line no : %d parameter_list : parameter_list COMMA type_specifier \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName() + "," + $3->getName() ,"parameter_list");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
			
		}
 		| type_specifier ID { fprintf(flogs,"At line no : %d parameter_list : type_specifier ID \n\n",line_count);
			
			Symbolinfo* temp = new Symbolinfo($2->getName(),"ID");
			
			temp->vtype = $1->getName();
			
			var_func_parameter.push_back(temp);
			
			$$ = new Symbolinfo($1->getName() + " " + $2->getName() ,"parameter_list");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
		}
		| type_specifier { fprintf(flogs,"At line no : %d parameter_list : type_specifier\n\n",line_count);
			
			$$ = new Symbolinfo($1->getName(),"parameter_list");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
		}
 		;

 		
compound_statement: LCURL {table->enterScope();
				
				for(int i =0;i < var_func_parameter.size();i++)
				{
					Symbolinfo *temp = var_func_parameter[i];
					
					Symbolinfo* check = table->lookupCurrentScope(temp->getName());
					
					if(check==0)
					{	
						if(temp->vtype.compare("void")!=0)
						{
							table->insertItem(temp);
						}
					}
					else
					{	
						fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
						error_count++;
					}

				}
				} statements RCURL {fprintf(flogs,"At line no : %d compound_statement : LCURL statements RCURL \n\n",line_count);	
				
				$$ = new Symbolinfo("{\n\n" + $3->getName() + "\n\n}","compound_statement");
				
				fprintf(flogs,"%s\n\n",$$->getName().c_str());
				
				table->exitScope();

			}
 		    | LCURL {table->enterScope();
			 	for(int i =0;i < var_func_parameter.size();i++)
				{
					Symbolinfo *temp = var_func_parameter[i];
					
					Symbolinfo* check = table->lookupCurrentScope(temp->getName());
					
					if(check==0)
					{	
						if(temp->vtype.compare("void")!=0)
						{
							table->insertItem(temp);
						}
					}
					else
					{	
						fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
						error_count++;
					}

				}
			 } RCURL {fprintf(flogs,"At line no : %d compound_statement : LCURL RCURL \n\n",line_count);
				
				$$ = new Symbolinfo( "{}" ,"compound_statement");
				
				fprintf(flogs,"%s\n\n",$$->getName().c_str());
				
				table->exitScope();
			}
 		    ;
 		    
var_declaration: type_specifier declaration_list SEMICOLON {fprintf(flogs,"At line no : %d var_declaration : type_specifier declaration_list SEMICOLON \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName() + " " + $2->getName() + ";","var_declaration");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());

			if($1->getName().compare("void")==0)
			{
				fprintf(ferrors,"Variable cannot be void type error at line no : %d\n\n",line_count);
				error_count++;
			}
			else
			{
				for(int i =0;i < var_var_declaration.size();i++)
				{	
					Symbolinfo *temp = var_var_declaration[i];
					
					Symbolinfo* check = table->lookupCurrentScope(temp->getName());
					
					if(check==0)
					{	
						temp->vtype = $1->getName() ;
						table->insertItem(temp);
					}
					else
					{	
						fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
						error_count++;
					}	
				}
			}
			var_var_declaration.clear();
		}
 		;
 		 
type_specifier: INT {fprintf(flogs,"At line no : %d type_specifier : INT \n\n",line_count);$$ = new Symbolinfo("int","INT");fprintf(flogs,"int \n\n");
		}
 		| FLOAT {fprintf(flogs,"At line no : %d type_specifier : FLOAT \n\n",line_count);$$ = new Symbolinfo("float","FLOAT");fprintf(flogs,"float \n\n");
		}
 		| VOID {fprintf(flogs,"At line no : %d type_specifier : VOID \n\n",line_count);$$ = new Symbolinfo("void","VOID");fprintf(flogs,"void \n\n");
		}
 		;
 		
declaration_list: declaration_list COMMA ID {fprintf(flogs,"At line no : %d declaration_list : declaration_list COMMA ID \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName()+","+$3->getName(),"declaration_list COMMA ID");  
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());

			Symbolinfo* check = table->lookupCurrentScope($3->getName());
			
			if(check==0)
			{
				var_var_declaration.push_back(new Symbolinfo($3->getName(),"ID"));
			}
			else
			{
				fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
				error_count++;
			}

		}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {fprintf(flogs,"At line no : %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName()+","+$3->getName()+"["+$5->getName()+"]","declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());

			Symbolinfo* check = table->lookupCurrentScope($3->getName());
			
			if(check==0)
			{
				check = new Symbolinfo($3->getName(),"ID");
				
				check->size = $5->getName();
				
				var_var_declaration.push_back(check);
			}
			else
			{
				fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
				error_count++;
			}

		}
 		| ID {fprintf(flogs,"At line no : %d declaration_list : ID \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName(),"declaration_list");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
			
			Symbolinfo* check = table->lookupCurrentScope($1->getName());
			
			if(check==0)
			{
				var_var_declaration.push_back(new Symbolinfo($1->getName(),"ID"));
			}
			else
			{
				fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
				error_count++;
			} 
		 
		}
 	    | ID LTHIRD CONST_INT RTHIRD {fprintf(flogs,"At line no : %d declaration_list : ID LTHIRD CONST_INT RTHIRD \n\n",line_count);
			
			$$ = new Symbolinfo($1->getName()+"["+$3->getName()+"]","declaration_list");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());

			Symbolinfo* check = table->lookupCurrentScope($1->getName());
			
			if(check==0)
			{
				check = new Symbolinfo($1->getName(),"ID");
				
				check->size = $3->getName();
				
				var_var_declaration.push_back(check);
			}
			else
			{
				fprintf(ferrors,"Multiple declaration of variable error occured at line no : %d\n\n",line_count);
				error_count++;
			}
		}	
 		;
 		  
statements: statement {fprintf(flogs,"At line no : %d statements : statement \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"statement");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 

	   }
	   | statements statement {fprintf(flogs,"At line no : %d statements : statement \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName() + "\n\n" + $2->getName(),"statement");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	   }
	   ;
	   
statement: var_declaration {fprintf(flogs,"At line no : %d statement : var_declaration \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"statement");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	  }
	  | expression_statement {fprintf(flogs,"At line no : %d statement : expression_statement \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"statement");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	  }
	  | compound_statement { fprintf(flogs,"At line no : %d statement : compound_statement \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"statement");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement { fprintf(flogs,"At line no : %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n\n",line_count);
	 		
			$$ = new Symbolinfo("for (" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName() ,"statement");
			
			if($3->vtype.compare("void")==0||$4->vtype.compare("void")==0||$5->vtype.compare("void")==0)
			{
				fprintf(ferrors,"Void type on for block error at line no : %d\n\n",line_count);
				error_count++;
			}

			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE { fprintf(flogs,"At line no : %d statement : IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE \n\n",line_count);
	 		
			$$ = new Symbolinfo("if (" + $3->getName() + ")" + $5->getName() ,"statement");
			
			if($3->vtype.compare("void")==0)
			{
				error_count++;
				fprintf(ferrors,"Void type on if block error at line no : %d\n\n",line_count);
			}

			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	  }
	  |IF LPAREN expression RPAREN statement ELSE statement { fprintf(flogs,"At line no : %d statement : IF LPAREN expression RPAREN statement ELSE statement \n\n",line_count);
	 		
			$$ = new Symbolinfo("if (" + $3->getName() + ")" + $5->getName() + "\nelse" + $7->getName() ,"statement");
			
			if($3->vtype.compare("void")==0)
			{
				error_count++;
				fprintf(ferrors,"Void type on if block error at line no : %d\n\n",line_count);
			}

			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	  }
	  | WHILE LPAREN expression RPAREN statement { fprintf(flogs,"At line no : %d statement : WHILE LPAREN expression RPAREN statement \n\n",line_count);
	 		
			$$ = new Symbolinfo("while (" + $3->getName() + ")" + $5->getName() ,"statement");
			
			if($3->vtype.compare("void")==0)
			{
				error_count++;
				fprintf(ferrors,"Void type on while block error at line no : %d\n\n",line_count);
			}

			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON { fprintf(flogs,"At line no : %d statement : WHILE LPAREN expression RPAREN statement \n\n",line_count);
	 		
			$$ = new Symbolinfo("println(" + $3->getName() + ");" ,"statement");
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());
	  }
	  | RETURN expression SEMICOLON {fprintf(flogs,"At line no : %d statement : RETURN expression SEMICOLON \n\n",line_count);
	 	
		$$ = new Symbolinfo("return " + $2->getName() + ";","statement");

		typeCheck = $2->vtype;

		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	  }
	  ;


expression_statement: SEMICOLON	{fprintf(flogs,"At line no : %d expression_statement : expression SEMICOLON \n\n",line_count);
	 			
				$$ = new Symbolinfo($1->getName() + ";","expression_statement");
				
				$$->vtype = "int";

				fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 		}		
			| expression SEMICOLON {fprintf(flogs,"At line no : %d expression_statement : expression SEMICOLON \n\n",line_count);
	 			
				$$ = new Symbolinfo($1->getName() + ";","expression_statement");
				
				$$->vtype = $1->vtype;

				fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
				
				var_argumentlist.clear();
	 		}
			;
	  
variable: ID {fprintf(flogs,"At line no : %d variable : ID \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"variable");
		
		Symbolinfo *temp = table->lookup($1->getName());

		if(temp!=0)
		{
			if(temp->isfunc==true)
			{
				fprintf(ferrors,"Function used as variable error at line no : %d\n\n",line_count);
				error_count++;
			}

			if(temp->size.compare("0")!=0)
			{
				fprintf(ferrors,"Index not used with array error at line no : %d\n\n",line_count);
				error_count++;
			}
			$$->vtype = temp->vtype;
		}
		else
		{
			fprintf(ferrors,"Undeclared variable at line no : %d\n\n",line_count);
			
			error_count++;
			
			$$->vtype = "int";
		}

		
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
		 
	 }		
	 | ID LTHIRD expression RTHIRD { fprintf(flogs,"At line no : %d variable : ID LTHIRD expression RTHIRD \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName() + "[" + $3->getName() + "]","variable");
		
		Symbolinfo *temp = table->lookup($1->getName());
		
		if(temp==0)
		{  
			fprintf(ferrors,"Undeclared variable at line no : %d\n\n",line_count);
			error_count++;
		}
		else
		{
			if(temp->size.compare("0")==0)
			{
				fprintf(ferrors,"Index not needed with variable error at line no : %d\n\n",line_count);
				error_count++;
			}
			else if($3->vtype.compare("int")!=0)
			{
				fprintf(ferrors,"Index of array not integer type error at line no : %d\n\n",line_count);
				error_count++;
			}
			else if(temp->isfunc==true)
			{
				fprintf(ferrors,"Function used as variable error at line no : %d\n\n",line_count);
				error_count++;
			}
			$$->vtype = temp->vtype;
		}
			
		fprintf(flogs,"%s\n\n",$$->getName().c_str());

		 
	 }
	 ;
	 
 expression: logic_expression	{fprintf(flogs,"At line no : %d expression : logic_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"expression");
			
			$$->vtype = $1->vtype;
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	   }
	   | variable ASSIGNOP logic_expression {fprintf(flogs,"At line no : %d expression : variable ASSIGNOP logic_expression \n\n",line_count);
	 		
			if($3->vtype.compare("void")==0)
			{	
				fprintf(ferrors,"ASSIGNOP on void expression error at line no : %d\n\n",line_count);
				error_count++;
			}
			else if($1->vtype.compare($3->vtype)!=0)
			{
				fprintf(ferrors,"Type mismatch at line no : %d\n\n",line_count);
				error_count++;
			}

			if($1->vtype.compare("int")==0&&$3->vtype.compare("float")==0)
			{
				fprintf(ferrors,"Warning : Float variable assigning to int variable at line no : %d \n\n",line_count);
			}
			else if($3->vtype.compare("int")==0&&$1->vtype.compare("float")==0)
			{
				fprintf(ferrors,"Warning : Int variable assigning to float variable at line no : %d \n\n",line_count);
			}
			
			$$ = new Symbolinfo($1->getName() + "=" + $3->getName() ,"expression");
			
			$$->vtype = $1->vtype; 	
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str());			 
	   }	
	   ;
			
logic_expression: rel_expression {fprintf(flogs,"At line no : %d logic_expression : rel_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"logic_expression");
			
			$$->vtype = $1->vtype;
			 
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 	 }	
		 | rel_expression LOGICOP rel_expression {fprintf(flogs,"At line no : %d logic_expression : rel_expression LOGICOP rel_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName() + $2->getName() + $3->getName() ,"logic_expression");
			
			if($1->vtype.compare("void")==0||$3->vtype.compare("void")==0)
			{	
				fprintf(ferrors,"LOGICOP on void expression error at line no : %d\n\n",line_count);
				error_count++;
			}

			$$->vtype = "int";
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 	 } 	
		 ;
			
rel_expression: simple_expression {fprintf(flogs,"At line no : %d rel_expression	: simple_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"rel_expression");
			
			$$->vtype = $1->vtype;
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 	} 
		| simple_expression RELOP simple_expression	{fprintf(flogs,"At line no : %d rel_expression	: simple_expression RELOP simple_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName() + $2->getName() + $3->getName(),"rel_expression");
			
			if($1->vtype.compare("void")==0||$3->vtype.compare("void")==0)
			{	
				fprintf(ferrors,"RELOP on void expression error at line no : %d\n\n",line_count);
				error_count++;
			}

			$$->vtype = "int";

			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 	}
		;
				
simple_expression: term {fprintf(flogs,"At line no : %d simple_expression : term \n\n",line_count);
	 			
				$$ = new Symbolinfo($1->getName(),"simple_expression");
				
				$$->vtype = $1->vtype;
				
				fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 	  }
		  | simple_expression ADDOP term {fprintf(flogs,"At line no : %d simple_expression : simple_expression ADDOP term \n\n",line_count);
	 			
				$$ = new Symbolinfo($1->getName() + $2->getName() + $3->getName()  ,"simple_expression");
				
				if($1->vtype.compare("void")==0||$3->vtype.compare("void")==0)
				{	
					fprintf(ferrors,"ADDOP on void expression error at line no : %d\n\n",line_count);
					error_count++;
				}
				
				if($1->vtype.compare("float")==0||$3->vtype.compare("float")==0)
				{
					$$->vtype = "float";
				}
				else
				{
					$$->vtype = "int";
				}
				fprintf(flogs,"%s\n\n",$$->getName().c_str());
		  }
		  ;
					
term:	unary_expression {fprintf(flogs,"At line no : %d term : unary_expression \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"term");
		
		$$->vtype = $1->vtype;
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 }
     |  term MULOP unary_expression {fprintf(flogs,"At line no : %d term : term MULOP unary_expression \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName() + $2->getName() + $3->getName(),"term");

		if($1->vtype.compare("void")==0||$3->vtype.compare("void")==0)
		{
			fprintf(ferrors,"MULOP on void expression error at line no : %d\n\n",line_count);
			error_count++;
		}

		if($2->getName().compare("*")==0)
		{
			if($1->vtype.compare("float")==0||$3->vtype.compare("float")==0)
			{
				$$->vtype = "float";
			}
			else
			{
				$$->vtype = "int";
			}	
		}
		else if($2->getName().compare("/")==0)
		{
			if($1->vtype.compare("float")==0||$3->vtype.compare("float")==0)
			{
				$$->vtype = "float";
			}
			else
			{
				$$->vtype = "int";
			}
		}
		else
		{
			if($1->vtype.compare("float")==0||$3->vtype.compare("float")==0)
			{
				fprintf(ferrors,"Modulus operator error at line no : %d\n\n",line_count);
				
				$$->vtype = "int";
				
				error_count++;
			}
			else
			{
				$$->vtype = "int";
			}

		}

		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	 }
     ;

unary_expression: ADDOP unary_expression  {fprintf(flogs,"At line no : %d unary_expression : ADDOP unary_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName() + $2->getName(),"unary_expression");
			
			if($2->vtype.compare("void")==0)
			{
				fprintf(ferrors,"ADDOP on void expression error at line no : %d\n\n",line_count);
				error_count++;
				$$->vtype = "int";
			}
			else
			{
				$$->vtype = $2->vtype;
			}
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		 }
		 | NOT unary_expression {fprintf(flogs,"At line no : %d unary_expression : NOT unary_expression \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName() + $2->getName(),"unary_expression");
			
			if($2->vtype.compare("void")==0)
			{
				fprintf(ferrors,"NOT on void expression error at line no : %d\n\n",line_count);
				error_count++;
				$$->vtype = "int";
			}
			else
			{
				$$->vtype = $2->vtype;
			}
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		 } 
		 | factor {fprintf(flogs,"At line no : %d unary_expression : factor \n\n",line_count);
	 		
			$$ = new Symbolinfo($1->getName(),"unary_expression");
			
			$$->vtype = $1->vtype;
			
			fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		 }
		 ;
	
factor: variable {fprintf(flogs,"At line no : %d factor	: variable \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"factor");
		
		$$->vtype = $1->vtype;
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	}
	| ID {
		if(table->lookup($1->getName())!=0)
		{
			table->lookup($1->getName())->no = var_argumentlist.size();
		} 
		} LPAREN argument_list RPAREN { fprintf(flogs,"At line no : %d factor : ID LPAREN argument_list RPAREN \n\n",line_count);
	 	
		$$ = new Symbolinfo( $1->getName() + "(" + $4->getName() + ")","factor");
		
		Symbolinfo *check = table->lookup($1->getName());
		
		if(check==0)
		{
			fprintf(ferrors,"Function is not declared or defined error at line no : %d \n\n",line_count);
			error_count++;
		}
		else
		{
			if(check->isfunc!=1)
			{
				fprintf(ferrors,"Not a function/Faulty function error at line no : %d\n\n",line_count);
				error_count++;
			}
			else
			{
				int a = var_argumentlist.size()-check->no - check->funcParameter.size() ;
				if(a!=0)
				{
					fprintf(ferrors,"Parameter size mismatch of function error at line no : %d\n\n",line_count);
					
					error_count++;
					
					for(int i =0;i < var_argumentlist.size()-check->no;i)
					{
						var_argumentlist.erase(var_argumentlist.begin()+i+check->no);
					}
				}
				else
				{	
					for(int i =0;i < var_argumentlist.size()-check->no;i)
					{
						if(var_argumentlist[i+check->no]->vtype.compare(check->funcParameter[i]->vtype)!=0)
						{
							fprintf(ferrors,"Parameter type mismatch error of function at line no : %d\n\n",line_count);
							error_count++;
						}
						var_argumentlist.erase(var_argumentlist.begin()+i+check->no);
					}
					
				}
			}
			$$->vtype = check->vtype;
		}
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
	}
	| LPAREN expression RPAREN { fprintf(flogs,"At line no : %d factor : LPAREN expression RPAREN \n\n",line_count);
	 	
		$$ = new Symbolinfo("(" + $2->getName() + ")","factor");
		
		$$->vtype = $2->vtype;
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str());
	}
	| CONST_INT {fprintf(flogs,"At line no : %d factor : CONST_INT \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"factor");
		
		$$->vtype = "int";
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	}
	| CONST_FLOAT {fprintf(flogs,"At line no : %d factor : CONST_FLOAT \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName(),"factor");
		
		$$->vtype = "float";
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	}
	| variable INCOP {fprintf(flogs,"At line no : %d factor : variable INCOP \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName() + "++"  ,"factor");

		$$->vtype = $1->vtype;

		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	}
	| variable DECOP {fprintf(flogs,"At line no : %d factor : variable DECOP \n\n",line_count);
	 	
		$$ = new Symbolinfo($1->getName() + "--"  ,"factor");
		
		$$->vtype = $1->vtype;
		
		fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
	}
	;
	
argument_list: arguments {fprintf(flogs,"At line no : %d argument_list : arguments \n\n",line_count);
	 	
			  	  $$ = new Symbolinfo($1->getName(),"arguments");
		
		      	  $$->vtype = $1->vtype;
		
			  	  fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		  	  }
			  | {fprintf(flogs,"At line no : %d argument_list :  \n\n",line_count);
	 	
			  	  $$ = new Symbolinfo("","arguments");
		
		      	  $$->vtype = "int";
		
			  	  fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		  	  }
			  ;
	
arguments: arguments COMMA logic_expression {fprintf(flogs,"At line no : %d arguments : arguments COMMA logic_expression \n\n",line_count);
	 	
			  $$ = new Symbolinfo($1->getName() + "," + $3->getName()  ,"arguments");
		
		      $$->vtype = $1->vtype;

			  if($3->vtype.compare("void")==0)
			  {
				  fprintf(ferrors,"Return type of argument void type error at line no : %d\n\n",line_count);
				  error_count++;
			  }
			  else
			  {
				  var_argumentlist.push_back($3);
			  }
		
			  fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		  }

	      | logic_expression {fprintf(flogs,"At line no : %d arguments : logic_expression \n\n",line_count);
	 	
			  $$ = new Symbolinfo($1->getName(),"arguments");
		
		      $$->vtype = $1->vtype;

			  var_argumentlist.push_back($1);
		
			  fprintf(flogs,"%s\n\n",$$->getName().c_str()); 
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{	
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n\n");
		exit(1);
	}
	
	
	yyin=fp;
	yyparse();

	fprintf(flogs,"Symbol Table : \n");
	table->printAllScopeTable();
	fprintf(flogs,"\n");
	fprintf(flogs,"Total lines : %d\n\n",line_count);
	fprintf(flogs,"Total error : %d\n\n",error_count);
	fprintf(ferrors,"Total error : %d\n\n",error_count);

	fclose(flogs);
	fclose(ferrors);
	fclose(fp);
	
	return 0;
}

