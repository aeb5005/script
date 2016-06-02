#!/bin/bash

# nc_out is the traceroute results from the client
# intrace_out is the result from intrace from server to client

FILE="nc_out"
FILE2="intrace_out"
PIPE="fifo"
PIPE2="fifo2"

if [ ! -e "$FILE" ] ; then
        echo making "$FILE"
	touch "$FILE"
fi

if [ ! -w "$FILE" ] ; then
        echo cannot write to "$FILE"
        exit 1
fi

if [ ! -e "FILE2" ] ; then
	echo making "$FILE2"
	touch "$FILE2"
fi

if [ ! -w "$FILE2" ] ; then
	echo cannot write to "$FILE2"
	exit 1
fi

# making named pipe for nc input
if [ ! -e "$PIPE" ] ; then 
	echo making pipe 1
	mkfifo "$PIPE"
	exec 3<>"$PIPE"
fi

# named pipe for intrace input for enter
if [ ! -e "$PIPE2" ] ; then
	echo making pipe 2
	mkfifo "$PIPE2"
	exec 6<>"$PIPE2"
fi

# is sudo needed? appears so, not sure why 
# if [ ! pgre (FINISH THIS)
sudo ./intrace -h 76.99.28.199 -p 44544 0<$PIPE2 1>$FILE2 &

nc -k -l 44544 0<$PIPE 1>$FILE &

# if enter, it's go time
# -q or --quiet exits if match is found with 0 status
# -e tells echo to interpret escape characters, \n is enter
# or use yes command
done=0
while [ "$done" -eq 0 ] ; do
	echo waiting...
	sleep 1
	if grep -q "ENTER" intrace_out; then
		echo InTrace is ready to begin
		yes '' > "$PIPE2"
		done=1
	fi
done

