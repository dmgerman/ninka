#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use Ninka;

my %opts = parse_cmdline_parameters();
my $input_file = $ARGV[0];
my $create_intermediary_files = exists $opts{i};
my $verbose = exists $opts{v};

my $license_result = Ninka::process_file($input_file, $create_intermediary_files, $verbose);
print "$input_file;$license_result\n";
exit 0;

sub parse_cmdline_parameters {
    my %opts = ();
    if (!getopts('iv', \%opts) || scalar(@ARGV) == 0) {
        print STDERR "Ninka v${Ninka::VERSION}

Usage: ninka [options] <filename>

Options:
  -i create intermediary files
  -v verbose\n";

        exit 1;
    }
    return %opts;
}

__END__

=encoding utf8

=head1 NAME

ninka - source file license identification tool

=head1 SYNOPSYS

B<ninka> [options] F<filename>

=head1 DESCRIPTION

Scans a source file and returns the found licenses.

=head1 OPTIONS

=over

=item B<-i>

create intermediary files (for debugging)

=item B<-v>

verbose

=back

=head1 EXAMPLES

=over

=item B<ninka> F<foo.c>

Determine the licenses in file F<foo.c>.

=item B<ninka -i> F<foo.c>

Determine the licenses in file F<foo.c> and create intermediary files (for debugging).

=item find * | xargs -n1 -I@ B<ninka> '@'

Determine the licenses of files in a directory.

=back

=head1 AUTHOR

B<ninka> was written by Daniel M. German <dmg@uvic.ca> and Yuki Manabe <y-manabe@ist.osaka-u.ac.jp>.

=head1 SEE ALSO

Daniel M. German, Yuki Manabe and Katsuro Inoue. A sentence-matching method
for automatic license identification of source code files. In 25nd IEEE/ACM
International Conference on Automated Software Engineering (ASE 2010).

You can download it from http://turingmachine.org/~dmg/papers/dmg2010ninka.pdf.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2014  Yuki Manabe and Daniel M. German, 2015 René Scheibe

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
