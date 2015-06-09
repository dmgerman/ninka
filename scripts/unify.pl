#!/usr/bin/perl

# first pass, unify names of licenses and remove duplicates.

# we trick regarding gpl related licenses so they are "clustered" together..
#
# replace GPL with __GPL
# replace exception in the text with ___exception

use strict;

my %equiv = (
    "boostV1Ref" => "boostV1",
    "X11" => "X11mit",
    "X11Festival" => "X11mit",
    "X11mitNoSellNoDocDocBSDvar" => "X11mit",
    "X11mitwithoutSell" => 'X11mit',
    "X11mitBSDvar" => "X11mit",
    "X11mitwithoutSellCMUVariant" => "X11mit",
    "X11mitwithoutSellCMUVariant" => "X11mit",
    "X11mitwithoutSellandNoDocumentationRequi" => "X11mit",
    "MITvar3" => "X11mit",
    "MITvar2" => "X11mit",
    "MIT" => "X11mit",
    "ZLIBref" => "ZLIB",
    "BSD3NoWarranty" => "BSD3",
    "BSD2EndorseInsteadOfBinary" => "BSD2",
    "BSD2var2" => "BSD2",
    "LesserGPLv2" => "LibraryGPLv2",
    "LesserGPLv2+"  => "LibraryGPLv2+",
    "orLGPLVer2.1" => "LesserGPLVer2.1",
    "postgresqlRef" => "postgresql",
    );

while (<>) {
    chomp;
    my @f = split(/;/);
    # first remove duplicates

    my $l = $f[1];

    # do a simple rewriting of this exception which is an incomplete license

    $l =~ s/^Exception$/UNKNOWN/;

    my @l = split(/,/,$l);
    my %lics =  %{{ map { $_ => 1 } @l }};

    %lics = Do_Equivalent(%lics);
    %lics = Remove_Redundant(%lics);
    %lics = Do_Exceptions(%lics);

    my @out = sort keys %lics;

    my $t = join(',', @out);
    if ($t eq "") {
	$t = "UNKNOWN";
    }
    print $f[0], ";$t\n";
}

sub Do_Exceptions
{
    my (%lics) = @_;

    if ($lics{'digiaQTExceptionNoticeVer1.1'} ne '' and $lics{'Qt'}) {
	delete $lics{'digiaQTExceptionNoticeVer1.1'};
	delete $lics{'Qt'};
	$lics{'Qt-qtExcep'} = 'Qt-qtExcep';
    }
    if ($lics{'BisonException'} ne "" and $lics{"GPLv3+"} ne "") {
	delete $lics{'BisonException'};
	delete $lics{"GPLv3+"};
	$lics{'GPLv3+-bisonExcep'} = 'GPLv3+-bisonExcep';
    }
    if ($lics{'BisonException'} ne "" and $lics{"GPLv2+"} ne "") {
	delete $lics{'BisonException'};
	delete $lics{"GPLv2+"};
	$lics{'GPLv2+-bisonExcep'} = 'GPLv2+-bisonExcep';
    }
    if ($lics{'BisonException'} ne "" and $lics{"GPLv2"} ne "") {
	delete $lics{'BisonException'};
	delete $lics{"GPLv2"};
	$lics{'GPLv2-bisonExcep'} = 'GPLv2-bisonExcep';
    }
    if ($lics{'ClassPathException'} ne "" and $lics{"GPLv2"} ne "") {
	delete $lics{'ClassPathException'};
	delete $lics{"GPLv2"};
	$lics{"GPLv2-classPathExcep"} = "GPLv2-classPathExcep";
    }
    if ($lics{'CDDLorGPLv2'} ne "" and $lics{"ClassPathExceptionGPLv2"} ne "") {
	delete $lics{'CDDLorGPLv2'};
	delete $lics{"ClassPathExceptionGPLv2"};
	$lics{'CDDLorGPLv2-classPathExcep'} = 'CDDLorGPLv2-classPathExcep';
    }
    if ($lics{'LinkException'} ne "" and $lics{"GPLv3+"} ne "") {
	delete $lics{'LinkException'};
	delete $lics{"GPLv3+"};
	$lics{'GPLv3+-linkExcep'} = 'GPLv3+-linkExcep';
    }
    if ($lics{'LinkException'} ne "" and $lics{"GPLv2+"} ne "") {
	delete $lics{'LinkException'};
	delete $lics{"GPLv2+"};
	$lics{'GPLv2+-linkExcep'} = 'GPLv2+-linkExcep';
    }
    if ($lics{'LinkException'} ne "" and $lics{"GPLv3"} ne "") {
	delete $lics{'LinkException'};
	delete $lics{"GPLv3"};
	$lics{'GPLv3-linkExcep'} = 'GPLv3-linkExcep';
    }
    if ($lics{'LinkException'} ne "" and $lics{"GPLv2"} ne "") {
	delete $lics{'LinkException'};
	delete $lics{"GPLv2"};
	$lics{'GPLv2-linkExcep'} = 'GPLv2-linkExcep';
    }

    return %lics;

}

sub Remove_Redundant
{
    my (%lics) = @_;

    if ($lics{"GPLnoVersion"} ne "" and $lics{"GPLv2"} . $lics{"GPLv2+"} .$lics{"GPLv3"} . $lics{"GPLv3+"} ne "") {
	delete $lics{"GPLnoVersion"};
    }
    if ($lics{"GPLv2+"} ne "" and $lics{"GPLv3+"} ne "") {
	delete $lics{"GPLv2+"};
    }
    if ($lics{'MPL1_1andLGPLv2_1'} ne "" and $lics{"MPLv1_1"} ne "") {
	delete $lics{"MPLv1_1"};
    }


    return %lics;

}

sub Do_Equivalent
{
    my (%lics) = @_;
    my %outA;

    # then normalize licenses
    foreach my $a (keys %lics) {
	next if $a eq "SeeFile";
	if ($equiv{$a} ne "") {
	    $outA{$equiv{$a}} = $equiv{$a};
	}  else {
	    $outA{$a} = $a;
	}
    }
    return %outA;

}


sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
