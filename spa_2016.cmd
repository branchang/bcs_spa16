:: Name:    spa_2016.cmd
:: Purpose: Windows script to start / stop Big Data services
:: Author:  Nick Rozanski
:: Syntax:  spa_2016.cmd [ start | stop | status | spark_client | hive_client ]
 
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET script=%~n0
SET command=%~1
for /F "tokens=2 delims=:" %%i in ('"ipconfig | findstr IPv4"') do SET IP_ADDRESS=%%i
SET IP_ADDRESS=%IP_ADDRESS: =%
REM see http://superuser.com/questions/230233/how-to-get-lan-ip-to-a-variable-in-a-windows-batch-file
REM if the above doesn't work do SET IP_ADDRESS=nnn.nnn.nnn.nnn
ECHO IP address is %IP_ADDRESS%.
 
CALL env.cmd

IF "%command%" == "start"  (CALL :start_all  && EXIT /B 0)
IF "%command%" == "stop"   (CALL :stop_all   && EXIT /B 0)
IF "%command%" == "status" (CALL :status_all && EXIT /B 0)

IF "%command%" == "spark_client" (CALL :spark_client && EXIT /B 0)
IF "%command%" == "hive_client"  (CALL :hive_client && EXIT /B 0)

ECHO Syntax: spa_2016.cmd [ start / stop / status / spark_client / hive_client ]

ENDLOCAL
ECHO ON
@EXIT /B 0

:: ======================
:: Start Functions
:: ======================
 
:start_all
CALL :start_hadoop || GOTO :start_failed
CALL :start_spark  || GOTO :start_failed
CALL :start_hive   || GOTO :start_failed
ECHO Java processes:
%JAVA_HOME%\bin\jps.exe
EXIT /B 0
:start_failed
EXIT /B 1
 
:: ----------------------
:start_hadoop
ECHO %script%: Starting Hadoop
CALL start-dfs.cmd || (ECHO %script%: Failed to start Hadoop HDFS, error=%ERRORLEVEL%)
ECHO %script%: Started HDFS
CALL :sleep 5
CALL start-yarn.cmd || (ECHO %script%: Failed to start Hadoop YARN, error=%ERRORLEVEL%)
ECHO %script%: Started YARN
EXIT /B 0
 
:: ----------------------
:start_spark
ECHO %script%: Starting Spark
start spark\bin\spark-class.cmd org.apache.spark.deploy.master.Master || (ECHO %script%: Failed to start Spark Master, error=%ERRORLEVEL%)
ECHO %script%: Started Spark Master on %IP_ADDRESS%
CALL :sleep 5
start spark\bin\spark-class.cmd org.apache.spark.deploy.worker.Worker spark://%IP_ADDRESS%:7077 || (ECHO %script%: Failed to start Spark Worker, error=%ERRORLEVEL%)
ECHO %script%: Started Spark Worker on %IP_ADDRESS%
EXIT /B 0
 
:: ----------------------
:start_hive
ECHO %script%: Starting Hive
REM ++ start Hive ++ || (ECHO %script%: Failed to start Hive server, error=%ERRORLEVEL%)
REM ?? C:\cygwin\bin\bash hiveserver2 ??
EXIT /B 0
 
:: ======================
:: Stop Functions
:: ======================
 
:stop_all
ECHO %script%: Stopping Hadoop
CALL %SPA_2016%\hadoop\sbin\stop-dfs.cmd ||  (ECHO %script%: Failed to stop Hadoop DFS, error=%ERRORLEVEL%)
CALL %SPA_2016%\hadoop\sbin\stop-yarn.cmd || (ECHO %script%: Failed to stop Hadoop YARN, error=%ERRORLEVEL%)
ECHO PLEASE CLOSE SPARK WINDOWS
ECHO PLEASE CLOSE HIVE WINDOWS
REM Don't know how to do that yet...
ECHO Java processes:
%JAVA_HOME%\bin\jps.exe
EXIT /B 0

:: ======================
:: Status Functions
:: ======================
 
:status_all
ECHO Java processes:
%JAVA_HOME%\bin\jps.exe
EXIT /B 0
 
:: ======================
:: Client Functions
:: ======================
 
:spark_client
ECHO %script%: Running Spark client
ECHO Press Control-D to quit
spark\bin\spark-shell.cmd
EXIT /B 0

:hive_client
ECHO %script%: Running Hive client
ECHO Press Control-D to quit
ECHO NOT WRITTEN YET
EXIT /B 0

:: ======================
:: Utility Functions
:: ======================
 
:sleep
ECHO %script%: Sleeping for %1 seconds
PING.EXE -N %~1 127.0.0.1 > NULL
EXIT /B 0
