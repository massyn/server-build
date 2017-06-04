#!/usr/bin/perl
use strict;

# Library file used across the set of server build scripts

sub check_sudo
{
	if(`whoami` !~ /root/)
	{
		die "You must be running this as root (try sudo instead)...";
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
	$Q{WWWROOT} = &ask("Enter the path where the web server files will be stored","/wwwroot",$Q{WWWROOT});
	$Q{ROLEWEB} = &ask("Will this be a web server?","Y",$Q{ROLEWEB});
	$Q{ROLEDB} = &ask("Will this be a database?","Y",$Q{ROLEDB});
	$Q{ROLEMAIL} = &ask("Will this be a mail server (outbound)?","Y",$Q{ROLEMAIL});

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

sub ask
{
        my ($q,$d,$c) = @_;

	if($c ne '')
	{
		return $c;
	}

        chomp($d);

        print "$q --> ";

        if($d ne '')
        {
                print "[$d] ";
        }

        my $ans = <STDIN>;
        chomp($ans);

        my $result;
        if($ans eq '' && $d ne '')
        {
                $result = $d;
        }
        else
        {
                $result = $ans;
        }

        print "You picked - $result\n";
        return $result;
}


sub addline
{
        my ($file,$line) = @_;

        # is it in there ?
        open(IN,"$file") || die "can not read $file - $!";
        foreach my $a (<IN>)
        {
                chomp($a);
                if($a eq "$line")
                {
                        close IN;
                        return();
                }
        }
        close IN;

        # == we made it this far, so add it in
        open(OUT,">>$file");
        print OUT "$line\n";
        close OUT;
}

sub param
{
        my ($file,$param,$value) = @_;

        print "Checking file $file for $param as $value\n";
        my $data;
        open(IN,"$file") || die "Can not read $file - $!";
        foreach my $a (<IN>)
        {
                $data .= $a;
        }
        close IN;

        my $tag = 0;
        open(OUT,">$file") || die "Oh dear - $!";
        foreach my $a (split(/\n/,$data))
        {
                chomp($a);
                if($a =~ /$param/i)
                {
                        print OUT "$param $value\n";
                        $tag = 1;
                }
                else
                {
                        print OUT "$a\n";
                }
        }

        if($tag == 0)
        {
                print OUT "$param $value\n";
        }
        close OUT;
}

sub write_template
{
	my ($input,$output,$ref) = @_;
	
	my %variables = %$ref;
	
	my $data;	
	open(IN,$input) || &log("ERROR - Can not read $input - $?");
	foreach my $l (<IN>)
	{
		$data .= $l;			
	}
	close IN;

	close IN;
	foreach my $v (keys %variables)
	{
		print "$v ==> $variables{$v}\n";
	}
}
