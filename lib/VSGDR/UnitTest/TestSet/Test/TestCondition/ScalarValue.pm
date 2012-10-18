package VSGDR::UnitTest::TestSet::Test::TestCondition::ScalarValue;

use 5.010;
use strict;
use warnings;

=head1 NAME

VSGDR::UnitTest::TestSet::Test::TestCondition::ScalarValue - The great new VSGDR::UnitTest::TestSet::Test::TestCondition::ScalarValue!

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';


use parent qw(VSGDR::UnitTest::TestSet::Test::TestCondition) ;
BEGIN {
*AUTOLOAD = \&VSGDR::UnitTest::TestSet::Test::TestCondition::AUTOLOAD ;
}

use Data::Dumper ;
use Carp ;

our $VERSION    = "0.04";
use vars qw($AUTOLOAD %ok_field);

#TODO 1: Sort out value testing you damn fool.

# Authorize constructor hash fields
my %ok_params = () ;
for my $attr ( qw(CONDITIONTESTACTIONNAME CONDITIONNAME CONDITIONENABLED CONDITIONEXPECTEDVALUE CONDITIONNULLEXPECTED CONDITIONRESULTSET CONDITIONROWNUMBER CONDITIONCOLUMNNUMBER) ) { $ok_params{$attr}++; } 
my %ok_fields       = () ;
my %ok_fields_type  = () ;
# Authorize attribute fields
for my $attr ( qw(conditionTestActionName conditionName conditionEnabled conditionExpectedValue conditionResultSet conditionNullExpected conditionRowNumber conditionColumnNumber) )  { $ok_fields{$attr}++; $ok_fields_type{$attr} = 'plain'; } 
$ok_fields_type{conditionName}      = 'quoted';  
$ok_fields_type{conditionEnabled}   = 'bool';  

sub _init {

    local $_ = undef ;

    my $self                = shift ;
    my $class               = ref($self) || $self ;
    my $ref                 = shift or croak "no arg";

    $self->{OK_PARAMS}      = \%ok_params ;
    $self->{OK_FIELDS}      = \%ok_fields ;
    $self->{OK_FIELDS_TYPE} = \%ok_fields_type ;
    my @validargs           = grep { exists($$ref{$_}) } keys %{$self->{OK_PARAMS}} ;
    croak "bad args"
        if scalar(@validargs) != 8 ; 

    my ${Name}              = $$ref{CONDITIONNAME};
    my ${TestActionName}    = $$ref{CONDITIONTESTACTIONNAME};
    my ${Enabled}           = $$ref{CONDITIONENABLED};
    my ${ExpectedValue}     = $$ref{CONDITIONEXPECTEDVALUE};
    my ${NullExpected}      = $$ref{CONDITIONNULLEXPECTED};
    my ${ResultSet}         = $$ref{CONDITIONRESULTSET};
    my ${RowNumber}         = $$ref{CONDITIONROWNUMBER};
    my ${ColumnNumber}      = $$ref{CONDITIONCOLUMNNUMBER};

    $self->conditionName(${Name}) ; 
    $self->conditionTestActionName(${TestActionName}) ; 
    $self->conditionEnabled(${Enabled}) ; 
    $self->conditionExpectedValue(${ExpectedValue}) ; 
    $self->conditionNullExpected(${NullExpected}) ; 
    $self->conditionResultSet(${ResultSet}) ; 
    $self->conditionRowNumber(${RowNumber}) ; 
    $self->conditionColumnNumber(${ColumnNumber}) ; 

  
    return ;
    
}

sub testConditionType {
    my $self    = shift;
    return 'ScalarValue' ;
}

sub testConditionMSType {
    return 'ScalarValueCondition' ;
}

sub check {
    local $_                = undef ;
    my $self                = shift ;
    my $ra_res              = shift ;

#warn Dumper $ra_res ;
#warn $self->conditionEnabled() ;

    # unquote scalar string values
    # should use Data method but that's in entirely the wrong class
    my $unQuotedValue = $self->conditionExpectedValue() ;
    $unQuotedValue    =~ s{\\"}{"}gms;  #" kill TextPad syntax highlighting
    
    if ( $self->conditionISEnabled() ) {
        if ( not $self->conditionNullISExpected()   and not defined( $ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1]) ) {
say  'Condition is ', $self->conditionName() ;
say  'value    is  ', 'undef' ;
say  'expected was ', $unQuotedValue  ;
            return scalar 0 ; 
        }
        elsif ( ( $self->conditionNullISExpected() and not defined( $ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1]) ) or
        
             ( '"'.$ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1].'"' eq $unQuotedValue )
# horrible hack around for now ........... where was my nice clean fix.
or             ( ( $unQuotedValue =~ m{^"true"$}i  ) and ( $ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1] eq "1" ) )
or             ( ( $unQuotedValue =~ m{^"false"$}i ) and ( $ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1] eq "0" ) )
           ) {
            return scalar 1 ; 
        }
        else {
# another hackaround for date values
            my $v  = $ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1] ;
            my $v2 = $unQuotedValue ;
            ( my $v3 = $v2 ) =~ s{/}{-}g;

#warn $v;               
#warn $v2;               
#warn $v3;
#warn substr $v3, 1 , 10  ;
#warn substr $v, 0, 10;

            if (   ( $v  =~ m{^ "? \d{4}-\d{2}-\d{2} \s 00:00:00 "? $}x )
               and ( $v2 =~ m{^ "? \d{4}[/-]\d{2}[/-]\d{2} "? $}x )
               and ( substr($v3,1,10)  eq substr($v,0,10)  )
               ) {
#warn 'aaa';
                return scalar 1 ; 
            }
            else {
say  'Condition is ', $self->conditionName() ;
say  'value    is  ', '"'.$ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1].'"'  ;
say  'expected was ', $unQuotedValue  ;
            return scalar 0 ; 
            }
        }
    }
    else {
#say 'Condition ', $self->conditionName(), ' is disabled' ;
        return scalar -1 ; 
    }
} 

sub conditionNullISExpected {
    local $_                = undef ;
    my $self                = shift ;
    if ( $self->conditionNullExpected() =~ m{\A 1 \z}ix ) {
        return scalar 1 ;
    }
    elsif ( $self->conditionNullExpected() =~ m{\A True \z}ix ) {
        return scalar 1 ;
    }
    else {
        return scalar 0 ;
    }
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

    perldoc VSGDR::UnitTest::TestSet::Test::TestCondition::ScalarValue


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

1; # End of VSGDR::UnitTest::TestSet::Test::TestCondition::ScalarValue
