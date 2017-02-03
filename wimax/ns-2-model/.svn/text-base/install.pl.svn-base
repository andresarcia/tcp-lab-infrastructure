#!/usr/bin/perl -w

# Provide the correct path to ns-2.33
$PATH_TO_NS_2_33="/usr/local/ns-allinone-2.33/ns-2.33";

if (-e "$PATH_TO_NS_2_33/VERSION")
{
    open TMP, "$PATH_TO_NS_2_33/VERSION";
    $_=<TMP>;
    if ($_ != "2.33")
    {
	print STDERR "ERROR: This is not the 2.33 version of ns";
    } 
}
else
{
    print STDERR "ERROR: Path to ns-2.33 not found";
    exit 1;
}

$path = `pwd`;
chop $path;
#Tcp
#print "TCP Files\n";
#@tcp_files = <./tcp/*>;
#foreach $tcp_file (@tcp_files) {
#	$tcp_file = substr $tcp_file,2;
#	print  "$tcp_file \n"; 
#  print `mv -f $PATH_TO_NS_2_33/$tcp_file $PATH_TO_NS_2_33/$tcp_file-backup `;
#  $fullpath = "$path"."/"."$tcp_file";
#  print $fullpath . "\n";
#  print `ln -s "$fullpath" "$PATH_TO_NS_2_33/$tcp_file"`;
#}

#wimax
print "WiMAX Files\n";

@wimax_files = <./wimax/*.*>;
foreach $wimax_file (@wimax_files) {
	$wimax_file = substr $wimax_file,2;
	print  "$wimax_file \n"; 
  #print `mv -f $PATH_TO_NS_2_33/$wimax_file $PATH_TO_NS_2_33/$wimax_file-backup `;
  print `rm -f $PATH_TO_NS_2_33/$wimax_file`;
  $fullpath = "$path"."/"."$wimax_file";
  print $fullpath . "\n";
  print `ln -s "$fullpath" "$PATH_TO_NS_2_33/$wimax_file"`;
}

@wimax_files = <./wimax/*/*>;
foreach $wimax_file (@wimax_files) {
	$wimax_file = substr $wimax_file,2;
	print  "$wimax_file \n"; 
# print `mv -f $PATH_TO_NS_2_33/$wimax_file $PATH_TO_NS_2_33/$wimax_file-backup `;
  print `rm -f $PATH_TO_NS_2_33/$wimax_file`;
  $fullpath = "$path"."/"."$wimax_file";
  print $fullpath . "\n";
  print `ln -s "$fullpath" "$PATH_TO_NS_2_33/$wimax_file"`;
}

#TCL FILES
print "TCL Files\n";
@tcl_files = <./tcl/*.*>;
foreach $tcl_file (@tcl_files) {
	$tcl_file = substr $tcl_file,2;
	print  "$tcl_file \n"; 
#  print `mv -f $PATH_TO_NS_2_33/$tcl_file $PATH_TO_NS_2_33/$tcl_file-backup `;
  print `rm -f $PATH_TO_NS_2_33/$wimax_file`;
  $fullpath = "$path"."/"."$tcl_file";
  print $fullpath . "\n";
  print `ln -s "$fullpath" "$PATH_TO_NS_2_33/$tcl_file"`;
}

#@tcl_files = <./tcl/*/*>;
foreach $tcl_file (@tcl_files) {
	$tcl_file = substr $tcl_file,2;
	print  "$tcl_file \n"; 
# print `mv -f $PATH_TO_NS_2_33/$tcl_file $PATH_TO_NS_2_33/$tcl_file-backup `;
  print `rm -f $PATH_TO_NS_2_33/$wimax_file`;
  $fullpath = "$path"."/"."$tcl_file";
  print $fullpath . "\n";
  print `ln -s "$fullpath" "$PATH_TO_NS_2_33/$tcl_file"`;
}


print <<FINAL_NOTE;

Now, manually add the correspondant lines in 'add-to-makefile.in' to
your Makefile.in located in your ns-2.33 directory. Then './configure' and
'make'.

Add also the object file tcp-full-newreno.o in the same line of tcp-full.o,
this separation make the code little bit more readable. 

FINAL_NOTE
