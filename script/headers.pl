#!/usr/bin/env perl

'''
headers.pl

> Convert nested Markdown into a markdown file with headers

Usage: cat file.md | perl headers.pl <levels>

Options:

    <levels> => The highest level of nesting which should be turned into a
    header in the resulting markdown

Example:

Input:

- Title
    - Subtitle
        - Pros
            - Pro 1
            - Pro 2
        - Cons
            - Con 1
    - Subtitle 2
        - Pros
            - Pro 3
            - Pro 4
        - Cons
            - Con 2

Run: cat file | perl headers.pl 2

Result:

# Title
## Subtitle
### Pros
- Pro 1
- Pro 2
### Cons
- Con 1
## Subtitle 2
### Pros
- Pro 3
- Pro 4
### Cons
- Con 2

After rendering, markdown with headers looks better than nested markdown.
'''

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
