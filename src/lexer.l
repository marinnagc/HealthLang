%option noinput nounput noyywrap yylineno

%{
#include "parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
%}

%%

[ \t\r\n]+                              ;

\/\/[^\n]*                              ;

"if"                                    { return IF; }
"else"                                  { return ELSE; }
"while"                                 { return WHILE; }
"and"                                   { return AND; }
"or"                                    { return OR; }

"ajustar_O2"                            { return AJUSTAR_O2; }
"ajustar_soro"                          { return AJUSTAR_SORO; }
"aumentar_O2"                           { return AUMENTAR_O2; }
"reduzir_O2"                            { return REDUZIR_O2; }
"aumentar_soro"                         { return AUMENTAR_SORO; }
"reduzir_soro"                          { return REDUZIR_SORO; }

"alerta"                                { return ALERTA; }
"silenciar"                             { return SILENCIAR; }

"esperar"                               { return ESPERAR; }
"log"                                   { return LOG; }

"oxigenio"                              { return OXIGENIO; }
"batimento"                             { return BATIMENTO; }
"intravenoso"                           { return INTRAVENOSO; }

"("                                     { return LPAREN; }
")"                                     { return RPAREN; }
"{"                                     { return LBRACE; }
"}"                                     { return RBRACE; }
";"                                     { return SEMI; }

"=="                                    { return EQ; }
"!="                                    { return NE; }
"<="                                    { return LE; }
">="                                    { return GE; }
"<"                                     { return LT; }
">"                                     { return GT; }

[0-9]+                                  { yylval.num = atoi(yytext); return NUMBER; }

.                                       { fprintf(stderr, "Lexical error at line %d: '%s'\n", yylineno, yytext); return ERROR; }

%%
