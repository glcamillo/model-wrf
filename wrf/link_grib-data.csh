#!/bin/csh -v

echo "Number of command line arguments is " $#argv
echo $argv[1]
echo $argv[2]
echo $argv[3]

set DataDir = $argv[1]
set SourceDir = $argv[2]

set alpha = ( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z )
set i1 = 1
set i2 = 1
set i3 = 1

rm -f $DataDir/GRIBFILE.??? >& /dev/null

foreach f ( $SourceDir/gfs.t$argv[3]z.* )
  ln -sf ${f} $DataDir/GRIBFILE.$alpha[$i3]$alpha[$i2]$alpha[$i1]
      @ i1 ++
   
      if ( $i1 > 26 ) then
         set i1 = 1
         @ i2 ++
        if ( $i2 > 26 ) then
           set i2 = 1
           @ i3 ++
           if ( $i3 > 26 ) then
              echo "RAN OUT OF GRIB FILE SUFFIXES!"
           endif
        endif
      endif
end

