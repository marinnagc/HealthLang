CC = gcc
CFLAGS = -Wall -Wextra -O2

all: healthlang

healthlang: parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $@ parser.tab.c lex.yy.c -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d -Wall -Wcounterexamples parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f healthlang parser.tab.c parser.tab.h lex.yy.c

.PHONY: all clean

# Requisitos: bison, flex, gcc (ou clang).
# Build: cd src && make
# Rodar: ./healthlang < ../examples/taquicardia.hl
run:
	@echo "==> Teste taquicardia"
	./healthlang < ../../examples/taquicardia.hl > ../../vm/testes/taquicardia.vmasm
	@echo "==> Teste oxigenio"
	./healthlang < ../../examples/oxigenio.hl > ../../vm/testes/oxigenio.vmasm
	@echo "==> Teste soro"
	./healthlang < ../../examples/soro.hl > ../../vm/testes/soro.vmasm
	@echo "==> Teste desidratacao"
	./healthlang < ../../examples/desidratacao.hl > ../../vm/testes/desidratacao.vmasm
