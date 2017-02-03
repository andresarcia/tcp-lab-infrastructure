#!/usr/bin/perl -w

#`ns throughput.tcl -fn "out.res" -nbss 1 -stime 50 -dlr 0.5 -bwp dDDA`;

@ms_nb_array = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
@bwp_array = ("dDDA", "iDDA");

foreach $bwp (@bwp_array) {
	$outflname =$bwp."thrput.out"; 
	`rm $outflname`;

	$outflname =$bwp."bwColPro.out"; 
	`rm $outflname`;

	foreach $ms_nb (@ms_nb_array) {
		$ns_cmd ='ns throughput.tcl -fn "/dev/null" -stime 1000 -dlr 0.5';
		$ns_cmd .= " -bwp ";
		$ns_cmd .= $bwp;
		$ns_cmd .= " -nbss ";
		$ns_cmd .= $ms_nb;
		system($ns_cmd);
	}
}

draw_figure("thrput.eps", "thrput.out","Number of MS", "Aggregated Throughput (Mbps)");
draw_figure("bwColPro.eps", "bwColPro.out","Number of MS", "Collision Probability");

`mv thrput.eps output/`;
`mv bwColPro.eps output/`;

sub draw_figure {
	my ($out_flname,$input_flname,$xlabel, $ylabel) = @_;

	my $gnuplot_file = "draw.plt";
	my $fh_plot_file;

	open $fh_plot_file, ">$gnuplot_file" || die "can't open file $gnuplot_file\n";

	$dDDA_flname = "dDDA".$input_flname;
	$iDDA_flname = "iDDA".$input_flname;
	print $fh_plot_file <<GNUPLOT_GRAPH;
set terminal postscript eps
set out "$out_flname"
set xlabel "$xlabel"
set ylabel "$ylabel"
plot "$dDDA_flname" using 1:2 ti "dDDA" with linespoints pt 1, "$iDDA_flname" using 1:2 ti "iDDA" with linespoints pt 4;
GNUPLOT_GRAPH

	close $fh_plot_file;

	`gnuplot $gnuplot_file`;
	`rm "$gnuplot_file"`;
} # end of sub draw_figure
