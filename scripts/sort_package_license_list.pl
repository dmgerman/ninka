#!/usr/bin/perl

use strict;
use warnings;

open (FH, $ARGV[0]);
my @list;

while (my $line = <FH>){
    chomp $line;
    push (@list,$line);
}

@list = sort { ($b =~ tr /\//\//) <=> ($a =~ tr /\//\//) || $b cmp $a } @list;

foreach my $line(@list){
    print "$line\n";
}
