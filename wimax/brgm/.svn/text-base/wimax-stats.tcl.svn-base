# This module contains fucntions for obtaining WiMAX statistics.
# Paltrinieri Alejandro  (University of Buenos Aires, Argentina)
#
# init-stats         		initializes stats for the given SS or BS.
# init-stats-wimax	 		initializes stats for the given list of SSs and for the given BS
# get-T16-exp-rate	 		return the T16 expiration rate for a given SS 	
# get-mean-T16-exp-rate 	return the mean T16 expiration rate for a given list of SSs 	
# get-collision-rate 
# get-bwreq-collision-rate
# get-bwreq-collision-probability

Mac/802_16/SS instproc init-stats {} {
  set ns [Simulator instance]
  $self instvar monitor_begin_time_ 
  $self instvar t16_expiration_counter_ bwreq_sent_counter_ 

  set monitor_begin_time_ [$ns now]

  set t16_expiration_counter_ 0
  set bwreq_sent_counter_ 0
}

Mac/802_16/BS instproc init-stats {} {
  set ns [Simulator instance]
  $self instvar monitor_begin_time_ 
  $self instvar collision_counter_ bwreq_collision_counter_ bwreq_loss_counter_

  set monitor_begin_time_ [$ns now]

  set collision_counter_ 0
  set bwreq_collision_counter_ 0
  set bwreq_loss_counter_ 0
}


proc init-stats-wimax { bs_node ss_list } {
	
	upvar $ss_list sslist

    set length [array size sslist]
    
    [$bs_node set mac_(0)] init-stats
  	    
    for { set i 1 } { $i <= $length } { incr i } {
        [$sslist($i) set mac_(0)] init-stats
    }
     
}

Mac/802_16/SS instproc get-T16-exp-rate {} {
 	$self instvar monitor_begin_time_ t16_expiration_counter_
 	set ns [Simulator instance]

 	if { [ info exists monitor_begin_time_] } {
   		set begin $monitor_begin_time_
 	} else {
   		set begin 0.0
 	}

 	set duration [expr [$ns now] - $begin]
 	if { $duration == 0.0 } {
   		return 0.0
 	} else {
   		return [expr ($t16_expiration_counter_+0.0) / $duration]
 	}
}

Mac/802_16/SS instproc get-bwreq-rate {} {
 	$self instvar monitor_begin_time_ bwreq_sent_counter_
 	set ns [Simulator instance]

 	if { [ info exists monitor_begin_time_] } {
   		set begin $monitor_begin_time_
 	} else {
   		set begin 0.0
 	}

 	set duration [expr [$ns now] - $begin]
 	if { $duration == 0.0 } {
   		return 0.0
 	} else {
   		return [expr ($bwreq_sent_counter_+0.0) / $duration]
 	}
}

proc get-mean-bwreq-rate { sslist } {
	upvar $sslist ss_list
	set sum 0.0
  	set length [array size ss_list]

  	for { set i 1 } { $i <= $length } { incr i } {
    	set sum [expr $sum + [[$ss_list($i) set mac_(0)] get-bwreq-rate]]
  	}
  	return [expr $sum / $length]

}

proc get-mean-T16-exp-rate { sslist } {
	upvar $sslist ss_list
	set sum 0.0
  	set length [array size ss_list]

  	for { set i 1 } { $i <= $length } { incr i } {
    	set sum [expr $sum + [[$ss_list($i) set mac_(0)] get-T16-exp-rate]]
  	}
  	return [expr $sum / $length]
}

Mac/802_16/BS instproc get-collision-rate {} {
	$self instvar monitor_begin_time_ collision_counter_
 	set ns [Simulator instance]

 	if { [ info exists monitor_begin_time_] } {
   		set begin $monitor_begin_time_
 	} else {
   		set begin 0.0
 	}

 	set duration [expr [$ns now] - $begin]
 	if { $duration == 0.0 } {
   		return 0.0
 	} else {
   		return [expr ($collision_counter_+0.0) / $duration]
 	}
}

Mac/802_16/BS instproc get-bwreq-collision-rate {} {
	$self instvar monitor_begin_time_ bwreq_collision_counter_
 	set ns [Simulator instance]
 	set result 0.0

 	if { [ info exists monitor_begin_time_] } {
   		set begin $monitor_begin_time_
 	} else {
   		set begin 0.0
 	}

 	set duration [expr [$ns now] - $begin]
 	if { $duration == 0.0 } {
   		set result 0.0
 	} else {
   		set result [expr ($bwreq_collision_counter_+0.0) / $duration]
 	}

 	return $result
}

proc get-bwreq-collision-probability { bs_node sslist } {
	upvar $sslist ss_list
	set length [array size ss_list]
	set sum 0.0

  	for { set i 1 } { $i <= $length } { incr i } {
    	set sum [expr $sum + [[ $ss_list($i) set mac_(0)] set bwreq_sent_counter_]]
  	}
  	
  	return [expr [[$bs_node set mac_(0)] set bwreq_loss_counter_] / $sum]
}


#TCP Metrics
#TODO: Move to tcplab-metrics

Agent/TCP instproc get-timeout-rate {} {
  	set ns [Simulator instance]
  	$self instvar tcp_monitor_begin_time_ 
  	$self instvar nrexmit_ 

 	set result 0.0

 	if { [ info exists monitor_begin_time_] } {
   		set begin $monitor_begin_time_
 	} else {
   		set begin 0.0
 	}

 	set duration [expr [$ns now] - $begin]
 	if { $duration == 0.0 } {
   		set result 0.0
 	} else {
   		set result [expr ($nrexmit_+0.0) / $duration]
 	}

	return $result
}

Agent/TCP instproc get-packet-loss-rate {} {
  	set ns [Simulator instance]
  	$self instvar tcp_monitor_begin_time_ 
  	$self instvar nrexmitpack_ 

 	set result 0.0

 	if { [ info exists monitor_begin_time_] } {
   		set begin $monitor_begin_time_
 	} else {
   		set begin 0.0
 	}

 	set duration [expr [$ns now] - $begin]
 	if { $duration == 0.0 } {
   		set result 0.0
 	} else {
   		set result [expr ($nrexmitpack_+0.0) / $duration]
 	}

	return $result
}

proc get-mean-tcp-timeout-rate { tcp } {
	set length [llength $tcp]
    set sum 0.0
    
    if { $length == 0 } {
	error "Error: empty TCP flow list to in init-stats";
    }
    
    for { set i 0 } { $i < $length } { incr i } {
        set sum [expr $sum + [[lindex $tcp $i] get-timeout-rate]]
    }
    
    return [expr $sum / $length]
}

proc get-mean-tcp-packet-loss-rate { tcp } {
	set length [llength $tcp]
    set sum 0.0
    
    if { $length == 0 } {
	error "Error: empty TCP flow list to in init-stats";
    }
    
    for { set i 0 } { $i < $length } { incr i } {
        set sum [expr $sum + [[lindex $tcp $i] get-packet-loss-rate]]
    }
    
    return [expr $sum / $length]
}