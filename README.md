# HealthLang — Linguagem de Protocolos de Saúde 

**HealthLang** é uma linguagem de alto nível simples, pensada para escrever **protocolos clínicos básicos** de forma clara e legível.
Ela foi projetada para que **profissionais de saúde (médicos, enfermeiros)** consigam **ler e compreender** os protocolos escritos sem precisar conhecer programação tradicional.

---

## Objetivo

* Simular **respostas automáticas** de uma máquina virtual (VitalsVM).
* Permitir que protocolos clínicos sejam escritos em **linguagem quase natural**.
---

## Público-alvo

* **Usuário da linguagem (médico/enfermeiro):**
  Vê apenas **sensores** e **ações clínicas**.
  Exemplo:

  ```c
  if (batimento > 100) {
    ajustar_soro(30);
    alerta();
  }
  ```

  → Fácil de entender: “se FC > 100, ajustar soro para 30 e disparar alarme”.

* **Implementador (VM/compilador):**
  Por baixo dos panos, comandos como `ajustar_soro(30)` viram operações de máquina (`INC/DEC`) para controlar os registradores da VM.

---

## Elementos da linguagem

### Sensores (somente leitura)

* `batimento` → frequência cardíaca (bpm)
* `oxigenio` → saturação periférica de O₂ (%)
* `intravenoso` → nível de fluido intravenoso (soro)

### Controles internos da VM

* `O2` → fluxo de oxigênio (mutável)
* `IV` → taxa de soro (mutável)

> O usuário **não manipula `O2` e `IV` diretamente**. Ele usa comandos de alto nível (`ajustar_soro(30)`) e o compilador traduz isso em instruções da VM.

### Ações clínicas

* `ajustar_O2(N)` → configura O₂ para o valor N
* `ajustar_soro(N)` → configura soro para N
* `aumentar_O2(N)` / `reduzir_O2(N)` → ajustes relativos
* `aumentar_soro(N)` / `reduzir_soro(N)` → ajustes relativos
* `alerta()` → ativa alarme
* `silenciar()` → desativa alarme
* `esperar(ms)` → pausa X milissegundos (simula observação clínica entre ajustes)
* `log(sensor)` → imprime valor de um sensor (debug/testes)

### Estruturas de controle

* **Condicional:** `if … else`
* **Laço:** `while (…) { … }`

---

## EBNF da HealthLang

```ebnf
(* HealthLang — EBNF v1.2 *)

PROGRAM    = { STATEMENT } ;

STATEMENT  = IF | WHILE | ADJUST | ACTION | WAIT | LOG | ";" ;

IF         = "if" "(" BOOL ")" BLOCK [ "else" BLOCK ] ;
WHILE      = "while" "(" BOOL ")" BLOCK ;
BLOCK      = "{" { STATEMENT } "}" ;

(* condições compostas *)
BOOL       = SIMPLE { LOGOP SIMPLE } ;
SIMPLE     = SENSOR COMPARISON NUMBER ;
LOGOP      = "and" | "or" ;
COMPARISON = "<" | "<=" | ">" | ">=" | "==" | "!=" ;

(* ajustes de controle *)
ADJUST     = "ajustar_O2"   "(" NUMBER ")" ";"
           | "ajustar_soro" "(" NUMBER ")" ";"
           | "aumentar_O2"  "(" NUMBER ")" ";"
           | "reduzir_O2"   "(" NUMBER ")" ";"
           | "aumentar_soro" "(" NUMBER ")" ";"
           | "reduzir_soro"  "(" NUMBER ")" ";" ;

(* ações binárias *)
ACTION     = "alerta" "(" ")" ";"
           | "silenciar" "(" ")" ";" ;

WAIT       = "esperar" "(" NUMBER ")" ";" ;
LOG        = "log" "(" SENSOR ")" ";" ;

SENSOR     = "oxigenio" | "batimento" | "intravenoso" ;

NUMBER     = DIGIT { DIGIT } ;
DIGIT      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```

---

## Exemplos

### 1. Bradicardia

Arquivo: `examples/bradicardia.hl`

```c
// Se batimento < 40, ativar alerta. Senão, silenciar.
if (batimento < 40) {
  alerta();
} else {
  silenciar();
}
```

---

### 2. Oxigenoterapia progressiva

Arquivo: `examples/oxigenio.hl`

```c
// Se SpO2 < 92, ajustar O2 para 60 e alertar.
// Enquanto SpO2 < 95, aumentar em passos de 2, esperando 1s entre ajustes.
if (oxigenio < 92) {
  ajustar_O2(60);
  alerta();
}

while (oxigenio < 95) {
  aumentar_O2(2);
  esperar(1000);
}

silenciar();
```

---

### 3. Taquicardia → hidratação

Arquivo: `examples/taquicardia.hl`

```c
// Se batimento > 100, aumentar soro (IV) e alertar.
// Caso contrário, silenciar alarme.
if (batimento > 100) {
  ajustar_soro(30);
  alerta();
} else {
  silenciar();
}
```

---

### 4. Hidratação progressiva

Arquivo: `examples/hidratacao_progressiva.hl`

```c
// Enquanto batimento continuar > 95, aumentar soro em passos de 2
// Espera 5s entre ajustes para simular reavaliação clínica.
while (batimento > 95) {
  aumentar_soro(2);
  esperar(5000);
}

silenciar();
```

---

## Observações

* **Para o profissional de saúde:** a linguagem é simples e legível, quase como pseudocódigo médico.
* **Para o compilador:** comandos de ajuste são traduzidos em operações de baixo nível (`INC/DEC`) até atingir o alvo.
* **esperar(ms):** evita loops instantâneos e simula o tempo fisiológico necessário para reavaliar sinais.



**Ferramentas:**
- Flex → Análise Léxica (lexer.l)
- Bison → Análise Sintática (parser.y)
- VitalsVM → Máquina Virtual customizada


## Estrutura do Repositório

```
HealthLang/
├── compiler/
│   ├── src/              # Código fonte do compilador (Flex/Bison)
│   │   ├── lexer.l       # Analisador léxico
│   │   ├── parser.y      # Analisador sintático
│   │   ├── Makefile      # Script de compilação
│   │   └── healthlang    # Executável gerado
│   └── examples/         # Programas de exemplo em HealthLang
│       ├── choque_hipovolemico.hl
│       ├── desidratacao.hl
│       ├── monitoramento_continuo.hl
│       ├── oxigenio.hl
│       ├── soro.hl
│       └── taquicardia.hl
├── vm/
│   ├── implementacao/    # Código da máquina virtual
│   │   ├── vm.py         # Interpretador VitalsVM
│   │   └── run.sh        # Script auxiliar
│   ├── vmasm_files/      # Arquivos assembly compilados
│   │   ├── choque_hipovolemico.vmasm
│   │   ├── desidratacao.vmasm
│   │   ├── monitoramento_continuo.vmasm
│   │   ├── oxigenio.vmasm
│   │   ├── soro.vmasm
│   │   └── taquicardia.vmasm
│   └── vmasm_spec.md     # Especificação da VM e ISA
├── saidas/               # Resultados das execuções
│   └── saida_*.txt       # Logs de saída dos programas
├── grammar.ebnf          # Gramática formal EBNF da linguagem
├── README.md             # Documentação principal
└── TUTORIAL.md           # Guia passo a passo de uso
```

---

## Etapas de Compilação e Execução

### 1. Compilar a linguagem

```bash
cd compiler/src
make
```

---

### 2. Gerar os programas de teste (compilação dos exemplos)

```bash
make run
```

Esse comando compila os exemplos `.hl` (como `taquicardia.hl`) e gera os arquivos `.vmasm` correspondentes em `vm/testes/`.

---

### 3. Executar a VM com o programa gerado

```bash
cd ../../vm/implementacao
./run.sh ../testes/taquicardia.vmasm
```

---

### Saída esperada

O programa simula o comportamento fisiológico do paciente, mostrando o valor dos sensores a cada ciclo de monitoramento.

Exemplo de saída:

```
S_BPM=81
--- ciclo 100 ---
S_SPO2=94
S_IVLV=52
--- ciclo 200 ---
S_SPO2=96
S_IVLV=58
```

---

## VitalsVM — Nossa Máquina Virtual

A **VitalsVM** é uma máquina virtual customizada, minimalista e Turing-completa, inspirada em Minsky Machines, criada especificamente para simular protocolos clínicos. Elementos:

### Registradores (mutáveis)

| Nome | Função                   |
| ---- | ------------------------ |
| O2   | Fluxo de oxigênio        |
| IV   | Taxa de soro intravenoso |

### Sensores (somente leitura)

| Nome   | Significado                     |
| ------ | ------------------------------- |
| S_SPO2 | Saturação de oxigênio no sangue |
| S_BPM  | Batimentos por minuto           |
| S_IVLV | Nível de fluido intravenoso     |

### Instruções

| Instrução                  | Descrição                                    | Exemplo                    |
| -------------------------- | -------------------------------------------- | -------------------------- |
| `SET R N`                  | Define valor do registrador                  | `SET O2 60`                |
| `INC R`                    | Incrementa registrador                       | `INC IV`                   |
| `DECJZ R label`            | Decrementa R e pula para label se chegar a 0 | `DECJZ O2 loop_end`        |
| `GOTO label`               | Pula para um rótulo                          | `GOTO check`               |
| `CJMP sensor OP val label` | Pula se condição for verdadeira              | `CJMP S_BPM GT 120 alerta` |
| `PRINT id`                 | Exibe registrador ou sensor                  | `PRINT S_BPM`              |
| `PUSH` / `POP`             | Pilha temporária                             |                            |
| `HALT`                     | Finaliza o programa                          |                            |

---

## Exemplo Completo

### Código em HealthLang

```c
AJUSTAR_SORO(40);
WHILE (BATIMENTO > 120) {
    AJUSTAR_SORO(60);
    ALERTA();
    ESPERAR(5);
}
```

### Código gerado (.vmasm)

```asm
SET IV 40
__while_cond_0:
CJMP S_BPM LE 120 __while_end_1
SET IV 60
PRINT S_BPM
PUSH O2
SET O2 5
__wait_loop_2:
DECJZ O2 __wait_end_3
GOTO __wait_loop_2
__wait_end_3:
POP O2
GOTO __while_cond_0
__while_end_1:
HALT
```

---

## Sobre o Loop Contínuo

Por ser uma simulação de **monitoramento vital**, a VM executa indefinidamente, simulando um sistema de UTI em funcionamento contínuo.
O parâmetro `--steps` no `run.sh` define o limite de iterações (para evitar travar o terminal durante testes).

---

**Marinna Grigolli Cesar**
Engenharia da Computação — Insper
2025.2

```