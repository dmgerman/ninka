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

#
# hashComments.pl
#
# This script extracts the first <n> comments from any language that uses the same prefix.
#

use strict;
use warnings;
use Getopt::Std;

# parse cmdline parameters
my %opts = ();
if (!getopts ('vc:p:', \%opts)) {
    print STDERR "Usage: $0 [OPTIONS] <filename>

Options:
  -v verbose
  -p comment char
  -c count of comment blocks\n";

    exit 1;
}

my $verbose = exists $opts{v};

my $comment_char   = exists $opts{p} ? $opts{p} : '#';
my $comments_count = exists $opts{c} ? $opts{c} : 1;

my $inside_comment = 0;
my $inside_code = 0;

my $comment_count = 0;
my $code_count = 0;

my $input_file = $ARGV[0];
my $comments_file = "$input_file.comments";

open my $input_fh, '>', $input_file or die "can't open input file [$input_file]";
open my $comments_fh, '>', $comments_file or die "can't create output file [$comments_file]";

<$input_fh>;
print $comments_fh unless /^\#\!/;

while (my $line = <$input_fh>) {
    chomp $line;
    if (is_comment($line)) {
        $line =~ s/\t/ /g;
        $line =~ s/ +/ /g;
        $comment_count++ if (not $inside_comment);
        $inside_comment = 1;
        $line =~ /$comment_char+/;
        print $comments_fh substr($line, $+[0]) . "\n";
    } elsif (is_blank($line)) {
        print $comments_fh "$line\n";
    } else {
        last;
    }
}

close $input_fh;
close $comments_fh;

sub is_comment {
    my ($string) = @_;
    return ($string =~ /^\s*$comment_char/);
}

sub is_blank {
    my ($string) = @_;
    return ($string =~ /^\s*$/);
}

