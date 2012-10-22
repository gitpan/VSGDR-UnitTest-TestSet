#!/bin/perl

use strict;
use warnings;
use Modern::Perl;
use autodie qw(:all);
no indirect ':fatal';
use 5.010;

use version ; our $VERSION = qv('1.0.0');

use Carp;
use Getopt::Euclid qw( :vars<opt_> );
use File::Basename;

use VSGDR::UnitTest::TestSet::Test;
use VSGDR::UnitTest::TestSet::Test::TestCondition;
use VSGDR::UnitTest::TestSet::Representation;
use VSGDR::UnitTest::TestSet::Resx;

use Data::Dumper;


my %ValidParserMakeArgs = ( vb  => "NET::VB"
                          , cs  => "NET::CS"
                          , xls => "XLS"
                          , xml => "XML"
                          ) ;
                          
my @validSuffixes       = map { '.'.$_ } keys %ValidParserMakeArgs ;


my($infname, $indirectories, $insfx) = fileparse($opt_infile, @validSuffixes);
$insfx      = lc $insfx ;
$insfx        = substr(lc $insfx,1) ;
my($outfname, $outdirectories, $outsfx) = fileparse($opt_outfile, @validSuffixes);
$outsfx       = lc $outsfx ;
$outsfx       = substr(lc $outsfx,1) ;

croak 'Invalid input file'   unless exists $ValidParserMakeArgs{$insfx} ;
croak 'Invalid output file'  unless exists $ValidParserMakeArgs{$outsfx} ;

my %Parsers         = () ;
$Parsers{${insfx}}  = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${insfx}} } );
$Parsers{${outsfx}} = VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $ValidParserMakeArgs{${outsfx}} } );

my $testSet         = $Parsers{$insfx}->deserialise($opt_infile);
unlink $opt_outfile if -f $opt_outfile ;
$Parsers{$outsfx}->serialise($opt_outfile,$testSet);

exit ;

END {}

__END__



=head1 NAME

trGDRTests.pl - Translates GDR test from one .Net language to another.
Alternative formats supported include XML and Excel.
The file type is determined from the file suffix.
Currently supported types are .cs, .vb, .xml, and .xls.


=head1 VERSION

1.0.0



=head1 USAGE

trGDRTests.pl -i <file> -o <file>



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
