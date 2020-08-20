import sys
from transformers import *
model = BertForMaskedLM.from_pretrained("dkleczek/bert-base-polish-uncased-v1")
tokenizer = BertTokenizer.from_pretrained("dkleczek/bert-base-polish-uncased-v1")

if len(sys.argv) != 3:
    print("Usage: run-tokeniser.py [lattice] [output]")
    sys.exit()

lat = open(file=sys.argv[1], mode="r", encoding="utf-8")
output = open(file=sys.argv[2], mode="a", encoding="utf-8")
for line in lat:
    if not ' ' in line.strip():
        continue
    else:
        parts = line.strip().split(" ")
        if len(parts) != 4:
            continue
        else:
            word = parts[2]
            toks = tokenizer.tokenize(word)
            output.write("%s\t%s\n" % (word, " ".join(toks)))
