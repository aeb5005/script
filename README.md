# Script for automating traceroute and intrace on EC2 server

* Basic idea is client (rooted Android phone) connects to AP and runs traceroute to EC2 server.
* The client connects to a remote EC2 server using netcat, and pipes the traceroute results through nc to a file on the server.
* The server needs to recognize that the client is connected. This can be done in many ways, such as poll netstat.
* I simply poll the results file for size change. Once change is detected, intrace is ran with client as destination.
* Client information is parsed from netstat results using grep and awk.
* inTrace packet sniffs the active TCP NC connection to get seq and ack values. 
* inTrace then runs a TCP traceroute back to client.
* inTrace *should* bypass firewalls and report existence of NAT if they exist between server and client, but this is dependent on the network. 
