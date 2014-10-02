package Ninka::SentenceExtractor;

use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'comments' is mandatory" unless exists $args{comments};

    my $path = dirname(__FILE__);

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{comments} = $args{comments};
    $self->{abbreviations} = load_abbreviations(catfile($path, 'abbreviations.dict'));

    return $self;
}

sub execute {
    my ($self) = @_;

    my $text = $self->{comments};
    my @clean_sentences = ();

    # append a newline just in case
    $text .= "\n";

    # some characters are used to create lines
    $text =~ s/\+?\-{3,1000}\+?/ /gmx;
    $text =~ s/={3,1000}/ /gmx;
    $text =~ s/:{3,1000}/ /gmx;
    $text =~ s/\*{3,1000}/ /gmx;

    # some characters are used for pretty-printing but never appear in sentences
    $text =~ s/\|+/ /gmx;
    $text =~ s/\\+/ /gmx;

    # deal with comments /*, */ and //
    $text =~ s@^[ \t]*/\*@@gmx;
    $text =~ s@\*/[ \t]*$@@gmx;
    $text =~ s@([^:])// @$1@gmx;

    # normalize line separator
    $text =~ s/\r\n/\n/g;

    # try to replace the leading/ending character of each line #/-,
    # at most 3 heading characters and each repeated as many times as necessary
    $text =~ s/^[ \t]{0,3}[\*\#\/\;]+//gmx;
    $text =~ s/^[ \t]{0,3}[\-]+//gmx;

    $text =~ s/[\*\#\/]+[ \t]{0,3}$//gmx;
    $text =~ s/[\-]+[ \t]{0,3}$//gmx;

    # try to replace the ending character of each line if it is * or #
    $text =~ s/[\*\#]+//gmx;

    # get rid of lines with nothing but spaces
    $text =~ s/^[ \t]+$/\n/gmx;

    # let us try the following trick
    # we first get rid of \t and replace it with ' '
    # we then use \t as a "single line separator" and \n as multiple line
    # so we can match each with a single character
    $text =~ tr/\t/ /;
    $text =~ s/\n(?!\n)/\t/g;
    $text =~ s/\n\n+/\n/g;
    $text .= "\n";

    # this gets us in big trouble... licenses that have numeric abbreviations
    $text =~ s/v\.\s+2\.0/v<dot> 2<dot>0/g;

    while ($text =~ /^([^\n]*)\n/gsm) {
        my $curr = $1;

        # let us count the number of alphabetic chars to check if we are skipping anything we should not
        my $count1 = 0;
        for my $i (0..length($curr)-1) {
            my $c = substr($curr, $i, 1);
            $count1++ if ($c ge 'A' && $c le 'z');
        }

        my @sentences = $self->split_text($curr);

        my $count2 = 0;
        foreach my $sentence (@sentences) {
            for my $i (0..length($sentence)-1) {
                my $c = substr($sentence, $i, 1);
                $count2++ if ($c ge 'A' && $c le 'z');
            }
            my $clean_sentence = clean_sentence($sentence);
            push @clean_sentences, $clean_sentence if $clean_sentence,
        }

        if ($count1 != $count2) {
            print STDERR "number of printable chars does not match for [$curr]: [$count1] vs. [$count2]\n";
            foreach my $sentence (@sentences) {
                my $clean_sentence = clean_sentence($sentence);
                print STDERR "cleaned sentence [$clean_sentence]\n";
            }
            exit 1;
        }
    }

    return \@clean_sentences;
}

sub clean_sentence {
    ($_) = @_;

    # check for trailing bullets of different types
    s/^o //;
    s/^\s*[0-9]{1-2}+\s*[\-\)]//;
    s/^[ \t]+//;
    s/[ \t]+$//;

    # remove a trailing -
    s/^[ \t]*[\-\.\s*] +//;

    s/\s+/ /g;

    s/['"`]+/<quotes>/g;

    s/:/<colon>/g;

    s/\.+$/./;

    die if /\n/m;

    return $_;
}

sub split_text {
    my ($self, $text) = @_;

    my @result;
    my $current_sentence = '';

    # this breaks the sentence into
    # 1. any text before a separator
    # 2. the separator
    # 3. any text after a separator
    while ($text =~ /^
                     ([^\.\!\?\:\n]*)
                     ([\.\!\?\:\n])
                     (?=(.?))
                   /xsm) { #/(?:(?=([([{\"\'`)}\]<]*[ ]+)[([{\"\'`)}\] ]*([A-Z0-9][a-z]*))|(?=([()\"\'`)}\<\] ]+)\s))/sm) {
        $text = $';
        my $sentence_match = $1;
        my $sentence = $1 . $2;
        my $punctuation = $2;
        my $after = $3;

        # if next character is not a space, then we are not in a sentence"
        if ($after ne ' ' && $after ne "\t") {
            $current_sentence .= $sentence;
            next;
        }
        # at this point we know that there is a space after
        if ($punctuation eq ':' || $punctuation eq '?' || $punctuation eq '!') {
            # let us consider this right here a beginning of a sentence
            push @result, $current_sentence . $sentence;
            $current_sentence = '';
            next;
        }
        if ($punctuation eq '.') {
            # we have a bunch of alternatives
            # for the time being just consider a new sentence

            # TODO
            # simple heuristic... let us check that the next words are not the beginning of a sentence
            # in our library
            # END TODO

            # is the last word an abbreviation? for this the period has to follow the word.
            # this expression might have to be updated to take care of special characters in names. :(
            if ($sentence_match =~ /(.?)([^[:punct:]\s]+)$/) {
                my $before = $1;
                my $last_word = $2;
                # is it an abbreviation

                if (length($last_word) == 1) {
                    # single character abbreviations are special...
                    # we will assume they never split the sentence if they are capitalized.
                    if ($last_word ge 'A' && $last_word le 'Z') {
                        $current_sentence .= $sentence;
                        next;
                    }
                    print STDERR "1 last word an abbrev $sentence_match lastword [$last_word] before [$before]\n" if $self->{verbose};

                    # but some are lowercase!
                    if ($last_word eq 'e' || $last_word eq 'i') {
                        $current_sentence .= $sentence;
                        next;
                    }
                    print STDERR "2 last word an abbrev $sentence_match lastword [$last_word] before [$before]\n" if $self->{verbose};
                } else {
                    $last_word = lc $last_word;

                    # Only accept abbreviations if the previous char is empty (beginning of line) or a space.
                    # This avoids things like .c
                    if (($before eq '' || $before eq ' ') && $self->{abbreviations}{$last_word}) {
                        $current_sentence .= $sentence;
                        next;
                    } else {
                        # just keep going, we handle this case below
                    }
                }
            }

            push @result, $current_sentence . $sentence;
            $current_sentence = '';
            next;
        }
        die 'We have not dealt with this case';
    }
    push @result, $current_sentence . $text;

    return @result;
}

sub load_abbreviations {
    my ($file) = @_;
    my %abbreviations = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        $abbreviations{$line} = $line;
    }

    close $fh;

    return \%abbreviations;
}

1;

__END__

=head1 NAME

Ninka::SentenceExtractor

=head1 DESCRIPTION

Breaks comments into sentences.

=head1 COPYRIGHT AND LICENSE

This program is originally based on the sentence splitter program
published by Paul Clough. Version 1.0, available from
http://ir.shef.ac.uk/cloughie/software.html (splitter.zip)
The original program is without a license.

It was mostly rewritten.
His ideas, however, linger in here (and his file of abbreviations)

Modifications to the original by Daniel M German and Y. Manabe,
which are under the following license:

This patch is free software; you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This patch is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this patch.  If not, see <http://www.gnu.org/licenses/>.

=cut
