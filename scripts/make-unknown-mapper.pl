#!/usr/bin/perl

use warnings;
use strict;
use utf8;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

open(SYMTAB, '<', $ARGV[0]) or die $!;
binmode(SYMTAB, ":utf8");

my %symbols = ();
while(<SYMTAB>) {
	chomp;
	my @l = split/ /;
	$symbols{$l[0]} = 1;
}
close(SYMTAB);

my %seen = ();
while(<STDIN>) {
	chomp;
	my @line = split/[ \t]/;
	next if($#line < 2);
	next if(exists $seen{$line[2]});
	if(exists $symbols{$line[2]}) {
		print "0 0 $line[2] $line[2]\n";
		$seen{$line[2]} = 1;
	} else {
		print "0 0 $line[2] <unk>\n";
		$seen{$line[2]} = 1;
	}
}
print "0\n";

