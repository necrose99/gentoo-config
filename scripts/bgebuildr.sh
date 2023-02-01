#!/bin/sh 
#./bgebuildr to run in background
## ssh and fire up if disconected it will keep going. 
## else  also cronjob.. builds world binaries when posible but dose not yet merge them.. 
# useful on rpi4 or remote arm64 / etc hosts for deoing emerge jobs and closing out ssh /resume latter
# ie emerge @universe ..... only millions of year......s... seemingly start the build n drop 

nohup ebuildr > /dev/null 2>&1 &