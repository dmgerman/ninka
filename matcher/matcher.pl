#!/usr/bin/perl

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
# matchter.pl
#
# This script use a set of license sentence name as input 
# and output license name corresponds to a rule which match the set.
#
# author: Yuki Manabe
#
# usage: matchter.pl (inputfilename)
#

use strict;

my %NonCriticalRules ;

# these should go into a file, but for the time being, let us keep them here

# once we have matched a rule, these are not that important

my @gplNonCritical = ('GPLnoVersion',
                      'FSFwarranty',
                      'LibraryGPLcopyVer0',
                      'GPLseeVer0',
                      'GPLwrite',
                      'SeeFile',
                      'FreeSoftware',
                      'FSFwarrantyVer0',
                      'LibraryGPLseeDetailsVer0',
                      'FSFwarranty',
                      'LesserGPLseeDetailsVer0',
                      'GPLcopyVer0',
                      'GNUurl',
                      'GPLseeDetailsVer0');

$NonCriticalRules{"LibraryGPLv3+"} = [@gplNonCritical];
$NonCriticalRules{"LibraryGPLv3"} = [@gplNonCritical];
$NonCriticalRules{"LibraryGPLv2+"} = [@gplNonCritical];
$NonCriticalRules{"LibraryGPLv2"} = [@gplNonCritical];
$NonCriticalRules{"LesserGPLv3"} = [@gplNonCritical, 'LesserGPLseeVer3','LesserGPLcopyVer3','SeeFileVer3'];
$NonCriticalRules{"LesserGPLv2.1+"} = [@gplNonCritical];
$NonCriticalRules{"LesserGPLv2.1"} = [@gplNonCritical];
$NonCriticalRules{"LGPLv2orv3"}= [@gplNonCritical];
$NonCriticalRules{"LesserGPLv2"} = [@gplNonCritical];
$NonCriticalRules{"LesserGPLv2+"} = [@gplNonCritical];

$NonCriticalRules{"GPLv2+"} = [@gplNonCritical];
$NonCriticalRules{"GPLv2"} = [@gplNonCritical];
$NonCriticalRules{"GPLv1+"} = [@gplNonCritical];
$NonCriticalRules{"GPLv1"} = [@gplNonCritical];
$NonCriticalRules{"GPLv3+"} = [@gplNonCritical];
$NonCriticalRules{"GPLv3"} = [@gplNonCritical];
$NonCriticalRules{"AGPLv3"} = [@gplNonCritical, 'AGPLreceivedVer0','AGPLseeVer0'];
$NonCriticalRules{"AGPLv3+"} = [@gplNonCritical, 'AGPLreceivedVer0','AGPLseeVer0'];
$NonCriticalRules{"GPLnoVersion"} = [@gplNonCritical];

$NonCriticalRules{"Apachev1.1"} = ['ApacheLic1_1'];
$NonCriticalRules{"LibGCJLic"}  = ['LibGCJSee'];
$NonCriticalRules{"CDDLicV1"}  = ['Compliance','CDDLicWhere','ApachesPermLim','CDDLicIncludeFile','UseSubjectToTerm', 'useOnlyInCompliance'];
$NonCriticalRules{"CDDLic"}  = ['Compliance','CDDLicWhere','ApachesPermLim','CDDLicIncludeFile','UseSubjectToTerm', 'useOnlyInCompliance'];

$NonCriticalRules{"MPLv1_0"}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NonCriticalRules{"MPLv1_1"}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NonCriticalRules{"NPLv1_1"}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NonCriticalRules{"NPLv1_0"}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];

$NonCriticalRules{"subversion"} = ['SeeFileSVN','subversionHistory'];
$NonCriticalRules{"subversion+"} = ['SeeFileSVN','subversionHistory'];
$NonCriticalRules{"tmate+"} = ['SeeFileSVN'];

$NonCriticalRules{"openSSLvar2"} = ['BSDcondAdvPart2'];

# initialize

my $path = $0;
$path =~ s/[^\/]+$//;
if ($path eq "") {
    $path = "./";
  }

my $rules= $path . "rules.dict";
my $interrules= $path . "interrules.dict";

die "Usage $0 <filename>.sentences" unless $ARGV[0] =~ /\.senttok$/;

open (INPUTFILE, "<$ARGV[0]") or die ("Error: $ARGV[0] is not found.");
open (RULES, "<$rules") or die ("Error: rules.dict is not found.");
open (IRULES, "<$interrules") or die ("Error: interrules.dict is not found.");

# read rules

my @rulelist=();
my @interrulelist=();
my @licSentNames=();
my $countUnknowns = 0;

my $sentence;
while ($sentence=<RULES>){
  chomp $sentence;
  #check format
  if ($sentence =~ /^#/ || $sentence !~ /(.*):(.*,)*(.*)/){
    next;
  }
  $sentence =~ /(.*?):(.*)/;
  push (@rulelist,[$1,$2]);
}
#print $rulelist;

#for my $ref( @rulelist ){
#  no strict "refs";
#    print "@$ref\n";
#  }

close RULES;

while ($sentence=<IRULES>){
  chomp $sentence;
  #check format
  if ($sentence =~ /^#/ || $sentence !~ /(.*?):(.*)/){
    next;
  }
  foreach my $item (split(/\|/,$2)){
    push (@interrulelist,[$item,$1]);
  }
}

close IRULES;

##########################################

#for my $ref( @interrulelist ){
#    print "@$ref\n";
#}

# matching
# 1. read senttok file
my @original;
while ($sentence = <INPUTFILE>){
  #check format
  #chomp $sentence;
  if ($sentence =~ /^(.*?)[\n,]/){
    if ($1 ne "UNKNOWN"){
    } else {
        $countUnknowns++;        
    }
    push (@licSentNames,$1);
  }
  chomp $sentence;
  push (@original, $sentence);
}
if (scalar(@original) == 0) {
    print "NONE\n";
    exit 0;
}
   
#print join(";",@licSentNames)."\n";

close INPUTFILE;

# 2. replace
for (my $i=0;$i<=$#interrulelist ;$i++){
  #for my $ref( @interrulelist[$i]){
  #  print "@$ref\n";
  #}
  #print $interrulelist[$i][0];
  @licSentNames = map { $_ eq $interrulelist[$i][0] ? $interrulelist[$i][1] : $_ } @licSentNames;
}

#print @licSentNames;
#print join(";",@licSentNames)."\n";


# 3. matching
###############################

# we will iterate over rules, matching as many as we can...

my @result=();


# create a string with the sentences
my $senttok= "," . join(",",@licSentNames) . ",";

#print STDERR "\nStarting>>>>$senttok\n";

for (my $j=0;$j<=$#rulelist;$j++){
    
    my $rule=$rulelist[$j][1];
    my $rulename=$rulelist[$j][0];
    
    while ($senttok =~ s/,${rule},/,/){
        push (@result,$rulename);
#        print ">>>>$senttok|$rulelist[$j][1]\n";
#        print "Result: ", join(',', @result);
#        print "\n";
    }
}

# ok, at this point we have removed all the matched sentences...
#print STDERR "Ending>>>>>>>$senttok\n";
#print STDERR "Size>>" , scalar(@result), "\n";
#print STDERR "Result>>", join(',', @result), "\n";

# let us remove allrights
my $onlyAllRight = 1;
for my $i (0.. scalar(@licSentNames)-1){
    if (($licSentNames[$i] eq "AllRights")) {
        $licSentNames[$i] = '';
    } else {
        $onlyAllRight = 0;
    }
}

# output result
if (scalar(@result) > 0){
    # at this point we have matched


    # let us clean up the rules... let us print the matched rules, and the 
#    if (grep(/GPL/, @result)) {
#        print "GPL...\n";
#        foreach my $r ($NonCriticalRules{GPL}) {
#            $senttok =~ s/(,|^)$r(,|$)/$1$2/g;
#        }
#    }
    foreach my $res (@result) {
        my $temp = $NonCriticalRules{$res};
        foreach my $r (@$temp) {
#            print ">>Senttok [$r][$senttok]\n";
            while ($senttok =~ s/(,|^)$r(,|$)/$1$2/g) {
                ;
            }
        }
    }

    # we also want to remove any rule contains allrights
    $senttok =~ s/AllRights(,?)/$1/g;
    $senttok =~ s/UNKNOWN,/,/g;
    $senttok =~ s/,+/,/g;

    print join(',',@result), ";$senttok;$countUnknowns\n";
  

}else{

    # if it contains only AllRights there it is o'right
    # at this point there is at least one rule

    # let us remove the non important sentences... by making them empty 
    # on this array...
    if ($onlyAllRight) {
        print "NONE;\n";
    } elsif ($countUnknowns != 0) {
        print "UNMATCHED \[", join (',',@original), "\]\n";
    } else {
        my $t = join (',',@original);
        $t =~ s/;/<SEMI>/g;
        print "UNKNOWN [$t];";
        my $t = join (',',@licSentNames);
        $t =~ s/;/<SEMI>/g;
        print "UKNSIMP [$t]";
        print "\n";
    }
}

sub Is_Unknown
{
    my ($s) = @_;
    my @f = split (/,/, $s);
    return $f[0] eq "UNKNOWN";
}


