#!/usr/bin/perl
#
#    Copyright (C) 2014,2015  Anthony Kohan and Daniel M. German
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 2 of
#    the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use Switch;
use File::Temp;
use File::Find;
use File::Basename;
use Scalar::Util qw(looks_like_number);
use Spreadsheet::WriteExcel;



if(scalar(@ARGV) != 2){
    print STDERR "Ninka 1.3. sqlite wrapper\n";
    print STDERR "Processes package file (.tar.gz, zip, jar. etc) and outputs to excel file\n";
    print STDERR "Incorrect number of arguments\n";
    print STDERR "Correct usage is: $0 <path to package file> <excel-file>\n";
    exit 1;
}

my $path = $0;

$path =~ s/\/+[^\/]+$//;
if ($path eq "") {
    $path = "./";
}

my ($pack, $excelFile) = @ARGV;

my $workbook = Spreadsheet::WriteExcel->new($excelFile);
my $worksheet = $workbook->add_worksheet();
my $format = $workbook->add_format(); # Add a format
$format->set_bold();
$format->set_color('blue');
$format->set_align('center');

$worksheet->set_column(0, 9,  30);
$worksheet->write(0, 0, 'Container File', $format);
$worksheet->write(0, 1, 'Path', $format);
$worksheet->write(0, 2, 'Filename', $format);
$worksheet->write(0, 3, 'Licenses', $format);
$worksheet->write(0, 4, 'Num found', $format);
$worksheet->write(0, 5, 'Lines', $format);
$worksheet->write(0, 6, 'TokensIgnored', $format);
$worksheet->write(0, 7, 'TokensUnmatched', $format);
$worksheet->write(0, 8, 'TokensUnknown', $format);
$worksheet->write(0, 9, 'Tokens', $format);

my $tempdir = File::Temp->newdir();
my $dirname = $tempdir->dirname;

print "***** Extracting file [$pack] to temporary directory [$dirname] *****\n";
my $packext = getExtension($pack);
if ($packext eq ".bz2" || $packext eq ".gz") {
    execute("tar -xvf '$pack' --directory '$dirname'");
} elsif ($packext eq ".jar" || $packext eq ".zip") {
    execute("unzip -d $dirname $pack");
} else {
    print "ninka-wrapper does not support packages with extension [$packext]\n";
}

my @files;
find(
    sub { push @files, $File::Find::name unless -d; },
    $dirname
);

print "***** Beginning Execution of Ninka *****\n";
foreach my $file (@files) {
    if (-T $file) {
	print "Running ninka on file [$file]\n";
	execute("perl ${path}/ninka.pl '$file'");
    }
}


print "***** Entering Ninka Data into excell file [$excelFile] *****\n";
my $row = 1;

foreach my $file (@files) {

    my $filepath = dirname($file);
    $filepath =~ s/$dirname//;
    my $basefile = fileparse($file, ());
    my $packname = basename($pack);

    #Read entire file into a string
    my $filename = "${file}.license";

    $worksheet->write($row, 0, $packname);
    $worksheet->write($row, 1, $filepath);
    $worksheet->write($row, 2, $basefile);

    print "Inserting [$basefile] into table spreedsheet\n";

    if (-T $filename)  {

	open (my $fh, '<', $filename) or die "Can't open file $!";
	my $filedata = do { local $/; <$fh> };

	my @columns = parseLicenseData($filedata);


	my $originalFile = $file;
	$originalFile =~ s/\.license$//;

	foreach my $i (0..7) {
	    $worksheet->write($row, $i+3, $columns[$i]);
	}
	close($fh);

    } else {
	$worksheet->write($row, 3, "Binary File");
    }
    $row++;
}

$workbook->close();

sub parseLicenseData {
    my ($data) = @_;
    chomp($data);
    my @columns;
    my @fields = split(';', $data);
    if($fields[0] eq "NONE\n"){
	@columns = '' x 7;
	@columns[0] = 'NONE';
    } else {
	@columns = @fields;
    }
    return @columns;
}

sub getExtension {
    my ($file) = @_;
    my $filename = basename($file);
    my ($ext) = $filename =~ /(\.[^.]+)$/;
    return $ext;
}

sub removeExtension {
    my ($file) = @_;
    (my $filename = $file) =~ s/\.[^.]+$//;
    return $filename;
}

sub execute {
    my ($command) = @_;
    my $output = `$command`;
    my $status = ($? >> 8);
    die "execution of [$command] failed: status [$status]\n" if ($status != 0);
    return $output;
}
