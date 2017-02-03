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
