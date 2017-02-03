# By Andrés Arcia (sept/08)
# Testing a 802.11 infrastructure. 

source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl
source ../../../includes/tcl-tcp-lab/tcplab-metrics.tcl
source ../../../includes/tcl-tcp-lab/tcplab-flows.tcl
source ../../../includes/tcl-tcp-lab/getopt.tcl


# ------------------------
# Global variables section
# ------------------------

global cmd_line_opt
global bs_opt
global wl_nodes
global wired_node
global bs_node
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
}

# command line parameters:

# simulation aspects
set cmd_line_opt(simutime)       100
set cmd_line_opt(filename)       "output/experiment"
set cmd_line_opt(usenam)         0
set cmd_line_opt(tracing)        0
set cmd_line_opt(substrnum)      1

# TCP aspects
set cmd_line_opt(segsize)        960
set cmd_line_opt(filesize)       1500000
set cmd_line_opt(tcp_sender)    "Agent/TCP/Newreno"
set cmd_line_opt(tcp_sink)      "Agent/TCPSink"
set cmd_line_opt(ackscheme)      "delack"
# convert cmd_line_opt to tcp_opt
set tcp_opt(segsize)           $cmd_line_opt(segsize)       
set tcp_opt(tcp_sender)        $cmd_line_opt(tcp_sender)    
set tcp_opt(tcp_sink)          $cmd_line_opt(tcp_sink)
# TCP flows statistics
set tcp_opt(reset_stats)    0.4
set tcp_opt(auto_rwnd)      0
set tcp_opt(auto_ssth)      0
# 
set tcp_opt(initialwin)     4
set tcp_opt(ssthresh)       40
set tcp_opt(maxburst)		5
# WiFi aspects
set cmd_line_opt(number_of_ss)   1
set cmd_line_opt(bs_buffer_size) 50

# To see all the cmd_line_opt array
# print_opt

# decode the input parameters
my_getopt $argv

# ----------
# NS tracing
# ----------

set tf [open $cmd_line_opt(filename) w]

$ns trace-all $tf

# TODO: remember to name TCP-LAB options. Start defining specific variable-names 
# TODO: for array of options. 

# Create an 802.16 infraestructure:

source ./wifi-settings.tcl

Class BS-mac-phy-adapter -superclass specifics-802-11

BS-mac-phy-adapter instproc init {args} {

eval $self next $args
}

source ../infrastructure.tcl

Infrastructure my-infra

# --------------------------------
# Collect Statistics (see TCP-LAB)
# --------------------------------

set tcp_list {}

for {set i 1} {$i <= $cmd_line_opt(number_of_ss)} {incr i} {
 set tmp [create-ftp-over-tcp-agent $cmd_line_opt(tcp_sender) $cmd_line_opt(tcp_sink) $wired_node $wl_nodes($i) $i]
	    
 set snd($i) [lindex $tmp 0]
 set rcv($i) [lindex $tmp 1]
 set ftp_src($i) [lindex $tmp 2]
    
 set-delack-conditions $snd($i) $rcv($i)    
   
 # NOTE: Remember that there is some warm-up time for the DSDV protocol to 
 # have the route from the wireless nodes to the base station.
 
 $ns at 10 "$ftp_src($i) start"

 lappend tcp_list $snd($i)
}


proc finish {} {

    global ns tcp_list tf gr_list

    $ns flush-trace

    close $tf
    
    if { [llength $gr_list] > 0 } {
        end-graphs $gr_list 
    }   
    
    puts "Mean goodput: [get-mean-goodput $tcp_list]"
    
    exit 0
}

# since there are losses at the wired node, one possible reason is the maxburst_ 
# variable.
puts "max burst = [$snd(1) set maxburst_]"
$snd(1) set maxburst_ 3

set gr_list [create-tcp-graphs [list "cwnd_" "t_seqno_"] [list "$snd(1)" "$snd(1)"] [list "snd_1" "snd_1"]]

$ns at $cmd_line_opt(simutime) "finish"

$ns run
