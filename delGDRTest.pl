#!/bin/perl

use strict;
use warnings;
use 5.010;
use autodie qw(:all);  
no indirect ':fatal';

use version ; our $VERSION = qv('1.0.4');

use Carp;

use VSGDR::UnitTest::TestSet::Test;
use VSGDR::UnitTest::TestSet::Test::TestCondition;
use VSGDR::UnitTest::TestSet::Representation;

use VSGDR::UnitTest::TestSet::Resx;

use Getopt::Euclid qw( :vars<opt_> );
use Data::Dumper;
use Smart::Comments;
use File::Basename;

my %ValidParserMakeArgs = ( vb  => "NET::VB"
                          , cs  => "NET::CS"
                          , xls => "XLS"
                          , xml => "XML"
                          ) ;
#my @validSuffixes       = keys %ValidParserMakeArgs ;
#my @validSuffixes       = map { '.'.$_ } keys %ValidParserMakeArgs ;
my @validSuffixes       = map { '.'.$_ } keys %ValidParserMakeArgs ;

#TODO: 1. Init and cleanup test code still seems to go missing.


### get and validate parameters

warn 'may break parsable output';

croak 'no input file'               unless defined($opt_infile);
croak 'no output file'              unless defined($opt_outfile);
croak 'no test name expression'     unless defined($opt_testname);

my $inFile  = $opt_infile ;
my $outFile = $opt_outfile ;

my($infname, $directories, $insfx)      = fileparse($inFile, @validSuffixes);
$insfx      = lc $insfx ;
$insfx      = substr(lc $insfx,1) ;    

my($outfname, $outdirectories, $outsfx) = fileparse($outFile, @validSuffixes);
$outsfx     = lc $outsfx ;
$outsfx     = substr(lc $outsfx,1) ;    

my $outResxFile = "${outfname}.resx" ;

croak 'Invalid input file'  unless exists $ValidParserMakeArgs{$insfx} ;
croak 'Invalid output file' unless exists $ValidParserMakeArgs{$outsfx} ;

### check output files can be written to 
# yes so it's a race-condition anyway

croak 'Output resource file cannot be written to' unless -f $outResxFile or ! -e $outResxFile ;

my $qr_testname  = qr{$opt_testname} ; 

### build parsers


my %Parsers = () ;
$Parsers{${insfx}}  = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${insfx}}  } );
$Parsers{${outsfx}} = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${outsfx}} } );

### build internal representations of input

my $o_resx = VSGDR::UnitTest::TestSet::Resx->new() ;

my $testSet         = $Parsers{$insfx}->deserialise($inFile);
my $resx_data       = ''; { $/ = undef ; open ( my $fh, "<", "${infname}.resx"); $resx_data = <$fh> ; close $fh } ;
my $rh_testScripts  = $o_resx->parse($resx_data) ; 


my $ra_tests        = $testSet->tests() ;
my @filteredTests   = grep { my $s=$_->testName() ; $s !~ ${qr_testname} && $_ ; }  @$ra_tests ;


### filter input to output


my $filteredTestSet = VSGDR::UnitTest::TestSet->new( { NAMESPACE        => $testSet->className()
                                                      , CLASSNAME        => $testSet->className()
                                                      } 
                                                    ) ;
$filteredTestSet->initializeConditions($testSet->initializeConditions) ;
$filteredTestSet->cleanupConditions($testSet->cleanupConditions) ;
$filteredTestSet->tests(\@filteredTests) ;

unlink $outFile if -f $outFile ;
$Parsers{$outsfx}->serialise($outFile,$filteredTestSet);

my $o_resx_clone   = $o_resx->clone() ;

my %filtered_testScripts  = () ;
map { my $s=$_->testActionLiteralName() ;     exists $$rh_testScripts{$s} && ( $filtered_testScripts{$s} = $$rh_testScripts{$s} ) ;
         $s=$_->preTestActionLiteralName() ;  exists $$rh_testScripts{$s} && ( $filtered_testScripts{$s} = $$rh_testScripts{$s} ) ;
         $s=$_->postTestActionLiteralName() ; exists $$rh_testScripts{$s} && ( $filtered_testScripts{$s} = $$rh_testScripts{$s} ) ;
    } grep { my $s=$_->testName() ; $s !~ ${qr_testname} && $s ; }  
    @$ra_tests ;


$o_resx_clone->scripts(\%filtered_testScripts);
unlink $outResxFile if -f $outResxFile ;
$o_resx_clone->serialise($outResxFile,$o_resx_clone);

### end

exit ;

END {} 


__END__



=head1 NAME


delGDRTest.pl - Delete Tests from a GDR Unit Test file.



=head1 VERSION

1.0.4



=head1 USAGE

delGDRTest.pl -i <file> -o <file> -t <testname_re> 


=head1 REQUIRED ARGUMENTS


=over


=item  -i[n][file]  [=]<file>

Specify input file

=for Euclid:
    file.type:    readable



=item  -o[ut][file] [=]<file>

Specify output file

=for Euclid:
    file.type:    writable


=item  -t[estname] [=]<testname_re>

Specify test name ( as perl RE ) 

=for Euclid:
    testname_re.type:    string

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
