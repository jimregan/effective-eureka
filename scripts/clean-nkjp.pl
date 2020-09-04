#!/usr/bin/perl

use warnings;
use strict;
use utf8;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

while(<>) {
	chomp;
	s/^ *//;
	s/\r//g;
	my @tmp = split/ /;
	my $count = shift @tmp;
	my $ngram = join(' ', @tmp);
	$ngram =~ s/\x{00ad}//g;
	$ngram =~ s/\x{000a}//g;
	$ngram =~ s/\x{0060}//g;
	$ngram =~ s/\x{00b4}//g;
	$ngram =~ s/[\■,\.\(\)\[\]§„…”"\/»\*\?!;:\{\}~\%'\&\#’˝�\+\\\+_\$\`‘<>=«‹›“•|^×¨°–·′£¦½±‰ˇ÷ľ¼™©¬‚¶²®→—╬¹˙¿€¤³►]//g;
	next if(/\@/);
	next if(/\p{Cyrillic}|\p{Devanagari}|\p{Han}|\p{Greek}|\p{Kana}|\p{Hira}|\p{Georgian}/);
	#print "$ngram $count\n";
	# need to merge
	print "$count $ngram\n";
}
