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

# == make sure everything has the right execution permissions
system("chmod +x *.pl");
system("chmod +x *.sh");

# == read the config
my $CONFIG = "/etc/server_build.cfg";
my %Q = &manage_config($CONFIG);

# == get the system ready
&run("apt-get update");

# == start installing packages
open(IN,"packages.cfg");
foreach my $a (<IN>)
{
	chomp($a);
	my ($r,$p) = split(/\;/,$a);
	
	if(
		($r eq '*') ||
		($r eq 'db' && $Q{ROLEDB} =~ /y/i) || 
		($r eq 'web' && $Q{ROLEWEB} =~ /y/i) || 
		($r eq 'mail' && $Q{ROLEMAIL} =~ /y/i)
	)
	{
		# Search for the package first
		my $package = `apt-cache search . | grep -E "$p" | awk {'print \$1'} 2>&1`;
		print "Installing $package...\n";
		&run("apt-get -y install $package");
	}
}

# == configure some of the basics
&setup_basics($Q{HOSTNAME},$Q{DOMAIN});

# == configure the web server
if($Q{ROLEWEB} =~ /y/i)
{
	&log(" == Building the web server == ");
	
	&setup_web();
	&www_virtualhost(\%Q);
	
	system("./harden-php.pl");	# == we need to harden php if this is a web server
}

&setup_sshd();

#&run("apt-get -y upgrade");
&run("apt-get -y autoremove");

&log(" ===== ALL DONE - consider rebooting before doing anything else ===== ");

exit(0);
# ==
sub setup_basics
{
        my ($SERVERNAME,$DOMAIN) = @_;
        &run("hostname $SERVERNAME");
        &run("domainname $DOMAIN");

        &addline("/etc/hosts","127.0.0.1        $SERVERNAME");
        &addline("/etc/hosts","127.0.0.1        $SERVERNAME.$DOMAIN");

        &run("figlet $SERVERNAME > /etc/motd");
        &run("echo Authorised Users Only > /etc/issue");

}

sub setup_web
{
	&run("service apache2 stop");
	
        if(!-d "/etc/apache2/ssl")
        {
                &run("mkdir /etc/apache2/ssl");
        }

        if(!-d $Q{WWWROOT})
        {
                &run("mkdir $Q{WWWROOT}");
        }

        # -- setup the basic website
        if(!-d "$Q{WWWROOT}/$Q{HOSTNAME}.$Q{DOMAIN}")
        {
                &run("mkdir $Q{WWWROOT}/$Q{HOSTNAME}.$Q{DOMAIN}");
	}

	&run("getent group $Q{WWWGROUP} || groupadd $Q{WWWGROUP}");

        &run("chown $Q{WWWUSER}:$Q{WWWGROUP} $Q{WWWROOT}");
        &run("chmod 770 $Q{WWWROOT}");
        &run("chown -R $Q{WWWUSER}:$Q{WWWGROUP} $Q{WWWROOT}");
        &run("chmod -R 770 $Q{WWWROOT}");

        # == allow webmasters to read the web server logs -- part of their role
        &run("chown -R root:$Q{WWWGROUP} /var/log/apache2");

        # -- add the current admin user to the $WWWUSER group

        &run("usermod -a -G $Q{WWWGROUP} $ENV{SUDO_USER}");
        &run("usermod -a -G $Q{WWWGROUP} $Q{WWWUSER}");

        &run("service apache2 stop");
        if(`ps -ef |grep apache | grep -v grep` =~ /apache/)
        {
                &run("kill -9 \`ps -ef |grep apache | grep -v grep | awk {'print \$2'}\`")
        }

	my $phpini = "/etc/php/7.1/apache2/php.ini";
	
        &addline($phpini,"extension=php_mysqli.so");

        &run("a2enmod ssl");
        &run("a2enmod rewrite");
        &run("a2enmod cgi");
        &run("a2enmod cache");
        &run("a2enmod headers");

        &param("/etc/apache2/sites-enabled/000-default.conf","DocumentRoot",$Q{WWWROOT});

	&write_template("apache.conf","/etc/apache2/apache2.conf", { WWWROOT => $Q{WWWROOT} });
        
        # == disable server tokens

        &param("/etc/apache2/conf-enabled/security.conf","ServerTokens","Prod");
        &param("/etc/apache2/conf-enabled/security.conf","ServerSignature","Off");

	&run("service apache2 start");
}

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
	  &param("/etc/ssh/sshd_config","AuthorizedKeysFile","%h/.ssh/authorized_keys");
        }
}
