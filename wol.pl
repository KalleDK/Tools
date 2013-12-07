#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Config::Simple;
use Getopt::Long;
use Net::Wake;

sub send_wol {
	my ($machine) = @_;
	Net::Wake::by_udp($machine->{SUBNET},$machine->{MAC});
	print "Waking $machine->{MAC}\n";

}



my $machine;

GetOptions( 'machine=s{1}' => \$machine);

if (!defined $machine) { die "Missing --machine"; }

$machine = uc $machine;

my $config_file = $ENV{"HOME"} . "/computers.cfg";

if (! -e $config_file ) {
	die "Config file doesn't exists: $config_file";
}
my $cfg = new Config::Simple($config_file);

my $mac = $cfg->param(-block=>$machine);

if (!%$mac) { die "Machine doesn't exists: $machine\n"; }

send_wol($mac);

