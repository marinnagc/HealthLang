# HealthLang - Roteiro de Apresentação

Este documento serve como guia para criar sua apresentação em PowerPoint/PDF.

---

## Slide 1: Capa

**Conteúdo:**
- **Título:** HealthLang - Linguagem de Protocolos Clínicos
- **Subtítulo:** Uma DSL para Automação de Respostas em Ambientes Hospitalares
- **Seu nome:** Marinna Grigolli Cesar
- **Curso:** Engenharia da Computação - Insper
- **Data:** 2025.2

**Elementos visuais:**
- Logo ou ícone médico (coração, ECG, hospital)
- Cores: azul/verde (associadas à saúde)

---

## Slide 2: Motivação

**Título:** Por que HealthLang?

**Conteúdo:**
- **Problema:** Protocolos clínicos são complexos e críticos
  - Erros podem ser fatais
  - Dificuldade de padronização
  - Profissionais de saúde não são programadores

- **Solução:** Linguagem de alto nível legível
  - Sintaxe próxima à linguagem natural médica
  - Foco em clareza, não em complexidade técnica
  - Automatização de respostas baseadas em sinais vitais

**Elementos visuais:**
- Imagem de monitor de UTI / sinais vitais
- Comparação: código tradicional vs HealthLang

---

## Slide 3: O que é HealthLang?

**Título:** Características da Linguagem

**Conteúdo:**
- **DSL (Domain-Specific Language)** para protocolos clínicos
- **Inspirada em linguagem médica** real
- **Compilada para assembly customizado** (VitalsVM)

**Três pilares:**
1. **Sensores** - Leitura de sinais vitais (oxigenio, batimento, intravenoso)
2. **Ações** - Comandos clínicos (ajustar_O2, ajustar_soro, alerta)
3. **Lógica** - Estruturas de controle (if/else, while)

**Elementos visuais:**
- Diagrama mostrando: Protocolo Médico → HealthLang → Assembly → VitalsVM

---

## Slide 4: Exemplo de Código

**Título:** Como é um protocolo em HealthLang?

**Conteúdo:**
```c
// Protocolo de Taquicardia
if (batimento > 120) {
    ajustar_soro(50);
    alerta();
    log(batimento);
} else {
    silenciar();
}
```

**Explicação em linguagem natural:**
- "Se a frequência cardíaca passar de 120 bpm"
- "Ajustar soro para 50 ml/h"
- "Disparar alarme"
- "Registrar valor do batimento"

**Elementos visuais:**
- Código com syntax highlighting
- Setas explicativas

---

## Slide 5: Arquitetura do Sistema

**Título:** Como funciona o compilador?

**Conteúdo:**
```
Arquivo .hl (HealthLang)
    ↓
[Análise Léxica - Flex]
    ↓
[Análise Sintática - Bison]
    ↓
Arquivo .vmasm (Assembly)
    ↓
[VitalsVM - Interpretador Python]
    ↓
Simulação de Sinais Vitais
```

**Tecnologias utilizadas:**
- **Flex:** Geração do analisador léxico
- **Bison:** Geração do parser sintático
- **C:** Geração do compilador
- **Python:** Implementação da VitalsVM

**Elementos visuais:**
- Diagrama de blocos com cores diferentes para cada etapa

---

## Slide 6: Gramática EBNF

**Título:** Estrutura Formal da Linguagem

**Conteúdo (simplificado):**
```ebnf
PROGRAM    = { STATEMENT } ;
STATEMENT  = IF | WHILE | ADJUST | ACTION | WAIT | LOG ;
IF         = "if" "(" BOOL ")" BLOCK [ "else" BLOCK ] ;
ADJUST     = "ajustar_O2" "(" NUMBER ")" ";"
           | "ajustar_soro" "(" NUMBER ")" ";" ;
SENSOR     = "oxigenio" | "batimento" | "intravenoso" ;
```

**Destaque:**
- Sintaxe simples e clara
- Estruturas familiares (if, while)
- Vocabulário do domínio médico

---

## Slide 7: VitalsVM - Nossa Máquina Virtual

**Título:** VitalsVM - VM Customizada (+ Bônus!)

**Conteúdo:**

**Por que criar uma VM própria?**
- ✅ **+1 conceito no APS**
- ✅ Controle total sobre o comportamento
- ✅ Modelagem fisiológica integrada
- ✅ ISA otimizada para o domínio médico

**Arquitetura:**

**Registradores mutáveis:**
- `O2` - Fluxo de oxigênio (0-100)
- `IV` - Taxa de soro intravenoso (0-100)

**Sensores readonly (atualizam a cada tick):**
- `S_SPO2` - Saturação de oxigênio 80-100%
- `S_BPM` - Batimentos por minuto 40-160 bpm
- `S_IVLV` - Nível de fluido corporal 0-100%

**ISA Turing-Completa:**
- `SET, INC, DECJZ` (estilo Minsky Machine)
- `GOTO, CJMP` (controle de fluxo condicional)
- `PUSH/POP` (pilha para memória temporária)
- `PRINT, HALT` (debug e controle)

**Elementos visuais:**
- Diagrama da arquitetura da VM
- Badge/destaque: "VM Própria = +1 Conceito!"

---

## Slide 8: Modelo Fisiológico

**Título:** Simulação de Sinais Vitais

**Conteúdo:**
A VM simula como os sinais vitais respondem às intervenções:

**Exemplos:**
- `S_SPO2` **sobe** quando `O2` aumenta (com inércia)
- `S_BPM` **cai** quando `IV` aumenta (hidratação)
- `S_IVLV` **sobe** gradualmente com infusão de soro

**Fórmulas simplificadas:**
```
S_SPO2 += clamp((O2 - 50) / 50, -2, +2)
S_BPM  += clamp((90 - IV) / 20, -3, +1)
S_IVLV += clamp(IV / 10 - 1, -1, +2)
```

**Elementos visuais:**
- Gráfico mostrando a evolução dos sensores ao longo do tempo

---

## Slide 9: Exemplos Práticos

**Título:** 6 Protocolos Implementados

**Conteúdo:**

| Protocolo | Descrição |
|-----------|-----------|
| **taquicardia.hl** | Detecção de FC elevada |
| **oxigenio.hl** | Ajuste progressivo de O₂ |
| **soro.hl** | Reposição volêmica |
| **desidratacao.hl** | Simulação de perda de volume |
| **choque_hipovolemico.hl** | Múltiplas condições críticas |
| **monitoramento_continuo.hl** | Loop infinito (UTI 24/7) |

**Destaque:**
- Cobrem casos reais de urgência
- Demonstram todas as funcionalidades da linguagem

---

## Slide 10: Demonstração - Monitoramento Contínuo

**Título:** Protocolo de UTI em Ação

**Código:**
```c
while (batimento >= 0) {
    if (oxigenio < 92) {
        ajustar_O2(70);
        alerta();
    }
    if (batimento > 120) {
        aumentar_soro(5);
        alerta();
    }
    esperar(50);
}
```

**Saída da execução:**
```
--- ciclo 100 ---
S_BPM=120
S_SPO2=87
--- ciclo 200 ---
S_BPM=115
S_SPO2=91
```

**Elementos visuais:**
- Screenshot da saída real do programa
- GIF ou vídeo curto da execução

---

## Slide 11: Resultados dos Exemplos

**Título:** Execução e Saídas Reais

**Conteúdo:**

**1. taquicardia.hl** - Detecção simples de FC alta
```
S_BPM=81  → FC normal, silenciar alarme
```

**2. oxigenio.hl** - Ajuste de oxigenoterapia
```
S_SPO2=94  → SpO2 normal após ajuste
```

**3. soro.hl** - Reposição volêmica até meta
```
S_IVLV=70 → S_IVLV=98 → S_BPM=70
Volume restaurado com sucesso!
```

**4. desidratacao.hl** - Perda progressiva de volume
```
S_IVLV: 70→60→50→40→30
S_BPM: 85→90→95→100→105
Taquicardia compensatória pela desidratação
```

**5. choque_hipovolemico.hl** - Protocolo de emergência
```
Múltiplas verificações aninhadas
Intervenção agressiva em casos críticos
```

**6. monitoramento_continuo.hl** - UTI 24/7
```
--- ciclo 100 ---
S_BPM=120, S_SPO2=87
--- ciclo 200 ---
S_BPM=115, S_SPO2=91
Loop infinito verificando constantemente
```

**Elementos visuais:**
- Boxes coloridos para cada exemplo
- Setas mostrando progressão dos valores

---

## Slide 12: Curiosidades Técnicas

**Título:** Destaques do Desenvolvimento

**Conteúdo:**

1. **Turing-Completude**
   - Baseada em Minsky Machines (INC + DECJZ + GOTO)
   - Capaz de expressar qualquer computação

2. **Suporte a Aninhamento**
   - Pilha de labels para ifs/whiles aninhados
   - Gestão correta de escopo

3. **Compilação Direta e Eficiente**
   - Flex gera analisador léxico em C
   - Bison gera parser LALR(1)
   - Zero dependências externas no executável

4. **Modelo Fisiológico com Inércia**
   - Sensores não mudam instantaneamente
   - Limites fisiológicos realistas
   - SpO2: 80-100%, BPM: 40-160, IVLV: 0-100
   - Atualização a cada instrução executada

5. **VM Implementada do Zero**
   - 209 linhas de Python
   - Parser de assembly próprio
   - Sistema de labels e jumps
   - Proteção contra loops infinitos (--steps)

**Elementos visuais:**
- Ícones técnicos (engrenagens, circuitos)
- Badge: "209 linhas de Python pura"

---

## Slide 12: Ferramentas Utilizadas

**Título:** Stack Tecnológico

**Conteúdo:**

**Compilador:**
- ✅ Flex 2.6+ (analisador léxico)
- ✅ Bison 3.8+ (parser sintático)
- ✅ GCC (compilação C)
- ✅ Makefile (automação)

**Máquina Virtual:**
- ✅ Python 3.x (interpretador)
- ✅ Argparse (CLI)

**Documentação:**
- ✅ EBNF formal
- ✅ Markdown (README + TUTORIAL)
- ✅ Especificação ISA

---

## Slide 13: Estrutura do Repositório

**Título:** Organização do Projeto

**Conteúdo:**
```
HealthLang/
├── compiler/
│   ├── src/          # Flex + Bison → healthlang
│   └── examples/     # 6 protocolos .hl
├── vm/
│   ├── implementacao/ # VitalsVM (vm.py)
│   └── vmasm_files/   # Assembly gerado
├── saidas/           # Logs de execução
├── grammar.ebnf      # Gramática formal
├── README.md         # Documentação
└── TUTORIAL.md       # Guia de uso
```

**Elementos visuais:**
- Árvore de diretórios com cores

---

## Slide 14: Como Usar

**Título:** Workflow Completo

**Conteúdo:**

**1. Compilar o compilador:**
```bash
cd compiler/src && make
```

**2. Compilar um protocolo:**
```bash
./healthlang ../examples/taquicardia.hl \
             ../../vm/vmasm_files/taquicardia.vmasm
```

**3. Executar na VitalsVM:**
```bash
cd ../../vm/implementacao
python3 vm.py ../vmasm_files/taquicardia.vmasm --steps 500
```

**Elementos visuais:**
- Terminal com comandos destacados

---

## Slide 15: Resultados

**Título:** O que foi alcançado?

**Conteúdo:**

✅ **Requisitos do APS:**
- [x] EBNF estruturada
- [x] Flex + Bison funcionais
- [x] VitalsVM própria (Turing-completa)
- [x] 6 exemplos práticos testados
- [x] Documentação completa

✅ **Funcionalidades:**
- Linguagem legível para não-programadores
- Simulação realista de fisiologia
- Suporte a protocolos complexos
- Monitoramento contínuo (loops infinitos)

✅ **Bônus:**
- VitalsVM criada do zero (+1 conceito)

---

## Slide 16: Limitações e Trabalhos Futuros

**Título:** O que pode melhorar?

**Limitações atuais:**
- Não suporta operadores lógicos AND/OR no parser (apenas ifs aninhados)
- Modelo fisiológico simplificado
- Sem persistência de estado
- Sem interface gráfica

**Possíveis extensões:**
- Adicionar mais sensores (pressão arterial, temperatura)
- Implementar variáveis temporárias
- Suporte a funções/procedimentos
- Interface web para visualização em tempo real
- Integração com dispositivos IoT reais

---

## Slide 17: Aplicações Reais

**Título:** Onde isso pode ser usado?

**Cenários potenciais:**

1. **Educação Médica**
   - Treinamento de enfermeiros e médicos
   - Simulação de emergências

2. **Prototipagem de Protocolos**
   - Teste rápido de novos protocolos clínicos
   - Validação antes da implementação real

3. **Sistemas Embarcados**
   - Equipamentos hospitalares automáticos
   - Monitores inteligentes de UTI

4. **Pesquisa**
   - Modelagem de sistemas fisiológicos
   - Estudos de algoritmos de controle

---

## Slide 18: Conclusão

**Título:** HealthLang em Resumo

**Conteúdo:**

**Criamos:**
- ✅ Uma linguagem de programação completa
- ✅ Um compilador funcional (Flex + Bison)
- ✅ Uma VitalsVM Turing-completa
- ✅ Um conjunto robusto de exemplos práticos

**Aprendizados:**
- Design de linguagens de domínio específico
- Compiladores e análise sintática
- Arquitetura de máquinas virtuais
- Modelagem de sistemas complexos

**Impacto:**
- Ponte entre programação e medicina
- Ferramenta educacional e de prototipagem
- Base para sistemas críticos reais

---

## Slide 19: Demonstração ao Vivo (Opcional)

**Título:** Live Demo

**O que mostrar:**
1. Abrir um arquivo `.hl` e explicar o código
2. Compilar com `make` e `./healthlang`
3. Mostrar o `.vmasm` gerado
4. Executar na VitalsVM e mostrar a saída
5. Modificar um parâmetro e rodar novamente

**Dica:** Use o `monitoramento_continuo.hl` para mostrar o loop em ação

---

## Slide 20: Perguntas?

**Título:** Obrigada!

**Conteúdo:**
- **GitHub:** github.com/marinnagc/HealthLang
- **Contato:** [seu email]
- **Documentação completa:** README.md e TUTORIAL.md no repositório

**Elementos visuais:**
- QR code para o repositório
- Ícones de GitHub, email

---

## Dicas Gerais de Design

**Paleta de cores sugerida:**
- Azul escuro: #1E3A5F (profissional, confiança)
- Verde médico: #00A86B (saúde, vida)
- Branco/cinza claro: backgrounds
- Vermelho: alertas/urgências

**Fontes:**
- Títulos: Sans-serif bold (Arial, Helvetica)
- Código: Monospace (Consolas, Courier New)
- Corpo: Sans-serif (Arial, Calibri)

**Elementos visuais:**
- Use ícones de hospitais, monitores, ECG
- Screenshots reais do código e execução
- Diagramas simples e coloridos
- Evite muito texto por slide (máximo 6 bullets)

---

**Tempo estimado:** 15-20 minutos
**Número de slides:** 20 (ajuste conforme o tempo disponível)
