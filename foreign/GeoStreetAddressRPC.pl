#! /usr/bin/perl

# Dpenedencies were bundled using command
# cpanm --self-contained -L foreign JSON https://cpan.metacpan.org/authors/id/T/TE/TEEDOT/Geo-StreetAddress-Canada-1.04.tar.gz

use strict;
use lib './foreign/lib/perl5';
use Geo::StreetAddress::Canada;
use JSON;

if ($#ARGV + 1 != 2) {
    print "Usage: GeoStreetAddressRPC.pl command address\n";
    exit 1;
}

my $command = $ARGV[0];
my $address = $ARGV[1];

if ($command == "parseLocation") {
    my $hashref = Geo::StreetAddress::Canada->parse_location($address);
    print encode_json($hashref), "\n";
} elsif ($command == "parseAddress") {
    my $hashref = Geo::StreetAddress::Canada->parse_address($address);
    print encode_json($hashref), "\n";
} elsif ($command == "parseInformalAddress") {
    my $hashref = Geo::StreetAddress::Canada->parse_informal_address($address);
    print encode_json($hashref), "\n";
}