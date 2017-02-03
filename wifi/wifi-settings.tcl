Class specifics-802-11

specifics-802-11 instproc init {args} {

global bs_opt

set bs_opt(phy)    Phy/WirelessPhy         ;# network interface type
set bs_opt(BSmac)  Mac/802_11              ;# BS MAC type
set bs_opt(HSmac)  Mac/802_11              ;# SS MAC type

# Parameter for 802.16 nodes: BS and SS.

$self set-802-11-mac
$self set-802-11-phy

}

specifics-802-11 instproc set-802-11-mac {} {

#Rate for Data Frames
Mac/802_11 set dataRate_ 11Mb   
#Rate for Control Frames
Mac/802_11 set basicRate_ 2Mb    
#Changing the default value as in the test-suite-WLtutorial.tcl
Mac/802_11 set bugFix_timer_ false;
}

specifics-802-11 instproc set-802-11-phy {} {

#Data Rate 
Phy/WirelessPhy set bandwidth_ 11Mb   
#Transmit Power (15dBm)
Phy/WirelessPhy set Pt_ 0.031622777    
#Collision Threshold
Phy/WirelessPhy set CPThresh_ 10.0   
#Carrier Sense Power (-94dBm)
Phy/WirelessPhy set CSThresh_ 3.1622777e-14   
#Receive Power Threshold
Phy/WirelessPhy set RXThresh_ 3.1622777e-13  

}
