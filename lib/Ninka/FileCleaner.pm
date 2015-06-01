package Ninka::FileCleaner;

use strict;
use warnings;
use IPC::Open3 'open3';
use Symbol 'gensym';

sub new {
    my ($class, %args) = @_;

    my $self = bless({}, $class);

    die "parameter 'input_file' is mandatory" unless exists $args{input_file};

    $self->{verbose} = ($args{verbose} // 0) == 1;
    $self->{input_file} = $args{input_file};

    return $self;
}

sub execute {
    my ($self) = @_;

    my $input_file = $self->{input_file};
        
    my $original = $input_file;

    $input_file =~ s/'/\\'/g;
    $input_file =~ s/\$/\\\$/g;
    $input_file =~ s/;/\\;/g;
    $input_file =~ s/ /\\ /g;

    print "Starting: $original;\n" if ($self->{verbose});

    return $input_file;
}

1;

__END__

=head1 NAME

Ninka::FileCleaner

=head1 DESCRIPTION

Escapes apostrophes and other potentially disturbing characters

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2014  Yuki Manabe and Daniel M. German, 2015 Daniele Fognini and Johannes Najjar

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
