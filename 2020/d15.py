#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 21 19:28:25 2020

@author: marco
"""

start_seq="11,18,0,20,1,7,16"
# start_seq="0,3,6"
# start_seq="3,1,2"

hist=[int(x) for x in start_seq.split(',')]

index={k:v for k,v in zip(hist,range(len(hist)))}


for i in range(len(hist)-1, 30000000):
    n = hist[i]
    
    last=index.get(n,None)
    if last is not None:
        next_n = i-last
    else:
        next_n = 0
    
    hist.append(next_n)
    index[n] = i

print(hist[-2])