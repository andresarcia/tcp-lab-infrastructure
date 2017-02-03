# By Andrés Arcia (sept/08)
# Testing a 802.16 infrastructure. 

source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl
source $env(TCPLAB)/trunk/includes/tcl/tcplab-flows.tcl
source $env(TCPLAB)/trunk/includes/tcl/getopt.tcl


# ------------------------
# Global variables section
# ------------------------

global cmd_line_opt
global bs_opt
global wl_nodes
global wired_node
global ns

set ns [new Simulator]

$ns use-newtrace

# ------------------------
# Option decoding section
# ------------------------

# just in case of calculating automatically the BS buffer size: 
#[expr 2*([bw_parse $opt(btneckbw)]*[delay_parse $opt(delay)]/8)/($opt(segsize)+40)]

# parameters that can be changed through the command-line:
set cmd_line_opt(opt_conv) {
    { snd tcp_sender }
    { rcv tcp_sink }
    { nbss number_of_ss }
    { bsbuf bs_buffer_size }
    { fn filename }
    { nam usenam }
    { tr tracing }
    { ss segsize }
    { fs filesize }
    { sstr substrnum }
    { stime simutime }
    { acks  ackscheme }
    { dlr dlratio }
    { diuc ssdiuc }
    { ult ultraffic}
    { cbrbw cbrbandwidth}
    { trs trafficStart}	
}

# command line parameters:

# simulation aspects
set cmd_line_opt(simutime)       1000
set cmd_line_opt(filename)       "./" 
set cmd_line_opt(usenam)         0
set cmd_line_opt(tracing)        0
set cmd_line_opt(substrnum)      1

#CBR Traffic Start
set cmd_line_opt(trafficStart)   3

#CBR Trafic direction 0:DL & 1:UL 
set cmd_line_opt(ultraffic)      0
set cmd_line_opt(cbrbandwidth)	 100

# TCP aspects
set cmd_line_opt(segsize)        960
set cmd_line_opt(filesize)       1500000
set cmd_line_opt(tcp_sender)    "Agent/TCP/FullTcp/Newreno"
set cmd_line_opt(tcp_sink)      "Agent/TCP/FullTcp/Newreno"
set cmd_line_opt(ackscheme)      "delack"
# convert cmd_line_opt to tcp_opt
set tcp_opt(segsize)           $cmd_line_opt(segsize)       
set tcp_opt(tcp_sender)        $cmd_line_opt(tcp_sender)    
set tcp_opt(tcp_sink)          $cmd_line_opt(tcp_sink)
# TCP flows statistics
set tcp_opt(reset_stats)    0
set tcp_opt(auto_rwnd)      0
set tcp_opt(auto_ssth)      0

# WiMAX aspects
set cmd_line_opt(number_of_ss)   1
set cmd_line_opt(bs_buffer_size) 100
set cmd_line_opt(dlratio)        0.5
set cmd_line_opt(ssdiuc)	 7

# To see all the opt array (sometimes, there are surprises!)
# print_opt

#Load WiMAX default settings
source ./wimax-settings.tcl

# decode the input parameters
my_getopt $argv

# check for invalid options:
if {$cmd_line_opt(dlratio) < 0 || $cmd_line_opt(dlratio) > 1} {
   puts "ERROR: Invalid DL-ratio ($cmd_line_opt(dlratio))"
   exit 1
}

#Set WiMax Command Line Settings
WimaxScheduler/BS set dlratio_ $cmd_line_opt(dlratio)
WimaxScheduler/BS set upTransmitLimit_ 0
WimaxScheduler/BS set dlTransmitLimit_ 0

# ----------
# NS tracing
# ----------

set tf [open $cmd_line_opt(filename) w]

# NOTE: trace file must be defined as it is used by the 802.16 MAC.

$ns trace-all $tf

# Create an 802.16 infraestructure:
Class BS-mac-phy-adapter -superclass specifics-802-16

BS-mac-phy-adapter instproc init {args} {

eval $self next $args
}

source ./infrastructure.tcl

Infrastructure my-infra


# Set a  new default modulation, missing to create an access to the  
# scheduler from TCL. Othewise, this operation leaves the old scheduler in 
# memory (memory leak).
set bs_sched [new WimaxScheduler/BS]
$bs_sched set-default-modulation OFDM_64QAM_3_4
[$bs_node set mac_(0)] set-scheduler $bs_sched

# --------------------------------
# Collect Statistics (see TCP-LAB)
# --------------------------------

set udp_list {}

[$bs_node set mac_(0)] set-channel 0

for {set i 1} {$i <= $cmd_line_opt(number_of_ss)} {incr i} {
	 #set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
		
	 #CREATE-CBR HEADER proc create-cbr { n0 n1 bw packet_size { start_time 0.0 } { fid 0 } } 
	 if {$cmd_line_opt(ultraffic) == 0} {
	 	set tmp [create-cbr $wired_node $wl_nodes($i) $cmd_line_opt(cbrbandwidth) $cmd_line_opt(segsize) $cmd_line_opt(trafficStart)  $i]
	 } else {
	 	set tmp [create-cbr $wl_nodes($i) $wired_node $cmd_line_opt(cbrbandwidth) $cmd_line_opt(segsize) $cmd_line_opt(trafficStart)  $i]
	 }
		 
	 set snd($i) [lindex $tmp 0]
	 set cbr_src($i) [lindex $tmp 1]
	    
	 [$wl_nodes($i) set mac_(0)] set-channel 0
	 # TODO: what does set-diuc do if the scheduler has another different diuc?
	 [$wl_nodes($i) set mac_(0)] set-diuc $cmd_line_opt(ssdiuc)
	 	
	 lappend udp_list $snd($i)
}


#Reset after warm-up time init-stats-tcp-list $lr_list

proc finish {} {

    global ns cbr_list tf  
    
    $ns flush-trace

    close $tf
	    
    exit 0
}


$ns at $cmd_line_opt(simutime) "finish"

$ns run
