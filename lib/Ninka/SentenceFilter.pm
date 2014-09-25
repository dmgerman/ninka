package Ninka::SentenceFilter;

use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'sentences' is mandatory" unless exists $args{sentences};

    my $path = dirname(__FILE__);

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{sentences} = $args{sentences};
    $self->{critical_words} = read_critical_words(catfile($path, 'criticalwords.dict'));

    return $self;
}

sub execute {
    my ($self) = @_;

    my $good_sentences = [];
    my $bad_sentences = [];

    foreach my $sentence (@{$self->{sentences}}) {
        chomp $sentence;
        next unless $sentence;
        my $array_ref = $self->contains_critical_word($sentence) ? $good_sentences : $bad_sentences;
        push @$array_ref, $sentence;
    }

    return ($good_sentences, $bad_sentences);
}

sub read_critical_words {
    my ($file) = @_;
    my @critical_words = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\#/;
        $line =~ s/\#.*$//; # remove everything to the end of line
        push @critical_words, qr/\b$line\b/i;
    }

    close $fh;

    return \@critical_words;
}

sub contains_critical_word {
    my ($self, $sentence) = @_;

    my $check = 0;
    foreach my $critical_word (@{$self->{critical_words}}) {
        if ($sentence =~ $critical_word) {
            $check = 1;
            last;
        }
    }

    return $check;
}

1;

__END__

=head1 NAME

Ninka::SentenceFilter

=head1 DESCRIPTION

Classifies input sentences into two categories, good sentences and bad sentences.
A sentence including a critical word (ex. legal term) is regarded as good.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010  Yuki Manabe and Daniel M. German

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
