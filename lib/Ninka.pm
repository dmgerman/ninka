package Ninka;

use strict;
use warnings;
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

    my %parameters_step1 = (%common_parameters, input_file => $input_file);
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
