INDIR=$1
OUTDIR=$2
mkdir -p $OUTDIR

MICRO_JAVA_OPTS="-Xss2M -d64 -server \
     -Dfile.encoding=UTF-8 \
     -XX:+UnlockExperimentalVMOptions -XX:G1MaxNewSizePercent=80 \
     -XX:+UseG1GC -XX:+UseNUMA \
     -Dhawtdispatch.threads=3"

BINARY_HOME=$PWD"/binary"
CONFIG_HOME=$PWD"/config"
LOGDIR=$PWD"/logs"
mkdir -p $LOGDIR
TIMESTAMP=`date "+%F_%H-%M-%S"`

# RUTA
NAME="RutaDisturbances"
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
RUTA_RULES=$PWD"/RutaRules/disturbances/disturbances.ruta"
OUT1=$OUTDIR/$NAME"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$TIMESTAMP".log"

FILECOUNT=0
for item in $INDIR/*
do
if [ -f "$item" ]
    then
         FILECOUNT=$[$FILECOUNT+1]
fi
done
echo IN File count for $NAME: $FILECOUNT

java -Xmx${REQUIRED_MEMORY}k $MICRO_JAVA_OPTS \
     -jar ${BINARY_HOME}/${NAME}.jar \
     -t $THREADS \
     -casPoolSize 1 \
     -rf $RUTA_RULES \
     FILE \
     -fs USERSUPPLIEDID \
     -i $INDIR \
     -o $OUT1 \
>> $LOG_FILE 2>&1
duration8=$SECONDS
echo $NAME finished in $(($duration8 / 60)):$(($duration8 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration8))
SECONDS=0

# XCas2Json
#NAME="DESCRIBE2Json"
NAME="XCas2Json"
echo Running $NAME
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
TEMPLATE="disturbances"
IN1=$OUT1
OUT8=$OUTDIR/$NAME"_"$TEMPLATE"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$TEMPLATE"_"$TIMESTAMP".log"

FILECOUNT=0
for item in $IN1/*
do
if [ -f "$item" ]
    then
         FILECOUNT=$[$FILECOUNT+1]
fi
done
echo IN File count for $NAME: $FILECOUNT


java -Xmx${REQUIRED_MEMORY}k $MICRO_JAVA_OPTS \
      -jar ${BINARY_HOME}/${NAME}.jar \
      -t $THREADS \
      -casPoolSize 1 \
      -jt $CONFIG_HOME"/"$TEMPLATE".json" \
      FILE \
      -fs USERSUPPLIEDID \
      -i $IN1 \
      -o $OUT1 \
>> $LOG_FILE 2>&1
duration9=$SECONDS
echo $NAME finished in $(($duration9 / 60)):$(($duration9 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration9))

total=$(($duration1 + $duration2 + $duration3 + $duration5 + $duration6 + $duration7 + $duration8 + $duration9))

echo Pipeline finished in $(($total / 60)):$(($total % 60))
FILECOUNT=0
for item in $OUT1/*
do
if [ -f "$item" ]
    then
         FILECOUNT=$[$FILECOUNT+1]
fi
done
echo Total Files IN: $INFILES ... Total files OUT: $FILECOUNT
