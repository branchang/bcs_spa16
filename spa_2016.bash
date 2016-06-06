#!/bin/bash
# start or stop Big data services

# set environment
source "$(dirname $0)"/env.src
echo The project directory is $SPA_2016.
echo

start() {
    echo ''
    echo '===> Starting Hadoop...'
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start secondarynamenode 
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
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

stop() {
    echo ''
    echo '===> Stopping Hive...'
    pid="$(ps -e | grep HiveServer2 | grep -v 'grep ' | awk '{print $1}')"
    if [ "$pid" == "$pid" ]; then
        echo Killing Hive process $pid
        kill $pid
    fi
    echo ''
    echo '===> Stopping Spark...'
    $SPARK_HOME/sbin/stop-all.sh
    echo ''
    echo '===> Stopping Hadoop...'
    $HADOOP_PREFIX/sbin/stop-dfs.sh
}

status() {
    echo 'Hadoop and Spark Processes:'
    jps="$(which jps 2>/dev/null)"
    [ -z "$jps" ] && jps=$JAVA_HOME/bin/jps
    $jps | grep -v Jps | sort -k 2
    echo 'Hive Process:'
    ps -e | grep HiveServer | grep -v 'grep '
    echo
}

[ "$1" == start ] && start && exit
[ "$1" == stop ] && stop && exit
[ "$1" == status ] && status && exit
[ "$1" == spark-client ] && $SPARK_HOME/bin/pyspark && exit
[ "$1" == hive-client ] && $SPARK_HOME/bin/beeline -u jdbc:hive2:// --color && exit

echo "Syntax: $0 [ start | stop | status | spark-client | hive-client ]"
exit 1

