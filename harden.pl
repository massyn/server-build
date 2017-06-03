#!/usr/bin/perl

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

&setup_sshd();

sub setup_sshd
{
        if(!-f "/etc/ssh/sshd_config")
        {
                &log("sshd_config not found!");
        }
        else
        {
          &param("/etc/ssh/sshd_config","PermitRootLogin","no");
          &param("/etc/ssh/sshd_config","X11Forwarding","no");
          &param("/etc/ssh/sshd_config","ChallengeResponseAuthentication","yes");
          #&param("/etc/ssh/sshd_config","ClientAliveInterval","300");
          #&param("/etc/ssh/sshd_config","ClientAliveCountMax","0");
          &param("/etc/ssh/sshd_config","IgnoreRhosts","yes");
          &param("/etc/ssh/sshd_config","HostbasedAuthentication","no");
          my $port = &ask("Enter a different SSH port name",1022,1022);
          &param("/etc/ssh/sshd_config","Port",$port);
          &param("/etc/ssh/sshd_config","PermitEmptyPasswords","no");
          &param("/etc/ssh/sshd_config","Banner","/etc/issue");
          &param("/etc/ssh/sshd_config","AllowTcpForwarding","no");
          &param("/etc/ssh/sshd_config","LoginGraceTime","30s");
        }
}
