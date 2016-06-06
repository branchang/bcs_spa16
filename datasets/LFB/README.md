# Data Source: London Fire Brigade

The data was obtained from
[The Mayor of London's Website](http://data.london.gov.uk/dataset/london-fire-brigade-incident-records).

You need to convert the Excel file to "Windows CSV" using Microsoft Excel.

# Loading the Data

There are two steps:

1. load the operating system files into Hadoop
1. load the Hadoop files into Hive

## Load the Operating System Files into Hadoop
Run the script `./load_hadoop.bash`.

This will load the file into Hadoop directory `hdfs:/user/nick/load/lfb/LFB`.

## Load the Hadoop Files into Hive

Create the `spa_2016` database if you haven't already,
by running the following Hive SQL commands using `beeline` (see below):

    CREATE DATABASE spa_2016;
    USE spa_2016;


Then run the commands in the load script `load_external.hive`:

    cat ./load_external.hive $SPARK_HOME/bin/beeline -u jdbc:hive2:// --color


# Looking at the Data

## Programmatic Access to Data Using Spark

    $SPARK_HOME/bin/pyspark

##  Submit Hive SQL Queries

    $SPARK_HOME/bin/beeline -u jdbc:hive2:// --color

## Submit Hive SQL Queries From a Script

    cat myscript.hive | $SPARK_HOME/bin/beeline -u jdbc:hive2:// --color


