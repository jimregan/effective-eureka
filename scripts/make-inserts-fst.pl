#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my %inserts = ();
my %symbols = (
	'<eps>' => 0,
);
my %seen = ();

open(LAT, '<', $ARGV[0]) or die $!;
open(INSERTS, '<', $ARGV[1]) or die $!;
binmode(LAT, ":utf8");
binmode(INSERTS, ":utf8");
binmode(STDERR, ":utf8");

my $symcnt = 1;
while(<INSERTS>) {
	chomp;
	$symbols{$_} = $symcnt;
	$inserts{$_} = 1;
	$symcnt++;
}
close(INSERTS);
open(OUTFST, '>', 'inserts.fst.txt');
open(SYMS, '>', 'inserts-symbols.txt');
binmode(OUTFST, ":utf8");
binmode(SYMS, ":utf8");

# state 0 is the start state, so 'first' state is 1
my $state = 1;
while(<LAT>) {
	chomp;
	next if($_ !~ / /);
	my @p = split/ /;
	my $word = $p[2];
	next if($#p < 3);
	if(exists $seen{$word}) {
		next;
	} else {
		if(!exists $symbols{$word}) {
			$symbols{$word} = $symcnt;
			$symcnt++;
		}
		for my $ins (keys %inserts) {
			print OUTFST "0\t$state\t<eps>\t$ins\n";
			my $next = $state + 1;
			print OUTFST "$state\t$next\t$word\t$word\n";
			print OUTFST "$next\n";
			$state = $next + 1;
		}
		$seen{$word} = 1;
	}
}
close(LAT);
close(OUTFST);

for my $k (keys %symbols) {
	print SYMS "$k\t$symbols{$k}\n";
}
close(SYMS);
