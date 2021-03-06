:: Name:    env.cmd
:: Purpose: Set Big Data environment for Windows
:: Author:  Nick Rozanski
:: Syntax:  env.cmd
:: Notes:   the Windows version is env.src
::          note that Hadoop does not work under Cygwin

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
SET HADOOP_PREFIX=%SPA_2016%\hadoop
SET HADOOP_HOME=%HADOOP_PREFIX%
REM set HADOOP_CONF_DIR=%HADOOP_PREFIX%\etc\hadoop
REM set HADOOP_COMMON_HOME=%HADOOP_PREFIX%
REM set HADOOP_HDFS_HOME=%HADOOP_PREFIX%
REM set HADOOP_YARN_HOME=%HADOOP_PREFIX%
REM set HADOOP_COMMON_LIB_NATIVE_DIR=%HADOOP_PREFIX%\lib\native
REM set HADOOP_OPTS=-Djava.library.path=%HADOOP_PREFIX%\lib"

REM Spark configuration
SET SPARK_HOME=%SPA_2016%\spark

REM Hive configuration
SET HIVE_HOME=%SPA_2016%\hive
