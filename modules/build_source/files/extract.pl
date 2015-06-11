#!/usr/bin/perl
my $file=$ARGV[0];
sub extract {
	if($_[0] == 0) {
		`tar xf $file`;
	}
	else{
		`tar xf $file --strip-components 1`;
	}
}
@res = `tar --exclude="*/*" -tf $file`;
foreach $line(@res) {
	if ($line eq "configure\n"){
		extract(0);
		exit 0;
	}
}
extract(1);
