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
# This script classify input sentences into two categories,
# good sentences and bad sentences.
# This script regard a sentence include a critical word (ex. legal term) as good
#
# usage: filter.pl (inputfilename)
#
# Author: Yuki Manabe
#
use strict;

#print $ARGV[0];

# where are we running the program from
my $path = $0;
$path =~ s/[^\/]+$//;
if ($path eq '') {
    $path = './';
}
my $file_critical_words = $path . 'criticalword.dict';

die "Usagee $0 <filename>.sentences" unless $ARGV[0] =~ /\.sentences$/;

my $file_good = $ARGV[0];

die "Filename should end in '.sentences' [$file_good]" unless $file_good =~ s/\.sentences$/\.goodsent/;
my $file_bad = $ARGV[0];
$file_bad =~ s/\.sentences$/\.badsent/;

#print $file_good;
#print $file_bad;

open (INPUTFILE, "<$ARGV[0]") or die ("Error: $ARGV[0] is not found.");
open (DICTIONARY, "<$file_critical_words") or die ('Error: criticalword.dict is not found.');

open (GOODOUT, ">$file_good") || die ('Error');
open (BADOUT, ">$file_bad") || die ('Error');

my @critical_words = ();
# read dictionary into list
my $critical_word;
while ($critical_word = <DICTIONARY>) {
    chomp $critical_word;
    next if $critical_word =~ /^\#/;
    $critical_word =~ s/\#.*$//; # remove everything to the end of file
    push(@critical_words, "$critical_word");
}
close(DICTIONARY);

#matching cliticalwords in list against sentences.
my $sentence;
while ($sentence = <INPUTFILE>) {
    my $check = 0;
    chomp $sentence;
    foreach $critical_word (@critical_words) {
        if ($sentence =~ /\b$critical_word\b/i) {
            $check = 1;
            #print "$critical_word:$sentence";
            last;
        }
    }
    if ($check == 1) {
        print GOODOUT "$sentence\n";
    } else {
        print BADOUT "$sentence\n";
    }
}

close(INPUTFILE);
close(GOODOUT);
close(BADOUT);

