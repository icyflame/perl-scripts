#!/usr/bin/env perl

use strict;
use warnings;
binmode STDOUT, ":utf8";

my $levels = shift @ARGV || 0;
$levels++;
my $end = $levels * 4;

my @lines;

while (my $line = <>) {
    if ($line =~ m/^( *)-/) {
        my $matched = $1;
        my $space = length($matched);
        my $hash = $space / 4 + 1;
        
        if ($hash <= $levels) {
            my $replacement = "#"x$hash;
            $line =~ s/^$matched-/$replacement/g;
        } else {
            $line =~ s/^ {0,$end}//g;
        }
    }

    push @lines, $line;
}

print join "", @lines;
