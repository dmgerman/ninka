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

use Getopt::Std;
use strict;

my $path = $0;

$path =~ s/\/+[^\/]+$//;
if ($path eq '') {
    $path = './';
}

# set parameters
my %opts = ();
if (!getopts ('vc:p:',\%opts)) {
print STDERR "Usage $0 -v

  -v verbose
  -c count of comment blocks

\n";

    die;
}

my $f = $ARGV[0];

my $original = $f;

$f =~ s/'/\\'/g;
$f =~ s/\$/\\\$/g;
$f =~ s/;/\\;/g;
$f =~ s/ /\\ /g;


#die "illegal file [$f]"  if $f =~ m@/\.@;

my $numberComments = 1;
$numberComments = $opts{c} if exists $opts{c};
my $verbose = 1;
$verbose = exists $opts{v};

if (get_size($original) == 0) {
    print STDERR "Empty file, just exit\n" if $verbose;
    exit 0; # nothing to report, just end
}





my $commentsCmd = Determine_Comments_Extractor($f);

execute("$commentsCmd");

if ($commentsCmd =~ /^comments/ and
    get_size("${f}.comments") == 0){
    `cat $f | head -700  > ${f}.comments`;
}

exit 0;


sub Determine_Comments_Extractor
{
    my ($f) = @_;

    if ($f =~ /\.([^\.]+)$/) {
        my $ext= $1;

        if ($ext =~ /^(pl|pm|py)$/
            ) {
########################
# for the time being, let us just extract the top 400 lines

            return "cat '$f' | head -400  > '${f}.comments'";
#            return "$path/hashComments.pl -p '#' '$f'";
        } elsif ($ext eq 'jl' or
                 $ext eq 'el'
            ) {
            return "cat $f | head -400  > ${f}.comments";
#            return "$path/hashComments.pl -p ';' $f";;
        } elsif ($ext =~ /^(java|c|cpp|h|cxx|c\+\+|cc)$/ ) {
            my $comm = `which comments`;
            if ($comm ne '') {
                return "comments -c1 '$f' 2> /dev/null";
            } else {
                return "cat $f | head -400  > ${f}.comments";
            }
        } else {
            return "cat $f | head -700  > ${f}.comments";
        }
    } else {
        print "\n>>>>>>>>>>>>>>>>>>>>>\n";
        return "cat $f | head -700  > ${f}.comments";
    }
}

sub execute
{
    my ($c) = @_;
#    print "\nTo execute [$c]\n";
    my $r = `$c`;
    my $status = ($? >> 8);
    die "execution of program [$c] failed: status [$status]" if ($status != 0);
    return $r;
}


sub get_size
{
    my ($f) = @_;
    my $size = (stat($f))[7];
    return $size;
}
