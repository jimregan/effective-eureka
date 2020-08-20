#!/usr/bin/perl

my %inserts = ();
my %symbols = (
	'<eps>' => 0,
);
my %seen = ();

open(LAT, '<', $ARGV[0]);
open(INSERTS, '<', $ARGV[1]);

my $symcnt = 1;
while(<INSERTS>) {
	chomp;
	$symbols{$_} = $symcnt;
	$symcnt++;
}
close(INSERTS);
open(OUTFST, '>', 'inserts.fst.txt');
open(SYMS, '>', 'inserts-symbols.txt');

# state 0 is the start state, so 'first' state is 1
my $state = 1;
while(<LAT>) {
	chomp;
	next if($_ !~ / /);
	my @p = split/ /;
	next if($#p < 3);
	if(exists $seen{$word}) {
		next;
	} else {
		if(!exists $symbols{$word}) {
			$symbols{$word} = $symcnt;
			$symcnt++;
		}
		for my $ins (keys %inserts) {
			print OUTFST "0\t$state\t<eps>\t$ins\t$weight\n";
			$next = $state + 1;
			print OUTFST "$state\t$next\t$word\t$word\n";
			$state = $next;
		}
		$seen{$word} = 1;
	}
}

for my $k (keys %symbols) {
	print SYMS "$k\t$symbols{$k}\n";
}
