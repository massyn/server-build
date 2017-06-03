#!/usr/bin/perl
use strict;

# Library file used across the set of server build scripts

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
  
  my $out = `lsb_release -a 2>&1`;
  
  if($out =! /Ubuntu 17\.04/)
  {
    return "17.04";
  }
  else
  {
    return "unknown";
  }  
}
