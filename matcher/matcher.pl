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

my %NON_CRITICAL_RULES = ();

# these should go into a file, but for the time being, let us keep them here

# once we have matched a rule, these are not that important

my @GENERAL_NON_CRITICAL = ('AllRights');

my @GPL_NON_CRITICAL = ('GPLnoVersion',
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

$NON_CRITICAL_RULES{'LibraryGPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv3'} = [@GPL_NON_CRITICAL, 'LesserGPLseeVer3','LesserGPLcopyVer3','SeeFileVer3'];
$NON_CRITICAL_RULES{'LesserGPLv2.1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2.1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLv2orv3'}= [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2+'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'GPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'AGPLv3'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0','AGPLseeVer0'];
$NON_CRITICAL_RULES{'AGPLv3+'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0','AGPLseeVer0'];
$NON_CRITICAL_RULES{'GPLnoVersion'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'Apachev1.1'} = ['ApacheLic1_1'];
$NON_CRITICAL_RULES{'Apachev2'}   = ['ApachePre','ApacheSee'];

$NON_CRITICAL_RULES{'LibGCJLic'}  = ['LibGCJSee'];
$NON_CRITICAL_RULES{'CDDLicV1'}  = ['Compliance','CDDLicWhere','ApachesPermLim','CDDLicIncludeFile','UseSubjectToTerm', 'useOnlyInCompliance'];
$NON_CRITICAL_RULES{'CDDLic'}  = ['Compliance','CDDLicWhere','ApachesPermLim','CDDLicIncludeFile','UseSubjectToTerm', 'useOnlyInCompliance'];

$NON_CRITICAL_RULES{'CDDLorGPLv2'}= ['CDDLorGPLv2doNotAlter','AllRights','useOnlyInCompliance', 'CDDLorGPLv2whereVer0', 'ApachesPermLim', 'CDDLorGPLv2include','CDDLorGPLv2IfApplicable', 'CDDLorGPLv2Portions', 'CDDLorGPLv2ifYouWishVer2', 'CDDLorGPLv2IfYouAddVer2'];

$NON_CRITICAL_RULES{'CPLv1orGPLv2+orLGPLv2+'} = ['licenseBlockBegin', 'licenseBlockEnd'];

$NON_CRITICAL_RULES{'Qt'} = ['Copyright','qtNokiaExtra','QTNokiaContact', 'qtDiaTems'];
$NON_CRITICAL_RULES{'orLGPLVer2.1'} = ['LesserqtReviewGPLVer2.1','qtLGPLv2.1where'];
$NON_CRITICAL_RULES{'orGPLv3'} = ['qtReviewGPLVer3.0','qtReviewGPLVer3','qtGPLwhere'];
$NON_CRITICAL_RULES{'digiaQTExceptionNoticeVer1.1'} = ['qtDigiaExtra'];

$NON_CRITICAL_RULES{'MPLv1_0'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NON_CRITICAL_RULES{'MPLv1_1'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_1'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_0'}  = ['ApacheLicWherePart1','MPLwarranty','MPLSee'];

$NON_CRITICAL_RULES{'subversion'} = ['SeeFileSVN','subversionHistory'];
$NON_CRITICAL_RULES{'subversion+'} = ['SeeFileSVN','subversionHistory'];
$NON_CRITICAL_RULES{'tmate+'} = ['SeeFileSVN'];

$NON_CRITICAL_RULES{'openSSLvar2'} = ['BSDcondAdvPart2'];

$NON_CRITICAL_RULES{'MPLv1_1'} = ['licenseBlockBegin','MPLsee','Copyright','licenseBlockEnd','ApacheLicWherePart1','MPLwarranty', 'MPLwarrantyVar'];
$NON_CRITICAL_RULES{'MPL1_1andLGPLv2_1'} = ['MPLoptionIfNotDelete2licsVer0','MPL_LGPLseeVer0'];

$NON_CRITICAL_RULES{'FreeType'} = ['FreeTypeNotice'];

$NON_CRITICAL_RULES{'GPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];

# initialize

my $path = $0;
$path =~ s/[^\/]+$//;
if ($path eq '') {
    $path = './';
}

my $rules_file = $path . 'rules.dict';
my $interrules_file = $path . 'interrules.dict';

die "Usage $0 <filename>.senttok" unless $ARGV[0] =~ /\.senttok$/;

my $count_unknowns = 0;

# read the rules
my @rules = read_rules($rules_file);
my @inter_rules = read_inter_rules($interrules_file);

my @license_sentence_names = ();
my @original;

read_original($ARGV[0], \@license_sentence_names, \@original);

#foreach my $x (@license_sentence_names) {
#    print "$x\n";
#}
#exit;

#foreach my $x (@original) {
#    print "$x\n";
#}
#exit;

##########################################

#for my $ref( @inter_rules ){
#   print "@$ref\n";
#}

# matching spdx requires to match strict licenses, with no alternatives...

my $senttok = ',' . join(',', @license_sentence_names) . ',';
my @result = ();
my $count_matches = 0;

print "[$senttok]\n" if $debug;
match_license();

# do we have to check again?
## todo, verifythat we have unmatched sentences...

@license_sentence_names = split(',', $senttok);

# first remove the extrict part from it

#print_result();

my $match = 0;
for (my $i = 0; $i <= $#license_sentence_names; $i++) {
    if ($license_sentence_names[$i] == 0 and
        ($license_sentence_names[$i] ne 'UNKNOWN' and
         $license_sentence_names[$i] ne '')) {
#        print "[$license_sentence_names[$i]]\n";
        $license_sentence_names[$i] =~ s/Extrict$//;
        $match++;
    }
}

#print_result();

if ($match > 0) {
#    print "REDO\n";
    for (my $i = 0; $i <= $#inter_rules; $i++) {
        #for my $ref( @inter_rules[$i]){
        #  print "@$ref\n";
        #}
        #print $inter_rules[$i][0];
        @license_sentence_names = map { $_ eq $inter_rules[$i][0] ? $inter_rules[$i][1] : $_ } @license_sentence_names;
    }

    $senttok = join(',', @license_sentence_names) . ',';

    match_license();
}

print_result();

exit 0;

#print @license_sentence_names;
#print join(';',@license_sentence_names)."\n";

# 3. matching
###############################

# we will iterate over rules, matching as many as we can...

sub is_unknown {
    my ($s) = @_;
    my @f = split (/,/, $s);
    return $f[0] eq 'UNKNOWN';
}

sub read_rules {
    my ($file) = @_;
    open (RULES, "<$file") or die ('Error: rules.dict is not found.');
    my $sentence;
    my @rules = ();
    while ($sentence = <RULES>) {
        chomp $sentence;
        # clean up spaces
        $sentence =~ s/^\s+//;
        $sentence =~ s/\s+$//;
        $sentence =~ s/\s*,\s*/,/g;
        $sentence =~ s/\s*:\s*/:/g;
        #check format
        if ($sentence =~ /^#/ || $sentence !~ /(.*):(.*,)*(.*)/) {
            next;
        }
        $sentence =~ /(.*?):(.*)/;
        push (@rules, [$1, $2]);
    }
    close RULES;
    return @rules;
}

sub read_inter_rules {
    my ($file) = @_;

    my @inter_rules;
    open (IRULES, "<$file") or die ('Error: interrules.dict is not found.');
    my $sentence;
    while ($sentence = <IRULES>) {
        chomp $sentence;
        #check format
        if ($sentence =~ /^#/ || $sentence !~ /(.*?):(.*)/) {
            next;
        }
        foreach my $item (split(/\|/, $2)) {
            push (@inter_rules, [$item, $1]);
        }
    }
    close IRULES;
    return @inter_rules;
}

sub read_original {
    my ($file, $tokens, $originals) = @_;

    open (INPUTFILE, $file) or die ("Error: $file is not found.");

    my $sentence;
    my @original;
    while ($sentence = <INPUTFILE>) {
        chomp $sentence;
        my @fields = split(':', $sentence);
        push(@$originals, $fields[1]);
        my @token = split(';', $fields[0]);
        push(@$tokens, $token[0]);
    }
    if (scalar(@$originals) == 0) {
        print "NONE\n";
        exit 0;
    }

#print join(';',@license_sentence_names)."\n";

    close INPUTFILE;
}

sub match_license {
# create a string with the sentences

    for (my $j = 0; $j <= $#rules; $j++) {
        my $rule = $rules[$j][1];
        my $rulename = $rules[$j][0];
        my $rule_length = scalar(split(',', $rule));
        # replace rule with the length of the rule
        print "To try [$rulename][$rule] on [$senttok]\n" if $debug;
        while ($senttok =~ s/,${rule},/,$rule_length,/) {
            $count_matches++;
            push (@result, $rulename);
#        print ">>>>$senttok|$rules[$j][1]\n";
#        print 'Result: ', join(',', @result);
#        print "\n";
        }
    }

#    print ">>>>[$senttok]\n";

    my $only_all_right = 0;

# ok, at this point we have removed all the matched sentences...
#print STDERR "Ending>>>>>>>$senttok\n";
#print STDERR 'Size>>' , scalar(@result), "\n";
#print STDERR 'Result>>', join(',', @result), "\n";

# let us remove allrights
#    my $only_all_right = 1;
#    for my $i (0.. scalar(@license_sentence_names)-1){
#        if (($license_sentence_names[$i] eq 'AllRights')) {
#            $license_sentence_names[$i] = '';
#        } else {
#            $only_all_right = 0;
#        }
#    }

# output result
    if (scalar(@result) > 0) {
        # at this point we have matched

        # let us clean up the rules... let us print the matched rules, and the
#    if (grep(/GPL/, @result)) {
#        print "GPL...\n";
#        foreach my $r ($NON_CRITICAL_RULES{GPL}) {
#            $senttok =~ s/(,|^)$r(,|$)/$1$2/g;
#        }
#    }
        # general removal of rules

        foreach my $r (@GENERAL_NON_CRITICAL) {
            while ($senttok =~ s/,$r,/,-1,/) {
                ;
            }
        }
#        print "[$senttok]\n";

        foreach my $res (@result) {
            my $temp = $NON_CRITICAL_RULES{$res};
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

sub print_result {
#        $senttok =~ s/AllRights(,?)/$1/g;
#        $senttok =~ s/UNKNOWN,/,/g;
#        $senttok =~ s/,+/,/g;

    my $save = $senttok;
    # ok, so now, what I want to output it:
    # licenses; number of licenses matched;number of sentences matched; number of sentences ignored;number of sentences not matched;number of sentences unknown
    my @sections = split(',', $senttok);
    die 'assertion 1' if $sections[0] ne '';
    die 'assertion 2' if $sections[scalar(@sections)] ne '';

    my $ignored_lines = 0;
    my $license_lines = 0;
    my $unknown_lines = 0;
    my $unmatched_lines = 0;
    foreach my $i (1..scalar(@sections)-1) {
#        print "$i;$sections[$i]\n";
        if ($sections[$i] < 0) {
            $ignored_lines += - $sections[$i];
        } elsif ($sections[$i] != 0) {
            $license_lines += $sections[$i];
        } elsif ($sections[$i] eq 'UNKNOWN') {
            $unknown_lines++;
        } else {
            $unmatched_lines++;
        }
    }
    $senttok =~ s/^,(.*),$/$1/;

#    print "$ignored_lines > $license_lines > $unknown_lines > $unmatched_lines\n";
    if (scalar (@result) == 0) {
        print 'UNKNOWN';
    } else {
        print join(',',@result);
    }
    print ";$count_matches;$license_lines;$ignored_lines;$unmatched_lines;$unknown_lines;$senttok\n";
    $senttok = $save;
}

