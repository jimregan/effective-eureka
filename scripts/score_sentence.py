from transformers import *
from mlm.scorers import MLMScorer, MLMScorerPT
from mlm.models import get_pretrained
import mxnet

model = BertForMaskedLM.from_pretrained("dkleczek/bert-base-polish-uncased-v1")
tokenizer = BertTokenizer.from_pretrained("dkleczek/bert-base-polish-uncased-v1")
vocab = None

scorer = MLMScorerPT(model, vocab, tokenizer, [mxnet.gpu()])

out = open(file="scored", mode="a", encoding="utf-8")
sentences = []
last_id = ''
counter = 1
with open(file="Poleval2020Task1Eval/nbest.txt", mode="r", encoding="utf-8") as nbest:
  for line in nbest:
    words = line.strip().split(' ')
    id = words[0]
    sentence = ' '.join(words[1:])
    score = scorer.score_sentences([sentence])
    out.write('%s\t%s\t%s\n' % (id, sentence, score))
