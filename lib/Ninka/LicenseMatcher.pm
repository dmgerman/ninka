package Ninka::LicenseMatcher;

use strict;
#use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';

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
$NON_CRITICAL_RULES{'LesserGPLv3'} = [@GPL_NON_CRITICAL, 'LesserGPLseeVer3', 'LesserGPLcopyVer3', 'SeeFileVer3'];
$NON_CRITICAL_RULES{'LesserGPLv2.1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2.1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLv2orv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2+'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'GPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'AGPLv3'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0', 'AGPLseeVer0'];
$NON_CRITICAL_RULES{'AGPLv3+'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0', 'AGPLseeVer0'];
$NON_CRITICAL_RULES{'GPLnoVersion'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'Apachev1.1'} = ['ApacheLic1_1'];
$NON_CRITICAL_RULES{'Apachev2'} = ['ApachePre', 'ApacheSee'];

$NON_CRITICAL_RULES{'LibGCJLic'} = ['LibGCJSee'];
$NON_CRITICAL_RULES{'CDDLicV1'} = ['Compliance', 'CDDLicWhere', 'ApachesPermLim', 'CDDLicIncludeFile', 'UseSubjectToTerm', 'useOnlyInCompliance'];
$NON_CRITICAL_RULES{'CDDLic'} = ['Compliance', 'CDDLicWhere', 'ApachesPermLim', 'CDDLicIncludeFile', 'UseSubjectToTerm', 'useOnlyInCompliance'];

$NON_CRITICAL_RULES{'CDDLorGPLv2'} = ['CDDLorGPLv2doNotAlter', 'AllRights', 'useOnlyInCompliance', 'CDDLorGPLv2whereVer0', 'ApachesPermLim', 'CDDLorGPLv2include', 'CDDLorGPLv2IfApplicable', 'CDDLorGPLv2Portions', 'CDDLorGPLv2ifYouWishVer2', 'CDDLorGPLv2IfYouAddVer2'];

$NON_CRITICAL_RULES{'CPLv1orGPLv2+orLGPLv2+'} = ['licenseBlockBegin', 'licenseBlockEnd'];

$NON_CRITICAL_RULES{'Qt'} = ['Copyright', 'qtNokiaExtra', 'QTNokiaContact', 'qtDiaTems'];
$NON_CRITICAL_RULES{'orLGPLVer2.1'} = ['LesserqtReviewGPLVer2.1', 'qtLGPLv2.1where'];
$NON_CRITICAL_RULES{'orGPLv3'} = ['qtReviewGPLVer3.0', 'qtReviewGPLVer3', 'qtGPLwhere'];
$NON_CRITICAL_RULES{'digiaQTExceptionNoticeVer1.1'} = ['qtDigiaExtra'];

$NON_CRITICAL_RULES{'MPLv1_0'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'MPLv1_1'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_1'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_0'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];

$NON_CRITICAL_RULES{'subversion'} = ['SeeFileSVN', 'subversionHistory'];
$NON_CRITICAL_RULES{'subversion+'} = ['SeeFileSVN', 'subversionHistory'];
$NON_CRITICAL_RULES{'tmate+'} = ['SeeFileSVN'];

$NON_CRITICAL_RULES{'openSSLvar2'} = ['BSDcondAdvPart2'];

$NON_CRITICAL_RULES{'MPLv1_1'} = ['licenseBlockBegin', 'MPLsee', 'Copyright', 'licenseBlockEnd', 'ApacheLicWherePart1', 'MPLwarranty', 'MPLwarrantyVar'];
$NON_CRITICAL_RULES{'MPL1_1andLGPLv2_1'} = ['MPLoptionIfNotDelete2licsVer0', 'MPL_LGPLseeVer0'];

$NON_CRITICAL_RULES{'FreeType'} = ['FreeTypeNotice'];

$NON_CRITICAL_RULES{'GPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'license_tokens' is mandatory" unless exists $args{license_tokens};

    my $path = dirname(__FILE__);

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{rules} = read_rules(catfile($path, 'rules.dict'));
    $self->{inter_rules} = read_inter_rules(catfile($path, 'interrules.dict'));

    my ($license_sentence_names, $originals) = read_license_tokens($args{license_tokens});
    $self->{license_sentence_names} = $license_sentence_names;
    $self->{originals} = $originals;

    $self->{count_matches} = 0;
    $self->{result} = [];

    return $self;
}

sub execute {
    my ($self) = @_;

    if (scalar(@{$self->{originals}}) == 0) {
        return 'NONE';
    }

    # matching spdx requires to match strict licenses, with no alternatives...

    my @license_sentence_names = @{$self->{license_sentence_names}};
    my $senttok = ',' . join(',', @license_sentence_names) . ',';
    print STDERR "senttok [$senttok]\n" if $self->{verbose};
    $senttok = $self->match_license($senttok);

    # do we have to check again?
    ## todo, verify that we have unmatched sentences...

    @license_sentence_names = split ',', $senttok;

    # first remove the extrict part from it
    my $match = 0;
    for (my $i = 0; $i <= $#license_sentence_names; $i++) {
        if ($license_sentence_names[$i] == 0 &&
            $license_sentence_names[$i] ne 'UNKNOWN' &&
            $license_sentence_names[$i] ne '') {
            $license_sentence_names[$i] =~ s/Extrict$//;
            $match++;
        }
    }

    if ($match) {
        foreach my $inter_rule (@{$self->{inter_rules}}) {
            @license_sentence_names = map { $_ eq $inter_rule->[0] ? $inter_rule->[1] : $_ } @license_sentence_names;
        }

        $senttok = join(',', @license_sentence_names) . ',';
        print STDERR "senttok [$senttok]\n" if $self->{verbose};
        $senttok = $self->match_license($senttok);
    }

    return $self->generate_license_result($senttok);
}

sub is_unknown {
    my ($s) = @_;
    my @f = split /,/, $s;
    return $f[0] eq 'UNKNOWN';
}

sub read_rules {
    my ($file) = @_;
    my @rules = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        # clean up spaces
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        $line =~ s/\s*,\s*/,/g;
        $line =~ s/\s*:\s*/:/g;
        # check format
        if ($line =~ /^#/ || $line !~ /(.*):(.*,)*(.*)/) {
            next;
        }
        $line =~ /(.*?):(.*)/;
        push @rules, [$1, $2];
    }

    close $fh;

    return \@rules;
}

sub read_inter_rules {
    my ($file) = @_;
    my @inter_rules = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        # check format
        if ($line =~ /^#/ || $line !~ /(.*?):(.*)/) {
            next;
        }
        foreach my $item (split /\|/, $2) {
            push @inter_rules, [$item, $1];
        }
    }

    close $fh;

    return \@inter_rules;
}

sub read_license_tokens {
    my ($license_tokens) = @_;

    my @tokens = ();
    my @originals = ();

    foreach my $license_token (@$license_tokens) {
        my @fields = split ':', $license_token;
        push @originals, $fields[1];
        my @token = split ';', $fields[0];
        push @tokens, $token[0];
    }

    return (\@tokens, \@originals);
}

# we will iterate over rules, matching as many as we can...
sub match_license {
    my ($self, $senttok) = @_;

    # create a string with the sentences
    foreach my $rule (@{$self->{rules}}) {
        my ($rule_name, $rule_tokens) = @$rule;
        my $rule_length = scalar(split ',', $rule_tokens);

        print STDERR "trying [$rule_name][$rule_tokens] on [$senttok]\n" if $self->{verbose};
        while ($senttok =~ s/,$rule_tokens,/,$rule_length,/) {
            print STDERR "rule matched\n" if $self->{verbose};
            $self->{count_matches}++;
            push @{$self->{result}}, $rule_name;
        }
    }

    # at this point we have removed all the matched sentences...
    print STDERR "senttok after matching rules [$senttok]\n" if $self->{verbose};
    print STDERR "result after matching rules [" . join(',', @{$self->{result}}) . "]\n" if $self->{verbose};

#    # let us remove allrights
#    my $only_all_right = 1;
#    for my $i (0.. scalar(@license_sentence_names)-1){
#        if ($license_sentence_names[$i] eq 'AllRights') {
#            $license_sentence_names[$i] = '';
#        } else {
#            $only_all_right = 0;
#        }
#    }

    # output result
    if (scalar(@{$self->{result}}) > 0) {
        # at this point we have matched

        # let us clean up the rules... let us print the matched rules, and the
#    if (grep(/GPL/, @{$self->{result}})) {
#        print "GPL...\n";
#        foreach my $r ($NON_CRITICAL_RULES{GPL}) {
#            $senttok =~ s/(,|^)$r(,|$)/$1$2/g;
#        }
#    }

        foreach my $rule (@GENERAL_NON_CRITICAL) {
            while ($senttok =~ s/,$rule,/,-1,/) {
                ;
            }
        }
        print STDERR "senttok after removal of general non-critical rules [$senttok]\n" if $self->{verbose};

        foreach my $rule_name (@{$self->{result}}) {
            foreach my $rule (@{$NON_CRITICAL_RULES{$rule_name}}) {
                while ($senttok =~ s/,$rule,/,-1,/g) {
                    ;
                }
            }
        }
        print STDERR "senttok after removal of non-critical rules [$senttok]\n" if $self->{verbose};
    }

    return $senttok;
}

sub generate_license_result {
    my ($self, $senttok) = @_;

#   $senttok =~ s/AllRights(,?)/$1/g;
#   $senttok =~ s/UNKNOWN,/,/g;
#   $senttok =~ s/,+/,/g;

    my @sections = split ',', $senttok;
    die 'assertion 1' if $sections[0] ne '';
    die 'assertion 2' if $sections[scalar(@sections)] ne '';

    my $ignored_lines = 0;
    my $license_lines = 0;
    my $unknown_lines = 0;
    my $unmatched_lines = 0;

    foreach my $i (1..scalar(@sections)-1) {
        if ($sections[$i] < 0) {
            $ignored_lines -= $sections[$i];
        } elsif ($sections[$i] != 0) {
            $license_lines += $sections[$i];
        } elsif ($sections[$i] eq 'UNKNOWN') {
            $unknown_lines++;
        } else {
            $unmatched_lines++;
        }
    }
    $senttok =~ s/^,(.*),$/$1/;

    my $license_result;
    if (scalar(@{$self->{result}}) == 0) {
        $license_result = 'UNKNOWN';
    } else {
        $license_result = join ',', @{$self->{result}};
    }
    # ok, so now, what I want to output is:
    # licenses; number of licenses matched;number of sentences matched; number of sentences ignored;number of sentences not matched;number of sentences unknown
    $license_result .= ";$self->{count_matches};$license_lines;$ignored_lines;$unmatched_lines;$unknown_lines;$senttok";

    return $license_result;
}

1;

__END__

=head1 NAME

Ninka::LicenseMatcher

=head1 DESCRIPTION

Uses a set of license sentence names as input and outputs license names corresponds to a rule which match the set.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010  Yuki Manabe and Daniel M. German

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
