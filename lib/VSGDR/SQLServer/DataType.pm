package VSGDR::SQLServer::DataType;

use 5.010;
use strict;
use warnings;

=head1 NAME

VSGDR::SQLServer::DataType - Sealed class for Microsoft Visual Studio Database Edition UnitTest Utility Suite by Ded MedVed

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';
use Carp;
use parent qw(Clone);

use overload        (
        q("")   => sub {$_[0]->{VALUE}}, 
        q(0+)   => sub {$_[0]->{VALUE}},
        '<=>'   => \&spaceship,
        'cmp'   => \&spaceship,
);


our %Types      =   ( Bit       => 1
                    , Generic   => 1
                    ) ;


sub new {

    local $_ ;

    my $invocant         = shift ;
    my $class            = ref($invocant) || $invocant ;

    my @elems            = @_ ;
    my $self             = bless {}, $class ;

    $self->_init(@elems) ;
    return $self ;
}


sub _init {

    local $_ ;

    my $self                = shift ;
    my $class               = ref($self) || $self ;
    my $arg                 = shift ;##  can''t check undef !or croak "no _init arg";

    my $Value               = $arg;
    $self->setValue(${Value} ) ; 

    return ;
    
}

sub setValue {

    local $_ ;

    my $self                = shift ;
    my $arg                 = shift ;##  can''t check undef or croak "no setValue arg";
    $self->{VALUE}          = $arg ;
        
}

sub value {

    local $_ ;

    my $self                = shift ;
    return scalar $self->{VALUE} ;
        
}

## parent type - do nothing
sub quoteValue {
    local $_ ;
    my $self                = shift ;
    my $value               = shift ;
    return                  $value ;
}

## parent type - do nothing
sub unQuoteValue {
    local $_ ;
    my $self                = shift ;
    my $value               = shift ;
    return                  $value ;
}


sub make {

    local $_ ;
    my $self            = shift ;
    my $flagthing       = shift or croak 'No object type' ;
    
    my $objectType ;
    if ( $flagthing == -7 ) {
        $objectType = 'Bit';
    }
    else {
        $objectType = 'Generic';
    }
    croak "Invalid SQL Server Data Type" unless exists $Types{${objectType}};
    
    require "VSGDR/SQLServer/DataType/${objectType}.pm";
    return "VSGDR::SQLServer::DataType::${objectType}"->new(@_) ;

}


sub spaceship { 
    my ($s1, $s2, $inverted) = @_;

return 0 if ( ! defined $s1->value() ) or ( ! defined $s2->value() ) ;
    return $inverted ? $s2->value() cmp $s1->value() : $s1->value() cmp $s2->value() ;
} 


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

    perldoc VSGDR::SQLServer::DataType


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

1; # End of VSGDR::SQLServer::DataType
