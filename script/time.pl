#!/usr/bin/env perl

use strict;
use warnings;

use DateTime;

my $val = 0;

if (@ARGV >= 1) {
    $val = $ARGV[0];
} else {
    $val = <>;
}

# Try once to ensure that regex passes and this is a valid number
DateTime->from_epoch(epoch => $val);

# if the difference between current time and the given value is more than 10
# times the current epoch -> divide by 1000
if (abs($val - CORE::time) > (10 * CORE::time)) {
    $val = $val / 1000;
}

my $dt = DateTime->from_epoch(epoch => $val);
$dt->set_time_zone("local");

my $now = DateTime->now();

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

my $cldr_format_date = "hh:mm a on dd MMM yyyy zzz";

my $suffix = " from now";
if ($now > $dt) {
    $suffix = " ago";
}

print "Unix time $val"."\n";
print $dt->format_cldr("$cldr_format_date")."\n";
print $relative_diff.$suffix."\n";
