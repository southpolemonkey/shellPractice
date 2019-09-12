for FILENAME in $(ls *.gz); do

  NEWFILENAME=`basename $FILENAME .dat.gz`.hash
  sha1sum $FILENAME > $NEWFILENAME
  
done
