use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);

my $pwd = `pwd`; chomp $pwd;
my $ninka_cmd = "$pwd/bin/ninka";
my $licenses_dir = "$pwd/t/data/licenses";
my $expected_output_dir = "$pwd/t/data/expected_output";
my $temp_dir = tempdir(CLEANUP => 1);

`cp $licenses_dir/* $temp_dir`;
my @license_files = sort(list_files_in_dir($licenses_dir));

plan tests => scalar(@license_files);

foreach my $license_file (@license_files) {
    subtest $license_file => sub {
        my $input_file = "$temp_dir/$license_file";
        my $output_expected = read_file_as_string("$expected_output_dir/$license_file");

        ok -e $input_file, "input file exists: '$input_file'";

        my $output_ninka_stdout = `$ninka_cmd '$input_file'`; chomp $output_ninka_stdout;
        is $output_ninka_stdout => "$temp_dir/$license_file;$output_expected", 'stdout is as expected';
    };
}

done_testing(scalar(@license_files));

sub read_file_as_string {
    my $file = shift;

    open my $fh, '<', $file or die "can't open file '$file': $!";
    my $content = do { local $/; <$fh> };
    chomp $content;
    close $fh or die "can't close file '$file': $!";

    return $content;
}

sub list_files_in_dir {
    my $dir = shift;

    opendir my $dh, $dir or die "can't open dir '$dir': $!";
    my @files = grep { /^[^.]/ && -f "$dir/$_" } readdir($dh);
    closedir $dh or die "can't close dir '$dir': $!";

    return @files;
}
