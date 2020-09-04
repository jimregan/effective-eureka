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
	for(my $i = 0; $i <= $#tmp; $i++) {
		$tmp[$i] =~ s/a\x{0328}/ą/g;
		$tmp[$i] =~ s/e\x{0328}/ę/g;
		$tmp[$i] =~ s/\x{0328}//g;
		$tmp[$i] =~ s/\x{0308}//g;
		$tmp[$i] =~ s/\x{0307}//g;
		$tmp[$i] =~ s/\x{0306}//g;
		$tmp[$i] =~ s/\x{0305}//g;
		$tmp[$i] =~ s/\x{0304}//g;
		$tmp[$i] =~ s/\x{008F}//g;
		$tmp[$i] =~ s/\x{0084}//g;
		$tmp[$i] =~ s/\x{0087}//g;
		$tmp[$i] =~ s/\x{0091}//g;
		$tmp[$i] =~ s/\x{0092}//g;
		$tmp[$i] =~ s/\x{0093}//g;
		$tmp[$i] =~ s/\x{0094}//g;
		$tmp[$i] =~ s/\x{008E}//g;
		$tmp[$i] =~ s/\x{008C}//g;

		$tmp[$i] =~ s/\x{00ad}//g;
		$tmp[$i] =~ s/\x{000a}//g;
		$tmp[$i] =~ s/\x{0060}//g;
		$tmp[$i] =~ s/\x{00b4}//g;
		$tmp[$i] =~ s/\x{009A}//g;
		$tmp[$i] =~ s/\x{009C}//g;
		$tmp[$i] =~ s/\x{200F}//g;
		$tmp[$i] =~ s/\x{202E}//g;
		$tmp[$i] =~ s/\x{0A7F}//g;
		$tmp[$i] =~ s/[\■,\.\(\)\[\]§„…”"\/»\*\?!;:\{\}~\%'\&\#’˝�\+\\\+_\$\`‘<>=«‹›“•|^×¨°–·′£¦½±‰ˇ÷ľ¼™©¬‚¶²®→—╬¹˙¿€¤³►†♥●○↓¥‛≥]//g;
		if($tmp[$i] =~ /\@/) {
			$tmp[$i] = '<unk>';
		}
		if($tmp[$i] =~ /\p{Cyrillic}|\p{Devanagari}|\p{Han}|\p{Greek}|\p{Kana}|\p{Hira}|\p{Georgian}/) {
			$tmp[$i] = '<unk>';
		}
	}
	print "$count " . join(' ', @tmp) . "\n";
}
