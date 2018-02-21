#!/usr/bin/perl

# == Configure additional virtual hosts for Apache

use strict;
do './library.pl';
&log("Starting $0");

# == before we do anything else, let's check the Ubuntu version
my $VER = &ubuntu_version();
if($VER eq 'unknown')
{
	die "Sorry, but this version of Ubuntu is not supported.";
}

# == manage the config
my $CONFIG = "/etc/server_build.cfg";
my %Q = &manage_config($CONFIG);

if($Q{ROLEWEB} =~ /y/i)
{
  # do we have wp-cli installed?  If not, do it first
  if(!-f '/usr/local/bin/wp')
  {
    system('curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp');
    system('chmod +x /usr/local/bin/wp');
  }
  
  # find all sites that could host wordpress
  opendir(DIR,"$Q{WWWROOT}");
  foreach my $d (readdir(DIR))
  {
    my $dir = "$Q{WWWROOT}/$d/www";
    
    if(-f "$dir/wp-config.php")
    {
      print "$dir ==> Found Wordpress\n";
      system("wp --path=$dir core update");
      system("wp --path=$dir plugin update --all");
      system("wp --path=$dir theme update --all");
    }
  }
}
