#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use JSON;

my %refs = ();

if($#ARGV == 1) {
	open(REFS, '<', $ARGV[1]);
	binmode(REFS, ":utf8");
	while(<REFS>) {
		chomp;
		my @parts = split/ /;
		my $id = shift @parts;
		$refs{$id} = join(' ', @parts);
	}
	close(REFS);
}
open(IN, '<', $ARGV[0]);
binmode(IN, ":utf8");
my %output = ();
my %curhyps = ();
my $curid = '';
while(<IN>) {
	chomp;
	my @parts = split/ /;
	my $id = shift @parts;
	my ($base, $hyp) = split/\-/, $id;
	if($curid eq '') {
		$curid = $base;
	} elsif($curid ne $base) {
		#print
		if(exists $refs{$curid}) {
			$curhyps{'ref'} = $refs{$curid};
		}
		$output{$curid} = \%curhyps;
		%curhyps = ();
		$curid = $base;
	}
	$curhyps{"hyp_$hyp"} = { 'text' => join(' ', @parts) }; 
}
my %print = ();
$print{$curid} = \%curhyps;
if(exists $refs{$curid}) {
	$curhyps{'ref'} = $refs{$curid};
}
$output{$curid} = \%curhyps;
print JSON->new->utf8->encode(\%output) . "\n";
