#!/usr/bin/env python3
"""
VitalsVM - Máquina Virtual para HealthLang
===========================================

VM Turing-completa customizada para simulação de protocolos clínicos.
Inspirada em Minsky Machines com modelo fisiológico integrado.

Autora: Marinna Grigolli Cesar
Insper - Engenharia da Computação - 2025.2
"""
import sys
import math
import argparse
from typing import List, Tuple, Dict, Any

REGS = {"O2", "IV"}
SENSORS = {"S_SPO2", "S_BPM", "S_IVLV"}

def clamp(v, lo, hi):
    return max(lo, min(hi, v))

def parse_program(lines: List[str]) -> Tuple[List[Tuple[str, List[str]]], Dict[str, int]]:
    prog: List[Tuple[str, List[str]]] = []
    labels: Dict[str, int] = {}

    # 1ª passagem: normaliza linhas e captura labels
    for line in lines:
        # tira comentários ; ou # (assemble estilo “; ...”)
        if ";" in line:
            line = line.split(";", 1)[0]
        if "#" in line:
            line = line.split("#", 1)[0]
        line = line.strip()
        if not line:
            continue

        # pode haver "label:" e instrução na mesma linha
        while True:
            colon = line.find(":")
            if colon == -1:
                break
            label = line[:colon].strip()
            if not label:
                break
            if label in labels:
                raise ValueError(f"Label duplicado: {label}")
            labels[label] = len(prog)
            line = line[colon+1:].strip()
            if not line:
                break

        if not line:
            continue

        parts = line.split()
        op = parts[0].upper()
        args = parts[1:]
        prog.append((op, args))

    return prog, labels

def resolve_arg(arg: str, labels: Dict[str, int]):
    # converte rótulo para PC (índice de instrução), ou int, ou string
    if arg in labels:
        return labels[arg]
    try:
        return int(arg)
    except ValueError:
        return arg  # registrador/sensor/ident

def step_towards(current: int, target: int, max_delta: int) -> int:
    """Move 'current' em direção a 'target' no máximo max_delta por tick."""
    if current < target:
        return min(current + max_delta, target)
    if current > target:
        return max(current - max_delta, target)
    return current
def update_sensors(regs: Dict[str, int], sens: Dict[str, int]):
    # Targets simples baseados em O2 e IV
    o2 = regs["O2"]
    iv = regs["IV"]

    # SpO2 vai de ~85 até 100 dependendo de O2
    target_spo2 = 85 + o2 // 5      # O2 0 -> 85, O2 100 -> 105 (~100)
    target_spo2 = clamp(target_spo2, 80, 100)

    # Volume intravenoso tende ao valor do registrador IV
    target_ivlv = clamp(iv, 0, 100)

    # Batimento cai conforme IV sobe (mais volume -> FC menor)
    target_bpm = 120 - iv // 2      # IV 0 -> 120, IV 100 -> 70
    target_bpm = clamp(target_bpm, 40, 160)

    # Agora andamos devagar na direção do alvo
    sens["S_SPO2"] = step_towards(sens["S_SPO2"], target_spo2, max_delta=1)
    sens["S_IVLV"] = step_towards(sens["S_IVLV"], target_ivlv, max_delta=2)
    sens["S_BPM"]  = step_towards(sens["S_BPM"],  target_bpm,  max_delta=1)


def run(prog: List[Tuple[str, List[str]]], labels: Dict[str, int], step_limit: int = 100000):

    regs = {"O2": 0, "IV": 0}
    sens = {"S_SPO2": 95, "S_BPM": 80, "S_IVLV": 50}  # valores padrão conforme especificação
    stack: List[int] = []

    pc = 0
    steps = 0

    def get_reg(name: str) -> str:
        up = name.upper()
        if up not in REGS:
            raise ValueError(f"Registrador inválido: {name}")
        return up

    while 0 <= pc < len(prog):
        if steps >= step_limit:
            raise RuntimeError(f"Step limit atingido ({step_limit}). Possível loop infinito.")
        op, args = prog[pc]

        # Execução
        if op == "SET":
            # SET R n
            r = get_reg(args[0])
            n = int(args[1])
            regs[r] = n
            pc += 1

        elif op == "INC":
            r = get_reg(args[0])
            regs[r] += 1
            pc += 1

        elif op == "DECJZ":
            # DECJZ R label
            r = get_reg(args[0])
            regs[r] -= 1
            if regs[r] == 0:
                target = resolve_arg(args[1], labels)
                if not isinstance(target, int):
                    raise ValueError(f"Label desconhecido: {args[1]}")
                pc = target
            else:
                pc += 1

        elif op == "GOTO":
            target = resolve_arg(args[0], labels)
            if not isinstance(target, int):
                raise ValueError(f"Label desconhecido: {args[0]}")
            pc = target

        elif op == "PRINT":
            # PRINT id   (id pode ser O2, IV, S_SPO2, S_BPM, S_IVLV)
            name = args[0].upper()
            if name in regs:
                print(f"{name}={regs[name]}")
            elif name in sens:
                print(f"{name}={sens[name]}")
            else:
                print("PRINT:", *args)
            pc += 1

        elif op == "PUSH":
            r = get_reg(args[0])
            stack.append(regs[r])
            pc += 1

        elif op == "POP":
            r = get_reg(args[0])
            if not stack:
                raise RuntimeError("Stack underflow em POP")
            regs[r] = stack.pop()
            pc += 1

        elif op == "GET":
            # GET S_SPO2 O2
            s_name = args[0].upper()
            r = args[1].upper()
            if s_name not in sens: raise ValueError("Sensor inválido")
            if r not in regs: raise ValueError("Registrador inválido")
            regs[r] = sens[s_name]
            pc += 1

        elif op == "CJMP":
            # CJMP S_SPO2 LT 95 label_true
            s_name = args[0].upper()
            opstr  = args[1].upper()
            num    = int(args[2])
            target = resolve_arg(args[3], labels)
            if s_name not in sens or not isinstance(target, int):
                raise ValueError("CJMP inválido")
            sval = sens[s_name]
            cond = {
                "LT": sval <  num,
                "LE": sval <= num,
                "GT": sval >  num,
                "GE": sval >= num,
                "EQ": sval == num,
                "NE": sval != num,
            }[opstr]
            pc = target if cond else pc + 1


        elif op == "HALT":
            break

        else:
            raise ValueError(f"Instrução desconhecida: {op}")

        # Atualiza sensores a cada tick
        update_sensors(regs, sens)
        steps += 1
        # Exibe "ticks" a cada 100 ciclos para simular o tempo passando
        if steps % 100 == 0:
            print(f"--- ciclo {steps} ---")


def main():
    ap = argparse.ArgumentParser(description="VitalsVM – interpretador de assembly .vmasm")
    ap.add_argument("file", help="caminho para arquivo .vmasm")
    ap.add_argument("--steps", type=int, default=100000, help="limite de passos (anti-loop infinito)")
    args = ap.parse_args()

    with open(args.file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    prog, labels = parse_program(lines)
    run(prog, labels, step_limit=args.steps)

if __name__ == "__main__":
    main()
