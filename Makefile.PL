use strict;
use warnings;
use utf8;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Ninka',
    VERSION_FROM => 'lib/Ninka.pm',
    ABSTRACT_FROM => 'lib/Ninka.pm',
    LICENSE => 'gpl_2',
    AUTHOR => [
        'Daniel M. German <dmg@uvic.ca>',
        'Yuki Manabe <y-manabe@ist.osaka-u.ac.jp>',
        'René Scheibe <rene.scheibe@gmail.com>',
    ],
    EXE_FILES => ['bin/ninka'],
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.52',
    },
    PREREQ_PM => {
        'DBI' => '0',
        'DBD::SQLite' => '0',
        'File::Basename' => '0',
        'File::Find' => '0',
        'File::Spec::Functions' => '0',
        'File::Temp' => '0',
        'Getopt::Std' => '0',
        'IPC::Open3' => '0',
        'Spreadsheet::WriteExcel' => '0',
    },
    TEST_REQUIRES => {
        'File::Temp' => '0',
        'Test::More' => '0.98',
        'Test::Pod' => '1.00',
        'Test::Strict' => '0',
    },
    META_MERGE => {
        resources => {
            homepage => 'http://ninka.turingmachine.org/',
            repository => 'https://github.com/dmgerman/ninka',
            license => 'http://www.gnu.org/licenses/gpl-2.0.html',
       },
    },
);
