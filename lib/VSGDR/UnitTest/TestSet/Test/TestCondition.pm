package VSGDR::UnitTest::TestSet::Test::TestCondition;

use 5.010;
use strict;
use warnings;


our $VERSION = '1.00';


#TODO 1. Add support for test method attributes eg new vs2010 exceptions  ala : -[ExpectedSqlException(MessageNumber = nnnnn, Severity = x, MatchFirstError = false, State = y)]


use Data::Dumper ;
use Carp ;


use vars qw($AUTOLOAD );

my %Types = (ScalarValue=> 1
             ,EmptyResultSet=> 1
             ,ExecutionTime=> 1
             ,Inconclusive=> 1
             ,NotEmptyResultSet=> 1
             ,RowCount=> 1
             ,Checksum=>1
             ,ExpectedSchema=>1
             );

sub make {

    local $_ = undef ;
    my $self         = shift ;
    my $objectType        = $_[0]->{TESTCONDITIONTYPE} or croak 'No object type' ;
    croak "Invalid Test Condition Type" unless exists $Types{$objectType };
    
    require "VSGDR/UnitTest/TestSet/Test/TestCondition/${objectType}.pm";
    return "VSGDR::UnitTest::TestSet::Test::TestCondition::${objectType}"->new(@_) ;

}

sub new {

    local $_ = undef ;

    my $invocant         = shift ;
    my $class            = ref($invocant) || $invocant ;

    my @elems            = @_ ;
    my $self             = bless {}, $class ;
   
    $self->_init(@elems) ;
    return $self ;
}


sub ok_field {
    my $self    = shift;
    my $attr    = shift;
    return $self->{OK_FIELDS}->{$attr} ;
}

sub commentifyName {
    my $self            = shift;
    my $commentChars    = shift or croak 'No Chars' ;
    return <<"EOF";
            ${commentChars}
            ${commentChars}@{[$self->conditionName()]}
            ${commentChars}
EOF
}

sub testAction {
    my $self    = shift;
    my $ta = $self->{CONDITIONTESTACTIONNAME} ;
    return $ta;
} 

sub testConditionAttributes {
    my $self    = shift;
    return keys %{$self->{OK_FIELDS}} ;
}
sub testConditionAttributeType {
    my $self    = shift;
    my $attr    = shift or croak 'no attribute' ;
    croak 'bad attribute'unless $self->ok_field($attr) ;
#warn Dumper $self->{OK_FIELDS_TYPE} ;    
    return $self->{OK_FIELDS_TYPE}->{$attr} ;
}

sub testConditionAttributeName {
    my $self    = shift;
    my $attr    = shift or croak 'no attribute' ;
    croak 'bad attribute'unless $self->ok_field($attr) ;
    ( my $n = $attr ) =~ s{^condition}{}x;
    return $n ;
}

sub conditionISEnabled {
    local $_                = undef ;
    my $self                = shift ;
    if ( $self->conditionEnabled() =~ m{\A 1 \z}ix ) {
        return scalar 1 ;
    }
    elsif ( $self->conditionEnabled() =~ m{\A True \z}ix ) {
        return scalar 1 ;
    }
    else {
        return scalar 0 ;
    }
}




sub DESTROY {}

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
#warn Dumper $attr ;    
    $attr =~ s{.*::}{}x;
    return unless $attr =~ m{[^A-Z]}x;  # skip DESTROY and all-cap methods
#warn Dumper $attr ;    
#warn Dumper $ok_field{$attr} ;
#warn Dumper %ok_field;
    croak "invalid attribute method: ->$attr()" unless $self->ok_field($attr);
    
    my $UC_ATTR     = uc $attr ;
      
    $self->{$UC_ATTR} = shift if @_;
    return $self->{$UC_ATTR};
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

    perldoc VSGDR::UnitTest::TestSet::Test::TestCondition


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

1; # End of VSGDR::UnitTest::TestSet::Test::TestCondition
