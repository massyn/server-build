#!/usr/bin/perl

use strict;
do './library.pl';
&log("Starting $0");

# == find all the databases

foreach my $db (`echo show databases |mysql | grep -v Database | grep -v performance_schema | grep -v information_schema`)
{
        chomp($db);
        print "==> $db\n";

        system("mysqldump $db > $db.sql");
}
