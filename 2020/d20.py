#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 14:22:31 2020

@author: marco
"""

import numpy as np
from functools import partial, reduce

class Tile:
        def __init__(self, data):
            self.id=int(data[0][5:-1])
            self.data=encode(data[1])
            self.matches=[]
            self.nbrs=np.zeros(4,dtype=int) # r t l b
        def __repr__(self):
            return f"Tile {self.id}\n{decode(self.data)}"
        
        @property
        def t(self):
                return self.data[0,:]

        @property
        def b(self):
                return self.data[-1,:]

        @property
        def l(self):
                return self.data[:,0]

        @property
        def r(self):
                return self.data[:,-1]   
            
        @property
        def sides(self):
            return np.array([self.r,self.t,self.l,self.b])
        
        
        def rot90(self):
            """rotate counterclockwise"""
            self.data = np.rot90(self.data)
            self.nbrs = np.roll(self.nbrs,1)
        def flip(self):
            self.data = np.flip(self.data, axis=1)
            self.nbrs = np.flip(self.nbrs)
        
vals={
      "#":'1',
      ".":'0',
      '\x1b[32m$\x1b[m':'2'
}

def encode(l):
    for k,v in vals.items():
        l=l.replace(k,v)
    l=l.strip()
    l=l.split('\n')
    l=[list(line) for line in l]
    data=np.array(l, dtype=int)
    return data


def decode(d):
    lines = '\n'.join([''.join(list(l)) for l in d.astype(str)])
    for k,v in vals.items():
        lines=lines.replace(v,k)
    return lines

def get_tile(num):
    """return a tile given it's id"""
    for t in tiles:
        if t.id==num:
            return t
    raise ValueError("Tile not vound")

def match_side(side,tile):
    return (np.all(side == tile.sides, axis=1).any() or
            np.all(side == np.flip(tile.sides), axis=1).any())

def match(ta,tb):
    right = match_side(ta.r, tb)
    top = match_side(ta.t, tb)
    left = match_side(ta.l, tb)
    bottom = match_side(ta.b, tb)
    return [right, top, left, bottom]

# load data
with open("d20_data.txt") as f:
    lines=f.read()  

data=[x.split('\n',1) for x in lines.split('\n\n')]

# create the tiles
tiles=[Tile(d) for d in data]

ids=np.array([tile.id for tile in tiles])

# index the tiles.
# keys are tile ID, values are tiles
tiles_dict={ tile.id:tile for tile in tiles}

#%%
n=len(tiles)
match_matrix=np.zeros((n,n))

for i in range(n):
    for j in range(i+1,n):
        ti=tiles[i]
        tj=tiles[j]
        matches=match(ti, tj)
        if np.any(matches):
            match_matrix[i,j]=1
            match_matrix[j,i]=1
            ti.matches.append(tj.id)
            tj.matches.append(ti.id)
    
matches = np.sum(match_matrix, axis=0)
corners = ids[ np.sum(match_matrix,axis=0)==2]
sides = ids[ np.sum(match_matrix,axis=0)==3]

print("corners:", len(corners))
p = len(sides) + len(corners)*2
s = len(tiles)
print("perimeter:", p)
print("surface:", s)

d1=p/4+0.5*np.sqrt(p**2/4-4*s)
d2=p/2-d1
assert d1==d2
d=int(d1)
print("dimension:", d)

print("Solution1:", corners.prod())

#%%

def fill_nbrs(tile):
    for i in tile.matches:
        ti=tiles_dict[i]
        tile.nbrs[match(tile,ti)]=ti.id

c0=tiles_dict[corners[0]]
t0=tiles_dict[c0.matches[0]]
t1=tiles_dict[c0.matches[1]]

#c0.flip()

fill_nbrs(c0)


# set c0 as top left corner
while np.any( c0.nbrs[1:3] != np.zeros(2) ):
    c0.rot90()


print(c0)
#%%

def adjust_r(tile):
    """rotate and flip tile's right neigbourh to match"""
    if tile.nbrs[0] == 0:  return
    tr=tiles_dict[tile.nbrs[0]]
    if np.all(tile.r==tr.l): return
    for i in range(3):
        tr.rot90()
        if np.all(tile.r==tr.l): return
    tr.flip()
    if np.all(tile.r==tr.l): return
    for i in range(3):
        tr.rot90()
        if np.all(tile.r==tr.l): return

def adjust_b(tile):
    """rotate and flip tile's bottom neigbourh to match"""
    if tile.nbrs[-1] == 0 :  return
    tr=tiles_dict[tile.nbrs[-1]]
    if np.all(tile.b==tr.t): return
    for i in range(3):
        tr.rot90()
        if np.all(tile.b==tr.t): return
    tr.flip()
    if np.all(tile.b==tr.t): return
    for i in range(3):
        tr.rot90()
        if np.all(tile.b==tr.t): return

mosaic=np.zeros((d,d), dtype=int)

mosaic[0,0]=c0.id

for i in range(d):
   for j in range(d):
       tile=tiles_dict[mosaic[i,j]]
       adjust_r(tile)
       adjust_b(tile)
       rn=tile.nbrs[0]
       bn=tile.nbrs[-1]
       if rn != 0:
           fill_nbrs(tiles_dict[rn])
           mosaic[i,j+1] = rn
       if bn != 0:
           fill_nbrs(tiles_dict[bn])
           mosaic[i+1,j] = bn


#%%
def get_picture(mosaic):
    d=len(mosaic)
    n=len(c0.data)-2
    s=np.zeros((n*d, n*d), dtype=int)
    for i in range(d):
        for j in range(d):
            data=tiles_dict[mosaic[i,j]].data
            s[n*i:n*(i+1), n*j:n*(j+1)] = data[1:-1,1:-1]
    return(s)

picture=get_picture(mosaic)
# picture=picture.T
picture=np.flip(picture)
#picture=np.rot90(picture)
#picture=np.rot90(picture)
#picture=np.rot90(picture)

monster="""                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """.replace(' ','.')


def remove_monster(i, j, monster):
    """changes # into 2 if a moster is found"""
    r,c=monster.shape
    area=picture[i:i+r,j:j+c]
    #print(decode(area))
    #print("---")
    #print(decode(monster))
    if((np.logical_and(area,monster)==monst).all()):
        #print("monster!")
        picture[i:i+r,j:j+c][monst==1]=2    
        return 1
    else :
        return 0

monst=encode(monster)
print(decode(picture))
r,c=monst.shape

monsters=0
for i in range(len(picture)-r):
    for j in range(len(picture)-c):
        monsters+=remove_monster(i, j, monst)

print(decode(picture))
print("monsters:", monsters)
print("Solution2", sum(sum(picture==0)))
