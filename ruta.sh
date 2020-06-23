INDIR=$1
OUTDIR=$2
JAR=$3 # path to the jar file 
RUTA_RULES=$4 # name of the rules file 

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
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
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
     -jar $JAR \
     -t $THREADS \
     -casPoolSize 1 \
     -rf $RUTA_RULES \
     FILE \
     -fs USERSUPPLIEDID \
     -i $INDIR \
     -o $OUTDIR \
>> $LOG_FILE 2>&1
duration8=$SECONDS
echo $NAME finished in $(($duration8 / 60)):$(($duration8 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration8))
SECONDS=0
