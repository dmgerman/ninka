#!/usr/bin/perl 
# 
# Sentence Splitter
#

#  Author: Paul Clough
#  With modifications by Daniel M German and Y. Manabe,
#
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 2 of the
#    License, or (at your option) any later version.
#
#    This patch is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;

my $abbrv_file = 'abbrev/abbrev.txt';
my $len = 0;

my %ABBREVIATIONS = ();
my $output_file = $ARGV[0];

# where are we running the splitter from?
my $path = $0;
$path =~ s/[^\/]+$//;
if ($path eq '') {
    $path = './';
}

$abbrv_file = $path . $abbrv_file;

die "Usage $0 <filename>.comments" unless $ARGV[0] =~ /\.comments$/;


die "Input file name should end in '.comments' [$output_file]" unless  $output_file =~ s/\.comments$/.sentences/;

open(OUT, ">$output_file") or die("Unable to create output file [$output_file]");


#print length($opt_o);

# Load in the dictionary and find the common words.
# Here, we assume the words in upper case are simply names and one
# word per line - i.e. in same form as /usr/dict/words
# Same assumptions as for dictionary
&loadAbbreviations;

my $text;
#	open(FILE, $opt_f) or die "Can't open $opt_f for reading\n";

my $line;
while (defined ($line = <>)) {
    $text.= $line;
}

# append a newline just in case
$text.="\n";

# - is used to create lines
# = is used to create lines
$text =~ s@\+?\-{3,1000}\+?@ @gmx;
$text =~ s@={3,1000}@ @gmx;
$text =~ s@:{3,1000}@ @gmx;
$text =~ s@\*{3,1000}@ @gmx;

# some characters are used for prettyprinting but never appear in sentences
$text =~ s@\|+@ @gmx;
$text =~ s@\\+@ @gmx;

# let us deal with /* before we do anything
$text =~ s@^[ \t]*/\*@@gmx;
$text =~ s/\*\/[ \t]*$//gmx;
$text =~ s@([^:])// @$1@gmx;


# Replace /\r\n/ with \n only
$text =~ s/\r\n/\n/g;


# now, try to replace the leading/ending character of each line #/-, at most 3 heading characters
# and each repeated as many times as necessaary
$text =~ s/^[ \t]{0,3}[\*\#\/\;]+//gmx;
$text =~ s/^[ \t]{0,3}[\-]+//gmx;

$text =~ s/[\*\#\/]+[ \t]{0,3}$//gmx;
$text =~ s/[\-]+[ \t]{0,3}$//gmx;

# now, try to replace the ending character of each line if it is * or #
$text =~ s/[\*\#]+//gmx;

# at this point we have lines with nothing but spaces, let us get rid of them
$text =~ s/^[ \t]+$/\n/gm;

# let us try the following trick
# We first get rid of \t and replace it with ' '
# we then use \t as a "single line separator" and \n as multiple line.
# so we can match each with a single character.
$text =~ tr/\t/ /;

$text =~ s/\n(?!\n)/\t/g;
$text =~ s/\n\n+/\n/g;
$text .= "\n";

# this gets us in big trouble... licenses that have numeric abbreviations
$text =~ s/v\.\s+2\.0/v<dot> 2<dot>0/g;

while ($text =~ /^([^\n]*)\n/gsm ) {
    my $curr = $1;
#    print "<<$curr\n<<\n";

    # let us count the number of alphabetic chars to check if we are skipping anything we should not
    my $count = 0;
    for my $i (0..length($curr)-1) {
        my $c = substr($curr,$i,1);
        $count++ if ($c ge 'A' && $c le 'z');
    }

    my @sentences = Split_Text($curr);

    my $count2 = 0;

    foreach my $s (@sentences) {
        for my $i (0..length($s)-1) {
            my $c = substr($s,$i,1);
            $count2++ if ($c ge 'A' && $c le 'z');
        }
        print OUT Clean_Sentence($s) , "\n";
    }
    if ($count != $count2) {
        print STDERR "-------------------------------------\n";
        print STDERR "[$curr]\n";
        foreach my $s (@sentences) {
            print STDERR Clean_Sentence($s) , "\n";
        }
        die "Number of printable chars does not match! [$count][$count2]";
    }
}
close OUT;
#print "$text\n";

exit;




#***************************************************************************************************

#***************************************************************************************************
# procedures
#***************************************************************************************************

sub Clean_Sentence
{
    ($_) = @_;
    # check for trailing bullets of different types

    s/^o //;
    s/^\s*[0-9]{1-2}+\s*[\-\)]//;
    s/^[ \t]+//;
    s/[ \t]+$//;
    # remove a trailing -
    s/^[ \t]*[\-\.\s*] +//;

    # replace quotes
    s/\s+/ /g;

    s/['"`]+/<quotes>/g;


    s/:/<colon>/g;

    s/\.+$/./;

    die if /\n/m;

    return $_;

}


sub Split_Text
{
    my ($text) = @_;
    my $len = 0;
    my $next_word;
    my $last_word;
    my $stuff_after_period;
    my $puctuation;
    my @result;
    my $after;
    my $currentSentence = '';
    # this breaks the sentence into 
    # 1. Any text before a separator
    # 2. The separator [.!?:\n]
    # 3.
    while ($text =~ /^ 
                     ([^\.\!\?\:\n]*) #
                     ([\.\!\?\:\n])
                     (?=(.?))
                   /xsm) { #/(?:(?=([([{\"\'`)}\]<]*[ ]+)[([{\"\'`)}\] ]*([A-Z0-9][a-z]*))|(?=([()\"\'`)}\<\] ]+)\s))/sm ) {
	$text = $';    #';
        my $sentenceMatch = $1;
        my $sentence = $1 . $2; 
	my $punctuation = $2;
        $after = $3;
        
        # if next character is not a space, then we are not in a sentence"
        if ($after ne ' ' && $after ne "\t") {
            $currentSentence .= $sentence;
            next;
        }
        #at this point we know that there is a space after
        if ($punctuation eq ':'  || $punctuation eq '?'  || $punctuation eq '!') {
            # let us consider this right here a beginning of a sentence
            push @result, $currentSentence . $sentence;
            $currentSentence = '';
            next;
        }
        if ($punctuation eq '.') {
            # we have a bunch of alternatives
            # for the time being just consider a new sentence

            # TODO
            # simple heuristic... let us check that the next words are not the beginning of a sentence
            # in our library
            # ENDTODO
            
            # is the last word an abbreviation? For this the period has to follow the word
            # this expression might have to be updated to take care of special characters  in names :(
            if ($sentenceMatch =~ /(.?)([^[:punct:]\s]+)$/) {
                my $before = $1;
                my $lastWord = $2;
                #is it an abbreviation
                
                if (length($lastWord) == 1 ) {
                    # single character abbreviations are special...
                    # we will assume they never split the sentence if they are capitalized. 
                    if (($lastWord ge 'A') and
                        ($lastWord le 'Z'))  {
                        $currentSentence .= $sentence;
                        next;
                    }
                    print "last word an abbrev $sentenceMatch lastword [$lastWord] before [$before]\n";

                    # but some are lowercase!
                    if (($lastWord eq 'e') or
                        ($lastWord eq 'i'))  {
                        $currentSentence .= $sentence;
                        next;
                    }
                    print "2 last word an abbrev $sentenceMatch lastword [$lastWord] before [$before]\n";
                } else {
                    
                    $lastWord = lc $lastWord;
                    
                    # only accept abbreviations if the previous char to the abbrev is space or
                    # is empty (beginning of line). This avoids things like .c
                    if (length($before) > 0 and $before eq ' ' and  $ABBREVIATIONS{$lastWord}) {
                        
                        $currentSentence .= $sentence;
                        next;
                    } else {
                        # just keep going, we handle this case below
                    }
                }
                
            }

            push @result, $currentSentence . $sentence;
            $currentSentence = '';
            next;
        }
        die 'We have not dealt with this case';
    }
    push @result, $currentSentence . $text;
    
    #Print_Non_Sentence($text,"\n",'');
    return @result;

}

sub loadAbbreviations 
{
    
    # Initialise var
    my $abbrv_term = '';	
    
    if (open(ABBRV, $abbrv_file)) {
        
        while (defined ($line = <ABBRV>)) {
            chomp($line);
            $ABBREVIATIONS{$line} = $line;	
        }		
        
        close(ABBRV);
    } else {
        die "cannot open dictionary file $abbrv_file: $!";		
    }
}


#***************************************************************************************************
