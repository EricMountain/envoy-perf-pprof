#!/usr/bin/env python3

import fileinput

func2cycles = {}
for line in fileinput.input():
    if line.find("/usr/local/bin/envoy") == -1:
        continue
    words = line.split()
    cycles = int(words[3])
    func = (words[6].split("+"))[0]
    func2cycles[func] = cycles

for f, c in sorted(func2cycles.items(), key=lambda item: item[1], reverse=True):
    print(f"{c} {f}")
