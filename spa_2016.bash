#!/bin/bash
# Name:    spa_2016.bash
# Purpose: start or stop Big data services, run Big Data tools
# Author:  Nick Rozanski
# Syntax:  spa_2016.bash  start | stop | status | init_metastore | hadoop_browser | pyspark | beeline
# Notes:   

# set environment
source "$(dirname $0)"/env.src
IP_ADDRESS="$(ifconfig | grep 'inet ' | tail -1 | awk '{print $2}')"

echo
echo The project directory is $SPA_2016.
echo Your IP address seems to be $IP_ADDRESS.
echo

# start all services
start() {
    echo '===> Starting Hadoop...'
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start secondarynamenode 
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
    $HADOOP_PREFIX/sbin/start-yarn.sh
    echo ''
    echo '===> Starting Spark...'
    $SPARK_HOME/sbin/start-master.sh
    $SPARK_HOME/sbin/start-slaves.sh spark://localhost:7077
    echo ''
    echo '===> Starting Hive...'
    hive_log_file=$SPA_2016/logs/hive.log
    echo Hive log file is $hive_log_file
    nohup $HIVE_HOME/bin/hive --service hiveserver2 > $hive_log_file 2>&1 &
}

# stop all services
stop() {
    echo '===> Stopping Hive...'
    pid="$(ps -e | grep HiveServer2 | grep -v 'grep ' | awk '{print $1}')"
    if [ -n "$pid" ]; then
       if [ "$pid" -eq "$pid" ]; then
          echo Killing Hive process $pid
          kill $pid
       fi
    else
        echo "Could not find Hive process (try jps and look for RunJar)"
    fi
    echo ''
    echo '===> Stopping Spark...'
    $SPARK_HOME/sbin/stop-all.sh
    echo ''
    echo '===> Stopping Hadoop...'
    $HADOOP_PREFIX/sbin/stop-yarn.sh
    $HADOOP_PREFIX/sbin/stop-dfs.sh
}

# display status
status() {
    echo 'Hadoop and Spark Processes:'
    jps="$(which jps 2>/dev/null)"
    [ -z "$jps" ] && jps=$JAVA_HOME/bin/jps
    $jps | grep -v Jps | sort -k 2
    echo
    echo 'Hive Process:'
    ps -e | grep HiveServer | grep -v 'grep '
    echo
}

# initialise the Hive metastore
init_metastore() {
    echo 'Initialising Hive Metastore (press enter to continue) or Control-C to abort'
    read press_enter
    hive_data_dir=$SPA_2016/data/hive
    mkdir $hive_data_dir
    rm -rf $hive_data_dir/*
    cd $hive_data_dir
    $HIVE_HOME/bin/schematool -initSchema -dbType derby
    echo 'Initialising Hive Metastore complete.'
}

# open Hadoop file explorer in browser
hadoop_browser() {
    client_url='http://localhost:50070/explorer.html#/'
    [ "$(uname)" == Linux ] && (sensible-browser $client_url &)
    [ "$(uname)" == Darwin ] && (open $client_url &)
    echo Opened Hadoop client URL $client_url
}

[ "$1" == start ]  && start && exit
[ "$1" == stop ]   && stop && exit
[ "$1" == status ] && status && exit

[ "$1" == init_metastore ] && init_metastore && exit

[ "$1" == hadoop_browser ] && hadoop_browser && exit
[ "$1" == pyspark ]        && $SPARK_HOME/bin/pyspark --master spark://$IP_ADDRESS:7077 && exit
[ "$1" == beeline ]        && $SPARK_HOME/bin/beeline -u jdbc:hive2:// --color && exit

echo "Syntax: $0 start | stop | status | init_metastore | hadoop_client | pyspark | beeline"
exit 1

