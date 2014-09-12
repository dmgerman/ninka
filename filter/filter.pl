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
# filter.pl
#
# This script classifies input sentences into two categories, good sentences and bad sentences.
# A sentence including a critical word (ex. legal term) is regarded as good.
#

use strict;
use warnings;
use File::Basename qw(dirname);
use Getopt::Std;

my $INPUT_FILE_EXTENSION = 'sentences';

parse_cmdline_parameters();

my $path = dirname($0);

my $input_file = $ARGV[0];
my $file_critical_words = "$path/criticalword.dict";

my $file_good = $input_file; $file_good =~ s/\.$INPUT_FILE_EXTENSION$/\.goodsent/;
my $file_bad  = $input_file; $file_bad  =~ s/\.$INPUT_FILE_EXTENSION$/\.badsent/;

open my $input_fh, '<', $input_file or die "can't open input file [$input_file]: $!";
open my $good_fh, '>', $file_good or die "can't create good sentences file [$file_good]: $!";
open my $bad_fh, '>', $file_bad or die "can't create bad sentences file [$file_bad]: $!";

my @critical_words = read_critical_words($file_critical_words);

while (my $sentence = <$input_fh>) {
    chomp $sentence;
    next unless $sentence;
    my $fh = contains_critical_word($sentence) ? $good_fh : $bad_fh;
    print $fh "$sentence\n";
}

close $input_fh;
close $good_fh;
close $bad_fh;

exit 0;

sub parse_cmdline_parameters {
    if (!getopts('') || scalar(@ARGV) == 0 || $ARGV[0] !~ /\.$INPUT_FILE_EXTENSION$/) {
        print STDERR "Usage $0 <filename>.$INPUT_FILE_EXTENSION\n";
        exit 1;
    }
}

sub read_critical_words {
    my ($file) = @_;
    my @critical_words = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\#/;
        $line =~ s/\#.*$//; # remove everything to the end of line
        push @critical_words, $line;
    }

    close $fh;

    return @critical_words;
}

sub contains_critical_word {
    my ($sentence) = @_;
    my $check = 0;
    foreach my $critical_word (@critical_words) {
        if ($sentence =~ /\b$critical_word\b/i) {
            $check = 1;
            last;
        }
    }
    return $check;
}

