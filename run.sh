#!/bin/bash
spin -a shutter.pml
echo "--------------"
gcc pan.c
echo "--------------"
./a.out -m100000