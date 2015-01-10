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

my %opts = ();
if (!getopts ("vfCcSsGgTtLd",\%opts) or scalar(@ARGV) == 0) {
print STDERR "Ninka version 1.3

Usage $0 -fCtTvcgsGd <filename>

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

\n";

    exit 1;
}



my $verbose = exists $opts{v};
my $delete = exists $opts{d};
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

my $f = $ARGV[0];


my $original = $f;

$f =~ s/'/\\'/g;
$f =~ s/\$/\\\$/g;
$f =~ s/;/\\;/g;
$f =~ s/ /\\ /g;

print "Starting: $original;\n" if ($verbose);

print "$original;";

my $commentsFile = "${f}.comments";
my $sentencesFile = "${f}.sentences";
my $goodsentFile = "${f}.goodsent";
my $sentokFile = "${f}.senttok";

if (not (-f $original)) {
    print "ERROR;[${original}] is not a file\n" ;
    exit 0;
}


Do_File_Process($original, $commentsFile, ($force or $forceComments),
                "$path/extComments/extComments.pl -c1 ${f}",
                "Creating comments file",
                exists $opts{c});


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
execute("$path/matcher/matcher.pl ${f}.senttok > ${f}.license");

print `cat ${f}.license`;

unlink("${f}.code");

if ($delete) {
    unlink("${f}.badsent");
    unlink("${f}.comments");
    unlink("${f}.goodsent");
    unlink("${f}.sentences");
    unlink("${f}.senttok");
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
