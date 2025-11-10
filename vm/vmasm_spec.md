# Especificação mínima 

## Registradores mutáveis (≥2)

* `O2` (inteiro) — fluxo de oxigênio
* `IV` (inteiro) — taxa de soro

## Sensores readonly (exemplos)

* `S_BPM`  (batimento)
* `S_SPO2` (oxigênio / saturação)
* `S_IVLV` (intravenoso / “nível” corporal)

> Os sensores podem ser atualizados por um **modelo simples** a cada “tick” (instrução), por exemplo:
>
> * `S_SPO2` sobe quando `O2` sobe (mas com **inércia** e teto).
> * `S_BPM` cai lentamente quando `IV` sobe (simulando hidratação).
> * `S_IVLV` sobe quando `IV` alto por um tempo.

## Memória

* **Pilha** com `PUSH`/`POP` (LIFO).
* (Opcional) Uma “RAM” de dicionário `{addr:int}` se quiser.

## Instruções (ISA)

```
; set/reset
SET     R n          ; R = n               (R ∈ {O2, IV})
INC     R            ; R = R + 1
DECJZ   R label      ; R = R - 1; if R == 0 jump label
GOTO    label        ; salto incondicional
PRINT   id           ; debug: imprime R ou sensor (id ∈ {O2, IV, S_BPM, S_SPO2, S_IVLV})
PUSH    R            ; empilha valor de R
POP     R            ; desempilha para R
HALT                  ; para

; rótulos:
nome_label:
```

> **Turing-complete**: `INC` + `DECJZ` + `GOTO` (estilo Minsky) já resolvem.
> **Pelo menos 2 registradores**: `O2`, `IV`.
> **Memória**: a pilha.
> **Sensores**: `S_*` somente leitura.

## Modelo de sensores (bem simples, exemplo)

* A cada instrução:

  ```
  S_SPO2 += clamp( (O2 - 50) / 50, -2, +2 )    ; sobe devagar se O2 > 50
  S_BPM  += clamp( 90 - IV, -3, +1 )           ; cai quando IV ~ alto
  S_IVLV += clamp( IV / 10, 0, +2 ) - 1        ; repõe lentamente, perde 1 por tick
  limitar: S_SPO2 em [80..100], S_BPM em [40..160], S_IVLV em [0..100]
  ```

  É só um *placeholder* para a simulação; bastante para demos.

---

# Como a HealthLang vira assembly (padrões)

Você NÃO precisa expor `INC/DEC` pro usuário; o **compilador** faz a ponte.

### 1) `ajustar_O2(60)`

* Estratégia: zera `O2`, depois `INC O2` 60 vezes (ou via `SET O2 60` se liberar no ISA).

```
SET O2 0
SET tmp 60      ; se tiver registrador temporário/stack
; (ou construir com DECJZ/loops)
SET O2 60       ; se permitir SET direto, melhor.
```

### 2) `aumentar_soro(2)`

```
INC IV
INC IV
```

### 3) `if (oxigenio < 92) {...} else {...}`

* Leia sensor em tempo de execução: comparar “sensor < n” precisa de rotina de comparação.
  Padrão (ideia): copie `S_SPO2` para uma “janela” de comparação (ou interprete via pseudo-instruções), mas como sua etapa atual não pede semântica, você só precisa **planejar** que o gerador de código criará uma sub-rotina de comparação para cada `SENSOR COMPARISON NUMBER` usando contagens/DECJZ.
  Para a entrega final, implementa uma **função padrão**:

  * `CMP_LT_SPO2 n -> branch label` (traduzida para laços `DECJZ` degradando um contador até bater `n`, etc).

### 4) `esperar(1000)`

* Transforme em NOPs/loops:

```
SET TMP 1000
delay:
  DECJZ TMP end_delay
  GOTO delay
end_delay:
```

#### Mapeamento da Linguagem
---

| HealthLang                                | Assembly (VMasM)                                                                             |
| ----------------------------------------- | -------------------------------------------------------------------------------------------- |
| `ajustar_O2(N);`                          | `SET O2 N`                                                                                   |
| `ajustar_soro(N);`                        | `SET IV N`                                                                                   |
| `aumentar_O2(k);`                         | repetir `INC O2` k vezes                                                                     |
| `aumentar_soro(k);`                       | repetir `INC IV` k vezes                                                                     |
| `reduzir_O2(k);`                          | **macro** de “decremento sem salto” (abaixo), repetir k vezes                                |
| `reduzir_soro(k);`                        | idem para `IV`                                                                               |
| `esperar(ms);`                            | **macro WAIT**: `PUSH O2; SET O2 ms; loop: DECJZ O2 end; GOTO loop; end: POP O2`             |
| `log(sensor);`                            | `PRINT S_SPO2` / `PRINT S_BPM` / `PRINT S_IVLV`                                              |
| `if (oxigenio < 95) { ... } else { ... }` | `CJMP S_SPO2 LT 95 L_true; GOTO L_false; L_true: [then] GOTO L_end; L_false: [else]; L_end:` |
| `while (batimento > 100) { ... }`         | `L_cond: CJMP S_BPM GT 100 L_body; GOTO L_end; L_body: [body]; GOTO L_cond; L_end:`          |
