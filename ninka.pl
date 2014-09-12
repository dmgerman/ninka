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
use warnings;
use Getopt::Std;

# parse cmdline parameters
my %opts = ();
if (!getopts('vfCcSsGgTtLd', \%opts) || scalar(@ARGV) == 0) {
    print STDERR "Ninka version 1.1

Usage: $0 [OPTIONS] <filename>

Options:
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

  -d delete intermediate files\n";

    exit 1;
}

my $verbose = exists $opts{v};
my $delete  = exists $opts{d};
my $force   = exists $opts{f};

my $path = get_my_path($0);

my $input_file = $ARGV[0];

my $comments_file  = "$input_file.comments";
my $sentences_file = "$input_file.sentences";
my $goodsent_file  = "$input_file.goodsent";
my $badsent_file   = "$input_file.badsent";
my $senttok_file   = "$input_file.senttok";
my $license_file   = "$input_file.license";

print STDERR "analysing file [$input_file]\n" if $verbose;

if (not (-f $input_file)) {
    print STDERR "file [$input_file] is not a file\n";
    exit 1;
}

process_file($input_file, $comments_file, ($force || exists $opts{C}),
             "$path/extComments/extComments.pl " . forward_verbosity() . "'$input_file'",
             'creating comments file', exists $opts{c});

process_file($comments_file, $sentences_file, ($force || exists $opts{S}),
             "$path/splitter/splitter.pl '$comments_file'",
             'splitting sentences', exists $opts{s});

process_file($sentences_file, $goodsent_file, ($force || exists $opts{G}),
             "$path/filter/filter.pl '$sentences_file'",
             'filtering good sentences', exists $opts{g});

process_file($goodsent_file, $senttok_file, ($force || exists $opts{T}),
             "$path/senttok/senttok.pl '$goodsent_file' > '$senttok_file'",
             'matching sentences against rules', exists $opts{t});

process_file($senttok_file, $license_file, ($force || exists $opts{L}),
             "$path/matcher/matcher.pl " . forward_verbosity() . "'$senttok_file' > '$license_file'",
             'matching sentence tokens against rules', 0);

print $input_file, ';', `cat '$license_file'`;

if ($delete) {
    unlink $comments_file;
    unlink $sentences_file;
    unlink $goodsent_file;
    unlink $badsent_file;
    unlink $senttok_file;
}

exit 0;

sub get_my_path {
    my ($self) = @_;
    my $path = $self;
    $path =~ s/\/+[^\/]+$//;
    if ($path eq '') {
        $path = './';
    }
    return $path;
}

sub forward_verbosity {
    return $verbose ? '-v ' : '';
}

sub process_file {
    my ($input, $output, $force, $cmd, $message, $end) = @_;

    print STDERR "$message\n" if $verbose;
    if ($force || is_newer($input, $output)) {
        print STDERR "running command [$cmd]\n" if $verbose;
        execute($cmd);
    } else {
        print STDERR "input file [$output] newer than input file [$input], doing nothing\n" if $verbose;
    }

    if ($end) {
        print STDERR "exiting after $message\n" if $verbose;
        exit 0;
    }
}

sub execute {
    my ($command) = @_;
    my $result = `$command`;
    my $status = ($? >> 8);
    die "execution of program [$command] failed: status [$status]" if ($status != 0);
    return $result;
}

sub is_newer {
    my ($f1, $f2) = @_;
    my $f1write = (stat $f1)[9];
    my $f2write = (stat $f2)[9];

    if (defined $f1write && defined $f2write) {
        return $f1write > $f2write;
    } else {
        return 1;
    }
}

