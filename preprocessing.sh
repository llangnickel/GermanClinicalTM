# preliminaries
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
MODELS_HOME=$PWD"/models"
LOGDIR=$PWD"/logs"
mkdir -p $LOGDIR
TIMESTAMP=`date "+%F_%H-%M-%S"`
SECONDS=0

# Start pipeline
echo "Starting Pipeline"
#remove \r\n and whitespace colonnes from files!
NAME="SED"
echo Running $NAME
IN0=$INDIR
TEMP=$OUTDIR/SEDTMP
OUT0=$OUTDIR/SED"_"$TIMESTAMP
mkdir -p $OUT0;
mkdir -p $TEMP;
FILECOUNT=0
for item in $IN0/*
do
if [ -f "$item" ]
    then
         FILECOUNT=$[$FILECOUNT+1]
fi
done
echo IN File count for $NAME: $FILECOUNT
INFILES=$FILECOUNT
for i in `find $IN0 -type f -name *.txt`; do
#-e 's/\\n/ /g' -e 's/\\r/ /g'
        sed -r -e 's/\\\\f:12055\\\\//g' -e 's/\\\\f:12052\\\\//g' -e 's/\\\\f:-\\\\//g' -e 's/\\\\f:12054\\\\//g' -e 's/\\\\c:400040\\\\//g' -e 's/\\\\c:FF\\\\//g' -e 's/\\\\c:-\\\\//g'  -e 's/\\t{1,}/ /g' -e 's/\xc2\x85//g' -e 's/&#10;/ /g' -e 's/\\\\//g' -e 's/&#13;/ /g' -e 's/&#9;/ /g' $i > $TEMP/$(basename $i);
done

for i in `find $TEMP -type f -name *.txt`; do
        sed -r -e 's/\s{2,}/ /g' -e 's/\\\W//g' $i > $OUT0/$(basename $i);
done
rm -rf $TEMP;
duration1=$SECONDS
echo $NAME finished in $(($duration1 / 60)):$(($duration1 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration1))
SECONDS=0

#Text2XCas
NAME="Text2XCAS"
echo Running $NAME
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
IN1=$OUT0
OUT1=$OUTDIR/$NAME"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$TIMESTAMP".log"

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
     -log "ALL" \
     -casPoolSize 1 \
     FILE \
     -fs USERSUPPLIEDID \
     -i $IN1 \
     -o $OUT1 \
>> $LOG_FILE 2>&1
duration2=$SECONDS
echo $NAME finished in $(($duration2 / 60)):$(($duration2 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration2))
SECONDS=0

# RegexSentenceDetector
NAME="RegExSentenceDetector"
echo Running $NAME
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
IN2=$OUT1
OUT2=$OUTDIR/$NAME"_"$MODEL"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$MODEL"_"$TIMESTAMP".log"

FILECOUNT=0
for item in $IN2/*
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
     -actionOnMaxError continue \
     --dropCasOnException true \
     -c ${CONFIG_HOME}/${NAME}.ini \
      FILE \
     -fs USERSUPPLIEDID \
     -i $IN2 \
     -o $OUT2 \
>> $LOG_FILE 2>&1
VGL=0
for item in $OUT2/*
do
if [ -f "$item" ]
    then
         VGL=$[$VGL+1]
fi
done
if [ $VGL != $FILECOUNT ]
  then
ERRFILE=$LOGDIR/$NAME"_"$TIMESTAMP"_ERROR.txt"
echo Printing failed Documents to $ERRFILE
diff -q $IN2 $OUT2 | grep Only | grep -oh '[a-zA-Z0-9_-\.]*.xmi' > $ERRFILE 
fi
duration3=$SECONDS
echo $NAME finished in $(($duration3 / 60)):$(($duration3 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration3))


SECONDS=0

# RegexFinder
NAME="RegexFinder"
echo Running $NAME
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
IN3=$OUT2
OUT3=$OUTDIR/$NAME"_"$MODEL"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$MODEL"_"$TIMESTAMP".log"

FILECOUNT=0
for item in $IN3/*
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
     -log "ALL" \
     -casPoolSize 1 \
     -c ${CONFIG_HOME}/${NAME}.ini \
      FILE \
     -fs USERSUPPLIEDID \
     -i $IN3 \
     -o $OUT3 \
>> $LOG_FILE 2>&1
duration4=$SECONDS
echo $NAME finished in $(($duration4 / 60)):$(($duration4 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration4))
SECONDS=0

# Tokenizer
NAME="JPMTokenizer"
echo Running $NAME
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
IN4=$OUT3
OUT4=$OUTDIR/$NAME"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$TIMESTAMP".log"

FILECOUNT=0
for item in $IN4/*
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
     -fs USERSUPPLIEDID \
     -i $IN4 \
     -o $OUT4 \
     -v "DocumentView" \
>> $LOG_FILE 2>&1
duration5=$SECONDS
echo $NAME finished in $(($duration5 / 60)):$(($duration5 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration5))
SECONDS=0

# Lemmatizer
NAME="Lemmatizer"
echo Running $NAME
THREADS=1
REQUIRED_MEMORY_PER_THREAD=1966080
REQUIRED_MEMORY=`expr $REQUIRED_MEMORY_PER_THREAD \* $THREADS`
MODEL="lemma-ger-3.6.model"
IN5=$OUT4
#OUT4=$OUTDIR/$NAME"_"$MODEL"_"$TIMESTAMP
LOG_FILE=$LOGDIR"/"$NAME"_"$TIMESTAMP".log"

FILECOUNT=0
for item in $IN5/*
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
     -actionOnMaxError continue \
     --dropCasOnException true \
	-casPoolSize 1 \
	-m ${MODELS_HOME}/$MODEL \
         FILE \
	-fs USERSUPPLIEDID \
	-i $IN5 \
	-o $OUTDIR \
>> $LOG_FILE 2>&1

# delete prelimary results
rm -r $IN1
rm -r $IN2
rm -r $IN3
rm -r $IN4

VGL=0
for item in $OUTDIR/*
do
if [ -f "$item" ]
    then
         VGL=$[$VGL+1]
fi
done
if [ $VGL != $FILECOUNT ]
  then
ERRFILE=$LOGDIR/$NAME"_"$TIMESTAMP"_ERROR.txt"
echo Printing failed Documents to $ERRFILE
diff -q $IN5 $OUTDIR | grep Only | grep -oh '[a-zA-Z0-9_-]*.xmi' > $ERRFILE 
fi
duration7=$SECONDS
echo $NAME finished in $(($duration6 / 60)):$(($duration6 % 60))
echo $NAME documents/s: $(($FILECOUNT / $duration6))
SECONDS=0
