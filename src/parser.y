%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);

%}

/* ===== Declaração de tokens vindos do lexer ===== */
%token IF ELSE WHILE
%token AND OR
%token AJUSTAR_O2 AJUSTAR_SORO AUMENTAR_O2 REDUZIR_O2 AUMENTAR_SORO REDUZIR_SORO
%token ALERTA SILENCIAR
%token ESPERAR LOG
%token OXIGENIO BATIMENTO INTRAVENOSO
%token LPAREN RPAREN LBRACE RBRACE SEMI
%token EQ NE LE GE LT GT
%token NUMBER
%token ERROR

/* Valor semântico simples: números inteiros */
%union {
  int num;
}

%type <num> NUMBER

/* Precedência (se quiser usar em extensões futuras) */
%left OR
%left AND
%nonassoc EQ NE LT LE GT GE

%%

program
  : statements                { printf("Parsed OK\n"); }
  ;

statements
  : %empty
  | statements statement
  ;

statement
  : if_stmt
  | while_stmt
  | adjust_stmt SEMI
  | action_stmt SEMI
  | wait_stmt SEMI
  | log_stmt SEMI
  | SEMI                       /* ; sozinho permitido */
  ;

if_stmt
  : IF LPAREN bool RPAREN block
    { /* ok */ }
  | IF LPAREN bool RPAREN block ELSE block
    { /* ok */ }
  ;

while_stmt
  : WHILE LPAREN bool RPAREN block
    { /* ok */ }
  ;

block
  : LBRACE statements RBRACE
    { /* ok */ }
  ;

/* ======= Boolean ======= */
bool
  : simple
  | bool OR simple
  | bool AND simple
  ;

simple
  : sensor comparison NUMBER
  ;

/* ======= Ajustes ======= */
adjust_stmt
  : AJUSTAR_O2   LPAREN NUMBER RPAREN
  | AJUSTAR_SORO LPAREN NUMBER RPAREN
  | AUMENTAR_O2  LPAREN NUMBER RPAREN
  | REDUZIR_O2   LPAREN NUMBER RPAREN
  | AUMENTAR_SORO LPAREN NUMBER RPAREN
  | REDUZIR_SORO  LPAREN NUMBER RPAREN
  ;

/* ======= Ações ======= */
action_stmt
  : ALERTA LPAREN RPAREN
  | SILENCIAR LPAREN RPAREN
  ;

/* ======= Utilidades ======= */
wait_stmt
  : ESPERAR LPAREN NUMBER RPAREN
  ;

log_stmt
  : LOG LPAREN sensor RPAREN
  ;

/* ======= Átomos ======= */
sensor
  : OXIGENIO
  | BATIMENTO
  | INTRAVENOSO
  ;

comparison
  : LT | LE | GT | GE | EQ | NE
  ;

%%

void yyerror(const char *s) {
  extern int yylineno;
  fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

int main(void) {
  if (yyparse() == 0) {
    /* Mensagem já impressa em program: "Parsed OK" */
    return 0;
  }
  return 1;
}
