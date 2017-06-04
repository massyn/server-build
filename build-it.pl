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

my %Q = &manage_config($CONFIG);


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

# == configure some of the basics
&setup_basics($Q{HOSTNAME},$Q{DOMAIN});

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

if($Q{ROLEWEB} =~ /y/i)
{
	&log(" == Building the web server == ");
	
	&setup_web();
	&www_virtualhost($Q{WWWROOT});
}

&log(" ===== ALL DONE ===== ");

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

	my $phpini = "/etc/php/7.0/apache2/php.ini";

        &param($phpini,"expose_php"," = Off");
        &addline($phpini,"extension=php_mysqli.so");

        &run("a2enmod ssl");
        &run("a2enmod rewrite");
        &run("a2enmod cgi");
        &run("a2enmod cache");
        &run("a2enmod headers");

        &param("/etc/apache2/sites-enabled/000-default.conf","DocumentRoot",$Q{WWWROOT});

#        print "We will now generate the default SSL certificate...\n";

 #       if(!-d "letsencrypt")
 #       {
 #               &run("git clone https://github.com/letsencrypt/letsencrypt");
 #       }

	&write_template("apache.conf","/etc/apache2/apache2.conf", { WWWROOT => $Q{WWWROOT} });
	
        
        # == disable server tokens

        &param("/etc/apache2/conf-enabled/security.conf","ServerTokens","Prod");
        &param("/etc/apache2/conf-enabled/security.conf","ServerSignature","Off");

	&run("service apache2 start");
}
