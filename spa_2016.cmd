:: Name:    spa_2016.cmd
:: Purpose: Windows script to start / stop Big Data services
:: Author:  Nick Rozanski
:: Syntax:  spa_2016.cmd start | stop | status | init_metastore | hadoop_browser | spark_shell | beeline

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

IF "%command%" == "init_metastore" (CALL :init_metastore && EXIT /B 0)

IF "%command%" == "hadoop" (CALL :hadoop && EXIT /B 0)

IF "%command%" == "hadoop_browser" (CALL :hadoop_browser && EXIT /B 0)
IF "%command%" == "spark_shell" (CALL :spark_shell && EXIT /B 0)
IF "%command%" == "beeline"  (CALL :beeline && EXIT /B 0)

ECHO Syntax: spa_2016.cmd start / stop / status / init_metastore / hadoop_browser / spark_shell / beeline

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
CALL %SPA_2016%\hadoop\sbin\start-dfs.cmd || (ECHO %script%: Failed to start Hadoop HDFS, error=%ERRORLEVEL%)
ECHO %script%: Started HDFS
CALL :sleep 5
CALL %SPA_2016%\hadoop\sbin\start-yarn.cmd || (ECHO %script%: Failed to start Hadoop YARN, error=%ERRORLEVEL%)
ECHO %script%: Started YARN
EXIT /B 0
 
:: ----------------------
:start_spark
ECHO %script%: Starting Spark
START %SPA_2016%\spark\bin\spark-class.cmd org.apache.spark.deploy.master.Master || (ECHO %script%: Failed to start Spark Master, error=%ERRORLEVEL%)
ECHO %script%: Started Spark Master on %IP_ADDRESS%
CALL :sleep 5
START %SPA_2016%\spark\bin\spark-class.cmd org.apache.spark.deploy.worker.Worker spark://%IP_ADDRESS%:7077 || (ECHO %script%: Failed to start Spark Worker, error=%ERRORLEVEL%)
ECHO %script%: Started Spark Worker on %IP_ADDRESS%
EXIT /B 0
 
:: ----------------------
:start_hive
ECHO %script%: Starting Hive Server
START %HIVE_HOME%\bin\hive.cmd --service hiveserver2 1> %SPA_2016%\logs\hive.log 2>&1 || (ECHO %script%: Failed to start Hive server, error=%ERRORLEVEL%)
ECHO %script%: Started Hive Server
EXIT /B 0
 
:: ======================
:: Stop Functions
:: ======================
 
:stop_all
ECHO %script%: Stopping Hadoop
CALL %SPA_2016%\hadoop\sbin\stop-dfs.cmd ||  (ECHO %script%: Failed to stop Hadoop DFS, error=%ERRORLEVEL%)
CALL %SPA_2016%\hadoop\sbin\stop-yarn.cmd || (ECHO %script%: Failed to stop Hadoop YARN, error=%ERRORLEVEL%)
ECHO Java processes:
%JAVA_HOME%\bin\jps.exe
ECHO PLEASE CLOSE THE ABOVE SPARK AND HIVE WINDOWS USING THE COMMAND:
ECHO 'taskkill /f /pid processid'
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
 
:hadoop
ECHO %script%: Running Hadoop command %*
START %SPA_2016%\hadoop\sbin\hadoop.cmd %*
ECHO %script%: Completed Hadoop command
EXIT /B 0

:hadoop_browser
ECHO %script%: Opening Hadoop browser
SET CLIENT_URL='http://localhost:50070/explorer.html#/'
START %CLIENT_URL%
EXIT /B 0

:spark_shell
ECHO %script%: Running Spark client
ECHO Press Control-D to quit
START %SPARK_HOME%\bin\spark-shell.cmd
EXIT /B 0

:beeline
ECHO %script%: Running Hive client (Spark version)
ECHO Type '!quit' to quit
%JAVA_HOME%\bin\java -cp "%SPARK_HOME%\conf\;%SPARK_HOME%\lib\spark-assembly-1.6.1-hadoop2.6.0.jar;%SPARK_HOME%\lib\datanucleus-api-jdo-3.2.6.jar;%SPARK_HOME%\lib\datanucleus-core-3.2.10.jar;%SPARK_HOME%\lib\datanucleus-rdbms-3.2.9.jar" -Djline.terminal=jline.UnsupportedTerminal  -Xms1g -Xmx1g org.apache.hive.beeline.BeeLine -u jdbc:hive2://
EXIT /B 0

:: ======================
:: Miscellaneous Functions
:: ======================
 
:init_metastore
REM SET metastore_dir=%SPA_2016%\data\hive
ECHO Does not work on Windows - please extract the TAR file in the downloads directory
REM MKDIR %metastore_dir%
REM PUSHD %metastore_dir%
REM ECHO Creating Hive metastore at %metastore_dir%\metastore_db
REM SET HADOOP=%HADOOP_HOME%\bin\hadoop.cmd
REM SET HIVE_LIB=%HIVE_HOME%\lib
REM SET HIVE_BIN_PATH=%HIVE_HOME%\bin
REM SET HIVEARGS=-initSchema -dbType derby
REM %HIVE_HOME%\bin\ext\schemaTool.cmd
REM ECHO Created Hive metastore at %metastore_dir%\metastore_db
REM DIR %metastore_dir%
REM POPD
EXIT /B 0

:sleep
ECHO %script%: Sleeping for %1 seconds
PING.EXE -N %~1 127.0.0.1 > NULL
EXIT /B 0
