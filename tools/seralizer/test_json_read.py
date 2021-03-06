#!/usr/bin/env python
import os
import os.path
import time
import cPickle as pkl
import numpy as np
import json

root = 'minute.json'

cnt = 0.0
for code in os.listdir(root):
  d = os.path.join(root, code)

  for basename in os.listdir(d):
    fullname = os.path.join(d, basename)

    data = json.loads(open(fullname).read())

    for r in data:
      cnt += r[1] + r[2]

print cnt
