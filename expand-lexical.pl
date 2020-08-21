#!/usr/bin/perl

use warnings;
use strict;
use utf8;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

my $vowels = '[aeiouy]+';
my $adj_like = '.*(ego|emu|ch|mi|ej|ą|a|i|y|m|e)$';
my %palat = (
	'ć' => 'c',
	'ń' => 'n',
	'ś' => 's',
	'ź' => 'z'
);

sub printer_inner {
	my $id = shift;
	my $arr = $_[0];
	my $expand = $_[1];
	my @buf = ();
	if($#{$expand} < 0) {
		for my $i (@$arr) {
			print "$id $i\n";
		}
	} else {
		my $cur = shift @$expand;
		if($#$arr < 0) {
			for my $i (@$cur) {
				push @buf, $i;
			}
		} else {
			for my $i (@$arr) {
				for my $j (@$cur) {
					push @buf, "$i $j";
				}
			}
		}
		printer_inner($id, \@buf, $expand);
	}
}

sub printer {
	my $id = shift;
	my @out = ();
	printer_inner($id, \@out, $_[0]);
}

while(<>) {
	chomp;
	my @words = split/ /;
	my $id = shift @words;
	my @out = ();
	for(my $i = 0; $i <= $#words; $i++) {
		if(($words[$i] eq 'w' || $words[$i] eq 'wy') && $i < $#words - 1) {
			push @out, ["w $words[$i+1]", "wy $words[$i+1]", "w$words[$i+1]", "wy$words[$i+1]"];
			$i++;
		} elsif(($words[$i] eq 'z' || $words[$i] eq 'ze' || $words[$i] eq 'za') && $i < $#words - 1) {
			push @out, ["z $words[$i+1]", "ze $words[$i+1]", "za $words[$i+1]", "z$words[$i+1]", "ze$words[$i+1]", "za$words[$i+1]"];
			$i++;
		} elsif(($words[$i] eq 'przy') && $i < $#words - 1) {
			push @out, ["przy $words[$i+1]", "przy$words[$i+1]", "prze$words[$i+1]"];
			$i++;
		} elsif($words[$i] =~ /[iey]$/ && $i < $#words - 1 && $words[$i+1] eq 'mu') {
			my $mod = $words[$i];
			$mod =~ s/y$/e/;
			push @out, ["${mod}mu", "$words[$i] mu"];
			$i++;
		} elsif($words[$i] =~ /[iey]$/ && $i < $#words - 1 && $words[$i+1] eq 'go') {
			my $mod = $words[$i];
			$mod =~ s/y$/e/;
			push @out, ["${mod}go", "$words[$i] go"];
			$i++;
		} elsif($words[$i] =~ /[iey]$/ && $i < $#words - 1 && $words[$i+1] eq 'im') {
			my $mod = $words[$i];
			$mod =~ s/e$//;
			push @out, ["${mod}m", "$words[$i] im"];
			$i++;
		} elsif($words[$i] =~ /i$/ && $i < $#words - 1 && $words[$i+1] eq 'je') {
			my $mod = $words[$i];
			push @out, ["${mod}e", "$words[$i] je"];
			$i++;
		} elsif($words[$i] =~ /i$/ && $i < $#words - 1 && $words[$i+1] eq 'ja') {
			my $mod = $words[$i];
			push @out, ["${mod}a", "$words[$i] ja"];
			$i++;
		} elsif($words[$i] =~ /i$/ && $i < $#words - 1 && $words[$i+1] eq 'ją') {
			my $mod = $words[$i];
			push @out, ["${mod}ą", "$words[$i] ją"];
			$i++;
		} elsif($words[$i] =~ /[ćńśż]$/ && $i < $#words - 1 && $words[$i+1] eq 'je') {
			my $mod = $words[$i];
			if($words[$i] =~ /([ćńśź])$/) {
				my $in = $1;
				my $out = $palat{$in};
				$mod =~ s/$in$/$out/;
			}
			push @out, ["${mod}e", "${mod}ie", "$words[$i] je"];
			$i++;
		} elsif($words[$i] =~ /i$/ && $i < $#words - 1 && $words[$i+1] eq 'ja') {
			my $mod = $words[$i];
			if($words[$i] =~ /([ćńśź])$/) {
				my $in = $1;
				my $out = $palat{$in};
				$mod =~ s/$in$/$out/;
			}
			push @out, ["${mod}a", "${mod}ia", "$words[$i] ja"];
			$i++;
		} elsif($words[$i] =~ /i$/ && $i < $#words - 1 && $words[$i+1] eq 'ją') {
			my $mod = $words[$i];
			if($words[$i] =~ /([ćńśź])$/) {
				my $in = $1;
				my $out = $palat{$in};
				$mod =~ s/$in$/$out/;
			}
			push @out, ["${mod}ą", "${mod}ią", "$words[$i] ją"];
			$i++;
		} elsif($words[$i] =~ /u$/ && $i < $#words - 1 && $words[$i+1] eq 'ów') {
			my $mod = $words[$i];
			$mod =~ s/u$//;
			push @out, ["${mod}ów", "$words[$i]ów", "$words[$i] ów"];
			$i++;
		} elsif($words[$i] =~ /[ou]$/ && $i < $#words - 1 && $words[$i+1] =~ /$adj_like/) {
			my $mod = $words[$i];
			$mod =~ s/u$/o/;
			push @out, ["${mod} $words[$i+1]", "$words[$i] $words[$i+1]", "$mod-$words[$i+1]", "$mod$words[$i+1]"];
			$i++;
		} elsif($words[$i] =~ /[eę]$/) {
			my $mod = $words[$i];
			$mod =~ s/[eę]$//;
			push @out, [$mod . 'e', $mod . 'ę'];
		} elsif($words[$i] =~ /[ąo]$/) {
			my $mod = $words[$i];
			$mod =~ s/[ąo]$//;
			push @out, [$mod . 'ą', $mod . 'o'];
		} elsif($words[$i] =~ /ów$/) {
			my $mod = $words[$i];
			$mod =~ s/ów$//;
			push @out, [$mod . 'ów', $mod . 'u'];
		} elsif($words[$i] =~ /u$/) {
			my $mod = $words[$i];
			$mod =~ s/u$//;
			push @out, [$mod . 'ów', $mod . 'u'];
		} else {
			push @out, ["$words[$i]"];
		}
	}
	printer($id, \@out);
}
