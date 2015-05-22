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
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use Getopt::Std;
use File::Basename;
use File::Path qw(make_path);


my %opts = ();
if (!getopts ("vfCcSsGgTtLdDh",\%opts) or scalar(@ARGV) != 2) {
print STDERR "Ninka version 1.3

Usage $0 -fCtTvcgsGd <filename> <outputDir>

  -v verbose
  -f force all processing

  -C force creation of comments
  -c stop after creation of comments

  -S force creation of sentences
  -s stop after creation of sentences

  -G force creation of goodsent
  -g stop after creation of goodsent

  -T force creation of senttok
  -t stop after creation of senttok

  -L force creation of matching

  -d delete intermediate files
  -D delete license output file

  -h re-create directory structure of original filename in output files under output dir. For the sake of security, no .. directory is allowed in the path name. Starting /s are removed.

\n";

    exit 1;
}



my $verbose = exists $opts{v};
my $delete = exists $opts{d};
my $deleteLic = exists $opts{D};
my $createDirsHier = exists $opts{h};
#$delete = 1;

my $path = dirname($0);

if ($path eq "") {
    $path = "./";
}

my $force = exists $opts{f};
my $forceGood = exists $opts{G};
my $forceSentences = exists $opts{S};
my $forceSentok = exists $opts{T};
my $forceComments = exists $opts{C};
my $forceLicense = exists $opts{L};

#die "Usage $0 <filename>" unless $ARGV[0] =~ /\.(c|cpp|java|cc|cxx|h|jl|py|pm|el|pl)$/;

my $original = $ARGV[0];
my $escapedOriginal = escape_filename($original);
my $dirOriginal = $ARGV[1];
my $f = basename($escapedOriginal);

print "Starting: $original;\n" if ($verbose);

print "$original;";

if (not (-f $original)) {
    print "ERROR;[${original}] is not a file\n" ;
    exit 0;
}
if (not (-d $dirOriginal)) {
    print "ERROR;[${dirOriginal}] is not a directory\n" ;
    exit 0;
} 
$dirOriginal =~ s@/$@@;

my $dir;
my $hier = "";
if ($createDirsHier) {
    $hier = dirname($original);
    # make sure it does not start with /
    $hier =~ s@^/+@@;
    # abort if relative... 
    if ($hier =~ m@/\.\./@ or $hier =~ m@^\.\.@ or $hier =~ m@\.\.$@) {
        die "directory name [$hier] of input file contains .. aborting\n";
    }
    $dir = "$dirOriginal/$hier";
    make_path($dir) unless -d $dir;
    $dir = escape_filename($dir);
}

my $commentsFile = "$dir/${f}.comments";
my $sentencesFile = "$dir/${f}.sentences";
my $goodsentFile = "$dir/${f}.goodsent";
my $badsentFile = "$dir/${f}.badsent";
my $sentokFile = "$dir/${f}.senttok";
my $licenseFile = "$dir/${f}.license";
my $codeFile = "$dir/${f}.code";


Do_File_Process($original, $commentsFile, ($force or $forceComments),
                "$path/extComments/extComments.pl -c1 ${escapedOriginal} > $commentsFile",
                "Creating comments file",
                exists $opts{c}
    );


Do_File_Process($commentsFile, $sentencesFile, ($force or $forceSentences),
                "$path/splitter/splitter.pl ${commentsFile}",
                "Splitting sentences", exists $opts{s}
    );

Do_File_Process( $sentencesFile, $goodsentFile, ($force or $forceGood),
                 "$path/filter/filter.pl ${sentencesFile}",
                 "Filtering good sentences", exists $opts{s}
    );

Do_File_Process($goodsentFile, $sentokFile, ($force or $forceSentok),
                "$path/senttok/senttok.pl ${goodsentFile} > ${sentokFile}",
                "Matching sentences against rules", exists $opts{t}
    );


print "Matching ${f}.senttok against rules" if ($verbose);
execute("$path/matcher/matcher.pl ${sentokFile} > ${licenseFile}");

print `cat ${licenseFile}`;

if ($delete) {
    unlink($commentsFile);
    unlink($sentencesFile);
    unlink($goodsentFile);
    unlink($badsentFile);
    unlink($sentokFile);
    unlink($codeFile) if -f $codeFile;
}

if ($deleteLic) {
    unlink($licenseFile);
}

exit 0;



sub Do_File_Process
{
    my ($input, $output, $force, $cmd, $message, $end) = @_;

    print "${message}:" if ($verbose);
    if ($force or newer($input, $output))  {
        print "Running ${cmd}:" if ($verbose);
        execute($cmd);
    } else {
        print "File [$output] newer than input [$input], not creating:" if ($verbose);
    }
    if ($end) {
        print "Existing after $message" if $verbose;
        print "\n";
        exit 0;
    }
}




sub execute
{
    my ($c) = @_;
#    print "\nTo execute [$c]\n";
    my $r = `$c`;
    my $status = ($? >> 8);
    die "execution of program [$c] failed: status [$status]" if ($status != 0);
    return $r;
}

sub newer
{
    my ($f1, $f2) = @_;
    my ($f1write) = (stat($f1))[9];
    my ($f2write) = (stat($f2))[9];
    if (defined $f1write and defined $f2write) {
        return $f1write > $f2write;
    } else {
        return 1;
    }
}

sub escape_filename
{
    my ($f) = @_;
    $f =~ s/'/\\'/g;
    $f =~ s/\$/\\\$/g;
    $f =~ s/;/\\;/g;
    $f =~ s/ /\\ /g;
    return $f;
}
