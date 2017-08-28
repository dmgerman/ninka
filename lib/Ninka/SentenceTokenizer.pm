package Ninka::SentenceTokenizer;

use strict;
#use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';

my $TOO_LONG = 70;

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'sentences' is mandatory" unless exists $args{sentences};

    my $path = dirname(__FILE__);

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{sentences} = $args{sentences};
    $self->{license_sentences} = read_license_sentences(catfile($path, 'licensesentence.dict'));

    return $self;
}

sub execute {
    my ($self) = @_;

    my @license_tokens = ();

    foreach my $line (@{$self->{sentences}}) {
        chomp $line;
        my $original_line = $line;

        if ($line =~ s/^Alternatively,? ?//) {
            push @license_tokens, 'Altern';
        }

        $line = normalize_sentence($line);
        my $save_line = $line;

        my $check = 0;
        my $match_name = 'UNKNOWN';
        my @parameters = ();
        my $distance = 1; #maximum? number
        my $most_similar_name = 'UNKNOWN';
        my $before;
        my $after;
        my $gpl = 0;
        my $gpl_later;
        my $gpl_version;

        if (looks_like_gpl($line)) {
            my $old = $line;
            $gpl = 1;
            ($line, $gpl_later, $gpl_version) = normalize_gpl($line);
        }
        my ($name, $sub_rule, $number, $regexp, $option);
        $save_line = $line;
        my $save_gpl = $gpl;
        my $LGPL = '';
        foreach my $sentence (@{$self->{license_sentences}}) {
            ($name, $sub_rule, $number, $regexp, $option) = split /:/, $sentence;
            # we need this due to the goto again
            $line = $save_line;
            $gpl = $save_gpl;
            $LGPL = '';
          again:
            if ($line =~ /$regexp/im) {
                $before = $`;
                $after = $';
                $check = 1;
                $match_name = $name;
                for (my $i = 1; $i <= $number; $i++) {
                    no strict 'refs';
                    push @parameters, $$i;
                }
                last;
            } else {
                # let us try again in case it is lesser/library
                # do it only once
                if ($gpl && $line =~ s/(Lesser|Library) GPL/GPL/i) {
                    $LGPL = $1;
                    goto again;
                }
                if ($gpl) {
                    $gpl = 0;
                    $line = $save_line;
                    goto again;
                }
                next;
            }
            last;
        }
        if ($check) {
            # licensesentence name, param1, param2, ...
            if ($gpl) {
                $match_name .= 'Ver' . $gpl_version;
                $match_name .= '+' if $gpl_later;
                $match_name = $LGPL . $match_name;
            }
            if (length($before) > $TOO_LONG || length($after) > $TOO_LONG) {
                $match_name .= '-TOOLONG';
            }
            # TODO: Use of uninitialized value in @parameters
            my $parameter_string = join ';', $match_name, $sub_rule, $before, $after, @parameters;
            push @license_tokens, "$parameter_string:$original_line";
        } else {
            # UNKNOWN, sentence
            chomp $line;
            my $parameter_string = join ';', $match_name, 0, $most_similar_name, $distance, $save_line;
            push @license_tokens, "$parameter_string:$original_line";
        }
    }

    return \@license_tokens;
}

sub normalize_gpl {
    my ($line) = @_;
    my $later = 0;
    my $version = 0;

    # do some very quick spelling corrections for english/british words
    $line =~ s/Version 2,? \(June 1991\)/Version 2/gi;
    $line =~ s/Version 2,? dated June 1991/Version 2/gi;
    $line =~ s/Version 2\.1,? dated February 1999/Version 2.1/gi;
    if ($line =~ s/,? or \(?at your option\)?,? any later version//i) {
        $later = 1;
    }
    if ($line =~ s/, or any later version//i) {
        $later = 1;
    }
    if ($line =~ s/ or (greater|later)//i) {
        $later = 1;
    }
    if ($line =~ s/or (greater|later) //i) {
        $later = 1;
    }
    if ($line =~ s/(version|v\.?) ([123\.0]+)/<VERSION>/i) {
        $version = $2;
    }
    if ($line =~ s/GPL ?[v\-]([123\.0]+)/GPL <VERSION>/i) {
        $version = $1;
    }
    if ($line =~ s/v\.?([123\.0]+)( *[0-9]+)/<VERSION>$2/i) {
        $version = $1;
    }

    $line =~ s/(distributable|licensed|released|made available)/<LICENSED>/ig;
    $line =~ s/Library General Public License/Library General Public License/ig;
    $line =~ s/Lesser General Public License/Lesser General Public License/ig;

    $line =~ s/General Public License/GPL/gi;
    $line =~ s/GPL \(GPL\)/GPL/gi;
    $line =~ s/GPL \(<QUOTES>GPL<QUOTES>\)/GPL/gi;

    $line =~ s/GNU //gi;
    $line =~ s/under GPL/under the GPL/gi;
    $line =~ s/under Lesser/under the Lesser/gi;
    $line =~ s/under Library/under the Library/gi;

    $line =~ s/of GPL/of the GPL/gi;
    $line =~ s/of Lesser/of the Lesser/gi;
    $line =~ s/of Library/of the Library/gi;

    $line =~ s/(can|may)/can/gi;
    $line =~ s/<VERSION> only/<VERSION>/gi;
    $line =~ s/<VERSION> of the license/<VERSION>/gi;
    $line =~ s/(<VERSION>|GPL),? as published by the Free Software Foundation/$1/gi;
    $line =~ s/(<VERSION>|GPL) \(as published by the Free Software Foundation\)/$1/gi;
    $line =~ s/(<VERSION>|GPL),? incorporated herein by reference/$1/gi;
    $line =~ s/terms and conditions/terms/gi;
    $line =~ s/GPL along with/GPL with/gi;

    $line =~ s/GPL \(<VERSION\)/GPL <VERSION>/gi;

    $line =~ s/ +/ /;
    $line =~ s/ +$//;

    return ($line, $later, $version);
}

sub looks_like_gpl {
    my ($line) = @_;
    return $line =~ /GNU|GPL|General Public License/;
}

sub normalize_sentence {
    my ($line) = @_;
    # do some very quick spelling corrections for english/british words
    $line =~ s/icence/icense/ig;
    $line =~ s/[.;]$//;
    return $line;
}

sub read_license_sentences {
    my ($file) = @_;
    my @license_sentences = ();

    open my $fh, '<', $file or die "can't open file [$file]: $!";

    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\#/;
        next if $line =~ /^ *$/;
        die "illegal format in license expression [$line]" unless $line =~ /(.*?):(.*?):(.*)/;
        push @license_sentences, $line;
    }

    close $fh;

    return \@license_sentences;
}

1;

__END__

=head1 NAME

Ninka::SentenceTokenizer - Display recognized sentence token

=head1 DESCRIPTION

For each sentence, it outputs its recognized sentence token, or unknown otherwise.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2014  Yuki Manabe and Daniel M. German

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

This patch is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
