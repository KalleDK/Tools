#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Config::Simple;
use Getopt::Long;
use Net::Wake;
use IO::Socket::PortState qw(check_ports);

sub send_wol {
	my ($machine) = @_;
	Net::Wake::by_udp($machine->{SUBNET},$machine->{MAC});
	print "Waking $machine->{MAC}\n";
}

sub isAlive {
	my ($machine) = @_;
	my $result;
	my $port = $machine->{PORT};
	
	my %check = (
		tcp => {
			$port => {
				name => 'Alive'
			},
		},
	);

	$result = check_ports($machine->{IP}, 100, \%check);

	if ($result->{tcp}->{$port}->{open}) { print "Alive\n";} else {print "Dead\n";}
}

my $wake;
my $status;
my $machine;
my $machine_name;
my $cfg;
my $config_file = $ENV{"HOME"} . "/computers.cfg";

GetOptions(	'wake=s{1}' => sub { my ($opt_name, $opt_value) = @_; $wake = 1; $machine_name = uc $opt_value; },
		'status=s{1}' => sub { my ($opt_name, $opt_value) = @_; $status = 1; $machine_name = uc $opt_value; } );

if (!defined $wake && !defined $status) { die "Missing -wake or -status"; }

if (! -e $config_file ) {
	die "Config file doesn't exists: $config_file";
}

$cfg = new Config::Simple($config_file);

$machine = $cfg->param(-block=>$machine_name);

if (!%$machine) { die "Machine doesn't exists: $machine_name\n"; }

if ($wake) {
	send_wol($machine);
};

if ($status) {
	isAlive($machine);
}

