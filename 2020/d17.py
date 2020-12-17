#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 14:22:31 2020

@author: marco
"""

import numpy as np
from multiprocessing import Pool
from functools import partial
import itertools

with open("d17_data.txt") as f:
    lines=f.read()

vals={
      "#":'1',
      ".":'0'
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
    
    
def grow(ndarray):
    s = np.array(ndarray.shape)
    nv = np.zeros(s+2, dtype=int)
    slc = [slice(None)] * len(s)
    for i in range(len(s)):
        slc[i] = slice(1,-1)
    nv[tuple(slc)] = ndarray.data
    return nv

def count_nbrs(ndarray, voxel):
    s = np.array(ndarray.shape)
    assert (s-np.array(voxel) > 0).all()
    
    voxel=np.array(voxel)
    # list the neighbours coordinates
    dim=voxel.shape[0]
    nbs_coord = np.array(list(itertools.product([0,1,2], repeat=dim))) - 1
    
    # print(nbs_coord)
    
    # remove the center (0,0,0)
    filt=np.apply_along_axis(lambda x: (x!=0).any(), 1, nbs_coord)
    nbs_coord = nbs_coord[filt]
    
    # recenter on voxel
    nbs_coord += voxel
    
    #filter negative coordinates and out of range
    filt=np.apply_along_axis(lambda x: (x>=0).all(), 1, nbs_coord)
    filt*=np.apply_along_axis(lambda x: (s-x > 0).all(), 1, nbs_coord)
    nbs_coord = nbs_coord[filt]
    
    actives=0
    for c in nbs_coord:
        actives+=getelement(ndarray,c).item()
        
    inactives=len(nbs_coord)-actives
    
    return actives, inactives

def apply_rules(status, actives, inactives):
    # print(status, actives, inactives)
    if status==1:
        if actives != 2 and actives != 3:
            status=0
    else:
        if actives==3:
            status=1
    # print("--->", status)
    return status

def myslice(v, axis, start, end):
    # select a slice of v along the given axis
    slc = [slice(None)] * len(v.shape)
    slc[axis] = slice(start,end)
    return v[tuple(slc)]

def getelement(ndarray, point):
    # get an element from an ndarray
    v=ndarray
    s=v.shape
    assert len(s)==len(point), "Invalid coordinate"
    assert (s-np.abs(point) > 0).all()
    slc = [slice(None)] * len(s)
    for i in range(len(s)):
        slc[i] = slice(point[i],point[i]+1)
    return v[tuple(slc)]

def reduce_volume(ndarray):
    # crops the array in n dimensions eliminating zeros
    v=ndarray.copy()
    s = v.shape
    
    for axis in range(len(s)):
        while True:
            if (myslice(v,axis,0,1)==0).all():
                v=myslice(v,axis,1,None)
            else:
                break
        while True:
            if (myslice(v,axis,-1,None)==0).all():
                v=myslice(v,axis,None,-1)
            else:
                break
    return v
        

def update_loop(c,v):
    status=getelement(v,c).item()
    actives, inactives = count_nbrs(v, c)
    status=apply_rules(status, actives, inactives)
    return (c,status)
       

def update(ndarray):
    v=ndarray
    nv=np.empty_like(ndarray)
    s = v.shape
    coords = np.indices(s).T.reshape(np.product(s),-1)
    f=partial(update_loop, v=v)
    with Pool(4) as p:
        result = p.map(f, coords)
    for c,status in result:
        x=getelement(nv,c)
        x.itemset(status) 
    return nv

volume=encode_lines(lines)
volume=volume.reshape(1,1,*volume.shape)

for i in range(6):
    print("cycle",i+1)
    # print(volume)
    volume=grow(volume)
    volume=update(volume)
    volume=reduce_volume(volume)
    # print(volume)
    
print(np.sum(volume))

    
# print(volume)
# volume=grow(volume)
# volume=update(volume)
# volume=reduce_volume(volume)
# volume=grow(volume)
# volume=update(volume)
# volume=reduce_volume(volume)
# print(volume)
# print(count_nbrs(volume,(2,2,2,2)))


