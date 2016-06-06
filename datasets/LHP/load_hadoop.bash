#!/bin/bash
# Load London House Price data into Hadoop

hadoop_directory=/user/nick/load/lhp

# set environment
source "$(dirname $0)"/../../env.src

echo Creating directory $hadoop_directory
$HADOOP_HOME/bin/hadoop fs -mkdir $hadoop_directory

echo Loading data into $hadoop_directory
echo $HADOOP_HOME/bin/hadoop fs -put ./load/* $hadoop_directory
$HADOOP_HOME/bin/hadoop fs -put ./load/* $hadoop_directory

echo Listing $hadoop_directory
$HADOOP_HOME/bin/hadoop fs -ls $hadoop_directory

