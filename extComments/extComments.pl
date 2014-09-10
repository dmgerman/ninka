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
# extComments.pl
#
# This script extracts comments from source code.
# If no comment extractor is known for a language, then extracts top lines from source.
#

use strict;
use warnings;
use Getopt::Std;

# parse cmdline parameters
my %opts = ();
if (!getopts('v', \%opts) || scalar(@ARGV) == 0) {
    print STDERR "Usage: $0 [OPTIONS] <filename>

Options:
  -v verbose\n";

    exit 1;
}

my $verbose = exists $opts{v};

my $path = get_my_path($0);

my $input_file = $ARGV[0];
my $comments_file = "$input_file.comments";

my $comments_cmd = determine_comments_cmd($input_file, $comments_file);
execute($comments_cmd);
if ($comments_cmd =~ /^comments/ && get_size($comments_file) == 0) {
    $comments_cmd = create_head_cmd($input_file, $comments_file, 700);
    execute($comments_cmd);
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

sub determine_comments_cmd {
    my ($input_file, $comments_file) = @_;

    if ($input_file =~ /\.([^\.]+)$/) {
        my $ext = $1;
        if ($ext =~ /^(pl|pm|py)$/) {
            return create_head_cmd($input_file, $comments_file, 400);
#            return "$path/hashComments.pl -p '#' '$input_file'";
        } elsif ($ext =~ /^(jl|el)$/) {
            return create_head_cmd($input_file, $comments_file, 400);
#            return "$path/hashComments.pl -p ';' '$input_file'";;
        } elsif ($ext =~ /^(java|c|cpp|h|cxx|c\+\+|cc)$/ ) {
            my $comments_binary = 'comments';
            if (`which $comments_binary` ne '') {
                return "$comments_binary -c1 '$input_file' 2> /dev/null";
            } else {
                return create_head_cmd($input_file, $comments_file, 400);
            }
        } else {
            return create_head_cmd($input_file, $comments_file, 700);
        }
    } else {
        return create_head_cmd($input_file, $comments_file, 700);
    }
}

sub create_head_cmd {
    my ($input_file, $output_file, $count_lines) = @_;
    return "head -$count_lines '$input_file' > '$output_file'";
}

sub execute {
    my ($cmd) = @_;
    my $result = `$cmd`;
    my $status = ($? >> 8);
    die "execution of program [$cmd] failed: status [$status]" if ($status != 0);
    return $result;
}

sub get_size {
    my ($file) = @_;
    my $size = (stat($file))[7];
    return $size;
}

