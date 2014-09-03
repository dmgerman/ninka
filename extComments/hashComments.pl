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
my $file = $ARGV[0];

open (OUT, ">${file}.comments") or die "Unable to create [${file}.comments]";

 <>;
print OUT unless /^\#\!/;

my $comment_char = '#';

$comment_char = $opts{p} if exists $opts{p};

my $comments_count = 1;
$comments_count = $opts{c} if exists $opts{c};

my $verbose = exists $opts{v};

my $inside_comment = 0;
my $inside_code = 0;

my $comment_count = 0;
my $code_count = 0;

while (<>) {
    chomp;
    if (is_comment($_)) {
        s/\t/ /g;
        s/ +/ /g;
        $comment_count++ if (not $inside_comment);
        $inside_comment = 1;
        /$comment_char+/;
        print OUT $' . "\n"; #'
    } elsif (is_blank($_)) {
        print OUT "\n";
    } else {
        exit 0;
    }
}

sub is_comment {
    my ($st) = @_;
    return  ($st =~ /^\s*$comment_char/);
}

sub is_blank {
    my ($st) = @_;
    return ($st =~ /^\s*$/);
}

