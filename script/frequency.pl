#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib/AnyEvent/lib";
use AnyEvent;

my $help_text = "
    frequency.pl
    Siddharth Kannan - April 2018

    Usage: stream_output | ./frequency.pl n
    
    Will print 1 of every n lines printed output by the stream that is piped
    into this script.

    Current Limitation: can be used with streams only; piping a file or fixed
    length text into this script will cause it to output forever

";

if (@ARGV < 1) {
    print $help_text;
    die "Must supply frequency: perl t.pl <frequency>";
}

my $freq = $ARGV[0];

if ($freq <= 0) {
    print $help_text;
    die "Supplied frequency must be positive";
}

my $i = 1;

my $fh = AnyEvent->io (
    fh => \*STDIN, 
    poll => "r",
    cb => sub {
        chomp (my $input = <STDIN>);
        $i++;
        if ($i % $freq == 0) {
            print STDERR $input;
            print "\n";
        }
    }
);

# Create the blocking main loop
my $blocker = AnyEvent->condvar;

my $exit = AnyEvent->signal (
    signal => "INT", 
    cb => sub { 
        $blocker->send; 
    }
);

$blocker->recv;

print "\n"
