:: Name:    env.cmd
:: Purpose: Set Windows environment for Big Dat services
:: Author:  Nick Rozanski
:: Syntax:  env.cmd
:: See:     http://steve-jansen.github.io/guides/windows-batch-scripting/

@ECHO OFF
SET script=%~n0

IF "%JAVA_HOME%" == "" (
   ECHO %script%: Error: JAVA_HOME not set
   EXIT /B 1
)
ECHO JAVA_HOME is %JAVA_HOME%.
SET SPA_2016=%~dp0
SET SPA_2016=%SPA_2016:~0,-1%
ECHO SPA_2016 is %SPA_2016%.
ECHO PATH IS %PATH%

REM Hadoop configuration
set HADOOP_PREFIX=%SPA_2016%\hadoop
set HADOOP_HOME=%HADOOP_PREFIX%
REM set HADOOP_CONF_DIR=%HADOOP_PREFIX%\etc\hadoop
REM set HADOOP_COMMON_HOME=%HADOOP_PREFIX%
REM set HADOOP_HDFS_HOME=%HADOOP_PREFIX%
REM set HADOOP_YARN_HOME=%HADOOP_PREFIX%
REM set HADOOP_COMMON_LIB_NATIVE_DIR=%HADOOP_PREFIX%\lib\native
REM set HADOOP_OPTS=-Djava.library.path=%HADOOP_PREFIX%\lib"

REM Spark configuration
set SPARK_HOME=%SPA_2016%\spark

REM Hive configuration
set HIVE_HOME=$SPA_2016\hive
