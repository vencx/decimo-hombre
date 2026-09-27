#!/usr/bin/env python3
"""Scans files or folders for personal data and secrets before a copy leaves the machine.
Usage: scan_pii.py <path> [<path> ...] [--extra patterns.txt]
Accepts files AND folders. Last line: 'TOTAL <n>'. rc 0 if n == 0, rc 1 if anything was found.
--extra: file with one regex per line (customer names, own domains…)."""
import pathlib, re, sys

PATS = {
    'telefono': re.compile(r'(?<![\d.])\+?\d{10,13}(?![\d.])'),
    'email': re.compile(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
    'whatsapp_jid': re.compile(r'@s\.whatsapp\.net|@g\.us|@lid\b'),
    'pushName': re.compile(r'pushName', re.I),
    'secreto': re.compile(r'(?i)\b(api[_-]?key|secret|password|token)\b\s*[:=]\s*\S{8,}'),
}

def ficheros(rutas):
    for r in rutas:
        p = pathlib.Path(r)
        if p.is_file():
            yield p
        elif p.is_dir():
            for q in p.rglob('*'):
                if q.is_file() and '.git' not in q.parts:
                    yield q
        else:
            print(f'NOT_FOUND|{r}')
            sys.exit(2)

def main():
    args = sys.argv[1:]
    if '--extra' in args:
        i = args.index('--extra')
        for n, linea in enumerate(pathlib.Path(args[i + 1]).read_text().splitlines()):
            if linea.strip():
                PATS[f'extra{n}'] = re.compile(linea.strip())
        del args[i:i + 2]
    if not args:
        print(__doc__); sys.exit(2)
    tot = 0
    for f in ficheros(args):
        try:
            t = f.read_text(errors='ignore')
        except Exception:
            continue
        for i, linea in enumerate(t.splitlines(), 1):
            for k, rx in PATS.items():
                for m in rx.finditer(linea):
                    tot += 1
                    print(f'{k}|{f}:{i}|{m.group(0)[:40]}')
    print('TOTAL', tot)
    sys.exit(0 if tot == 0 else 1)

main()
