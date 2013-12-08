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

	if ($result->{tcp}->{$port}->{open}) { print "ON\n";} else {print "OFF\n";}
}

sub listStatus {
	my ($cfg) = @_;
	my $line;
	my $machine;
	my @cfg_lines = $cfg->vars();
	foreach my $line (@cfg_lines) {
		if ($line =~ /(.*)\.IP$/ ) {
			print $1 . ": ";
			$machine = $cfg->param(-block=>$1);
			isAlive($machine);
		}
	}
}

sub showHostfile {
	my ($cfg) = @_;
	my $line;
	my $ip;
	my $hostname;
	my @cfg_lines = $cfg->vars();
	foreach my $line (@cfg_lines) {
		if ($line =~ /(.*)\.MAC$/ ) {
			$hostname = lc $1;
			$ip = $cfg->param($1.".IP");
			print $ip . "\t\t" . $hostname . "\n";
		}
	}
	
}

sub showDHCP {
	my ($cfg) = @_;
	my $line;
	my $ip;
	my $mac;
	my @cfg_lines = $cfg->vars();
	foreach my $line (@cfg_lines) {
		if ($line =~ /(.*)\.MAC$/ ) {
			$ip = $cfg->param($1.".IP");
			$mac = $cfg->param($1.".MAC");
			print "set system services dhcp static-binding $mac fixed-address $ip\n";
		}
	}


}

my $wake;
my $status;
my $dhcp;
my $list;
my $machine;
my $machine_name;
my $hostfile;
my $cfg;
my $config_file = $ENV{"HOME"} . "/computers.cfg";

GetOptions(	'wake=s{1}' => sub { my ($opt_name, $opt_value) = @_; $wake = 1; $machine_name = uc $opt_value; },
		'status=s{1}' => sub { my ($opt_name, $opt_value) = @_; $status = 1; $machine_name = uc $opt_value; },
		'hostfile' => \$hostfile,
		'list' => \$list,
		'dhcp' => \$dhcp );

if (!defined $list && !defined $dhcp && !defined $wake && !defined $status && !defined $hostfile) { die "Missing -wake or -status"; }

if (! -e $config_file ) {
	die "Config file doesn't exists: $config_file";
}

$cfg = new Config::Simple($config_file);


if ($wake) {
	$machine = $cfg->param(-block=>$machine_name);
	if (!%$machine) { die "Machine doesn't exists: $machine_name\n"; }
	send_wol($machine);
};

if ($status) {
	$machine = $cfg->param(-block=>$machine_name);
	if (!%$machine) { die "Machine doesn't exists: $machine_name\n"; }
	isAlive($machine);
}

if ($hostfile) {
	showHostfile($cfg);
}

if ($dhcp) {
	showDHCP($cfg);
}

if ($list) {
	listStatus($cfg);
}
