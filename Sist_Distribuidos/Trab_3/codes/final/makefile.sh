#!/bin/sh

if [ -e Causal.java ]
then
  javac Causal.java
  javac -d . Causal.java
  mv Causal.java causal.java
  mv Causal.class causal.class
else
  mv causal.java Causal.java
  javac Causal.java
  javac -d . Causal.java
  mv Causal.java causal.java
  mv Causal.class causal.class
fi

javac App.java

