#!/usr/bin/env perl
#
#    Copyright (C) 2009-2010  Yuki Manabe and Daniel M. German
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

my $file = $ARGV[0];

#die "illegal file [$file]"  if $file =~ m@/\.@;

my $number_comments = 1;
$number_comments = $opts{c} if exists $opts{c};
my $verbose = 1;
$verbose = exists $opts{v};

if (get_size($file) == 0) {
    print STDERR "Empty file, just exit\n" if $verbose;
    exit 0; # nothing to report, just end
}

my $comments_cmd = determine_comments_extractor($file);

execute("$comments_cmd");

if ($comments_cmd =~ /^comments/ and get_size("${file}.comments") == 0) {
    `cat '$file' | head -700  > ${file}.comments`;
}

exit 0;

sub determine_comments_extractor {
    my ($file) = @_;
    if ($file =~ /\.([^\.]+)$/) {
        my $ext= $1;

        if ($ext =~ /^(pl|pm|py)$/) {
            # for the time being, let us just extract the top 400 lines
            return "cat '$file' | head -400  > '${file}.comments'";
#            return "$path/hashComments.pl -p '#' '$file'";
        } elsif ($ext eq 'jl' or $ext eq 'el') {
            return "cat '$file' | head -400  > '${file}.comments'";
#            return "$path/hashComments.pl -p ';' '$file'";;
        } elsif ($ext =~ /^(java|c|cpp|h|cxx|c\+\+|cc)$/ ) {
            my $comments_cmd_location = `which comments`;
            if ($comments_cmd_location ne '') {
                return "comments -c1 '$file' 2> /dev/null";
            } else {
                return "cat '$file' | head -400  > '${file}.comments'";
            }
        } else {
            return "cat '$file' | head -700  > '${file}.comments'";
        }
    } else {
        print "\n>>>>>>>>>>>>>>>>>>>>>\n";
        return "cat '$file' | head -700  > '${file}.comments'";
    }
}

sub execute {
    my ($c) = @_;
    my $r = `$c`;
    my $status = ($? >> 8);
    die "execution of program [$c] failed: status [$status]" if ($status != 0);
    return $r;
}

sub get_size {
    my ($file) = @_;
    my $size = (stat($file))[7];
    return $size;
}

