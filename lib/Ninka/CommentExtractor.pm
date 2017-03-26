package Ninka::CommentExtractor;

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

    my $command = $self->determine_comments_command();
    my $comments = execute_command($command);
    if ($command =~ /^comments/ && length($comments) == 0) {
        $command = create_head_cmd($self->{input_file}, 700);
        $comments = execute_command($command);
    }

    return $comments;
}

sub determine_comments_command {
    my ($self) = @_;

    my $input_file = $self->{input_file};

    if ($input_file =~ /\.([^\.]+)$/) {
        my $ext = $1;
        if ($ext =~ /^(pl|pm|py)$/) {
            return create_head_cmd($input_file, 400);
        } elsif ($ext =~ /^(jl|el)$/) {
            return create_head_cmd($input_file, 400);
        } elsif ($ext =~ /^(java|c|cpp|h|cxx|c\+\+|cc)$/) {
            my $comments_binary = 'comments';
            if (`which $comments_binary` ne '') {
                return "$comments_binary -c1 '$input_file' 2> /dev/null";
            } else {
                return create_head_cmd($input_file, 400);
            }
        } else {
            return create_head_cmd($input_file, 700);
        }
    } else {
        return create_head_cmd($input_file, 700);
    }
}

sub create_head_cmd {
    my ($input_file, $count_lines) = @_;

    return "head -$count_lines $input_file";
}

sub execute_command {
    my ($command) = @_;

    if ($command =~ /&/) {
        die "illegal file name in command to be executed [$command]";
    }

    my ($child_in, $child_out, $child_err);
    $child_err = gensym();
    my $pid = open3($child_in, $child_out, $child_err, $command);
    my $comments = do { local $/; <$child_out> };
    chomp(my $error = join('; ', <$child_err>));
    waitpid $pid, 0;
    my $status = ($? >> 8);
    die "execution of program [$command] failed: status [$status], error [$error]" if ($status != 0);

    return $comments;
}

1;

__END__

=head1 NAME

Ninka::CommentExtractor

=head1 DESCRIPTION

Extracts comments from source code.
If no comment extractor is known for a language, then extracts top lines from source.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2014  Yuki Manabe and Daniel M. German

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
