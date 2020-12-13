use strict;
binmode STDOUT, ":utf8";
use warnings;

use Text::CSV qw(csv);
my $fh = IO::File->new('-');
my $input = csv (in => $fh, headers => "auto", sep_char => "\t" );

use JSON;
print to_json($input);
