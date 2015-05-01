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
use DBI;
use File::Temp;
use File::Find;
use File::Basename;
use Scalar::Util qw(looks_like_number);



if(scalar(@ARGV) != 2){
    print STDERR "Ninka 1.3. sqlite wrapper\n";
    print STDERR "Processes package file (.tar.gz, zip, jar. etc) and outputs to sqlite file\n";
    print STDERR "Incorrect number of arguments\n";
    print STDERR "Correct usage is: $0 <path to package file> <database name>\n";
    exit 1;
}

my $path = $0;

$path =~ s/\/+[^\/]+$//;
if ($path eq "") {
    $path = "./";
}

my ($pack, $db) = @ARGV;

my $dbh = DBI->connect("DBI:SQLite:dbname=$db", "", "", {RaiseError => 1, AutoCommit => 0})
    or die $DBI::errstr;
$dbh->do("CREATE TABLE IF NOT EXISTS
          comments (filename TEXT, path TEXT, container TEXT, content TEXT,
          PRIMARY KEY(filename, path, container))");
$dbh->do("CREATE TABLE IF NOT EXISTS
          sentences (filename TEXT, path TEXT, container TEXT, content TEXT,
          PRIMARY KEY(filename, path, container))");
$dbh->do("CREATE TABLE IF NOT EXISTS
          goodsents (filename TEXT, path TEXT, container TEXT, content TEXT,
          PRIMARY KEY(filename, path, container))");
$dbh->do("CREATE TABLE IF NOT EXISTS
          badsents (filename TEXT, path TEXT, container TEXT, content TEXT,
          PRIMARY KEY(filename, path, container))");
$dbh->do("CREATE TABLE IF NOT EXISTS
          senttoks (filename TEXT, path TEXT, container TEXT, content TEXT,
          PRIMARY KEY(filename, path, container))");
$dbh->do("CREATE TABLE IF NOT EXISTS
          licenses (filename TEXT, path TEXT, container TEXT, licenses TEXT,
          num_found INT, lines INT, toks_ignored INT, toks_unmatched INT,
          toks_unknown INT, tokens TEXT,
          PRIMARY KEY(filename, path, container))");

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
    print "Running ninka on file [$file]\n";
    execute("perl ${path}/ninka.pl '$file'");
}

my @ninkafiles;
find(
    sub {
	my $ext = getExtension($File::Find::name);
	if($ext =~ m/(comments|sentences|goodsent|badsent|senttok|license)$/){
	    push @ninkafiles, $File::Find::name;
	}
    },
    $dirname
);

print "***** Entering Ninka Data into Database [$db] *****\n";
foreach my $file (@ninkafiles) {

    my $filepath = dirname($file);
    $filepath =~ s/$dirname//;
    my $basefile = basename($file);
    my $rootfile = removeExtension($basefile);
    my $packname = basename($pack);

    #Read entire file into a string
    open (my $fh, '<', $file) or die "Can't open file $!";
    my $filedata = do { local $/; <$fh> };

    my $sth;
    switch (getExtension($basefile)){

#	case ".comments" {
#	    print "Inserting [$basefile] into table comments\n";
#	    $sth = $dbh->prepare("INSERT INTO comments VALUES
#                                  ('$rootfile', '$filepath', '$packname', ?)");
#	}
	case ".sentences" {
	    print "Inserting [$basefile] into table sentences\n";
	    $sth = $dbh->prepare("INSERT INTO sentences VALUES
                                  ('$rootfile', '$filepath', '$packname', ?)");
	}
	case ".goodsent" {
	    print "Inserting [$basefile] into table goodsents\n";
	    $sth = $dbh->prepare("INSERT INTO goodsents VALUES
                                  ('$rootfile', '$filepath', '$packname', ?)");
	}
	case ".badsent" {
	    print "Inserting [$basefile] into table goodsents\n";
	    $sth = $dbh->prepare("INSERT INTO badsents VALUES
                                  ('$rootfile', '$filepath', '$packname', ?)");
	}
	case ".senttok" {
	    print "Inserting [$basefile] into table senttoks\n";
	    $sth = $dbh->prepare("INSERT INTO senttoks VALUES
                                  ('$rootfile', '$filepath', '$packname', ?)");
	}
	case ".license" {
	    print "Inserting [$basefile] into table licenses\n";
	    my @columns = parseLicenseData($filedata);
	    $sth = $dbh->prepare("INSERT INTO licenses VALUES
                                  ('$rootfile', '$filepath', '$packname', '$columns[0]', '$columns[1]',
                                   '$columns[2]', '$columns[3]', '$columns[4]', '$columns[5]', '$columns[6]')");
	}
    }

    $sth->bind_param(1, $filedata);
    $sth->execute;
    close($fh);
}

$dbh->commit();
$dbh->disconnect();

sub parseLicenseData {
    my ($data) = @_;

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
