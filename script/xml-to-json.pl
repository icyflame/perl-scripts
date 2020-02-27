use strict;
binmode STDOUT, ":utf8";
use warnings;

use XML::Simple;
my $xml = new XML::Simple;

my $fh = IO::File->new('-');
my $input = XMLin($fh);

use JSON;
print to_json($input);
