#!/bin/perl

use strict;
use warnings;
use autodie qw(:all);  
use 5.010;


use Carp;
use Getopt::Euclid qw( :vars<opt_> );

use VSGDR::UnitTest::TestSet::Test;
use VSGDR::UnitTest::TestSet::Test::TestCondition;
use VSGDR::UnitTest::TestSet::Representation ;
use Data::Dumper;


my %ValidParserMakeArgs = ( vb  => "NET::VB"
                          , cs  => "NET::CS"
                          , xls => "XLS"
                          , xml => "XML"
                          ) ;

my %Parsers         = () ;

##########################

        my @testNames                   = () ;
        my $tests_count                 = 0 ;
        my $conditions_count            = 0 ;
        my $scalar_conditions_count     = 0 ;
        my $disabled_conditions_count   = 0 ;


#warn Dumper $opt_infile ;
    for my $testFile ( split /[,\s]/, $opt_infile ) {
#warn Dumper $testFile ;
        (my $insfx  = $testFile)  =~ s/^.*\.//g;
        $insfx  = lc $insfx ;

        die 'Invalid input file $testFile'  unless exists $ValidParserMakeArgs{$insfx} ;

        $Parsers{${insfx}}  = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${insfx}} } )
            if not exists $Parsers{${insfx}} ;
        my $testSet         = $Parsers{$insfx}->deserialise($testFile);

        my $ra_tests  = $testSet->tests() ;
        @testNames = map { $_->testName() } @{$ra_tests} ;

        $tests_count += @testNames ;

        my $test_No = 0 ;  
        for my $test (@$ra_tests) {

            $test_No++ ;

            my $ra_preTestConditions    = $test->preTest_conditions() ;
            my $ra_testConditions       = $test->test_conditions() ;
            my $ra_postTestConditions   = $test->postTest_conditions() ;

            $conditions_count += scalar @{$ra_preTestConditions} ;
            $conditions_count += scalar @{$ra_testConditions} ;
            $conditions_count += scalar @{$ra_postTestConditions} ;

            my @scalarTestConditions     = grep { $_->testConditionType() eq 'ScalarValue' } @{$ra_testConditions} ;
            my @scalarPreTestConditions  = grep { $_->testConditionType() eq 'ScalarValue' } @{$ra_preTestConditions} ;
            my @scalarPostTestConditions = grep { $_->testConditionType() eq 'ScalarValue' } @{$ra_postTestConditions} ;

            $scalar_conditions_count += @scalarTestConditions ;
            $scalar_conditions_count += @scalarPreTestConditions ;
            $scalar_conditions_count += @scalarPostTestConditions ;

            my @disabledTestConditions     = grep { ! $_->conditionISEnabled() } @{$ra_testConditions} ;
            my @disabledPreTestConditions  = grep { ! $_->conditionISEnabled() } @{$ra_preTestConditions} ;
            my @disabledPostTestConditions = grep { ! $_->conditionISEnabled() } @{$ra_postTestConditions} ;

            $disabled_conditions_count += @disabledTestConditions ;
            $disabled_conditions_count += @disabledPreTestConditions ;
            $disabled_conditions_count += @disabledPostTestConditions ;

        }

    }

print "Total tests                        = ${tests_count}\n";
print "Total test conditions              = ${conditions_count}\n";
print "Total scalar value test conditions = ${scalar_conditions_count}\n";
print "Total disabled test conditions     = ${disabled_conditions_count}\n";

exit ;

END {} 


__END__



=head1 NAME


statGDRTests.pl - Reports on Test and Test Conditions within a GDR Unit Test file.



=head1 VERSION

1.0.0



=head1 USAGE

statGDRTests.pl -i <file>




=head1 REQUIRED ARGUMENTS


=over



=item  -i[n][file]  [=]<file>

Specify input file

=for Euclid:
    file.type:    readable



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
