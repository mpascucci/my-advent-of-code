# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np

with open("d11_data.txt") as f:
    lines=f.read()

vals={
      "L":'0',
      "#":'1',
      ".":'2'
}


def encode_lines(l):
    for k,v in vals.items():
        l=l.replace(k,v)
    l=l.split()
    l=[list(line) for line in l]
    data=np.array(l, dtype=int)
    return data


def decode_data(d):
    lines = '\n'.join([''.join(list(l)) for l in d.astype(str)])
    for k,v in vals.items():
        lines=lines.replace(v,k)
    return lines


def look_direction(r, c, direction, data, d):
    rows, cols = data.shape

    if d is not None:
        rmin=max(0,r-d)
        rmax=min(rows-1,r+d)
        cmin=max(0,c-d)
        cmax=min(cols-1,c+d)
    else:
        rmin=0
        rmax=rows-1
        cmin=0
        cmax=cols-1
    
    r+=direction[0]
    c+=direction[1]
    t=2
    
    # print(direction, rmin,rmax,cmin,cmax)
    
    while r>=rmin and r<=rmax and c>=cmin and c<=cmax:
        # print(direction, r,c, data[r,c])
        t=data[r,c]
        if  t != 2:
            break
        r+=direction[0]
        c+=direction[1]
    
    return t

def look_around(row, col, data,d=None):
    obs=np.ones((3,3))*3
    for r in [-1,0,1]:
        for c in [-1,0,1]:
            if r==0 and c==0: continue
            obs[r+1,c+1] = look_direction(row,col,(r,c),data,d)
    
    occ=np.sum(obs==1)
    ept=np.sum(obs==0)
    return occ,ept


def update(data, cr, cc, d, max_occ):
    rows, cols=data.shape
    
    occ,ept=look_around(cr, cc, data, d)

    old=data[cr,cc]

    if old==0 and occ==0:
        new=1
    elif old==1 and occ>=max_occ:
        new=0
    else:
        new=old
    
    # print(f"({cr},{cc}) occ:{occ}-ept:{ept} {old}-->{new}")
        
    return new

def count_occupied(data):
    return np.sum(data==1)




data=encode_lines(lines)
rows, cols=data.shape
new_data=np.empty_like(data)

print("DATA ============")
print(decode_data(data))
i=0
while True:
    i+=1
    for r in range(rows):
        for c in range(cols):
            new_data[r,c]=update(data,r,c,d=1, max_occ=4)
            
    # print(i, "=============")
    # print(decode_data(new_data))
    
    if (new_data==data).all():
        break  
    else:
        data=new_data.copy()
        
    
    # if i==2: break
    
        
print("END ===============")    
# print(decode_data(data))

print(f"Solution 1: {count_occupied(data)} occupied")



data=encode_lines(lines)
rows, cols=data.shape
new_data=np.empty_like(data)

print("DATA ============")
print(decode_data(data))
i=0
while True:
    i+=1
    for r in range(rows):
        for c in range(cols):
            new_data[r,c]=update(data,r,c,d=None, max_occ=5)
            
    # print(i, "=============")
    # print(decode_data(new_data))
    
    if (new_data==data).all():
        break  
    else:
        data=new_data.copy()
        
    
    # if i==2: break
    
        
print("END ===============")    
# print(decode_data(data))

print(f"Solution 1: {count_occupied(data)} occupied")
