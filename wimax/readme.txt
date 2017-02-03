Processing commands:

* Using grep ^r out.res | grep MAC | grep -c cbr you can see the number of mac packets received at the BS.

* Using grep ^s out.res | grep MAC | grep -c cbr you can see the number of mac packets sent (200 packets). 


Design principles of infrast-802-16.tcl:

- Create n downward TCP connections 
- Create m upward TCP connections.
- Make available a set of parameters for TCP evaluation purposes:
	- file size, packet size, TCP version, etc. 
- Add new 802.16 MAC layer parameters that affect TCP performance:
	- frame size, modulation type, queue lengths, etc.


Bug Fix and Problems:

1) AODV vs. DSDV:

It is necesary to add to both implementations of wireless routing the following line within the ::recv method (in aodv.cc and dsdv.cc):

if (ch->ptype() != PT_TCP && ch->ptype() != PT_ACK)
    ch->size() += IP_HDR_LEN;
 
This is motivated by the existent adding of the IP header length in all TCP implementations.
