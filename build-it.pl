#!/usr/bin/perl
# == the main build file

use strict;

do './library.pl';
&log("Starting $0");

# == check if we are running with a sudo'ed root
&check_sudo();

# == before we do anything else, let's check the Ubuntu version
my $VER = &ubuntu_version();

if($VER eq 'unknown')
{
  die "Sorry, but this version of Ubuntu is not supported.";
}

my $CONFIG = "/etc/server_build.cfg";

&manage_config($CONFIG);

# == read the config
my %Q;
open(IN,"$CONFIG");
foreach my $l (<IN>)
{
  chomp($l);
  if($l eq '' || $l =~ /^#/)
  {
    next;
  }
  my ($a,$b) = split(/\=/,$l,2);
  $Q{$a} = $b;
  &log("config : $a = $b");
}
close IN;

# == get the system ready
&run("apt-get update");

# == start installing packages
open(IN,"packages.cfg");
foreach my $a (<IN>)
{
	chomp($a);
	my ($v,$r,$p) = split(/\;/,$a);
	
	#TODO - check the role
	if(
		($v eq '*' || $v eq $VER) && 
		(
			($r eq '*') || ($r eq 'db' && $Q{ROLEDB} =~ /y/i) || ($r eq 'web' && $Q{ROLEWEB} =~ /y/i) || ($r eq 'mail' && $Q{ROLEMAIL} =~ /y/i)
		)
	)
	{
		&run("apt-get -y install $p");
	}
}


