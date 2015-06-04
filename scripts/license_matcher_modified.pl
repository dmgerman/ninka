#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use Set::Object;
use Tie::IxHash;
use Tie::Autotie 'Tie::IxHash';
use Data::Dumper;

my %opts =();
my %licensedictionary=();
my %numofslashdictionary=();

tie %licensedictionary, 'Tie::IxHash';

my $prefix="/big2/y-manabe/licensereration/fedora/srcrpm_sandbox/";

getopts ("p:l:",\%opts);

open (PFH,$opts{"p"});

while (my $line=<PFH>){
    $line =~ /(.*);(.*)/;
    my $key = $1;
    my $license = $2;
    #if ($key =~ /\//){
#	$key =~ s/\//\\\//g;
    #  }
    #print "$key\n";
    if (defined $licensedictionary{substr($key,0,2)}{$key}){
	push (@{$licensedictionary{substr($key,0,2)}{$key}},$license);
#       print join(',',@{$licensedictionary{$key}});
    }else{
	my @tmp=($license);
	if (!defined $licensedictionary{substr($key,0,2)}){
	    #tie my %keylicensepairs,'Tie::IxHash';
	    #$licensedictionary{substr($key,0,2)}=\%keylicensepairs;
	}
	$licensedictionary{substr($key,0,2)}{$key}=\@tmp;
        my $numofslash = ($key =~ tr /\//\//);
        $numofslashdictionary{$key} = $numofslash;
    }
}

close PFH;

#print Dumper(\%licensedictionary);
#return;

#foreach my $key(keys %licensedictionary){
#    print $key.";";
#    print join(',',@{$licensedictionary{$key}});
#    print "\n";
#}

open (LFH,$opts{"l"});

while(my $line=<LFH>){
    #print $line;
    $line =~ /^${prefix}(.*?);(.*?)$/;
    my $filepath=$1;
    my $slicense=$2;
    my @slicenselist=split (/\,/,$slicense);
    my $licenseset = Set::Object->new(@slicenselist);
    #$licenseset= Set::Object->unique($licenseset);
    @slicenselist= sort($licenseset->members);
    my $uniqlicensenames = join (',',@slicenselist);
    #print "$license\n";
    foreach my $key(keys %{$licensedictionary{substr($filepath,0,2)}}){
	my @tmpdirnames;
	my @dirnames = split /\//,$filepath;
	if ($#dirnames >= ${numofslashdictionary}{$key}){
	    @tmpdirnames=@dirnames[0..$numofslashdictionary{$key}];
	}else{
	    next;
	}
#	print "$filepath,$licensedictionary{substr($filepath,0,2)}{$key},$key\n";
	#print "@{dirnames}[0..$numofslash]\n";
	my $tmpfilepath;
	$tmpfilepath = join('/',@tmpdirnames);
	#print "$key\n";
	if ($tmpfilepath eq $key){
	    print "${prefix}$filepath;$uniqlicensenames;";
	    print join(',',@{$licensedictionary{substr($key,0,2)}{$key}});
	    print "\n";
	    last;
	}
    }
}

close LFH;
