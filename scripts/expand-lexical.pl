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

sub has_space {
	my $arr = shift;
	for my $w (@$arr) {
		if($w =~ / /) {
			return 1;
		}
	}
	return 0;
}

my $symno = 1;
my %seen = ();
sub do_sym {
	my $word = shift;
	if(!exists $seen{$word}) {
		$seen{$word} = $symno;
		$symno++;
	}
}

sub writer {
	my $id = shift;
	open(OUTPUT, '>', "$id.txt");
	binmode(OUTPUT, ":utf8");
	open(OUTSYM, '>', "$id.syms.txt");
	binmode(OUTSYM, ":utf8");
	print OUTSYM "<eps> 0\n";
	my $prev = 0;
	my $cur = 1;
	my @arr = @{$_[0]};
	my $adv = 1;
	for my $sub (@arr) {
		for my $word (@$sub) {
			if(has_space($sub)) {
				$adv = $#$sub;
				if($word =~ / /) {
					my @tmpsplit = split/ /, $word;
					my $ccur = $cur;
					my $cprev = $prev;
					for (my $i = 0; $i <= $#tmpsplit; $i++) {
						print OUTPUT "$cprev $ccur $tmpsplit[$i] $tmpsplit[$i]\n";
						if($i < $#tmpsplit) {
							$cprev++;
							$ccur++;
						}
					}
				} else {
					my $ccur = $cur + 1;
					print OUTPUT "$prev $ccur $word $word\n";
					do_sym($word);
				}
			} else {
				$adv = 1;
				print OUTPUT "$prev $cur $word $word\n";
				do_sym($word);
			}
		}
		$prev += $adv;
		$cur = $prev + 1;
	}
	print OUTPUT "$prev\n";
	for my $k (keys %seen) {
		print OUTSYM "$k $seen{$k}\n";
	}
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
	writer($id, \@out);
}
