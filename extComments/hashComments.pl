#!/usr/bin/perl

#
#    Copyright (C) 2009-2014  Yuki Manabe and Daniel M. German
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 2 of
#    the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.
#

# this is to extract the first <n> comments from any language that 
# uses the same prefix

use Getopt::Std;


# set parameters
my %opts = ();
if (!getopts ('vc:p:',\%opts)) {
print STDERR "Usage $0 -v

  -v verbose
  -p comment char  
  -c count of comment blocks

\n";

    die;
}
my $f = $ARGV[0];

open (OUT, ">${f}.comments") or die "Unable to create [${f}.comments]";

 <>;
print OUT unless /^\#\!/;

my $commentChar = '#';

$commentChar = $opts{p} if exists $opts{p};

my $numberComments = 1;
$numberComments = $opts{c} if exists $opts{c};

my $verbose = exists $opts{v};

my $insideComment = 0;
my $insideCode = 0;

my $comCount = 0;
my $countCode = 0;

while (<>) {
    chomp;
    if (Is_Comment($_)) {
        s/\t/ /g;
        s/ +/ /g;
        $comCount ++ if (not $insideComment);
        $insideComment = 1;
        /$commentChar+/;
        print OUT $' . "\n"; #'
    } elsif (Is_Blank($_)) {
        print OUT "\n";
    } else {
        exit 0;
    } 
}


sub Is_Comment
{
    my ($st) = @_;
    return  ($st =~ /^\s*$commentChar/);
}

sub Is_Blank
{
    my ($st) = @_;
    return ($st =~ /^\s*$/);
}

