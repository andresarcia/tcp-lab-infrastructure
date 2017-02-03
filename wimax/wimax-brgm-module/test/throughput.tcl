source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl
source $env(TCPLAB)/tcplab-flows.tcl
source $env(TCPLAB)/getopt.tcl
source $env(TCPLAB)/tcplab-metrics.tcl
source ./wimax-stats.tcl

# ------------------------
# Global variables section
# ------------------------

global cmd_line_opt
global bs_opt
global wl_nodes
global wired_node
global ns


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
    { utlim up_transmit_limit}
    { dtlim down_transmit_limit}
	{ bwp bw_policy }
}


# command line parameters:

# simulation aspects
set cmd_line_opt(simutime)       1000
set cmd_line_opt(filename)       "./" 
set cmd_line_opt(usenam)         0
set cmd_line_opt(tracing)        0
set cmd_line_opt(substrnum)      1

# TCP aspects
set cmd_line_opt(segsize)        1000 
set cmd_line_opt(filesize)       1500000
#set cmd_line_opt(tcp_sender)    "Agent/TCP/FullTcp/Newreno"
#set cmd_line_opt(tcp_sink)      "Agent/TCP/FullTcp/Newreno"
set cmd_line_opt(tcp_sender)    "Agent/TCP/Newreno"
set cmd_line_opt(tcp_sink)      "Agent/TCPSink/DelAck"

set cmd_line_opt(ackscheme)      "delack"
# convert cmd_line_opt to tcp_opt
set tcp_opt(segsize)           $cmd_line_opt(segsize)       
set tcp_opt(tcp_sender)        $cmd_line_opt(tcp_sender)    
set tcp_opt(tcp_sink)          $cmd_line_opt(tcp_sink)
set tcp_opt(initialwin)        1
set tcp_opt(ssthresh)          65535
set tcp_opt(maxburst)          0 ;# 0 to ignore
# TCP flows statistics
set tcp_opt(reset_stats)    0
set tcp_opt(auto_rwnd)      0
set tcp_opt(auto_ssth)      0

# WiMAX aspects
set cmd_line_opt(number_of_ss)   1
set cmd_line_opt(bs_buffer_size) 50
set cmd_line_opt(dlratio)        0.5
set cmd_line_opt(ssdiuc)	 7
set cmd_line_opt(up_transmit_limit)	 0
set cmd_line_opt(down_transmit_limit)	0
set cmd_line_opt(bw_policy) dDDA

source ./wimax-settings.tcl

# decode the input parameters
my_getopt $argv

#Set WiMax Command Line Settings
WimaxScheduler/BS set dlratio_ $cmd_line_opt(dlratio)
WimaxScheduler/BS set upTransmitLimit_ $cmd_line_opt(up_transmit_limit)
WimaxScheduler/BS set dlTransmitLimit_ $cmd_line_opt(down_transmit_limit)

global defaultRNG
$defaultRNG seed 0

set ns [new Simulator]
$ns use-newtrace

set tf [open $cmd_line_opt(filename) w]
$ns trace-all $tf

# Create an 802.16 infraestructure:
source ./infrastructure.tcl
Infrastructure my-infra

# Set a  new default modulation, missing to create an access to the  
# scheduler from TCL. Othewise, this operation leaves the old scheduler in 
# memory (memory leak).
set bs_sched [new WimaxScheduler/BS]
$bs_sched set-default-modulation OFDM_64QAM_3_4
[$bs_node set mac_(0)] set-scheduler $bs_sched

[$bs_node set mac_(0)] set-bw-perception-policy $cmd_line_opt(bw_policy)

# for trace in TCPLAB
set tcp_list {}

[$bs_node set mac_(0)] set-channel 0

for {set i 1} {$i <= $cmd_line_opt(number_of_ss)} {incr i} {
	set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
	    
	set snd($i) [lindex $tmp 0]
	set rcv($i) [lindex $tmp 1]
	set ftp_src($i) [lindex $tmp 2]
    
	set-delack-conditions $snd($i) $rcv($i)   

 	[$wl_nodes($i) set mac_(0)] set-channel 0
 	
	[$wl_nodes($i) set mac_(0)] set-diuc $cmd_line_opt(ssdiuc)
 
	# NOTE: Remember that there is some warm-up time for the DSDV protocol to 
	# have the route from the wireless nodes to the base station.
	$ns at [expr 3+$i] "$ftp_src($i) start"

	lappend tcp_list $snd($i)
}

proc finish {} {
	global ns tcp_list tcpAggregatedThroughputFile cmd_line_opt wl_nodes bs_node
	global tf bwCollisionProbabilityFile
	global gr_list
    $ns flush-trace
    close $tf

	if { [llength $gr_list] > 0 } {
	end-graphs $gr_list 
	}   

    set aggregatedThroughput [expr [expr [get-list-mean-throughput $tcp_list]/1000000]*$cmd_line_opt(number_of_ss)]
    puts $tcpAggregatedThroughputFile "$cmd_line_opt(number_of_ss) $aggregatedThroughput"

	print-order-throughput $tcp_list [list "flow 1: " "flow 2:"]

	set bw_coll_pro [expr [get-bwreq-collision-probability $bs_node wl_nodes]]
	puts $bwCollisionProbabilityFile "$cmd_line_opt(number_of_ss) $bw_coll_pro"
   
    close $tcpAggregatedThroughputFile
	close $bwCollisionProbabilityFile
    
    exit 0
}



#Open TCP Aggregated Throughput Trace File
set outfn $cmd_line_opt(bw_policy)
append outfn "thrput.out"
set tcpAggregatedThroughputFile [open $outfn a+]

open-file-graph

set gr_list [create-tcp-graphs [list "cwnd_"] [list "$snd(1)" "$snd(2)"] [list "f1" "f2"]]

set outfn $cmd_line_opt(bw_policy)
append outfn "bwColPro.out"
set bwCollisionProbabilityFile [open $outfn a+]

#Reset Stats
set ftpReset 400
$ns at $ftpReset "[init-stats-tcp-list $tcp_list]"
$ns at $ftpReset "[init-stats-wimax $bs_node wl_nodes]"

$ns at $cmd_line_opt(simutime) "finish"

$ns run
