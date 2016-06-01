#!/bin/bash

# nc_out is the traceroute results from the client
# empty.txt is an empty file

FILE=nc_out
PIPE=fifo

if [ ! -e "$FILE" ] ; then
        touch "$FILE"
fi

if [ ! -w "$FILE" ] ; then
        echo cannot write to $FILE
        exit 1
fi

# making named pipe for nc input
mkfifo fifo
exec 3<>fifo

# named pipe for intrace input for enter
mkfifo fifo2
exec 6<>fifo2

touch intrace_out

sudo ./intrace -h 76.99.28.199 -p 44544 0<fifo 1>intrace_out &

nc -k -l 44544 0<fifo 1>nc_out &

# if enter, it's go time
# -q or --quiet exits if match is found with 0 status
# -e tells echo to interpret escape characters, \n is enter 
# or use yes command
if [ grep -q "ENTER" intrace_out ] ; then
	yes '' > fifo2
fi

# need to start intrace and send to background
# while diff is 0 (while they are the same do nothing, aka while blank do nothi$
# else: data is being sent, time to start intrace
# need to send enter signal to intrace
# intrace needs to be constantly appending to a file

