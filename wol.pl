#!/usr/bin/env perl



#
# Example INI file
#
# [PLAY]
# SUBNET=172.20.20.0
# IP=172.20.20.10
# MAC=ff:ff:2f:af:7f:3d
# PORT=3389
#
# [PLEX]
# SUBNET=172.20.20.0
# IP=172.20.20.20
# MAC=0f:f3:f4:3f:fb:fd
# PORT=3389


use strict;
use warnings;
use Data::Dumper;
use Config::Simple;
use Getopt::Long;
use Net::Wake;
use IO::Socket::PortState qw(check_ports);
use threads;

sub listDevices {
	my ($cfg, $target) = @_;
	my @machines;
	my $machine;
	if ($target eq "ALL") {
		my $line;
		my @cfg_lines = $cfg->vars();
		foreach $line (@cfg_lines) {
			if ($line =~ /(.*)\.IP$/ ) {
				$machine = $cfg->param(-block=>$1);
				$machine->{NAME} = $1;
				push(@machines,$machine);
			}
		}
	} else {
		my $machine = $cfg->param(-block=>$target);
        	if (!%$machine) { die "Machine doesn't exists: $target\n"; }
		$machine->{NAME} = $target;
		push(@machines,$machine);
	}
	return \@machines;
}

sub sendWOL {
	my ($machine) = @_;
	Net::Wake::by_udp($machine->{SUBNET},$machine->{MAC});
	print "Waking $machine->{MAC}\n";
}

sub isAlive {
	my ($ip, $port) = @_;
	my $result;
	my %check;
	my $status;
	%check = (
		tcp => {
			$port => {
				name => 'Alive'
			},
		},
	);
	$result = check_ports($ip, 100, \%check);
	if ($result->{tcp}->{$port}->{open}) { $status = 1;} else {$status = 0;}
	return $status;
}

sub wakeDevices {
	my ($cfg, $devices) = @_;
	foreach (@$devices) {
		sendWOL($_);
	}
}

sub listStatus {
	my ($cfg, $devices) = @_;
	foreach (@$devices) {
		$_->{THREAD} = threads->create(\&isAlive,$_->{IP},$_->{PORT});
	}
	foreach (@$devices) {
		print $_->{NAME} . ": " . $_->{THREAD}->join() . "\n";
	}
}

sub showHostfile {
	my ($cfg, $devices) = @_;
	foreach (@$devices) {
		print $_->{IP} . "\t\t" . $_->{HOSTNAME} . "\n";
	}
}

sub showDHCP {
	my ($cfg, $devices) = @_;
	foreach (@$devices) {
		print "set system services dhcp static-binding $_->{MAC} fixed-address $_->{IP}\n";
	}
}

sub showList {
	my ($cfg, $devices) = @_;
	foreach (@$devices) {
		print $_->{NAME} . "\n";
	}
}

my $wake;
my $status;
my $dhcp;
my $list;
my $hostfile;

my $target;

my $devices;
my $cfg;

my $config_file = $ENV{"HOME"} . "/computers.cfg";

GetOptions(	'wake=s{1}' => sub { my ($opt_name, $opt_value) = @_; $wake = 1; $target = uc $opt_value; },
		'status=s{1}' => sub { my ($opt_name, $opt_value) = @_; $status = 1; $target = uc $opt_value; },
		'hostfile=s{1}' => sub { my ($opt_name, $opt_value) = @_; $hostfile = 1; $target = uc $opt_value; },
		'list=s{1}' => sub { my ($opt_name, $opt_value) = @_; $list = 1; $target = uc $opt_value; },
		'dhcp=s{1}' => sub { my ($opt_name, $opt_value) = @_; $dhcp = 1; $target = uc $opt_value; }
);

if (!defined $list && !defined $dhcp && !defined $wake && !defined $status && !defined $hostfile) { die "Missing -wake, -status, -list, -dhcp or hostfile"; }

if (! -e $config_file ) {
	die "Config file doesn't exists: $config_file";
}

$cfg = new Config::Simple($config_file);

$devices = listDevices($cfg, $target);


if ($wake) {
	wakeDevices($cfg,$devices);
};

if ($status) {
	listStatus($cfg,$devices);
}

if ($hostfile) {
	showHostfile($cfg,$devices);
}

if ($dhcp) {
	showDHCP($cfg,$devices);
}

if ($list) {
	showList($cfg,$devices);
}
