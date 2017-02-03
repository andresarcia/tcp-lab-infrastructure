# By Andrs Arcia (sept/08)
# Testing a 802.16 infrastructure. 

source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl
source /usr/local/tcp-lab/trunk/includes/tcl/tcplab-flows.tcl
source /usr/local/tcp-lab/trunk/includes/tcl/getopt.tcl


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

#TCP Traffic Start
set trafficStart 2


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
}

# command line parameters:

# simulation aspects
set cmd_line_opt(simutime)       4000
set cmd_line_opt(filename)       "./" 
set cmd_line_opt(usenam)         0
set cmd_line_opt(tracing)        0
set cmd_line_opt(substrnum)      1

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
set cmd_line_opt(bs_buffer_size) 50
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

# ----------
# NS tracing
# ----------

set tf [open $cmd_line_opt(filename) w]

# NOTE: trace file must be defined as it is used by the 802.16 MAC.

$ns trace-all $tf

# TODO: remember to name TCP-LAB options. Start defining specific variable-names 
# TODO: for array of options. 

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

set tcp_list {}
set cWndGraphsFilelabelList {}

[$bs_node set mac_(0)] set-channel 0

for {set i 1} {$i <= $cmd_line_opt(number_of_ss)} {incr i} {
	set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
		    
	set snd($i) [lindex $tmp 0]
	set rcv($i) [lindex $tmp 1]
	set ftp_src($i) [lindex $tmp 2]
	    
	set-delack-conditions $snd($i) $rcv($i)   
	
	[$wl_nodes($i) set mac_(0)] set-channel 0
	# TODO: what does set-diuc do if the scheduler has another different diuc?
	[$wl_nodes($i) set mac_(0)] set-diuc $cmd_line_opt(ssdiuc)
	 
	# NOTE: Remember that there is some warm-up time for the DSDV protocol to 
	# have the route from the wireless nodes to the base station.
	
	$ns at [expr $trafficStart+$i] "$ftp_src($i) start"
	
	lappend tcp_list $snd($i)
	lappend cWndGraphsFilelabelList "[concat $cmd_line_opt(filename) "$i"]"
}


#Reset after warm-up time init-stats-tcp-list $lr_list

proc finish {} {

   global ns tcp_list cWndTraceFile_list tf tcpTraceThroughputFile cWndGraphs_list

   $ns flush-trace

   close $tf
	
   close $tcpTraceThroughputFile
	
  if { [llength $cWndGraphs_list] > 0 } {
       end-graphs $cWndGraphs_list 
   } 

   #puts "Mean goodput: [get-mean-goodput $tcp_list]"
	
   puts "Mean Throughput: [expr [get-list-mean-throughput $tcp_list]/1000000]"

   exit 0
}


#Throughput Graph
proc traceThroughput {file} {
	global ns tcp_list
	set time 0.01
	set now [$ns now]
	set thr [expr [get-list-mean-throughput $tcp_list]/1000000]
	puts $file "$now $thr"
	$ns at [expr $now+$time] "traceThroughput $file"
}

#Open TCP Throughput Trace File
set tcpTraceThroughputFile [open [concat $cmd_line_opt(filename) {ThroughputGraph}] w]
$ns at 0.0 "traceThroughput $tcpTraceThroughputFile"

#CWndGraphs
open-file-graph
if ([llength $cWndGraphsFilelabelList]<[llength $tcp_list]) {
	puts "ERROR: Graphs List Length < Tcp List Length";
	exit 1;
}
set cWndGraphs_list [create-tcp-graphs [list "cwnd_"] [list "$tcp_list"] [list "$cWndGraphsFilelabelList"]]

#TODO Save the aggregated throughput in a plot file to get Addissu Graphps
#set ftpReset [expr 0.35*$simu_time]
#$ns at $ftpReset "[init-stats-tcp-list $tcp_list]"

$ns at $cmd_line_opt(simutime) "finish"

$ns run
Class specifics-802-16 

specifics-802-16 instproc init {args} {

global bs_opt

set bs_opt(phy)    Phy/WirelessPhy/OFDM       ;# network interface type
set bs_opt(BSmac)  Mac/802_16/BS              ;# BS MAC type
set bs_opt(HSmac)  Mac/802_16/SS              ;# SS MAC type

# Parameter for 802.16 nodes: BS and SS.

$self set-802-16-mac
$self set-802-16-phy

}

specifics-802-16 instproc set-802-16-mac {} {

Mac/802_16 set debug_ 0
Mac/802_16 set rtg_ 10
Mac/802_16 set ttg_ 10
# in secs:
Mac/802_16 set frame_duration_ 0.005
# client_timeout_ avoids BS disconnecting the SS
Mac/802_16 set client_timeout_ 50
Mac/802_16 set fbandwidth_ 7.0e6
Mac/802_16 set t16_timeout_ 0.05	
}

specifics-802-16 instproc set-802-16-phy {} {

# Richard had g_ = 0.025
Phy/WirelessPhy/OFDM set g_ 0.0625
#define coverage area for base station: 20m coverage 
Phy/WirelessPhy set Pt_ 0.025
#taken from Addisu's code
Phy/WirelessPhy set freq_ 3.5e9
#Phy/WirelessPhy set RXThresh_ 2.90781e-09
Phy/WirelessPhy set RXThresh_ 2.025e-12 ;#500m radius
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]

}
# By Andrs Arcia (sept/08)
# Testing a 802.16 infrastructure. 

source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl
source /usr/local/tcp-lab/trunk/includes/tcl/tcplab-flows.tcl
source /usr/local/tcp-lab/trunk/includes/tcl/getopt.tcl


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
}

# command line parameters:

# simulation aspects
set cmd_line_opt(simutime)       4000
set cmd_line_opt(filename)       "./" 
set cmd_line_opt(usenam)         0
set cmd_line_opt(tracing)        0
set cmd_line_opt(substrnum)      1

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
set cmd_line_opt(bs_buffer_size) 50
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

# ----------
# NS tracing
# ----------

set tf [open $cmd_line_opt(filename) w]

# NOTE: trace file must be defined as it is used by the 802.16 MAC.

$ns trace-all $tf

# TODO: remember to name TCP-LAB options. Start defining specific variable-names 
# TODO: for array of options. 

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

set tcp_list {}

[$bs_node set mac_(0)] set-channel 0

for {set i 1} {$i <= $cmd_line_opt(number_of_ss)} {incr i} {
set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
	    
set snd($i) [lindex $tmp 0]
set rcv($i) [lindex $tmp 1]
set ftp_src($i) [lindex $tmp 2]

set-delack-conditions $snd($i) $rcv($i)   

[$wl_nodes($i) set mac_(0)] set-channel 0
# TODO: what does set-diuc do if the scheduler has another different diuc?
[$wl_nodes($i) set mac_(0)] set-diuc $cmd_line_opt(ssdiuc)

# NOTE: Remember that there is some warm-up time for the DSDV protocol to 
# have the route from the wireless nodes to the base station.

$ns at [expr 15+$i] "$ftp_src($i) start"

lappend tcp_list $snd($i)
}


#Reset after warm-up time init-stats-tcp-list $lr_list

proc finish {} {

   global ns tcp_list tf tcpTraceThroughputFile 

   $ns flush-trace

   close $tf
	
   close $tcpTraceThroughputFile

   #puts "Mean goodput: [get-mean-goodput $tcp_list]"
	
   puts "Mean Throughput: [expr [get-list-mean-throughput $tcp_list]/1000000]"

   exit 0
}


#Throughput Graph
proc traceThroughput {file} {
	global ns tcp_list
	set time 0.01
	set now [$ns now]
	set thr [expr [get-list-mean-throughput $tcp_list]/1000000]
	puts $file "$now $thr"
	$ns at [expr $now+$time] "traceThroughput $file"
}

#Open TCP Throughput Trace File
set tcpTraceThroughputFile [open [concat $cmd_line_opt(filename) {ThroughputGraph}] w]
$ns at 0.0 "traceThroughput $tcpTraceThroughputFile"

#TODO Save the aggregated throughput in a plot file to get Addissu Graphps
#set ftpReset [expr 0.35*$simu_time]
#$ns at $ftpReset "[init-stats-tcp-list $tcp_list]"

$ns at $cmd_line_opt(simutime) "finish"

$ns run

# TODO: review this.
# Traffic scenario: if all the nodes start talking at the same
# time, we may see packet loss due to bandwidth request collision. 
# ANYWAY, isn't there a random backoff to avoid this?
# set diff 0.02
#for {set i 0} {$i < $nb_mn} {incr i} {
#    $ns at [expr $traffic_start+$i*$diff] "$cbr_($i) start"
#    $ns at [expr $traffic_stop+$i*$diff] "$cbr_($i) stop"
#}
#$ns at 4 "$nd_(1) dump-table"
#$ns at 5 "$nd_(1) send-rs"
#$ns at 6 "$nd_(1) dump-table"
#$ns at 8 "$nd_(1) dump-table"
