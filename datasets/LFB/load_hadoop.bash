#!/bin/bash
# Load London Fire Brigade data into Hadoop

hadoop_directory=/user/nick/load/lfb/LFB

# set environment
source "$(dirname $0)"/../../env.src

echo Creating directory $hadoop_directory
$HADOOP_HOME/bin/hadoop fs -mkdir $hadoop_directory

echo Loading data into $hadoop_directory
$HADOOP_HOME/bin/hadoop fs -put ./load/* $hadoop_directory

echo Listing $hadoop_directory
$HADOOP_HOME/bin/hadoop fs -ls $hadoop_directory

