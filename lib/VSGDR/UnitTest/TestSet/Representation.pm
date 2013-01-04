package VSGDR::UnitTest::TestSet::Representation;

use 5.010;
use strict;
use warnings;


our $VERSION = '1.00';


use parent qw(Clone) ;

#TODO 1. Add support for test method attributes eg new vs2010 exceptions  ala : -[ExpectedSqlException(MessageNumber = nnnnn, Severity = x, MatchFirstError = false, State = y)]


use IO::File;

use Data::Dumper ;
use Carp ;

use vars qw($AUTOLOAD );

my %Types = ('XML'     => 1
             ,'NET::CS' => 1
             ,'NET::VB' => 1
             ,'XLS'     => 1
             ) ;


sub new {

    local $_ = undef ;

    my $invocant         = shift ;
    my $class            = ref($invocant) || $invocant ;

    my @elems            = @_ ;
    my $self             = bless {}, $class ;
   
    $self->_init(@elems) ;
    return $self ;
}


sub _init {

    local $_ = undef ;

    my $self                = shift ;
    my $class               = ref($self) || $self ;

    return ;
    
}


sub make {

    local $_ = undef ;
    my $self         = shift ;

    my $objectType        = $_[0]->{TYPE} or croak 'No Representation type' ;
    croak "Invalid Representation language type " unless exists $Types{$objectType };
    ( my $objectTypePathFileName = ${objectType} ) =~ s{::}{/}xg ;
    require "VSGDR/UnitTest/TestSet/Representation/${objectTypePathFileName}.pm";
    return "VSGDR::UnitTest::TestSet::Representation::${objectType}"->new(@_) ;

}

## default standard implementations of code below..............
##XLS has to override them.
## ======================================================
sub serialise {
    my $self        = shift or croak 'no self' ;
    my $file        = shift or croak 'no file' ;
    my $object      = shift or croak 'no object';
    
    my $code        = $self->deparse($object);    
    
    my $data;
    my $fh = new IO::File "> ${file}" ;
    if (defined ${fh} ) {
        print ${fh} $code;
        $fh->close;
    }
    else {
        croak "Unable to write to ${file}.";
    }
    return ;
}
## ======================================================
sub deserialise {

    my $self        = shift or croak 'no self' ;
    my $file        = shift or croak 'no file' ;
    my $data;
    my $fh = new IO::File;
    if ($fh->open("< ${file}")) {
        { local $/ = undef ; $data = <$fh> ; }     
        $fh->close;
    }
    else {
        croak "Unable to read from ${file}.";
    }
    my $object    = $self->parse($data);
    return ${object} ;
}
## ======================================================


1 ;



__DATA__

=head1 SYNOPSIS

Sealed unit.  No user serviceable parts.


=head1 AUTHOR

Ded MedVed, C<< <dedmedved at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-vsgdr-unittest-testset at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=VSGDR-UnitTest-TestSet>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc VSGDR::UnitTest::TestSet::Representation


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=VSGDR-UnitTest-TestSet>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/VSGDR-UnitTest-TestSet>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/VSGDR-UnitTest-TestSet>

=item * Search CPAN

L<http://search.cpan.org/dist/VSGDR-UnitTest-TestSet/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Ded MedVed.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of VSGDR::UnitTest::TestSet::Representation
