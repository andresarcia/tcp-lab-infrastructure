# By Andrés Arcia. (September 2008)
# Some parameter taken from R. Rouil code.
# This is a generic Infrastructure topology to test TCP scenarios. 
# A sing	le Base Station connected to a wired server, it set to serve a number 
# of Wireless Nodes.
# 
# If you want to add a new MAC/PHY layer, just write your own 802-XX-specifics  
# class, and derive your topology from it as follows:
#
# Class BS-mac-phy-adapter -superclass specifics-802-16
# or
# Class BS-mac-phy-adapter -superclass 802-11-specifics
#
# Infrastructure Topology:
#                                     1.x.0
#                                      
#                              /       WL_1 (1.1.0)
#      0.0.0          1.0.0   /    
#  <Wired Node> ------ <BS> -- ) ) )     WL_2 (1.2.0) 
#                             \   
#                              \       WL_n (1.n.0)
# 


# TODO: This class MUST be defined depending on the MAC used. 
# Class BS-mac-phy-adapter -superclass specifics-802-16
# or
# Class BS-mac-phy-adapter -superclass 802-11-specifics

Class Infrastructure -superclass BS-mac-phy-adapter

Infrastructure instproc init {args} {

global bs_opt cmd_line_opt 

eval $self next $args

# wired part characteristics
$self set topo [new Topography]
$self set wired(delay)  2ms
$self set wired(bw)     100Mb
$self set canvas(x)     1000           ;# X dimension of the topography
$self set canvas(y)		1000		   ;# Y dimension of the topography

# Base Station fix characteristics 
set bs_opt(chan)      Channel/WirelessChannel    ;# channel type
set bs_opt(ant)       Antenna/OmniAntenna        ;# antenna model
set bs_opt(prop)      Propagation/TwoRayGround   ;# radio-propagation model
set bs_opt(ifq)       Queue/DropTail/PriQueue    ;# MAC queue (interf. queue) 
set bs_opt(ifqlen)    $cmd_line_opt(bs_buffer_size) ;# max packet in ifq
set bs_opt(adhocrout) DSDV                       ;# adhoc routing protocol
set bs_opt(ll)        LL             ;# link layer type

$self create-topology

}

Infrastructure instproc create-topology {} {

$self create-routing
$self create-wired-node
$self create-bs-and-link
$self create-wireless-nodes

}

# ---------------------------------------
# Hierarchical routing.
# Needed for routing over a basestation.
# ---------------------------------------

Infrastructure instproc create-routing {} {

global ns cmd_line_opt	

$self instvar topo canvas

$ns node-config -addressType hierarchical
# Total number of domains. 
AddrParams set domain_num_ 2          		
# Number of clusters in each domain: 1 cluster per domain.
lappend cn 1 1            			 
# Number of nodes for each cluster C1 = 1 for TCP server ; and C2 = n_SS + 1 BS. 
AddrParams set cluster_num_ $cn
# Total number of nodes per cluster
lappend eilastlevel 1 [expr 1+$cmd_line_opt(number_of_ss)]
AddrParams set nodes_num_ $eilastlevel

# Create God:
# number_of_ss + 1 BS + 1 TCP server node in the wired part
create-god [expr $cmd_line_opt(number_of_ss) + 2]

$topo load_flatgrid $canvas(x) $canvas(y)

}

# -----------------------------------------
# Creates the TCP server node in first 
# addressing space.
# -----------------------------------------

Infrastructure instproc create-wired-node {} {

global ns wired_node

set wired_node [$ns node 0.0.0]

# provide some coordinates (fixed) for the wired-node possibly a TCP server.
$wired_node set X_ 50.0
$wired_node set Y_ 50.0
$wired_node set Z_ 0.0

}

# --------------
# Create the BS
# --------------

Infrastructure instproc create-bs-and-link {} {

global ns bs_opt wired_node bs_node

$self instvar topo wired

$ns node-config -adhocRouting $bs_opt(adhocrout) \
                 -llType $bs_opt(ll) \
                 -macType $bs_opt(BSmac) \
                 -ifqType $bs_opt(ifq) \
                 -ifqLen $bs_opt(ifqlen) \
                 -antType $bs_opt(ant) \
                 -propType $bs_opt(prop)    \
                 -phyType $bs_opt(phy) \
                 -channel [new $bs_opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace OFF \
                 -routerTrace OFF \
                 -macTrace OFF  \
                 -movementTrace OFF

set bs_node [$ns node 1.0.0]  

$bs_node random-motion 0
$bs_node set X_ 200.0
$bs_node set Y_ 200.0
$bs_node set Z_ 0.0

# Join TCP Server and BS:

$ns duplex-link $wired_node $bs_node $wired(bw) $wired(delay) DropTail

}

# -------------------------
# Create the wireless nodes
# -------------------------

Infrastructure instproc create-wireless-nodes {} {

global ns bs_opt bs_node wl_nodes cmd_line_opt

# TODO: Mobile nodes cannot do routing. 
# TODO: Find a way to forward packets from a SS to further subnetworks.

$ns node-config -macType $bs_opt(HSmac) \
                -wiredRouting OFF \
                -macTrace OFF \
                -routerTrace OFF \
                -agentTrace OFF


for {set i 1} { $i <= $cmd_line_opt(number_of_ss) } {incr i} {

	# Create the SS and assign the address
	set wl_nodes($i) [$ns node 1.$i.0] 	
	$wl_nodes($i) random-motion 0			

	# Attach the new SS to the BS.
    $wl_nodes($i) set X_ 500.0
	$wl_nodes($i) set Y_ 500.0
	$wl_nodes($i) set Z_ 0.0
	$wl_nodes($i) base-station [AddrParams addr2id [$bs_node node-addr]] 

   
}


}
