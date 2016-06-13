# Script for automating traceroute and intrace on EC2 server

* Basic idea is client (rooted Android phone) connects to AP and runs traceroute to android server.
* Once the server recognizes that there is an established connection (done with netcat on client and server) it begins
* inTrace packet sniffs the active TCP NC connection and uses this to do its own traceroute back to source
* inTrace *should* bypass firewalls and report existence of NAT if they exist between server and client
