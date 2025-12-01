%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

void yyerror(const char *s);
int yylex(void);

static FILE *out;
static int label_id = 0;

static void emit(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vfprintf(out, fmt, ap);
    fprintf(out, "\n");
    va_end(ap);
}

static void fresh(const char *base, char *buf) {
    sprintf(buf, "__%s_%d", base, label_id++);
}

/* Estrutura para suportar ifs/whiles aninhados */
typedef struct {
    char false_label[32];
    char end_label[32];
} IfLabels;

typedef struct {
    char cond_label[32];
    char end_label[32];
} WhileLabels;

#define MAX_NESTING 50
static IfLabels if_stack[MAX_NESTING];
static int if_depth = 0;
static WhileLabels while_stack[MAX_NESTING];
static int while_depth = 0;

/* helpers declarados aqui, definidos depois da gramática */
static const char *sensor_name(int s);
static const char *invert_op(int op);
%}

/* ===== Declaração de tipos ===== */
%union {
  int num;
}

/* Tokens */
%token OXIGENIO BATIMENTO INTRAVENOSO
%token LT LE GT GE EQ NE
%token <num> NUMBER

%type <num> sensor comparison

%token IF ELSE WHILE
%token AND OR
%token AJUSTAR_O2 AJUSTAR_SORO AUMENTAR_O2 REDUZIR_O2 AUMENTAR_SORO REDUZIR_SORO
%token ALERTA SILENCIAR
%token ESPERAR LOG
%token LPAREN RPAREN LBRACE RBRACE SEMI
%token ERROR

%%

program
  : statements             { emit("HALT"); }
  ;

statements
  : /* vazio */
  | statements statement
  ;

statement
  : if_stmt
  | while_stmt
  | adjust_stmt
  | action_stmt
  | wait_stmt
  | log_stmt
  | SEMI
  ;

/* ===== IF / ELSE ===== */

/* prefixo comum que já emite o CJMP */
if_prefix
  : IF LPAREN sensor comparison NUMBER RPAREN
    {
      fresh("iffalse", if_stack[if_depth].false_label);
      fresh("ifend",  if_stack[if_depth].end_label);

      const char *s  = sensor_name($3);
      const char *op = invert_op($4);

      /* pula para if_false se condição for falsa */
      emit("CJMP %s %s %d %s", s, op, $5, if_stack[if_depth].false_label);
      if_depth++;
    }
  ;

if_stmt
  /* if (cond) { then } */
  : if_prefix block
    {
      if_depth--;
      emit("GOTO %s", if_stack[if_depth].end_label);
      emit("%s:", if_stack[if_depth].false_label);
      emit("%s:", if_stack[if_depth].end_label);
    }

  /* if (cond) { then } else { else } */
  | if_prefix block
    {
      if_depth--;
      /* fim do THEN: pula por cima do ELSE e marca label do falso */
      emit("GOTO %s", if_stack[if_depth].end_label);
      emit("%s:", if_stack[if_depth].false_label);
      if_depth++;
    }
    ELSE
    block
    {
      if_depth--;
      emit("%s:", if_stack[if_depth].end_label);
    }
  ;

/* ===== WHILE ===== */
while_stmt
  : WHILE LPAREN sensor comparison NUMBER RPAREN
    {
      fresh("while_cond", while_stack[while_depth].cond_label);
      fresh("while_end",  while_stack[while_depth].end_label);

      const char *s  = sensor_name($3);
      const char *op = invert_op($4);

      emit("%s:", while_stack[while_depth].cond_label);
      emit("CJMP %s %s %d %s", s, op, $5, while_stack[while_depth].end_label);
      while_depth++;
    }
    block
    {
      while_depth--;
      emit("GOTO %s", while_stack[while_depth].cond_label);
      emit("%s:", while_stack[while_depth].end_label);
    }
  ;

/* ===== BLOCO ===== */
block
  : LBRACE statements RBRACE
  ;

/* ===== AJUSTES ===== */
adjust_stmt
  : AJUSTAR_O2   LPAREN NUMBER RPAREN SEMI { emit("SET O2 %d", $3); }
  | AJUSTAR_SORO LPAREN NUMBER RPAREN SEMI { emit("SET IV %d", $3); }
  | AUMENTAR_O2  LPAREN NUMBER RPAREN SEMI {
      for(int i=0;i<$3;i++) emit("INC O2");
    }
  | AUMENTAR_SORO LPAREN NUMBER RPAREN SEMI {
      for(int i=0;i<$3;i++) emit("INC IV");
    }
  | REDUZIR_O2   LPAREN NUMBER RPAREN SEMI {
      for(int i=0;i<$3;i++){
        char L[32]; fresh("decok", L);
        emit("DECJZ O2 %s", L);
        emit("GOTO %s", L);
        emit("%s:", L);
      }
    }
  | REDUZIR_SORO LPAREN NUMBER RPAREN SEMI {
      for(int i=0;i<$3;i++){
        char L[32]; fresh("decok", L);
        emit("DECJZ IV %s", L);
        emit("GOTO %s", L);
        emit("%s:", L);
      }
    }
  ;

/* ===== AÇÕES ===== */
action_stmt
  : ALERTA    LPAREN RPAREN SEMI { emit("PRINT S_BPM"); }
  | SILENCIAR LPAREN RPAREN SEMI { emit("; SILENCIAR sem efeito"); }
  ;

/* ===== ESPERAR ===== */
wait_stmt
  : ESPERAR LPAREN NUMBER RPAREN SEMI {
      char L1[32], L2[32];
      fresh("wait_loop", L1);
      fresh("wait_end",  L2);
      emit("PUSH O2");
      emit("SET O2 %d", $3);
      emit("%s:", L1);
      emit("DECJZ O2 %s", L2);
      emit("GOTO %s", L1);
      emit("%s:", L2);
      emit("POP O2");
    }
  ;

/* ===== LOG ===== */
log_stmt
  : LOG LPAREN OXIGENIO    RPAREN SEMI { emit("PRINT S_SPO2"); }
  | LOG LPAREN BATIMENTO   RPAREN SEMI { emit("PRINT S_BPM"); }
  | LOG LPAREN INTRAVENOSO RPAREN SEMI { emit("PRINT S_IVLV"); }
  ;

/* ===== Átomos ===== */
sensor
  : OXIGENIO    { $$ = 1; }  /* -> S_SPO2   */
  | BATIMENTO   { $$ = 2; }  /* -> S_BPM    */
  | INTRAVENOSO { $$ = 3; }  /* -> S_IVLV   */
  ;

comparison
  : LT { $$ = LT; }
  | LE { $$ = LE; }
  | GT { $$ = GT; }
  | GE { $$ = GE; }
  | EQ { $$ = EQ; }
  | NE { $$ = NE; }
  ;

%%

static const char *sensor_name(int s) {
    switch (s) {
        case 1: return "S_SPO2";
        case 2: return "S_BPM";
        case 3: return "S_IVLV";
        default: return "S_IVLV";
    }
}

/* devolve o operador “negado” (para pular quando a condição for falsa) */
static const char *invert_op(int op) {
    switch (op) {
        case LT: return "GE";
        case LE: return "GT";
        case GT: return "LE";
        case GE: return "LT";
        case EQ: return "NE";
        case NE: return "EQ";
        default: return "NE";
    }
}

void yyerror(const char *s) {
  extern int yylineno;
  fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

extern FILE *yyin;

int main(int argc, char **argv) {
  if (argc < 3) {
    fprintf(stderr, "Usage: %s <input.hl> <output.vmasm>\n", argv[0]);
    return 1;
  }
  
  yyin = fopen(argv[1], "r");
  if (!yyin) {
    perror(argv[1]);
    return 1;
  }
  
  out = fopen(argv[2], "w");
  if (!out) {
    perror(argv[2]);
    fclose(yyin);
    return 1;
  }
  
  int ret = yyparse();
  
  fclose(yyin);
  fclose(out);
  
  return ret;
}
