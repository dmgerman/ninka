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

use strict;
use Getopt::Std;

my %opts = ();
if (!getopts ("vfCcSsGgTtLd",\%opts) or scalar(@ARGV) == 0) {
print STDERR "Ninka version 1.1

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

my $path = $0;

$path =~ s/\/+[^\/]+$//;
if ($path eq "") {
    $path = "./";
}

my $force = exists $opts{f};
my $force_good = exists $opts{G};
my $force_sentences = exists $opts{S};
my $force_senttok = exists $opts{T};
my $force_comments = exists $opts{C};
my $force_license = exists $opts{L};

#die "Usage $0 <filename>" unless $ARGV[0] =~ /\.(c|cpp|java|cc|cxx|h|jl|py|pm|el|pl)$/;

my $input_file = $ARGV[0];

print "Starting: $input_file;\n" if ($verbose);

print "$input_file;";

my $comments_file = "${input_file}.comments";
my $sentences_file = "${input_file}.sentences";
my $goodsent_file = "${input_file}.goodsent";
my $senttok_file = "${input_file}.senttok";

if (not (-f "$input_file")) {
    print "ERROR;[${input_file}] is not a file\n" ;
    exit 0;
}

do_file_process($input_file, $comments_file, ($force or $force_comments),
                "$path/extComments/extComments.pl -c1 '${input_file}'",
                "Creating comments file",
                exists $opts{c});

do_file_process($comments_file, $sentences_file, ($force or $force_sentences),
                "$path/splitter/splitter.pl '${comments_file}'",
                "Splitting sentences", exists $opts{s});

do_file_process($sentences_file, $goodsent_file, ($force or $force_good),
                 "$path/filter/filter.pl '${sentences_file}'",
                 "Filtering good sentences", exists $opts{s});

do_file_process($goodsent_file, $senttok_file, ($force or $force_senttok),
                "$path/senttok/senttok.pl '${goodsent_file}' > '${senttok_file}'",
                "Matching sentences against rules", exists $opts{t});

print "Matching ${input_file}.senttok against rules" if ($verbose);
execute("$path/matcher/matcher.pl '${input_file}.senttok' > '${input_file}.license'");

print `cat '${input_file}.license'`;

unlink("${input_file}.code");

if ($delete) {
    unlink("${input_file}.badsent");
    unlink("${input_file}.comments");
    unlink("${input_file}.goodsent");
#    unlink("${input_file}.sentences");
    unlink("${input_file}.senttok");
}

exit 0;

sub do_file_process {
    my ($input, $output, $force, $cmd, $message, $end) = @_;

    print "${message}:" if ($verbose);
    if ($force or is_newer($input, $output)) {
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

sub execute {
    my ($command) = @_;
#    print "\nTo execute [$command]\n";
    my $result = `$command`;
    my $status = ($? >> 8);
    die "execution of program [$command] failed: status [$status]" if ($status != 0);
    return $result;
}

sub is_newer {
    my ($f1, $f2) = @_;
    my ($f1write) = (stat($f1))[9];
    my ($f2write) = (stat($f2))[9];
    if (defined $f1write and defined $f2write) {
        return $f1write > $f2write;
    } else {
        return 1;
    }
}

