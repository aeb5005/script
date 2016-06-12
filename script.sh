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
# if [ ! pgrep intrace ] ; then (FINISH THIS)

nc -k -l 44544 0<$PIPE 1>$FILE &

x=0
while [ "$x" -eq 0 ] ; do
	if [ -s "$FILE" ]; 
	then
		echo TCP connection established
		x=1
	else
		echo waiting to establish TCP connection...
		sleep 1
	fi
done

NCIP="$(sudo netstat -anpt|awk 'BEGIN {FS="[ :]+"};/ESTABLISHED/ && /nc/{print $6}')"
echo NCIP is $NCIP

NCPORT="$(sudo netstat -anpt|awk 'BEGIN {FS="[ :]+"};/ESTABLISHED/ && /nc/{print $7}')"
echo NCPORT is $NCPORT

sudo ./intrace -h $NCIP -p $NCPORT 0<$PIPE2 1>$FILE2 &

# if enter, it's go time
# -q or --quiet exits if match is found with 0 status
# -e tells echo to interpret escape characters, \n is enter
# or use yes command
done=0
while [ "$done" -eq 0 ] ; do
	echo waiting to packet sniff for inTrace...
	sleep 1
	if grep -q "ENTER" intrace_out; then
		echo InTrace is ready to begin
		# pretty sure this line below isn't needed
		# > "$FILE2"
		# yes '' > "$PIPE2"
		echo -e "\n" > "$PIPE2"
		done=1
	fi
done
# might as well wait a few seconds, intrace won't finish that fast
# sleep 5
done2=0
while [ "$done2" -eq 0 ] ; do
	echo waiting to end InTrace...
	if tac "$FILE2" | grep -Fq "[TCP]" ; then
	# if grep -Fq "[TCP]" "$FILE2" ; then
		echo InTrace results complete
		sudo pkill intrace
		done2=1
	fi
	sleep 0.5
done

# now to parse nc_out and intrace_out and send results back through the nc connection

# could try exit 0 which indicates success
exit 
