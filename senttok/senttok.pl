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
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
use strict;


my $TOO_LONG = 70;

# where are we running the splitter from?
my $path = $0;
$path =~ s/[^\/]+$//;
if ($path eq "") {
    $path = "./";
}
my $licSentences = $path . "licensesentence.dict";

open FH, "<$ARGV[0]";
my @licensesentencelist=();
open LICENSESENTENCEFILE, "<$licSentences";
my $line;
while ($line = <LICENSESENTENCEFILE>){
    chomp $line;
    next if $line =~ /^\#/;
    next if $line =~ /^ *$/;
    die "Illegal format in license expression [$line] " unless $line =~ /(.*?):(.*?):(.*)/;
  push @licensesentencelist,$line;
}

#foreach $line (@licensesentencelist) {
#  print $line;
#}
close LICENSESENTENCEFILE;
while ($line = <>){
    my $saveLine;
    my $originalLine;
    chomp $line;
    $originalLine = $line;

    if ($line =~ s/^Alternatively,? ?//) {
        print "Altern\n";
    }

    $line = Normalize_Sentence($line);


    my $check=0;
    my $matchname="UNKNOWN";
    my @parm=();
    my $sentence;
    my $distance=1; #maximum? number
    my $mostsimilarname="UNKNOWN";
    my $before; 
    my $after;
    my $gpl = 0;
    my ($gplLater, $gplVersion);

    $saveLine = $line;

#        print "Original
#   [$line]
#\n";


    my $lineAsGPL ='';

    if (Looks_Like_GPL($line)) {
        my $old = $line;
        $gpl = 1;
        ($line, $gplLater, $gplVersion) = Normalize_GPL($line);
        $lineAsGPL = $line;
    }
    my ($name, $subRule, $number, $regexp, $option);
    my $saveLine = $line;
    my $saveGPL = $gpl;
    my $LGPL = "";
    foreach $sentence (@licensesentencelist) {
        ($name, $subRule, $number, $regexp, $option) = split(/:/, $sentence);
        # we need this due to the goto again
        $line = $saveLine;
        $gpl = $saveGPL;
        $LGPL = "";
      again:
#       print "Testing 
#   lin[$line]
#   ori[$saveLine]
#   re [$regexp]
#   lpg[$LGPL]
#\n";
        if ( $line =~ /$regexp/im ){
            $before = $`; 
            $after = $'; #';
            $check=1;
            $matchname=$name;
            for (my $i = 1; $i <= $number; $i++){
                no strict 'refs';
                push @parm,$$i;
            }
            last;
        } else{
#            print "NO MATCH\n";
            # let us try again in cas it is lesser/library
            # do it only once
            if ($gpl and $line =~ s/(Lesser|Library) GPL/GPL/i) {
                $LGPL = $1;
                goto again;
            }
            if ($gpl) {
                $gpl = 0;
                $line = $saveLine;
                goto again;
            }
            next;## dmg
            my $targetset=$regexp;
            $targetset =~ s/^(.*)$/$1/;
            my $tmpdist=&levenshtein($line,$targetset)/max(length($targetset),length($sentence));
            if ($tmpdist<$distance){
                $mostsimilarname=$name;
                $distance=$tmpdist;
            }
        }
        last; ###
    }
    if ($check == 1){
        #licensesentence name, parm1, parm2,..
        if ($gpl) {
            $matchname .= "Ver" . $gplVersion;
            $matchname .= "+" if $gplLater;
            $matchname = $LGPL . $matchname;
        } else {
        }
        if (length($before)>$TOO_LONG ||
            length($after) >$TOO_LONG) {
            $matchname .= "-TOOLONG";
        }
        my $parmstrings=join(";",$matchname, $subRule, $before, $after, @parm);
        print $parmstrings,":$originalLine\n";

        
    }else{
        #UNKNOWN, sentence
        chomp $line;
        print $matchname,";",0, ";", $mostsimilarname,";",$distance,";",$saveLine,":$originalLine\n";
    } 
    
}

close FH;
exit 0;

sub Normalize_GPL
{
    my ($line) = @_;
    my $later = 0;
    my $version = 0;

    # do some very quick spelling corrections for english/british words
    $line =~ s/Version 2,? \(June 1991\)/Version 2/gi;
    $line =~ s/Version 2,? dated June 1991/Version 2/gi;
    $line =~ s/Version 2\.1,? dated February 1999/Version 2.1/gi;
    if ($line =~ s/,? or \(?at your option\)?,? any later version//i) {
        $later = 1;
    }
    if ($line =~ s/, or any later version//i) {
        $later = 1;
    }
    if ($line =~ s/ or (greater|later)//i) {
        $later = 1;
    }
    if ($line =~ s/or (greater|later) //i) {
        $later = 1;
    }
    if ($line =~ s/(version|v\.?) ([123\.0]+)/<VERSION>/i) {
        $version = $2;
#        print "Version [$version]\n";
    }
    if ($line =~ s/GPL ?[v\-]([123\.0]+)/GPL <VERSION>/i) {
        $version = $1;
    }
    if ($line =~ s/v\.?([123\.0]+)( *[0-9]+)/<VERSION>$2/i) {
        $version = $1;
    }

    $line =~ s/(distributable|licensed|released|made available)/<LICENSED>/ig;
    $line =~ s/Library General Public License/Library General Public License/ig;
    $line =~ s/Lesser General Public License/Lesser General Public License/ig;

    $line =~ s/General Public License/GPL/gi;
    $line =~ s/GPL \(GPL\)/GPL/gi;
    $line =~ s/GPL \(<QUOTES>GPL<QUOTES>\)/GPL/gi;


    $line =~ s/GNU //gi;
    $line =~ s/under GPL/under the GPL/gi;
    $line =~ s/under Lesser/under the Lesser/gi;
    $line =~ s/under Library/under the Library/gi;

    $line =~ s/of GPL/of the GPL/gi;
    $line =~ s/of Lesser/of the Lesser/gi;
    $line =~ s/of Library/of the Library/gi;

    $line =~ s/(can|may)/can/gi;
    $line =~ s/<VERSION> only/<VERSION>/gi;
    $line =~ s/<VERSION> of the license/<VERSION>/gi;
    $line =~ s/(<VERSION>|GPL),? as published by the Free Software Foundation/$1/gi;
    $line =~ s/(<VERSION>|GPL) \(as published by the Free Software Foundation\)/$1/gi;
    $line =~ s/(<VERSION>|GPL),? incorporated herein by reference/$1/gi;
    $line =~ s/terms and conditions/terms/gi;
    $line =~ s/GPL along with/GPL with/gi;

    $line =~ s/GPL \(<VERSION\)/GPL <VERSION>/gi;

    $line =~ s/ +/ /;
    $line =~ s/ +$//;

#    print ">>>>>>>>>>$line:$later:$version\n";

    return ($line,$later,$version);
}

sub Looks_Like_GPL
{
    my ($line) = @_;

    return 1 if $line =~ /GNU/;
    return 1 if $line =~ /General Public License/;
    return 1 if $line =~ /GPL/;

    return 0;
}


sub Normalize_Sentence
{
    my ($line) = @_;
    # do some very quick spelling corrections for english/british words
    $line=~ s/icence/icense/ig;
    $line=~ s/(\.|;)$//;

    return $line;
}

# Return the Levenshtein distance (also called Edit distance) 
# between two strings
#
# The Levenshtein distance (LD) is a measure of similarity between two
# strings, denoted here by s1 and s2. The distance is the number of
# deletions, insertions or substitutions required to transform s1 into
# s2. The greater the distance, the more different the strings are.
#
# The algorithm employs a proximity matrix, which denotes the distances
# between substrings of the two given strings. Read the embedded comments
# for more info. If you want a deep understanding of the algorithm, print
# the matrix for some test strings and study it
#
# The beauty of this system is that nothing is magical - the distance
# is intuitively understandable by humans
#
# The distance is named after the Russian scientist Vladimir
# Levenshtein, who devised the algorithm in 1965
#
sub levenshtein
  {
    # $s1 and $s2 are the two strings
    # $len1 and $len2 are their respective lengths
    #
    my ($s1, $s2) = @_;
    my ($len1, $len2) = (length $s1, length $s2);
    
    # If one of the strings is empty, the distance is the length
    # of the other string
    #
    return $len2 if ($len1 == 0);
    return $len1 if ($len2 == 0);
    
    my %mat;
    
    # Init the distance matrix
    #
    # The first row to 0..$len1
    # The first column to 0..$len2
    # The rest to 0
    #
    # The first row and column are initialized so to denote distance
    # from the empty string
    #
    for (my $i = 0; $i <= $len1; ++$i)
      {
        for (my $j = 0; $j <= $len2; ++$j)
	  {
            $mat{$i}{$j} = 0;
            $mat{0}{$j} = $j;
	  }
	
        $mat{$i}{0} = $i;
      }
    
    # Some char-by-char processing is ahead, so prepare
    # array of chars from the strings
    #
    my @ar1 = split(//, $s1);
    my @ar2 = split(//, $s2);
    
    for (my $i = 1; $i <= $len1; ++$i)
      {
        for (my $j = 1; $j <= $len2; ++$j)
	  {
            # Set the cost to 1 iff the ith char of $s1
            # equals the jth of $s2
            # 
            # Denotes a substitution cost. When the char are equal
            # there is no need to substitute, so the cost is 0
            #
            my $cost = ($ar1[$i-1] eq $ar2[$j-1]) ? 0 : 1;
	    
            # Cell $mat{$i}{$j} equals the minimum of:
            #
            # - The cell immediately above plus 1
            # - The cell immediately to the left plus 1
            # - The cell diagonally above and to the left plus the cost
            #
            # We can either insert a new char, delete a char or
            # substitute an existing char (with an associated cost)
            #
            $mat{$i}{$j} = min([$mat{$i-1}{$j} + 1,
                                $mat{$i}{$j-1} + 1,
                                $mat{$i-1}{$j-1} + $cost]);
	  }
      }
    
    # Finally, the Levenshtein distance equals the rightmost bottom cell
    # of the matrix
    #
    # Note that $mat{$x}{$y} denotes the distance between the substrings
    # 1..$x and 1..$y
    #
    return $mat{$len1}{$len2};
  }
  
  
  # minimal element of a list
  #
  sub min
    {
      my @list = @{$_[0]};
      my $min = $list[0];
      
      foreach my $i (@list)
	{
	  $min = $i if ($i < $min);
	}
      
      return $min;
    }
    
    sub max{
      my @list = @_;
      return $list[0]>$list[1]?$list[0]:$list[1];
    }
    
