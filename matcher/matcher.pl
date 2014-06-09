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
my $debug = 0;

my %NonCriticalRules ;

# these should go into a file, but for the time being, let us keep them here

# once we have matched a rule, these are not that important

my @generalNonCritical = ('AllRights');

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

$NonCriticalRules{'LibraryGPLv3+'} = [@gplNonCritical];
$NonCriticalRules{'LibraryGPLv3'} = [@gplNonCritical];
$NonCriticalRules{'LibraryGPLv2+'} = [@gplNonCritical];
$NonCriticalRules{'LibraryGPLv2'} = [@gplNonCritical];
$NonCriticalRules{'LesserGPLv3'} = [@gplNonCritical, 'LesserGPLseeVer3','LesserGPLcopyVer3','SeeFileVer3'];
$NonCriticalRules{'LesserGPLv2.1+'} = [@gplNonCritical];
$NonCriticalRules{'LesserGPLv2.1'} = [@gplNonCritical];
$NonCriticalRules{'LGPLv2orv3'}= [@gplNonCritical];
$NonCriticalRules{'LesserGPLv2'} = [@gplNonCritical];
$NonCriticalRules{'LesserGPLv2+'} = [@gplNonCritical];
$NonCriticalRules{'GPLVer2.1or3KDE+'} = [@gplNonCritical];
$NonCriticalRules{'LGPLVer2.1or3KDE+'} = [@gplNonCritical];


$NonCriticalRules{'GPLv2+'} = [@gplNonCritical];
$NonCriticalRules{'GPLv2'} = [@gplNonCritical];
$NonCriticalRules{'GPLv1+'} = [@gplNonCritical];
$NonCriticalRules{'GPLv1'} = [@gplNonCritical];
$NonCriticalRules{'GPLv3+'} = [@gplNonCritical];
$NonCriticalRules{'GPLv3'} = [@gplNonCritical];
$NonCriticalRules{'AGPLv3'} = [@gplNonCritical, 'AGPLreceivedVer0','AGPLseeVer0'];
$NonCriticalRules{'AGPLv3+'} = [@gplNonCritical, 'AGPLreceivedVer0','AGPLseeVer0'];
$NonCriticalRules{'GPLnoVersion'} = [@gplNonCritical];

$NonCriticalRules{'Apache-1.1'} = ['ApacheLic1_1'];
$NonCriticalRules{'Apache-2'}   = ['ApachePre','ApacheSee'];

$NonCriticalRules{'LibGCJLic'}  = ['LibGCJSee'];
$NonCriticalRules{'CDDLicV1'}  = ['Compliance','CDDLicWhere','ApachesPermLim','CDDLicIncludeFile','UseSubjectToTerm', 'useOnlyInCompliance'];
$NonCriticalRules{'CDDLic'}  = ['Compliance','CDDLicWhere','ApachesPermLim','CDDLicIncludeFile','UseSubjectToTerm', 'useOnlyInCompliance'];

$NonCriticalRules{'CDDLorGPLv2'}= ['CDDLorGPLv2doNotAlter','AllRights','useOnlyInCompliance', 'CDDLorGPLv2whereVer0', 'ApachesPermLim', 'CDDLorGPLv2include','CDDLorGPLv2IfApplicable', 'CDDLorGPLv2Portions', 'CDDLorGPLv2ifYouWishVer2', 'CDDLorGPLv2IfYouAddVer2'];

$NonCriticalRules{'CPLv1orGPLv2+orLGPLv2+'} = ['licenseBlockBegin', 'licenseBlockEnd'];

$NonCriticalRules{'Qt'} = ['Copyright','qtNokiaExtra','QTNokiaContact', 'qtDiaTems'];
$NonCriticalRules{'orLGPLVer2.1'} = ['LesserqtReviewGPLVer2.1','qtLGPLv2.1where'];
$NonCriticalRules{'orGPLv3'} = ['qtReviewGPLVer3.0','qtReviewGPLVer3','qtGPLwhere'];
$NonCriticalRules{'digiaQTExceptionNoticeVer1.1'} = ['qtDigiaExtra'];

$NonCriticalRules{'MPLv1_0'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NonCriticalRules{'MPLv1_1'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NonCriticalRules{'NPLv1_1'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NonCriticalRules{'NPLv1_0'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];

$NonCriticalRules{'subversion'} = ['SeeFileSVN','subversionHistory'];
$NonCriticalRules{'subversion+'} = ['SeeFileSVN','subversionHistory'];
$NonCriticalRules{'tmate+'} = ['SeeFileSVN'];

$NonCriticalRules{'openSSLvar2'} = ['BSDcondAdvPart2'];

$NonCriticalRules{'MPLv1_1'} = ['licenseBlockBegin','MPLsee','Copyright','licenseBlockEnd','ApacheLicWherePart1','MPLwarranty', 'MPLwarrantyVar'];
$NonCriticalRules{'MPL1_1andLGPLv2_1'} = ['MPLoptionIfNotDelete2licsVer0','MPL_LGPLseeVer0'];

$NonCriticalRules{'FreeType'} = ['FreeTypeNotice'];
$NonCriticalRules{'boostV1'} = ['boostSeev1', 'SeeFile'];


# initialize

my $path = $0;
$path =~ s/[^\/]+$//;
if ($path eq '') {
    $path = './';
  }

my $rules= $path . 'rules.dict';
my $interrules= $path . 'interrules.dict';

die "Usage $0 <filename>.senttok" unless $ARGV[0] =~ /\.senttok$/;


# read rules

my $countUnknowns = 0;


# read the rules

my @rulelist = Read_Rules($rules);

my @interRuleList = Read_Inter_Rules($interrules);


my @licSentNames=();
my @original;

Read_Original($ARGV[0], \@licSentNames, \@original);


#foreach my $x (@licSentNames) {
#    print "$x\n";
#}
#exit;

#foreach my $x (@original) {
#    print "$x\n";
#}
#exit;

##########################################

#for my $ref( @interRuleList ){
#   print "@$ref\n";
#}

# matching spdx requires to match strict licenses, with no alternatives...

my $senttok= ',' . join(',',@licSentNames) . ',';
my @result=();
my $countMatches = 0;

print "[$senttok]\n" if $debug;
Match_License();

# do we have to check again?
## todo, verifythat we have unmatched sentences...

@licSentNames = split(',', $senttok);

# first remove the extrict part from it

#Print_Result();

my $match = 0;
for (my $i=0;$i<=$#licSentNames ;$i++) {
    if ($licSentNames[$i] == 0 and
        ($licSentNames[$i] ne 'UNKNOWN'  and
         $licSentNames[$i] ne '')) {
#        print "[$licSentNames[$i]]\n";
        $licSentNames[$i] =~ s/Extrict$//;
        $match ++;
    }
}

#Print_Result();


if ($match > 0) {
#    print "REDO\n";
    for (my $i=0;$i<=$#interRuleList ;$i++){
        #for my $ref( @interRuleList[$i]){
        #  print "@$ref\n";
        #}
        #print $interRuleList[$i][0];
        @licSentNames = map { $_ eq $interRuleList[$i][0] ? $interRuleList[$i][1] : $_ } @licSentNames;
    }

    $senttok= join(',',@licSentNames) . ',';

    Match_License();
}

Print_Result();


exit 0;



#print @licSentNames;
#print join(';',@licSentNames)."\n";


# 3. matching
###############################

# we will iterate over rules, matching as many as we can...





sub Is_Unknown
{
    my ($s) = @_;
    my @f = split (/,/, $s);
    return $f[0] eq 'UNKNOWN';
}


sub Read_Rules
{
    my ($rulesF) = @_;
    open (RULES, "<$rulesF") or die ('Error: rules.dict is not found.');
    my $sentence;
    my @rules = ();
    while ($sentence=<RULES>){
        chomp $sentence;
	# clean up spaces
	$sentence=~ s/^\s+//;
	$sentence=~ s/\s+$//;
	$sentence=~ s/\s*,\s*/,/g;
	$sentence=~ s/\s*:\s*/:/g;
        #check format
        if ($sentence =~ /^#/ || $sentence !~ /(.*):(.*,)*(.*)/){
            next;
        }
        $sentence =~ /(.*?):(.*)/;
        push (@rules,[$1,$2]);
    }
    close RULES;
    return @rules;
}


sub Read_Inter_Rules
{
    my ($interrules) = @_;

    my @list;
    open (IRULES, "<$interrules") or die ('Error: interrules.dict is not found.');
    my $sentence;
    while ($sentence=<IRULES>){
        chomp $sentence;
        #check format
        if ($sentence =~ /^#/ || $sentence !~ /(.*?):(.*)/){
            next;
        }
        foreach my $item (split(/\|/,$2)){
            push (@list,[$item,$1]);
        }
    }
    close IRULES;
    return @list;
}

sub Read_Original
{
    my ($inputF, $tokens, $originals) = @_;

    open (INPUTFILE, $inputF) or die ("Error: $inputF is not found.");

    my $sentence;
    my @original;
    while ($sentence = <INPUTFILE>){
        chomp $sentence;
        my @fields = split(':',$sentence);
        push(@$originals,$fields[1]);
        my @token = split(';', $fields[0]);
        push(@$tokens,$token[0]);
    }
    if (scalar(@$originals) == 0) {
        print "NONE\n";
        exit 0;
    }

#print join(';',@licSentNames)."\n";

    close INPUTFILE;
}

sub Match_License
{

# create a string with the sentences

    for (my $j=0;$j<=$#rulelist;$j++){

        my $rule=$rulelist[$j][1];
        my $rulename=$rulelist[$j][0];
        my $lenRule = scalar(split(',', $rule));
        # replace rule with the length of the rule
	print "To try [$rulename][$rule] on [$senttok]\n" if $debug;
        while ($senttok =~ s/,${rule},/,$lenRule,/){
            $countMatches ++;
            push (@result,$rulename);
#        print ">>>>$senttok|$rulelist[$j][1]\n";
#        print 'Result: ', join(',', @result);
#        print "\n";
        }
    }

#    print ">>>>[$senttok]\n";

    my $onlyAllRight = 0;

# ok, at this point we have removed all the matched sentences...
#print STDERR "Ending>>>>>>>$senttok\n";
#print STDERR 'Size>>' , scalar(@result), "\n";
#print STDERR 'Result>>', join(',', @result), "\n";

# let us remove allrights
#    my $onlyAllRight = 1;
#    for my $i (0.. scalar(@licSentNames)-1){
#        if (($licSentNames[$i] eq 'AllRights')) {
#            $licSentNames[$i] = '';
#        } else {
#            $onlyAllRight = 0;
#        }
#    }

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
        # general removal of rules


        foreach my $r (@generalNonCritical) {
            while ($senttok =~ s/,$r,/,-1,/) {
                ;
            }
        }
#        print "[$senttok]\n";

        foreach my $res (@result) {
            my $temp = $NonCriticalRules{$res};
            foreach my $r (@$temp) {
#            print ">>Senttok [$r][$senttok]\n";
                while ($senttok =~ s/,$r,/,-1,/g) {
                    ;
                }
            }
        }
#        print "[$senttok]\n";
    }
}


sub Print_Result
{
#        $senttok =~ s/AllRights(,?)/$1/g;
#        $senttok =~ s/UNKNOWN,/,/g;
#        $senttok =~ s/,+/,/g;

    my $save = $senttok;
    # ok, so now, what I want to output it:
    # licenses; number of licenses matched;number of sentences matched; number of sentences ignored;number of sentences not matched;number of sentences unknown
    my @sections = split(',', $senttok);
    die 'assertion 1' if $sections[0] ne '';
    die 'assertion 2' if $sections[scalar(@sections)] ne '';

    my $ignoredLines = 0;
    my $licenseLines = 0;
    my $unknownLines = 0;
    my $unmatchedLines = 0;
    foreach my $i (1..scalar(@sections)-1) {
#        print "$i;$sections[$i]\n";
        if ($sections[$i] < 0) {
            $ignoredLines += - $sections[$i];
        } elsif ($sections[$i] != 0) {
            $licenseLines += $sections[$i];
        } elsif ($sections[$i] eq 'UNKNOWN') {
            $unknownLines ++;
        } else {
            $unmatchedLines++;
        }
    }
    $senttok =~ s/^,(.*),$/$1/;

#    print "$ignoredLines > $licenseLines > $unknownLines > $unmatchedLines\n";
    if (scalar (@result) == 0) {
	print 'UNKNOWN';
    } else {
	print join(',',@result);
    }
    print ";$countMatches;$licenseLines;$ignoredLines;$unmatchedLines;$unknownLines;$senttok\n";
    $senttok = $save;

}
