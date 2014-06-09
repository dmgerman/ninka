package Ninka;

use strict;
use warnings;
use Ninka::FileCleaner;
use Ninka::CommentExtractor;
use Ninka::LicenseMatcher;
use Ninka::SentenceExtractor;
use Ninka::SentenceFilter;
use Ninka::SentenceTokenizer;

our $VERSION = '1.01';

sub process_file {
    my ($input_file, $verbose) = @_;

    print STDERR "analysing file [$input_file]\n" if $verbose;

    if (not (-f $input_file)) {
        print STDERR "file [$input_file] is not a file\n";
        return;
    }

    my %common_parameters = (verbose => $verbose);

    my %parameters_step0 = (%common_parameters, input_file => $input_file);
    my $cleaned_input_file = Ninka::FileCleaner->new(%parameters_step0)->execute;
    
    my %parameters_step1 = (%common_parameters, input_file => $cleaned_input_file);
    my $comments = Ninka::CommentExtractor->new(%parameters_step1)->execute();

    my %parameters_step2 = (%common_parameters, comments => $comments);
    my $sentences_ref = Ninka::SentenceExtractor->new(%parameters_step2)->execute();

    my %parameters_step3 = (%common_parameters, sentences => $sentences_ref);
    my ($good_sentences_ref, $bad_sentences_ref) = Ninka::SentenceFilter->new(%parameters_step3)->execute();

    my %parameters_step4 = (%common_parameters, sentences => $good_sentences_ref);
    my $license_tokens_ref = Ninka::SentenceTokenizer->new(%parameters_step4)->execute();

    my %parameters_step5 = (%common_parameters, license_tokens => $license_tokens_ref);
    my $license_result = Ninka::LicenseMatcher->new(%parameters_step5)->execute();

    return $license_result;
}

1;

__END__

=head1 NAME

Ninka - Find licenses in source files.

=head1 SYNOPSIS

    use Ninka;

    my $input_file = 'some/path/file_of_interest';
    my $verbose = 0;

    my $license_result = Ninka::process_file($input_file, $verbose);

=head1 DESCRIPTION

Scans a file and returns the found licenses.

=head1 COPYRIGHT AND LICENSE

    Copyright (C) 2009-2010  Yuki Manabe and Daniel M. German

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
