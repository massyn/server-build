#!/usr/bin/perl
# == the main build file

use strict;

do './library.pl';

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
