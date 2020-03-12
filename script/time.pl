#!/usr/bin/env perl

use strict;
use warnings;

use DateTime;
use Text::Table;

use constant DATE_FORMAT => "hh:mm a on dd MMM yyyy zzz";
sub relative_difference {
    my $now = shift;
    my $dt = shift;

    my $difference = DateTime->from_epoch(epoch => abs($now->epoch-$dt->epoch));
    my $epoch = DateTime->from_epoch(epoch => 0);

    my $year = $difference->year - $epoch->year;
    my $month = $difference->month - $epoch->month;
    my $day = $difference->day - $epoch->day;

    my $hour = $difference->hour;
    my $minute = $difference->minute;
    my $second = $difference->second;

    my $relative_diff = "";
    if ($year > 0) { $relative_diff .= "$year years "; } 
    if ($month > 0) { $relative_diff .= "$month months "; } 
    if ($day > 0) { $relative_diff .= "$day days "; } 
    if ($hour > 0) { $relative_diff .= "$hour hours "; } 
    if ($minute > 0) { $relative_diff .= "$minute minutes "; } 
    if ($second > 0) { $relative_diff .= "$second seconds"; } 

    my $suffix = "from now";
    if ($now > $dt) {
        $suffix = "ago";
    }

    return $relative_diff . ' ' . $suffix;
}

my $val = 0;

if (@ARGV >= 1) {
    $val = $ARGV[0];
} else {
    $val = <>;
}

# Try once to ensure that regex passes and this is a valid number
DateTime->from_epoch(epoch => $val);

# If the difference between current time and the given value is more than 10
# times the current UNIX timestamp -> divide by 1000
if (abs($val - CORE::time) > (10 * CORE::time)) {
    $val = $val / 1000;
}

my $dt = DateTime->from_epoch(epoch => $val);
$dt->set_time_zone("local");

my $now = DateTime->now();

my @output = (
    "Unix time $val",
    $dt->format_cldr(DATE_FORMAT),
    relative_difference($now, $dt),
    "",
    ""
);

print join ("\n", @output);

my @timezones = (
    {
        tz => "Asia/Tokyo",
        display => "Tokyo"
    },
    {
        tz => "America/Los_Angeles",
        display => "California"
    },
);

my $tb = Text::Table->new( "", "" );

foreach my $key (@timezones) {
    my $timezone = $key->{tz};
    my $display = $key->{display};
    $dt->set_time_zone($timezone);
    $tb->add($display, $dt->format_cldr(DATE_FORMAT))
}

print $tb;
