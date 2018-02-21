#!/usr/bin/perl

use strict;

# == find the php.ini file

my $ini = &find_ini();

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

system("service apache2 restart");

sub find_ini
{
        my @locations = ('/etc/php/7.0/apache2/php.ini');

        foreach my $l (@locations)
        {
                if(-f $l)
                {
                        print "found php.ini in $l\n";
                        return $l;
                }
        }

        die "php.ini could not be found";
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
