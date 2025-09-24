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
