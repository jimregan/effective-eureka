#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use Data::Dumper;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

open(DATA, '<', $ARGV[0]) or die $!;
binmode(DATA, ":utf8");

my %vowel_swaps = ();
my %homophones = ();
my %added_pfx = ();
my %added_sfx = ();
my %missing_pfx = ();
my %missing_sfx = ();
my %other_spaced = ();
my %other_unspaced = ();
while(<DATA>) {
	chomp;
	my @line = split/\t/;
	if($line[0] eq 'VOWEL_SWAP_SUFFIX') {
		if(!exists $vowel_swaps{$line[1]}) {
			$vowel_swaps{$line[1]} = [];
		}
		push @{$vowel_swaps{$line[1]}}, $line[2];
	} elsif($line[0] eq 'HOMOPHONE') {
		if(!exists $homophones{$line[1]}) {
			$homophones{$line[1]} = [];
		}
		push @{$homophones{$line[1]}}, $line[2];
	} elsif($line[0] eq 'MISSING_SFX') {
		my $tmp = $line[1];
		$tmp =~ s/^\+//;
		$missing_sfx{$tmp} = 1;
	} elsif($line[0] eq 'MISSING_PFX') {
		my $tmp = $line[1];
		$tmp =~ s/\+$//;
		$missing_pfx{$tmp} = 1;
	} elsif($line[0] eq 'ADDED_SFX') {
		my $tmp = $line[1];
		$tmp =~ s/^\+//;
		$added_sfx{$tmp} = 1;
	} elsif($line[0] eq 'ADDED_PFX') {
		my $tmp = $line[1];
		$tmp =~ s/\+$//;
		$added_pfx{$tmp} = 1;
	} else {
		if($#line == 3) {
			if($line[0] =~ / /) {
				# Ok, the difficult case
				# there are only instances of two words in the
				# data, so it could be worse
				my ($first, $second) = split/ /, $line[0];
				if(!exists $other_spaced{$first}) {
					$other_spaced{$first} = { $second => [ $line[1] ] };
				} else {
					if(!exists $other_spaced{$first}->{$second}) {
						$other_spaced{$first}->{$second} = [];
					}
					push  @{$other_spaced{$first}->{$second}}, $line[1];
				}
			} else {
				if(!exists $other_unspaced{$line[0]}) {
					$other_unspaced{$line[0]} = [];
				}
				push @{$other_unspaced{$line[0]}}, $line[1];
			}
		} else {
			print STDERR "Error reading line: " . join('\t', @line) . "\n";
		}
	}

}
close(DATA);

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

sub do_single_word {
	my $word = shift;
	my @ret = ();
	my @safe = ();
	push @safe, $word;
	if(exists $homophones{$word}) {
		for my $i (@{$homophones{$word}}) {
			push @safe, $i;
		}
	}
	if(exists $other_unspaced{$word}) {
		for my $i (@{$other_unspaced{$word}}) {
			push @safe, $i;
		}
	}
	push @ret, @safe;

	my @unsafe = ();
	for my $i (keys %vowel_swaps) {
		if($word =~ /$i$/) {
			my $base = $word;
			$base =~ s/$i$//;
			for my $j (@{$vowel_swaps{$i}}) {
				push @unsafe, $base . $j;
			}
		}
	}
	for my $i (keys %added_sfx) {
		if($word =~ /$i$/) {
			my $out = $word;
			$out =~ s/$i$//;
			push @unsafe, $out;
		}
	}
	for my $i (keys %added_pfx) {
		if($word =~ /^$i/) {
			my $out = $word;
			$out =~ s/^$i//;
			push @unsafe, $out;
		}
	}
	for my $i (keys %missing_sfx) {
		push @unsafe, $word . $i;
	}
	for my $i (keys %missing_pfx) {
		push @unsafe, $i .$word;
	}
	my %tmp = ();
	for my $k (@unsafe) {
		$tmp{$k} = 1;
	}
	print "PRE: $#ret\n";
	@ret = keys %tmp;
	print "POST: $#ret\n";
	print Dumper(@ret) . "\n";
	return @ret;
}

while(<STDIN>) {
	chomp;
	my @words = split/ /;
	my $id = shift @words;
	my @out = ();
	for(my $i = 0; $i <= $#words; $i++) {
		if(exists $other_spaced{$words[$i]} && $i < $#words - 1 && exists $other_spaced{$words[$i]}->{$words[$i+1]}) {
			my @tmp = ();
			push @tmp, $words[$i] . ' ' . $words[$i+1];
			for my $j (@{$other_spaced{$words[$i]}->{$words[$i+1]}}) {
				push @tmp, $j;
			}
			my @tmp2 = do_single_word($words[$i + 1]);
			my @tmp3 = map { "$words[$i] " . $_ } @tmp2;
			push @tmp, @tmp3;
			push @out, \@tmp;
		} else {
			my @tmp = do_single_word($words[$i]);
			push @out, \@tmp;
		}
	}
	printer($id, \@out);
}
