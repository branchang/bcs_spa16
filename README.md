# Real-World Big Data In Action

A workshop in which you will create a Big Data cluster, load it with real data and run queries against it.

http://www.spaconference.org/spa2016/sessions/session657.html

## Course Errata

### Slides 8: Install Hadoop, Spark and Hive
You can use 7zip to extract the compressed tar files on Windows.
(There is a copy of the 7zip installer in the downloads directory.)

Right-click on a `.tgz` file and select 7zip -> Extract Here.

### Slides 14 and 15: Review Spark and Hive Configuration
No editing of configuration files is necessary.
Just review them to make sure they are correct for your setup.

### Slide 16: Create Hive Metastore Database
You don't need to create the empty Hive metastore database - it is included in the git repository.
I was unable to get the metastore command to work in Windows.
(The format seems to be portable so I created it on OS X.)

### Slide 31: Pyspark
If Pyspark on Windows can't find Python, make sure it is installed and the Python directory (typical C:\Python27) is in %PATH%.

### Slide 41
The Hadoop load command should read:

    $HADOOP_HOME/bin/hadoop fs -put \
        $SPA_2016/datasets/lhp/load/*.csv \
        hdfs://localhost:9000/user/spa16/load/lhp

(ie replace `lfb` with `lhp`).

Similarly, the Pyspark statement should start `lhp =`, not `lfb = `.

### Slide 45: Troubleshooting
For Windows you need to run `env.cmd`, not `env.bat`.

If you get lots of errors on startup, make sure you have initialised your Hadoop filesystem!

Look out for rogue back-quotes in scripts and slides.
I have checked carefully for these but it is possible one may have slipped through.
These generally cause pretty obvious syntax errors.

