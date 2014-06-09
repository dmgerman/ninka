#!/usr/bin/perl
#
#    Copyright (C) 2009-2014  Yuki Manabe and Daniel M. German
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 2 of the
#    License, or (at your option) any later version.
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
my $critWords = $path . 'criticalword.dict';

die "Usagee $0 <filename>.sentences" unless $ARGV[0] =~ /\.sentences$/;

my $goodfilename = $ARGV[0];


die "Filename should end in '.sentences' [$goodfilename]" unless $goodfilename =~ s/\.sentences$/\.goodsent/;
my $badfilename = $ARGV[0];
$badfilename =~ s/\.sentences$/\.badsent/;

#print $goodfilename;
#print $badfilename;

open (INPUTFILE, "<$ARGV[0]") or die ("Error: $ARGV[0] is not found.");
open (DICTIONARY, "<$critWords") or die ('Error: criticalword.dict is not found.');

open (GOODOUT, ">$goodfilename") || die ('Error');
open (BADOUT, ">$badfilename") || die ('Error');

my @cwordlist=();
# read dictionary into list
my $cword;
while ($cword=<DICTIONARY>){
  chomp $cword;
  next if $cword =~ /^\#/;
  $cword =~ s/\#.*$//; # remove everything to the end of file
  push(@cwordlist,"$cword");
}
close(DICTIONARY);

#matching cliticalwords in list against sentences.
my $sentence;
while ($sentence=<INPUTFILE>){
  my $check=0;
  chomp $sentence;
  foreach $cword (@cwordlist){
    if($sentence =~ /\b$cword\b/i){
      $check=1;
      #print "$cword:$sentence";
      last;
    }
  }
  if ($check==1){
    print GOODOUT "$sentence\n";
  }else{
     print BADOUT "$sentence\n";
  }
}

close(INPUTFILE);
close(GOODOUT);
close(BADOUT);
