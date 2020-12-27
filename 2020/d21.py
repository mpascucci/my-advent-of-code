#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 21 14:02:15 2020

@author: marco
"""
import re
from collections import namedtuple

class Data_line:
    def __init__(self,i,a):
        self.i=i
        self.a=a

    def __repr__(self):
        return f"{str(self.i)} : {str(self.a)}"

def parse_line(line):
    regex=r"^(.+)\s\(contains\s(.+)\)$" 
    ingrs, algs = re.match(regex, line).groups()
    ingrs=[ing.strip() for ing in ingrs.split(' ')]
    algs=[alg.strip() for alg in algs.split(',')]
    
    return Data_line(set(ingrs), set(algs))



def eliminable(dl1,dl2):
    """check if an ingredient can be identified in two lines.
    Returns a tuple of sets (name, identification)
    """
    
    i1=dl1.i
    i2=dl2.i
    a1=dl1.a
    a2=dl2.a

    inter_a = a1.intersection(a2)
    inter_i = i1.intersection(i2)

    if inter_a and inter_i and len(inter_a) == len(inter_i):
       return inter_i, inter_a
    else:
        return None


# load data
with open("d21_data.txt") as f:
    lines=f.read().strip().split('\n')
    
lines=[parse_line(line) for line in lines]
    
n=len(lines)

allergenes=set()

for line in lines:
    allergenes=allergenes.union(line.a)
    
algs={}
end=False
while not end:
    end=True
    for name in allergenes:
        for line in lines:
            if len(line.a) > 0:
                end=False
            if name in line.a:
                if name not in algs.keys():
                    algs[name]=line.i
                else:
                    algs[name]=algs[name].intersection(line.i)
                   
    for k,v in algs.items():
        if len(v) == 1:
            for line in lines:
                line.a=line.a-{k}
                line.i=line.i-v

safe=set()
s1=0
for line in lines:    
    s1+=len(line.i)
    safe=safe.union(line.i)

print("Allergenes", algs)
print("non allergenes:", safe)
print("solution 1:", s1)


#%%

keys=sorted(algs.keys())
print(keys)
ings=[]
for k in keys:
    ings.append(str(next(iter(algs[k]))))
print("Solution2:", ','.join(ings))