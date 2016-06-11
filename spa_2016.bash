#!/bin/bash
# start or stop Big data services

# set environment
echo
source "$(dirname $0)"/env.src
echo The project directory is $SPA_2016.
echo

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

hadoop_client() {
    client_url='http://localhost:50070/explorer.html#/'
    [ "$(uname)" == Linux ] && sensible-browser $client_url && return
    [ "$(uname)" == Darwin ] && open $client_url && return
    echo 'Not yet supported for Cygwin'
}

[ "$1" == start ] && start && exit
[ "$1" == stop ] && stop && exit
[ "$1" == status ] && status && exit

[ "$1" == hadoop-client ] && hadoop_client && exit
[ "$1" == spark-client ] && $SPARK_HOME/bin/pyspark && exit
[ "$1" == hive-client ] && $SPARK_HOME/bin/beeline -u jdbc:hive2:// --color && exit

echo "Syntax: $0 [ start | stop | status | hadoop-client | spark-client | hive-client ]"
exit 1

