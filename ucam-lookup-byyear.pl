#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Headers;
use IO::Prompter;

my $LOOKUP = "https://www.lookup.cam.ac.uk";

my $email = prompt "Your email address:", -out => *STDERR;
my $cookie = prompt "Complete cookie field for lookup.cam.ac.uk:", -out => *STDERR;
my $inst = prompt "Institution (e.g. DOWNUG):", -out => *STDERR;

my %years;
while (1) {
	my $year_no = prompt "Year number to fetch (or 'done'):", -out => *STDERR;
	last if $year_no eq "done";
	die unless $year_no =~ /^\d+\z/;

	my $matric_year = prompt "Corresponding matriculation year:", -out => *STDERR;
	die unless $year_no =~ /^\d+\z/;

	$years{$matric_year} = $year_no;
}

my $ua = new LWP::UserAgent;
$ua->agent("ucam-lookup-byyear (" . $ua->_agent . ") - for info contact $email");

sub request {
	my $str = shift;
	my $req = new HTTP::Request(
		GET => $LOOKUP.$str,
		new HTTP::Headers( "Cookie" => "$cookie" ),
	);
	my $resp = $ua->request($req);
	die $resp->status_line unless $resp->is_success;
	return $resp->decoded_content;
}

my $crsids = request "/inst/$inst/download-members?sort=identifier&crsids_only=true";
die "Bad cookie or something" if $crsids =~ /^<!DOCTYPE/;
my @crsids = split("\n", $crsids);

for my $crsid (@crsids) {
	my $vcard = request "/person/crsid/$crsid/vcard";

	# /!\ completely non-compliant vcard parser /!\
	# I only made this to work with the vCards that lookup.cam.ac.uk spits out
	
	# Remove carriage returns so we can split on \n
	$vcard =~ s/\r//g;
	
	my $firstname;
	my $lastname;
	my $matric_year;
	
	for my $line (split "\n", $vcard) {
		if ($line =~ /^N;/) {
			# Name field
			$line =~ s/.*://;
			my @parts = split(";", $line);
			$firstname = $parts[1];
			$lastname = $parts[0];
		} elsif ($line =~ /^REV:/) {
			# Matriculation year field
			$line =~ /^REV:(\d{4})/;
			$matric_year = $1;
		}
	}

	# Remove any commas in case someone added one to their name
	for my $ref (\$firstname, \$lastname) {
		${$ref} =~ s/,//g;
	}

	$firstname = "" unless defined $firstname;
	die "bad vcard for $crsid" unless defined $lastname && defined $matric_year;

	next unless exists $years{$matric_year};

	say join ",", ($crsid, $firstname, $lastname, $years{$matric_year});
}
