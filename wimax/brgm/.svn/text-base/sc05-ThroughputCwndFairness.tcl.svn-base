# By Andrés Arcia (sept/08)
# Testing a 802.16 infrastructure. 

source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl
source $env(TCPLAB)/trunk/includes/tcl/tcplab-flows.tcl
source $env(TCPLAB)/trunk/includes/tcl/getopt.tcl
source $env(TCPLAB)/trunk/includes/tcl/tcplab-metrics.tcl
source ./wimax-stats.tcl


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
    { utlim up_transmit_limit }
    { dtlim down_transmit_limit }
    { aggReqPeriod aggr_request_period_ }
    { bwpolicy bw_perception_policy_ }
    { ult ultraffic}
    { codscheme wimax_codification_scheme}
    #Metrics
    { cwndgraph	congestion_window_graph }
    { thrOrd throughput_order }
    { athrgraph a_throughput_graph }
    { athrgraphvstime a_throughput_vs_time_graph}
    { agoodgraph a_goodput_graph }
    { fairnessgraph fairness_graph }
    { t16rategraph t6_exp_rate_graph }
    { bwreqrategraph bw_request_rate_graph }
    { collrategraph	collision_rate_graph }
    { collprobgraph collision_prob_graph }
    { tcptimeoutrate tcp_timeout_rate }
    { tcppacketlossrate tcp_packet_loss_rate }
}

# command line parameters:

# simulation aspects
set cmd_line_opt(simutime)       1400
set cmd_line_opt(filename)       "./" 
set cmd_line_opt(usenam)         0
set cmd_line_opt(tracing)        0
set cmd_line_opt(substrnum)      1
set cmd_line_opt(ultraffic)      0

#Graphs Metrics
set cmd_line_opt(congestion_window_graph)      	0
set cmd_line_opt(a_throughput_graph)      	   	0
set cmd_line_opt(a_throughput_vs_time_graph)	0
set cmd_line_opt(fairness_graph)      		   	0
set cmd_line_opt(a_goodput_graph)			   	0
set cmd_line_opt(throughput_order)			   	0
set cmd_line_opt(t6_exp_rate_graph)      	   	0
set cmd_line_opt(collision_rate_graph)		   	0
set cmd_line_opt(collision_prob_graph)		   	0
set cmd_line_opt(bw_request_rate_graph)		   	0
set cmd_line_opt(tcp_timeout_rate)				0
set cmd_line_opt(tcp_packet_loss_rate)			0



# TCP aspects
set cmd_line_opt(segsize)        960 
#set cmd_line_opt(segsize)       1000 
set cmd_line_opt(filesize)       1500000
set cmd_line_opt(tcp_sender)    "Agent/TCP/FullTcp/Newreno"
set cmd_line_opt(tcp_sink)      "Agent/TCP/FullTcp/Newreno"
#set cmd_line_opt(tcp_sender)    "Agent/TCP/Newreno"
#set cmd_line_opt(tcp_sink)      "Agent/TCPSink"
#set cmd_line_opt(tcp_sink)      "Agent/TCPSink/DelAck"

set cmd_line_opt(ackscheme)      "delack"
# convert cmd_line_opt to tcp_opt
set tcp_opt(segsize)           $cmd_line_opt(segsize)  
# Special TCP behavior to limit the burst size after a loss 
set tcp_opt(maxburst)		   0	
set tcp_opt(tcp_sender)        $cmd_line_opt(tcp_sender)    
set tcp_opt(tcp_sink)          $cmd_line_opt(tcp_sink)
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
set cmd_line_opt(aggr_request_period_)	 0
set cmd_line_opt(bw_perception_policy_)	iDDA
set cmd_line_opt(wimax_codification_scheme) OFDM_64QAM_3_4


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
WimaxScheduler/BS set upTransmitLimit_ $cmd_line_opt(up_transmit_limit)
WimaxScheduler/BS set dlTransmitLimit_ $cmd_line_opt(down_transmit_limit)

# ----------
# NS tracing
# ----------

set tf [open /dev/null w]
#set tf [open $cmd_line_opt(filename) w]

# NOTE: trace file must be defined as it is used by the 802.16 MAC.

$ns trace-all $tf

# TODO: remember to name TCP-LAB options. Start defining specific variable-names 
# TODO: for array of options. 

# Create an 802.16 infraestructure:
Class BS-mac-phy-adapter -superclass specifics-802-16

BS-mac-phy-adapter instproc init {args} {
	eval $self next $args
}

Mac/802_16 set aggr_request_period_ $cmd_line_opt(aggr_request_period_)

source ./infrastructure.tcl

Infrastructure my-infra


# Set a  new default modulation, missing to create an access to the  
# scheduler from TCL. Othewise, this operation leaves the old scheduler in 
# memory (memory leak).
set bs_sched [new WimaxScheduler/BS]
$bs_sched set-default-modulation $cmd_line_opt(wimax_codification_scheme)
[$bs_node set mac_(0)] set-scheduler $bs_sched

#Set the bandwidth Perception Policy
[$bs_node set mac_(0)] set-bw-perception-policy $cmd_line_opt(bw_perception_policy_)

# --------------------------------
# Collect Statistics (see TCP-LAB)
# --------------------------------

set tcp_list {}
set tcp_list_down {}
set tcp_list_up {}
set tcp_list_names {}
set cWndGraphsFilelabelList {}

set cross_traffic 0

[$bs_node set mac_(0)] set-channel 0

for {set i 1} {$i <= $cmd_line_opt(number_of_ss)} {incr i} {

 if {$cmd_line_opt(ultraffic) == 0} {
 	#Download Traffic
 	set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
 } else {
 	if {$cmd_line_opt(ultraffic) == 1} {
 		#Upload Traffic
 		set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wl_nodes($i) $wired_node $i]
	 } else {
		#Cross-Traffic
		if {$cross_traffic ==0} {
			#Download
			set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
			set cross_traffic 1
		} else {
			#Upload
			set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wl_nodes($i) $wired_node $i]
			set cross_traffic 0
		}
	}
 }
 
 set snd($i) [lindex $tmp 0]
 set rcv($i) [lindex $tmp 1]
 set ftp_src($i) [lindex $tmp 2]
    
 set-delack-conditions $snd($i) $rcv($i)   

 [$wl_nodes($i) set mac_(0)] set-channel 0
 # TODO: what does set-diuc do if the scheduler has another different diuc?
 [$wl_nodes($i) set mac_(0)] set-diuc $cmd_line_opt(ssdiuc)
 
 # NOTE: Remember that there is some warm-up time for the DSDV protocol to 
 # have the route from the wireless nodes to the base station.
 
 $ns at [expr 3+$i] "$ftp_src($i) start"

 lappend tcp_list $snd($i)
 if {$cmd_line_opt(ultraffic) == 0} {
 	 lappend tcp_list_down $snd($i)
 } else {
 	if {$cmd_line_opt(ultraffic) == 1} {
 		lappend tcp_list_up $snd($i)
 	} else {
		#Cross-Traffic
		if {$cross_traffic ==0} {
			lappend tcp_list_up $snd($i)
		} else {
			lappend tcp_list_down $snd($i)
		}
	}
 }
 
 lappend tcp_list_names "\$snd($i)" 
  
 lappend cWndGraphsFilelabelList "[concat $cmd_line_opt(filename) "$i"]"
}


proc finish {} {

    global ns tcp_list tcp_list_down tcp_list_up wl_nodes bs_node tcp_list_names tf tcpAggregatedThroughputFile tcpAggregatedGoodputFile tcpFairnessFile cmd_line_opt cWndGraphs_list meanT16ExpRateFile bwreqCollisionRateFile bwreqCollisionProbabilityFile bwreqRateFile tcpTimeoutRateFile tcpPacketLossRateFile meanT16ExpRateFileAgg tcpFairnessFileDown tcpFairnessFileUp
    
    $ns flush-trace
    close $tf
    
    #TCP Throughput Order
    if ($cmd_line_opt(throughput_order)) {
    	set tcpOrderFile [open [concat {tcpOrder} $cmd_line_opt(filename)] w+]
    	set thr_l [print-order-throughput $tcp_list $tcp_list_names]
    	set length [llength $thr_l]
    	for { set i 0 } { $i < $length } { incr i } {
      		puts $tcpOrderFile [ lindex $thr_l $i ] 
	  	}
	  	close $tcpOrderFile
    }

    #Aggregated Throughput 
    if ($cmd_line_opt(a_throughput_graph)) {
   	set aggregatedThroughput [expr [expr [get-list-mean-throughput $tcp_list]/1000000]*$cmd_line_opt(number_of_ss)]
    	puts $tcpAggregatedThroughputFile "$cmd_line_opt(number_of_ss) $aggregatedThroughput"
    	close $tcpAggregatedThroughputFile
    }
    
    #Aggregated Goodput
    if ($cmd_line_opt(a_goodput_graph)) {
	   	set aggregatedGoodput [expr [get-total-goodput $tcp_list]/1000000]
    	puts $tcpAggregatedGoodputFile "$cmd_line_opt(number_of_ss) $aggregatedGoodput"
    	close $tcpAggregatedGoodputFile
    }
        
    #Mean T16 Expiration Rate File
	if ($cmd_line_opt(t6_exp_rate_graph)) {
		set result [expr [get-mean-T16-exp-rate wl_nodes]]
    	puts $meanT16ExpRateFile "$cmd_line_opt(number_of_ss) $result"
    	set result [expr $result * $cmd_line_opt(number_of_ss)]
    	puts $meanT16ExpRateFileAgg "$cmd_line_opt(number_of_ss) $result"
    	close $meanT16ExpRateFile
	}

	#BW REQ Collision Rate File
	if ($cmd_line_opt(collision_rate_graph)) {
		set result [expr [[$bs_node set mac_(0)] get-bwreq-collision-rate]]
    	puts $bwreqCollisionRateFile "$cmd_line_opt(number_of_ss) $result"
    	close $bwreqCollisionRateFile
	}

	#BW REQ Collision Probability File
	if ($cmd_line_opt(collision_prob_graph)) {
		set result [expr [get-bwreq-collision-probability $bs_node wl_nodes]]
    	puts $bwreqCollisionProbabilityFile "$cmd_line_opt(number_of_ss) $result"
    	close $bwreqCollisionProbabilityFile
	}

	#Mean BW REQ Rate File
	if ($cmd_line_opt(bw_request_rate_graph)) {
		set result [expr [get-mean-bwreq-rate wl_nodes]]
    	puts $bwreqRateFile "$cmd_line_opt(number_of_ss) $result"
    	close $bwreqRateFile
	}
	
	#TCP timeout rate File
	if ($cmd_line_opt(tcp_timeout_rate)) {
		set result [expr [get-mean-tcp-timeout-rate $tcp_list]]
    	puts $tcpTimeoutRateFile "$cmd_line_opt(number_of_ss) $result"
    	close $tcpTimeoutRateFile
	}

	#TCP packet loss rate File
	if ($cmd_line_opt(tcp_packet_loss_rate)) {
		set result [expr [get-mean-tcp-packet-loss-rate $tcp_list]]
    	puts $tcpPacketLossRateFile "$cmd_line_opt(number_of_ss) $result"
    	close $tcpPacketLossRateFile
	}
   
    #Fairness Index
    if ($cmd_line_opt(fairness_graph)) {
    
    	if {$cmd_line_opt(ultraffic) == 2} {
    		set fairness [expr [get-fairness-index $tcp_list_up]]
    		puts $tcpFairnessFileUp "$cmd_line_opt(number_of_ss) $fairness"
    		close $tcpFairnessFileUp
    		
    		set fairness [expr [get-fairness-index $tcp_list_down]]
    		puts $tcpFairnessFileDown "$cmd_line_opt(number_of_ss) $fairness"
    		close $tcpFairnessFileDown
		} else {	
    		set fairness [expr [get-fairness-index $tcp_list]]
    		puts $tcpFairnessFile "$cmd_line_opt(number_of_ss) $fairness"
    		close $tcpFairnessFile
    	}
    }
    
    #Congestion Window Graph
    if { [llength $cWndGraphs_list] > 0 } {
       end-graphs $cWndGraphs_list 
    } 
    
    exit 0
}


#TCP Congestion Window Graph
set cWndGraphs_list {}
if ($cmd_line_opt(congestion_window_graph)) {
	open-file-graph
	if ([llength $cWndGraphsFilelabelList]<[llength $tcp_list]) {
		puts "ERROR: Graphs List Length < Tcp List Length";
		exit 1;
	}
	set cWndGraphs_list [create-tcp-graphs [list "cwnd_"] $tcp_list $cWndGraphsFilelabelList]
}

set filemanEnd "$cmd_line_opt(dlratio)k$cmd_line_opt(down_transmit_limit)AggPeriod$cmd_line_opt(aggr_request_period_)-$cmd_line_opt(bw_perception_policy_)-cschm$cmd_line_opt(wimax_codification_scheme)"


#Open TCP Aggregated Throughput Trace File
if ($cmd_line_opt(a_throughput_graph)) {
	set tcpAggregatedThroughputFile [open [concat {aThroughput} $filemanEnd] a+]
}

#TCP Aggregated Throughput vs Time Trace File
if ($cmd_line_opt(a_throughput_vs_time_graph)) {
	set th_ [new AThroughput $tcp_list 2.8 $cmd_line_opt(filename)] 
}

#Open TCP Aggregated Goodput Trace File
if ($cmd_line_opt(a_goodput_graph)) {
	set tcpAggregatedGoodputFile [open [concat {aGoodput} $filemanEnd] a+]
}

#Open Mean T16 Expiration Rate File
if ($cmd_line_opt(t6_exp_rate_graph)) {
	set meanT16ExpRateFile [open [concat {t16Rate} $filemanEnd] a+]
	set meanT16ExpRateFileAgg [open [concat {t16RateAgg} $filemanEnd] a+]
}

#Open BW REQ Collision Rate File
if ($cmd_line_opt(collision_rate_graph)) {
	set bwreqCollisionRateFile [open [concat {collRate} $filemanEnd] a+]
}

#Open BW REQ Collision Probability File
if ($cmd_line_opt(collision_prob_graph)) {
	set bwreqCollisionProbabilityFile [open [concat {collProb} $filemanEnd] a+]
}

#Open Mean BW REQ Rate File
if ($cmd_line_opt(bw_request_rate_graph)) {
	set bwreqRateFile [open [concat {bwreqRate} $filemanEnd] a+]
}

#Open TCP timeout rate File
if ($cmd_line_opt(tcp_timeout_rate)) {
	set tcpTimeoutRateFile [open [concat {tcpTimeoutRate} $filemanEnd] a+]
}

#Open TCP packet loss rate File
if ($cmd_line_opt(tcp_packet_loss_rate)) {
	set tcpPacketLossRateFile [open [concat {tcpPacketLossRate} $filemanEnd] a+]
}


#Open Mean Fairness 
if ($cmd_line_opt(fairness_graph)) {
	if {$cmd_line_opt(ultraffic) == 2} {
		set tcpFairnessFileUp [open [concat {fairnessUp} $filemanEnd] a+]
		set tcpFairnessFileDown [open [concat {fairnessDown} $filemanEnd] a+]
	} else {
		set tcpFairnessFile [open [concat {fairness} $filemanEnd] a+]
	}
}


#Reset Stats - Purge initial 
set ftpReset 400
$ns at $ftpReset "[init-stats-tcp-list $tcp_list]"

$ns at $cmd_line_opt(simutime) "finish"

$ns run
