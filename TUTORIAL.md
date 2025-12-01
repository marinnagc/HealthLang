# Tutorial - Como Compilar e Executar HealthLang

Este tutorial mostra o passo a passo completo para compilar programas HealthLang e executá-los na VitalsVM.

---

## Pré-requisitos

Certifique-se de ter instalado:
- **GCC** (compilador C)
- **Flex** (gerador de analisadores léxicos)
- **Bison** (gerador de parsers)
- **Python 3** (para executar a VM)

### Instalação no Ubuntu/Debian:
```bash
sudo apt-get install gcc flex bison python3
```

### Instalação no macOS:
```bash
brew install gcc flex bison python3
```

---

## Passo 1: Compilar o Compilador HealthLang

Primeiro, você precisa gerar o executável do compilador a partir dos arquivos Flex e Bison.

```bash
cd compiler/src
make clean  # limpa arquivos anteriores (opcional)
make        # compila o compilador
```

Isso irá gerar o executável `healthlang` no diretório `compiler/src/`.

**O que acontece:**
- `flex lexer.l` → gera o analisador léxico
- `bison -d parser.y` → gera o analisador sintático
- `gcc` → compila tudo e gera o executável `healthlang`

---

## Passo 2: Compilar um Programa HealthLang

Agora você pode compilar um programa `.hl` para assembly `.vmasm`.

### Sintaxe:
```bash
./healthlang <arquivo_entrada.hl> <arquivo_saida.vmasm>
```

### Exemplo - Compilar um único arquivo:
```bash
cd compiler/src
./healthlang ../examples/taquicardia.hl ../../vm/vmasm_files/taquicardia.vmasm
```

### Exemplo - Compilar todos os exemplos:
```bash
cd compiler/src
for f in ../examples/*.hl; do
  ./healthlang "$f" "../../vm/vmasm_files/$(basename $f .hl).vmasm"
done
```

---

## Passo 3: Executar na VitalsVM

Agora você pode executar o arquivo `.vmasm` na máquina virtual.

### Sintaxe:
```bash
python3 vm.py <arquivo.vmasm> [--steps LIMITE]
```

- `--steps LIMITE`: define o número máximo de instruções a executar (padrão: 100000)

### Exemplo - Executar um programa:
```bash
cd vm/implementacao
python3 vm.py ../vmasm_files/taquicardia.vmasm --steps 500
```

### Exemplo - Executar com mais passos (para loops longos):
```bash
python3 vm.py ../vmasm_files/monitoramento_continuo.vmasm --steps 5000
```

---

## Passo 4: Salvar Saídas em Arquivos

Você pode redirecionar a saída para um arquivo de texto.

### Exemplo - Salvar saída de um programa:
```bash
cd vm/implementacao
python3 vm.py ../vmasm_files/oxigenio.vmasm --steps 1000 > ../../saidas/saida_oxigenio.txt
```

### Exemplo - Executar todos e salvar saídas:
```bash
cd vm/implementacao
for f in ../vmasm_files/*.vmasm; do
  nome=$(basename "$f" .vmasm)
  python3 vm.py "$f" --steps 1000 > "../../saidas/saida_${nome}.txt" 2>&1
done
```

---

## Fluxo Completo de Trabalho

### 1. Escrever código HealthLang
Crie um arquivo `.hl` em `compiler/examples/`:

```c
// meu_protocolo.hl
if (batimento > 120) {
    ajustar_soro(50);
    alerta();
    log(batimento);
}
```

### 2. Compilar para assembly
```bash
cd compiler/src
./healthlang ../examples/meu_protocolo.hl ../../vm/vmasm_files/meu_protocolo.vmasm
```

### 3. Executar na VM
```bash
cd ../../vm/implementacao
python3 vm.py ../vmasm_files/meu_protocolo.vmasm --steps 500
```

### 4. Ver a saída
```bash
python3 vm.py ../vmasm_files/meu_protocolo.vmasm --steps 500 > ../../saidas/saida_meu_protocolo.txt
cat ../../saidas/saida_meu_protocolo.txt
```

---

## Exemplos Disponíveis

O repositório já vem com 6 exemplos prontos:

| Arquivo                      | Descrição                                          |
| ---------------------------- | -------------------------------------------------- |
| `taquicardia.hl`             | Detecção simples de taquicardia                    |
| `oxigenio.hl`                | Ajuste de oxigenioterapia com loop                 |
| `soro.hl`                    | Reposição de volume até atingir meta               |
| `desidratacao.hl`            | Simulação de perda de volume progressiva           |
| `choque_hipovolemico.hl`     | Protocolo com múltiplas condições aninhadas        |
| `monitoramento_continuo.hl`  | Loop infinito simulando monitoramento 24/7 de UTI  |

### Para compilar e executar todos os exemplos:
```bash
# Compilar todos
cd compiler/src
for f in ../examples/*.hl; do
  ./healthlang "$f" "../../vm/vmasm_files/$(basename $f .hl).vmasm"
done

# Executar todos e salvar saídas
cd ../../vm/implementacao
for f in ../vmasm_files/*.vmasm; do
  nome=$(basename "$f" .vmasm)
  echo "Executando $nome..."
  python3 vm.py "$f" --steps 1000 > "../../saidas/saida_${nome}.txt" 2>&1
done
```

---

## Debugging e Solução de Problemas

### Erro: "Parse error at line X"
- Verifique a sintaxe do seu arquivo `.hl`
- Certifique-se de que todas as condições estão entre parênteses
- Verifique se há ponto-e-vírgula após comandos

### Erro: "Step limit atingido"
- Seu programa tem um loop infinito (pode ser intencional)
- Aumente o `--steps` para permitir mais execuções
- Exemplo: `--steps 10000`

### Erro: "Label desconhecido"
- Problema na compilação
- Recompile o compilador com `make clean && make`
- Recompile seu programa `.hl`

### Ver o assembly gerado:
```bash
cat vm/vmasm_files/seu_programa.vmasm
```

---

## Estrutura de Diretórios

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

## Referências

- **README.md**: Visão geral da linguagem e sua motivação
- **grammar.ebnf**: Especificação formal da gramática
- **vm/vmasm_spec.md**: Especificação da máquina virtual e ISA

---

**Marinna Grigolli Cesar**  
Engenharia da Computação — Insper  
2025.2
