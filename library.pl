#!/usr/bin/perl
use strict;

# Library file used across the set of server build scripts

sub check_sudo
{
	if(`whoami` !~ /root/)
	{
		die "You must be running this as root...";
	}

	if($ENV{SUDO_USER} eq '')
	{
		die "You can not run this directly as root.  You must be sudo'ing...";
	}
}
sub run
{
	# == Provide a command to run
	my ($cmd) = @_;

	&log("Running : $cmd");
	system($cmd);
	&log("  - Return : $?");
}

sub log
{
	# == Writes the log file
	my ($txt) = @_;

	open(LOG,">>/var/log/server_build.log");
	print LOG scalar gmtime(time) . " - $txt\n";
	print "LOG --> $txt\n";
	close LOG;
}

sub ubuntu_version
{
	# == return the current ubuntu version (which is supported by the script
	my $out = `lsb_release -r 2>&1`;

	if($out =! /Ubuntu 17\.04/)
	{
		return "17.04";
	}
	else
	{
		return "unknown";
	}
}

sub manage_config
{
	my ($CONFIG_FILE) = @_;
	my %Q;

	# -- if there is a config file, read it
	if(-f $CONFIG_FILE)
	{
		open(IN,"$CONFIG_FILE");
		foreach my $l (<IN>)
		{
			chomp($l);
			if($l eq '' || $l =~ /^#/)
			{
				next;
			}
			my ($a,$b) = split(/\=/,$l,2);
			$Q{$a} = $b;
		}
		close IN;
	}

	$Q{HOSTNAME} = &ask("Enter the server name",`hostname`,$Q{HOSTNAME});
	$Q{DOMAIN}  = &ask("Enter your domain name",`domainname`,$Q{DOMAIN});
	$Q{ADMIN} = &ask("Enter the admin email address",'',$Q{ADMIN});
	$Q{WWWGROUP} = &ask("Enter the name of the web group","webmasters",$Q{WWWGROUP});
	$Q{ROLEWEB} = &ask("Will this be a web server?","Y",$Q{ROLEWEB});
	$Q{ROLEDB} = &ask("Will this be a database?","Y",$Q{ROLEDB});

	# -- write the config file to the disk
	open(OUT,">$CONFIG_FILE") || die "Can't write config file - $!";
	print OUT "# Config created on " . scalar gmtime(time) . "\n";
	foreach my $c (sort keys %Q)
	{
		print OUT "$c=$Q{$c}\n";
	}
	close OUT;

	return %Q;
}

