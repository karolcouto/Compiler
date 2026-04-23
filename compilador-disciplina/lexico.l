%{
#include <string>
%}

%option noyywrap

ESPACO [ \t]
DIGITO [0-9]
LETRA [a-zA-Z_]
_     [_]

DELIM {ESPACO}+
ID ({LETRA}|{_})({LETRA}|{DIGITO}|{_})*
FLOAT {DIGITO}+"."{DIGITO}+
INT {DIGITO}+
%%

"\n"		{ linha++; }

{DELIM} 	{}

"main"      {return TK_MAIN; }
"int"       {return TK_INT; }
"float"     {return TK_FLOAT; }

[+-/*]		{ return *yytext; }
[(){};]     { return *yytext; }

"="         {return '='; }
";"         {return ';'; }

{ID}        {yylval.label = yytext; return TK_ID; }

{FLOAT} {
	yylval.label = yytext;
	yylval.tipo = "float";
	return TK_FLOAT_NUM;
}

{INT} {
	yylval.label = yytext;
	yylval.tipo = "int";
	return TK_INT_NUM;
}

.			{ fprintf(stderr, "Caractere nao reconhecido na linha %d: %s\n", linha, yytext); }

%%
