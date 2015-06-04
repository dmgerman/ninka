#!/usr/bin/perl

# this parses a line

#/big2/y-manabe/licensereration/fedora/srcrpm_sandbox/lua-lgi-0.7.1-1.fc19/lgi-0.7.1/lgi/marshal.c;UNKNOWN

#into
# pkg name: lua-lgi-0.7.1-1.fc19
# file:     lgi-0.7.1/lgi/marshal.c
# license:  UNKNOWN

use strict;

while (<>) {
    chomp;
    my @fields = split(';');
    my $license = $fields[1];
    my @f = split('/', $fields[0]);
    my $pkg = $f[6];
    my $file = join('/', splice(@f, 7, scalar(@f) -1));

    print "$pkg;$file;$license\n";
}
