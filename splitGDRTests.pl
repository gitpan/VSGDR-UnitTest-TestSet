#!/bin/perl

use strict;
use warnings;
use Modern::Perl;

use autodie qw(:all);  
no indirect ':fatal';

use 5.010;
use version ; our $VERSION = qv('1.0.0');

use Carp;

use VSGDR::UnitTest::TestSet::Test;
use VSGDR::UnitTest::TestSet::Test::TestCondition;
use VSGDR::UnitTest::TestSet::Representation;
use VSGDR::UnitTest::TestSet::Resx;

use Getopt::Euclid qw( :vars<opt_> );

use Data::Dumper;
use File::Basename;

my %ValidParserMakeArgs = ( vb  => "NET::VB"
                          , cs  => "NET::CS"
                          , xls => "XLS"
                          , xml => "XML"
                          ) ;
my @validSuffixes       = map { '.'.$_ } keys %ValidParserMakeArgs ;


my($infname, $indirectories, $insfx) = fileparse($opt_infile, @validSuffixes);
$insfx        = lc $insfx ;
$insfx        = substr(lc $insfx,1) ;
my($outfname, $outdirectories, $outsfx) = fileparse($opt_outfile, @validSuffixes);
$outsfx       = lc $outsfx ;
$outsfx       = substr(lc $outsfx,1) ;
    
my %Parsers = () ;
$Parsers{${insfx}}  = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${insfx}} } );
$Parsers{${outsfx}} = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${outsfx}} } );

my $testSet         = $Parsers{$insfx}->deserialise($opt_infile);

my $resxname        = $infname . ".resx" ;
my $o_resx          = VSGDR::UnitTest::TestSet::Resx->new() ;
$o_resx->deserialise($resxname) ;

my $rh_testScripts  = $o_resx->scripts() ; 
my $o_resx_clone    = $o_resx->clone() ;

my $testSet_clone   = $testSet->clone(); 
$testSet_clone->tests([]);
foreach my $test ( @{ $testSet->tests() } ) {

    my $rx_dyn = ${test}->testName() ;
    my @script_keys = grep { $_ =~ /^ testInitializeAction|testCleanupAction|${rx_dyn}/x ; } keys %{$rh_testScripts} ;

    my %test_testScripts = () ;
    map { $test_testScripts{$_} = $$rh_testScripts{$_} } @script_keys ;

    $o_resx_clone->scripts(\%test_testScripts) ;
    $testSet_clone->className($testSet->className() . '_' . $test->testName() ) ;
    $testSet_clone->tests([$test]) ;
    
    $Parsers{$outsfx}->serialise($outfname."_".$test->testName().".".$outsfx, $testSet_clone);
    $o_resx_clone->serialise( ${outfname}."_".$test->testName().".resx", ${o_resx_clone} ); 

}
    

exit ;

END {} 

__DATA__


=head1 NAME


splitGDRTests.pl - Splits GDR test files.
Splits out each test in a GDR .vb or .cs test file into a separate .cs or .vb file, each with a corresponding .resx file.  The files are named after the corresponding tests.
The output file name is a dummy parameter, used to determine the source code type of the output file, and the prefix applied to each file name.

eg splitGDRTests.pl -i myTest.cs -o split.vb

creates a .vb file for each test in myTest.cs, each file name beginning with 'split_'.



=head1 VERSION

1.0.0

=head1 USAGE

splitGDRTests.pl -i <infile> -o <outfile> 


=head1 REQUIRED ARGUMENTS

=over

=item  -i[n][file]    [=]<file>

Specify input file

=for Euclid:
    file.type:    readable
    repeatable


=item  -o[ut][file]    [=]<file>

Specify output file


=for Euclid:
    file.type:    writable

=back

=head1 OPTIONS

=over

=back

=head1 AUTHOR

Ded MedVed.



=head1 BUGS

Hopefully none.


=head1 COPYRIGHT

Copyright (c) 2012, Ded MedVed. All Rights Reserved.
This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html)

