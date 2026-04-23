%{
#include <iostream>
#include <string>
#include <map>


#define YYSTYPE atributos 
using namespace std;

int var_temp_qnt;
string declaracoes;
int linha = 1;
string codigo_gerado;
string promove(string t1, string t2);


struct Simbolo {
	string tipo;
	string nome_intermediario;
};

map<string, Simbolo> tabela;

struct atributos
{
	string label;
	string traducao;
	string tipo;
};

int yylex(void);
void yyerror(string);
string gentempcode(string tipo);
%}

%token TK_FLOAT_NUM TK_INT_NUM
%token TK_MAIN TK_ID TK_INT 
%token TK_FIM TK_ERROR
%token TK_FLOAT

%start S 

%left '+' '-'
%left '*' '/' 

%%

S 			: COMANDOS
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";

				codigo_gerado += declaracoes + "\n";
				codigo_gerado += $1.traducao;

				codigo_gerado += "\treturn 0;"
							"\n}\n";
			}
			;
COMANDOS    : COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;
COMANDO 	: E ';'
			{
				$$.traducao = $1.traducao;
			}
			|DECL ';'
			{
				$$.traducao = $1.traducao;
			}
			;
E 			: E '+' E 
			{
				$$.tipo = promove($1.tipo, $3.tipo);
				$$.label = gentempcode($$.tipo);

				$$.traducao = $1.traducao + $3.traducao +
				"\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E {
				$$.tipo = promove($1.tipo, $3.tipo);
				$$.label = gentempcode($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E {
				$$.tipo = promove($1.tipo, $3.tipo);
				$$.label = gentempcode($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E {
				$$.tipo = promove($1.tipo, $3.tipo);
				$$.label = gentempcode($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| TK_ID '=' E
			{
				
				$$.label = $1.label;

				if (tabela.find($1.label) == tabela.end()) {
					// não declarada
					$$.traducao = $3.traducao +
						"\t" + $1.label + " = " + $3.label + ";\n";
				}
				else {
					Simbolo s = tabela[$1.label];

					$$.traducao = $3.traducao +
						"\t" + s.nome_intermediario + " = " + $3.label + ";\n";
				}

				$$.tipo = $3.tipo;
				
			}
			| TK_INT_NUM
			{
				$$.tipo = "int";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_FLOAT_NUM
			{
				$$.tipo = "float";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				if (tabela.find($1.label) == tabela.end()){
					yyerror("Variável não declarada");
					$$.tipo = "int";
					$$.label = gentempcode($$.tipo);
					Simbolo s;
					s.tipo = "int";
					s.nome_intermediario = $1.label; 

					tabela[$1.label] = s;
					
					$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
					
				}else{
					Simbolo s = tabela[$1.label];
					$$.tipo = s.tipo;
					$$.label = s.nome_intermediario;
					$$.traducao = "";
				}
				;
			}
			| '(' E ')'
			{
				$$.tipo = $2.tipo;
				$$.label = $2.label;
    			$$.traducao = $2.traducao;
			}
			;
DECL        : TK_INT TK_ID
			{
				Simbolo s;
				s.tipo = "int";
				s.nome_intermediario = gentempcode("int"); 

				tabela[$2.label] = s;

			}
			| TK_FLOAT TK_ID
			{
				Simbolo s;
				s.tipo = "float";
				s.nome_intermediario = gentempcode("float");

				tabela[$2.label] = s;

				//declaracoes += "\tfloat " + $2.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

string promove(string t1, string t2)
{
	if (t1 == "float" && t2 == "float")
		return "float";
	return "int";
}

string gentempcode(string tipo)
{
	var_temp_qnt++;
	string temp = "t" + to_string(var_temp_qnt);

	declaracoes += "\t" + tipo + " " + temp + ";\n";

	return temp;
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0)
		cout << codigo_gerado;

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}
