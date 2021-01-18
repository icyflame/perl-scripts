#!/usr/bin/env perl

use strict;
use warnings;

if (@ARGV < 1) {
    print "Usage: ./sample.pl sampler-count\n";
    die "Must provide the frequency at which the input should be sampled at";
}

my $sampler = shift @ARGV;
my $c = 0;
while (my $line = <>) {
    if ($c % $sampler == 0) {
        printf $line;
    }
    $c ++;
}
