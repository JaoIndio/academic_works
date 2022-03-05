#!/bin/sh

cd "folder_path"/bin

gcc ../painel.c   -o painel   -lpthread -lm -lrt
gcc ../inversor.c -o inversor -lpthread -lm -lrt
gcc ../monitor.c  -o monitor  -lpthread -lm -lrt

#./painel
