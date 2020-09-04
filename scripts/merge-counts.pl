#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my %ngrams = ();

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

while(<>) {
	chomp;
	my @line = split/ /;
	my $count = shift @line;
	my $ngram = join(' ', @line);
	if(!exists $ngrams{$ngram}) {
		$ngrams{$ngram} = $count;
	} else {
		$ngrams{$ngram} += $count;
	}
}
for my $ngram (keys %ngrams) {
	next if($ngram eq '');
	print "$ngram $ngrams{$ngram}\n";
}
