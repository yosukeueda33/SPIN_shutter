#!/bin/bash
spin -a shutter.pml
echo "--------------"
gcc pan.c
echo "--------------"
./a.out -m100000 -N w1
./a.out -m100000 -N w2