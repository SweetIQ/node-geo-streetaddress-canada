package Geo::StreetAddress::Canada;

use 5.008_001;
use strict;
use warnings;

our $VERSION = '1.04';

use base 'Class::Data::Inheritable';

=head1 NAME

Geo::StreetAddress::Canada - Perl extension for parsing Canadian street addresses

=head1 SYNOPSIS

  use Geo::StreetAddress::Canada;

  $hashref = Geo::StreetAddress::Canada->parse_location(
                "151 Front Street West, Toronto, Ontario M1M 1M1" );

  $hashref = Geo::StreetAddress::Canada->parse_location(
                "Front & York, Toronto, Ontario" );

  $hashref = Geo::StreetAddress::Canada->parse_address(
                "151 Front Street West, Toronto, Ontario" );

  $hashref = Geo::StreetAddress::Canada->parse_informal_address(
                "Lot 3 York Street" );

  $hashref = Geo::StreetAddress::Canada->parse_intersection(
                "Spadina Avenue at Bremner Boulevard, Toronto, Ontario" );

  $hashref = Geo::StreetAddress::Canada->normalize_address( \%spec );
      # the parse_* methods call this automatically...

=head1 DESCRIPTION

Geo::StreetAddress::Canada is a regex-based street address and street intersection
parser for Canada. Its basic goal is to be as forgiving as possible
when parsing user-provided address strings. Geo::StreetAddress::Canada knows about
directional prefixes and suffixes, fractional building numbers, building units,
grid-based addresses, postal codes, and all of the official Canada Post abbreviations 
for street types, province names and secondary unit designators. Please note that this
extension will only return data in English. If you are looking for French language support,
Please see Geo::StreetAddress::FR(3pm). Patches are welcome if someone wishes to combine the two!

=head1 RETURN VALUES

Most Geo::StreetAddress::Canada methods return a reference to a hash containing
address or intersection information. This "address specifier" hash may contain 
any of the following fields for a given address. If a given field is not present 
in the address, the corresponding key will be set to C<undef> in the hash.

Future versions of this module may add extra fields.

=head1 ADDRESS SPECIFIER

=head2 number

House or street number.

=head2 prefix

Directional prefix for the street, such as N, NE, E, etc.  A given prefix
should be one to two characters long.

=head2 street

Name of the street, without directional or type qualifiers.

=head2 type

Abbreviated street type, e.g. Rd, St, Ave, etc. See the Canada Post Addressing Guidelines
at L<http://www.canadapost.ca/tools/pg/manual/PGaddress-e.asp#1423617> for a list of abbreviations used.

=head2 suffix

Directional suffix for the street, as above.

=head2 city

Name of the city, town, or other locale that the address is situated in.

=head2 province

The province which the address is situated in, given as its two-letter
postal abbreviation.  for a list of abbreviations used.

=head2 postalcode

Postal code for the address, with a space separating the FSA and LDU. IE: M1M 1M1.

=head2 sec_unit_type

If the address includes a Secondary Unit Designator, such as a room, suite or
appartment, the C<sec_unit_type> field will indicate the type of unit.

=head2 sec_unit_num

If the address includes a Secondary Unit Designator, such as a room, suite or apartment,
the C<sec_unit_num> field will indicate the number of the unit (which may not be numeric).

=head1 INTERSECTION SPECIFIER

=head2 prefix1, prefix2

Directional prefixes for the streets in question.

=head2 street1, street2

Names of the streets in question.

=head2 type1, type2

Street types for the streets in question.

=head2 suffix1, suffix2

Directional suffixes for the streets in question.

=head2 city

City or locale containing the intersection, as above.

=head2 province

Province abbreviation, as above.

=head2 postalcode

Postal code for address, as above.

=cut

=head1 GLOBAL VARIABLES

Geo::StreetAddress::Canada contains a number of global variables which it
uses to recognize different bits of Canadian street addresses. Although you
will probably not need them, they are documented here for completeness's
sake.

=cut

=head2 %Directional

Maps directional names (north, northeast, etc.) to abbreviations (N, NE, etc.).

=head2 %Direction_Code

Maps directional abbreviations to directional names.

=cut

our %Directional = (
    north       => "N",
    northeast   => "NE",
    east        => "E",
    southeast   => "SE",
    south       => "S",
    southwest   => "SW",
    west        => "W",
    northwest   => "NW",
);

our %Direction_Code; # setup in init();

=head2 %Street_Type

Maps English lowercase Canada Post standard street types to their canonical postal
abbreviations. 

=cut

our %Street_Type = (
	abbey		=> "abbey",
	acres		=> "acres",
	alley		=> "alley",
	avenue 		=> "ave",
	bay		=> "bay",
	beach		=> "beach",
	bend		=> "bend",
	boulevard	=> "blvd",
	"by-pass"	=> "bypass",
	bypass		=> "bypass",
	byway		=> "byway",
	campus		=> "campus",
	cape		=> "cape",
	centre 		=> "ctr",
	chase		=> "chase",
	circle		=> "cir",
	circuit		=> "circt",
	close		=> "close",
	common		=> "common",
	concession	=> "conc",
	corners		=> "crnrs",
	court		=> "crt",
	cove		=> "cove",
	crescent	=> "cres",
	crossing	=> "cross",
	dale		=> "dale",
	dell		=> "dell",
	diversion 	=> "divers",
	downs		=> "downs",
	drive		=> "dr",
	end		=> "end",
	esplanade	=> "espl",
	estates		=> "estate",
	expressway	=> "expy",
	extension 	=> "exten",
	farm		=> "farm",
	field		=> "field",
	forest		=> "forest",
	freeway		=> "fwy",
	front		=> "front",
	gardens		=> "gdns",
	gate		=> "gate",
	glade		=> "glade",
	glen		=> "glen",
	green		=> "green",
	grounds		=> "grnds",
	grove		=> "grove",
	harbour		=> "harbr",
	heath		=> "heath",
	heights		=> "hts",
	highlands	=> "hghlds",
	highway		=> "hwy",
	hill		=> "hill",
	hollow		=> "hollow",
	inlet		=> "inlet",
	island		=> "island",
	key		=> "key",
	knoll		=> "knoll",
	landing		=> "landng",
	lane		=> "lane",
	limits		=> "lmts",
	line		=> "line",
	link		=> "link",
	lookout		=> "lkout",
	loop		=> "loop",
	mall		=> "mall",
	manor		=> "manor",
	maze		=> "maze",
	meadow		=> "meadow",
	mews		=> "mews",
	moor		=> "moor",
	mount		=> "mount",
	mountain	=> "mtn",
	orchard		=> "orch",
	parade		=> "parade",
	park		=> "pk",
	parkway		=> "pky",
	passage		=> "pass",
	path		=> "path",
	pathway		=> "ptway",
	pines		=> "pines",
	place		=> "pl",
	plateau		=> "plat",
	plaza		=> "plaza",
	point		=> "pt",
	pointe		=> "pointe",
	port		=> "port",
	private		=> "pvt",
	promenade	=> "prom",
	quay		=> "quay",
	ramp		=> "ramp",
	range		=> "rg",
	ridge		=> "ridge",
	rise		=> "rise",
	road		=> "rd",
	row		=> "row",
	run		=> "run",
	square		=> "sq",
	street		=> "st",
	subdivision	=> "subdiv",
	terrace		=> "terr",
	thicket 	=> "thick",
	towers		=> "towers",
	townline	=> "tline",
	trail		=> "trail",
	turnabout	=> "trnabt",
	vale		=> "vale",
	via		=> "via",
	view		=> "view",
	village		=> "villge",
	villas		=> "villas",
	vista		=> "vista",
	walk		=> "walk",
	way		=> "way",
	wharf		=> "wharf",
	wood		=> "wood",
	wynd		=> "wynd",
);

our %_Street_Type_List;     # set up in init() later;
our %_Street_Type_Match;    # set up in init() later;

=head2 %Province_Code

Maps lowercased Canadian Province or territory names to their canonical two-letter
postal abbreviations. 

=cut

our %Province_Code = (
    	"alberta"			=> "AB",
	"british columbia" 		=> "BC",
	"manitoba"			=> "MB",
	"new brunswick"			=> "NB",
	"newfoundland and labrador"	=> "NL",
	"northwest territories"		=> "NT",
	"nova scotia"			=> "NS",
	"nunavut"			=> "NU",
	"ontario"			=> "ON",
	"prince edward island"		=> "PE",
	"quebec"			=> "PQ",
	"saskatchewan"			=> "SK",
	"yukon"				=> "YT",
	"alta"				=> "AB",
	"b.c."				=> "BC",
	"man"				=> "MB",
	"n.b."				=> "NB",
	"n.f."				=> "NL",
	"n.w.t."			=> "NT",
	"nwt"				=> "NT",
	"n.s."				=> "NS",
	"ont"				=> "ON",
	"p.e.i"				=> "PE",
	"pei"				=> "PE",
	"pq"				=> "QC",
	"que"				=> "QC",
	"sask"				=> "SK",
	"yuk"				=> "YT",
	"y.t."				=> "YT",	
	
);



=head2 %Addr_Match

A hash of compiled regular expressions corresponding to different
types of address or address portions. Defined regexen include
type, number, fraction, state, direct(ion), dircode, zip, corner,
street, place, address, and intersection.

Direct use of these patterns is not recommended because they may change in
subtle ways between releases.

=cut

our %Addr_Match; # setup in init()

init();

our %Normalize_Map = (
    prefix  	=> \%Directional,
    prefix1 	=> \%Directional,
    prefix2 	=> \%Directional,
    suffix  	=> \%Directional,
    suffix1 	=> \%Directional,
    suffix2 	=> \%Directional,
    type    	=> \%Street_Type,
    type1   	=> \%Street_Type,
    type2   	=> \%Street_Type,
    province	=> \%Province_Code,
);


=head1 CLASS ACCESSORS

=head2 avoid_redundant_street_type

If true then L</normalize_address> will set the C<type> field to undef
if the C<street> field contains a word that corresponds to the C<type> in L<\%Street_Type>.

For example, given "4321 Country Road 7", C<street> will be "Country Road 7"
and C<type> will be "Rd". With avoid_redundant_street_type set true, C<type>
will be undef because C<street> matches /\b (rd|road) \b/ix;

Also applies to C<type1> for C<street1> and C<type2> for C<street2>
fields for intersections.

The default is false, for backwards compatibility.

=cut

BEGIN { __PACKAGE__->mk_classdata('avoid_redundant_street_type' => 0) }

=head1 CLASS METHODS

=head2 init

    # Add another street type mapping:
    $Geo::StreetAddress::Canada::Street_Type{'cur'}='curv';
    # Re-initialize to pick up the change
    Geo::StreetAddress::Canada::init();

Runs the setup on globals.  This is run automatically when the module is loaded,
but if you subsequently change the globals, you should run it again.

=cut

sub init {

    %Direction_Code = reverse %Directional;

    %_Street_Type_List  = map { $_ => 1 } %Street_Type;

    # build hash { 'rd' => qr/\b (?: rd|road ) \b/xi, ... }
    %_Street_Type_Match = map { $_ => $_ } values %Street_Type;
    while ( my ($type_alt, $type_abbrv) = each %Street_Type ) {
        $_Street_Type_Match{$type_abbrv} .= "|\Q$type_alt";
    }
    %_Street_Type_Match = map {
        my $alts = $_Street_Type_Match{$_};
        $_ => qr/\b (?: $alts ) \b/xi;
    } keys %_Street_Type_Match;

    use re 'eval';

    %Addr_Match = (
        type => join("|", keys %_Street_Type_List),
        fraction => qr{\d+\/\d+},
        province => '\b(?:'.join("|",
            # escape spaces in province names (e.g., "nova scotia" --> "nova\\ scotia")
            # so they still match in the x environment below
            map { ( quotemeta $_) } keys %Province_Code, values %Province_Code
            ).')\b',
        direct  => join("|",
            # map direction names to direction codes
            keys %Directional,
            # also map the dotted version of the code to the code itself
            map {
                my $c = $_; $c =~ s/(\w)/$1./g; ( quotemeta $c, $_ )
            } sort { length $b <=> length $a } values %Directional
        ),
        dircode => join("|", keys %Direction_Code),
        postalcode => qr/[a-zA-Z]\d{1}[a-zA-Z](\-| |)\d{1}[a-zA-Z]\d{1}/,
		corner  => qr/(?:\band\b|\bat\b|&|\@)/i,
    );

    # we don't include letters in the number regex because we want to
    # treat "42S" as "42 S" (42 South). 
    $Addr_Match{number} = qr/(\d+-?\d*) (?{ $_{number} = $^N })/ix,

    # note that expressions like [^,]+ may scan more than you expect
    $Addr_Match{street} = qr/
        (?:
          # special case for addresses like 100 South Street
          (?:($Addr_Match{direct})\W+           (?{ $_{street} = $^N })
             ($Addr_Match{type})\b              (?{ $_{type}   = $^N }))
             #(?{ $_{_street}.=1 })
          |
          (?:($Addr_Match{direct})\W+           (?{ $_{prefix} = $^N }))?
          (?:
            ([^,]*\d)                           (?{ $_{street} = $^N })
            (?:[^\w,]*($Addr_Match{direct})\b   (?{ $_{suffix} = $^N; $_{type}||='' }))
            #(?{ $_{_street}.=3 })
           |
            ([^,]+)                             (?{ $_{street} = $^N })
            (?:[^\w,]+($Addr_Match{type})\b     (?{ $_{type}   = $^N }))
            (?:[^\w,]+($Addr_Match{direct})\b   (?{ $_{suffix} = $^N }))?
            #(?{ $_{_street}.=2 })
           |
            ([^,]+?)                            (?{ $_{street} = $^N; $_{type}||='' })
            (?:[^\w,]+($Addr_Match{type})\b     (?{ $_{type}   = $^N }))?
            (?:[^\w,]+($Addr_Match{direct})\b   (?{ $_{suffix} = $^N }))?
            #(?{ $_{_street}.=4 })
          )
        )
    /ix;


    $Addr_Match{sec_unit_type_numbered} = qr/
          (su?i?te
            |p\W*[om]\W*b(?:ox)?
            |(?:ap|dep)(?:ar)?t(?:me?nt)?
            |ro*m
            |flo*r?
            |uni?t
            |bu?i?ldi?n?g
            |ha?nga?r
            |lo?t
            |pier
            |slip
            |spa?ce?
            |stop
            |tra?i?le?r
            |box)(?![a-z])            (?{ $_{sec_unit_type}   = $^N })
        /ix;

    $Addr_Match{sec_unit_type_unnumbered} = qr/
          (ba?se?me?n?t
            |fro?nt
            |lo?bby
            |lowe?r
            |off?i?ce?
            |pe?n?t?ho?u?s?e?
            |rear
            |side
            |uppe?r
            )\b                      (?{ $_{sec_unit_type}   = $^N })
        /ix;

    $Addr_Match{sec_unit} = qr/
        (:?
            (?: (?:$Addr_Match{sec_unit_type_numbered} \W*)
                | (\#)\W*            (?{ $_{sec_unit_type}   = $^N })
            )
            (  [\w-]+)               (?{ $_{sec_unit_num}    = $^N })
        )
        |
            $Addr_Match{sec_unit_type_unnumbered}
        /ix;

    $Addr_Match{city_and_state} = qr/
        (?:
            ([^\d,]+?)\W+            (?{ $_{city}   = $^N })
            ($Addr_Match{province})  (?{ $_{province}  = $^N })
        )
        /ix;

    $Addr_Match{place} = qr/
        (?:$Addr_Match{city_and_state}\W*)?
        (?:($Addr_Match{postalcode})  (?{ $_{postalcode}    = $^N }))?
        /ix;

	$Addr_Match{address} = qr/
        (?:^
			[^\w\#]*    # skip non-word chars except # (eg unit)
			(  $Addr_Match{number} )\W*
			(?:$Addr_Match{fraction}\W*)?
			   $Addr_Match{street}\W+
			(?:$Addr_Match{sec_unit}\W+)?
			   $Addr_Match{place}
			\W*         # require on non-word chars at end
			$
		)           # right up to end of string
        /ix;

    my $sep = qr/(?:\W+|\Z)/;

    $Addr_Match{informal_address} = qr/
        (?:^
			\s*         # skip leading whitespace
			(?:$Addr_Match{sec_unit} $sep)?
			(?:$Addr_Match{number})?\W*
			(?:$Addr_Match{fraction}\W*)?
			   $Addr_Match{street} $sep
			(?:$Addr_Match{sec_unit} $sep)?
			(?:$Addr_Match{place})?
		)
        # don't require match to reach end of string
        /ix;

    $Addr_Match{intersection} = qr/
	(?:
	^\W*
           $Addr_Match{street}\W*?

        \s+$Addr_Match{corner}\s+

            (?{ exists $_{$_} and $_{$_.1} = delete $_{$_} for (qw{prefix street type suffix})})
           $Addr_Match{street}\W+
            (?{ exists $_{$_} and $_{$_.2} = delete $_{$_} for (qw{prefix street type suffix})})

           $Addr_Match{place}
        \W*$
	)
	/ix;
		
}

=head2 parse_location

    $spec = Geo::StreetAddress::Canada->parse_location( $string )

Parses any address or intersection string and returns the appropriate
specifier. If $string matches the $Addr_Match{corner} pattern then
parse_intersection() is used.  Else parse_address() is called and if that
returns false then parse_informal_address() is called.

=cut

sub parse_location {
    my ($class, $addr) = @_;

    if ($addr =~ /$Addr_Match{corner}/ios) {
        return $class->parse_intersection($addr);
    }
    return $class->parse_address($addr)
        || $class->parse_informal_address($addr);
}


=head2 parse_address

    $spec = Geo::StreetAddress::Canada->parse_address( $address_string )

Parses a street address into an address specifier using the $Addr_Match{address}
pattern. Returning undef if the address cannot be parsed as a complete formal
address.

You may want to use parse_location() instead.

=cut

sub parse_address {
    my ($class, $addr) = @_;
    local %_;

    $addr =~ /$Addr_Match{address}/ios
        or return undef;

    return $class->normalize_address({ %_ });
}


=head2 parse_informal_address

    $spec = Geo::StreetAddress::Canada->parse_informal_address( $address_string )

Acts like parse_address() except that it handles a wider range of address
formats because it uses the L</informal_address> pattern. That means a
unit can come first, a street number is optional, and the city and state aren't
needed. Which means that informal addresses like "#42 123 Main St" can be parsed.

Returns undef if the address cannot be parsed.

You may want to use parse_location() instead.

=cut

sub parse_informal_address {
    my ($class, $addr) = @_;
    local %_;

    $addr =~ /$Addr_Match{informal_address}/ios
        or return undef;

    return $class->normalize_address({ %_ });
}


=head2 parse_intersection

    $spec = Geo::StreetAddress::Canada->parse_intersection( $intersection_string )

Parses an intersection string into an intersection specifier, returning
undef if the address cannot be parsed. You probably want to use
parse_location() instead.

=cut

sub parse_intersection {
    my ($class, $addr) = @_;
    local %_;

    $addr =~ /$Addr_Match{intersection}/ios
        or return undef;

    my %part = %_;
    # if we've a type2 and type1 is either missing or the same,
    # and the type seems plural,
    # and is still valid if the trailing 's' is removed, then remove it.
    # So "X & Y Streets" becomes "X Street" and "Y Street".
    if ($part{type2} && (!$part{type1} or $part{type1} eq $part{type2})) {
        my $type = $part{type2};
        if ($type =~ s/s\W*$//ios and $type =~ /^$Addr_Match{type}$/ios) {
            $part{type1} = $part{type2} = $type;
        }
    }

    return $class->normalize_address(\%part);
}


=head2 normalize_address

    $spec = Geo::StreetAddress::Canada->normalize_address( $spec )

Takes an address or intersection specifier, and normalizes its components,
stripping out all leading and trailing whitespace and punctuation, and
substituting official abbreviations for prefix, suffix, type, and state values.
Also, city names that are prefixed with a directional abbreviation (e.g. N, NE,
etc.) have the abbreviation expanded.  The original specifier ref is returned.

Typically, you won't need to use this method, as the C<parse_*()> methods
call it for you.

=cut

sub normalize_address {
    my ($class, $part) = @_;

    #m/^_/ and delete $part->{$_} for keys %$part; # for debug

    # strip off some punctuation
    defined($_) && s/^\s+|\s+$|[^\w\s\-\#\&]//gos for values %$part;

    while (my ($key, $map) = each %Normalize_Map) {
        $part->{$key} = $map->{lc $part->{$key}}
              if  exists $part->{$key}
              and exists $map->{lc $part->{$key}};
    }

    $part->{$_} = ucfirst lc $part->{$_}
        for grep(exists $part->{$_}, qw( type type1 type2 ));

    if ($class->avoid_redundant_street_type) {
        for my $suffix ('', '1', '2') {
            next unless my $street = $part->{"street$suffix"};
            next unless my $type   = $part->{"type$suffix"};
            my $type_regex = $_Street_Type_Match{lc $type}
                or die "panic: no _Street_Type_Match for $type";
            $part->{"type$suffix"} = undef
                if $street =~ $type_regex;
        }
    }

    # attempt to expand directional prefixes on place names
    $part->{city} =~ s/^($Addr_Match{dircode})\s+(?=\S)
                      /\u$Direction_Code{uc $1} /iosx
                      if $part->{city};

    # strip ZIP+4 (which may be missing a hyphen)
    #part->{zip} =~ s/^(.{5}).*/$1/os if $part->{zip};

    return $part;
}


1;
__END__

=head1 BUGS, CAVEATS, MISCELLANY

Geo::StreetAddress::Canada might not correctly parse house numbers that contain
hyphens.

This software was originally part of Geo::StreetAddress::US (q.v.) but was split apart
into an independent module for your convenience. Therefore it has some
behaviors which were designed for Geo::StreetAddress::US, but which may not be right
for your purposes. If this turns out to be the case, please let me know.

Geo::StreetAddress::Canada does B<NOT> perform Canada Post certified address normalization.

B<French addresses are not supported. This extension will only output data in English.>
If you require support for French addresses, please see Geo::StreetAddress::FR(3pm). Patches are welcome 
to combine the two!

    
=head1 SEE ALSO

This software was originally part of Geo::StreetAddress::US(3pm).

Lingua::EN::AddressParse(3pm) and Geo::PostalAddress(3pm) both do something
very similar to Geo::StreetAddress::Canada, but are either too strict/limited in
their address parsing, or not really specific enough in how they break down
addresses (for my purposes). 

Canada Post Addressing Guidelines: L<http://www.canadapost.ca/tools/pg/manual/PGaddress-e.asp>

=head1 APPRECIATION

Thanks to Schuyler D. Erle E<lt>schuyler@geocoder.usE<gt>, the author of Geo::StreetAddress:US, for providing a very 
solid base upon which to build an extension tailored for Canadian use. 

=head1 AUTHOR

Scott Burlovich <lt>teedot@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Scott Burlovich.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
# vim: ts=8:sw=4:et

