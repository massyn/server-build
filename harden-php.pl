#!/usr/bin/perl

use strict;

do './library.pl';
&log("Starting $0");

# == check if we are running with a sudo'ed root
&check_sudo();

# == find the php.ini file
       
foreach $ini (`find /etc/php -name php.ini`) {
        chomp($ini);
        print "Found INI file ==> $ini\n";
        &harden_ini($ini);
}

system("service apache2 restart");

sub harden_ini
{
        my ($ini) = @_;
        &harden($ini,'expose_php'               ,'Off');
        &harden($ini,'error_reporting'          ,'E_ALL');
        &harden($ini,'display_errors'           ,'Off');
        &harden($ini,'display_startup_errors'   ,'Off');
        &harden($ini,'log_errors'               ,'On');
        &harden($ini,'ignore_repeated_errors'   ,'Off');


        # == session

        &harden($ini,'session.cookie_httponly','On');
        &harden($ini,'session.hash_function','"sha256"');
        &harden($ini,'session.auto_start','Off');
        &harden($ini,'session.hash_bits_per_character',6);
        &harden($ini,'session.use_trans_sid',0);
}

sub harden
{
        my ($ini,$param,$value) = @_;

        # == read the ini file into memory
        my $INIFILE;
        open(IN,$ini) || die "Cannot read $ini - $!";
        foreach my $a (<IN>)
        {
                $INIFILE .= $a;
        }
        close IN;

        # == start writing the new file
        open(OUT,">$ini") || die "Cannot write $ini - $!";

        # == find the parameter we're looking for

        foreach my $a (split(/\n/,$INIFILE))
        {
                chomp($a);
                if($a =~ /$param/ && $a !~ /^;/)
                {
                        print OUT "; $a\n";
                }
                else
                {
                        print OUT "$a\n";
                }
        }

        print OUT "$param = $value\n";

        close OUT;
}
