package VSGDR::UnitTest::TestSet::Test::TestCondition::ExpectedSchema;

use 5.010;
use strict;
use warnings;

=head1 NAME

VSGDR::UnitTest::TestSet::Test::TestCondition::ExpectedSchema - The great new VSGDR::UnitTest::TestSet::Test::TestCondition::ExpectedSchema!

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

our $VERSION    = "0.01";
use vars qw($AUTOLOAD %ok_field);

# Authorize constructor hash fields
my %ok_params = () ;
for my $attr ( qw(CONDITIONTESTACTIONNAME CONDITIONNAME CONDITIONENABLED CONDITIONVERBOSE CONDITIONAPPLYRESOURCES) ) { $ok_params{$attr}++; } 
my %ok_fields       = () ;
my %ok_fields_type  = () ;
# Authorize attribute fields
for my $attr ( qw(conditionTestActionName conditionName conditionEnabled conditionVerbose conditionApplyResources) )  { $ok_fields{$attr}++; $ok_fields_type{$attr} = 'plain'; } 
$ok_fields_type{conditionName}                  = 'quoted';  
$ok_fields_type{conditionEnabled}               = 'bool';  
$ok_fields_type{conditionApplyResources}        = 'literalcode';  


sub _init {

    local $_ = undef ;

    my $self                = shift ;
    my $class               = ref($self) || $self ;
    my $ref                 = shift or croak "no arg";

    $self->{OK_PARAMS}      = \%ok_params ;
    $self->{OK_FIELDS}      = \%ok_fields ;
    $self->{OK_FIELDS_TYPE} = \%ok_fields_type ;
    my @validargs           = grep { exists($$ref{$_}) } keys %{$self->{OK_PARAMS}} ;
#warn Dumper @validargs;    
    croak "bad args"
        if scalar(@validargs) != 4 ; 
#warn Dumper @validargs;    
    my ${Name}              = $$ref{CONDITIONNAME};
    my ${TestActionName}    = $$ref{CONDITIONTESTACTIONNAME};
    my ${Enabled}           = $$ref{CONDITIONENABLED};
    my ${Verbose}           = $$ref{CONDITIONVERBOSE};

    $self->conditionName(${Name}) ; 
    $self->conditionTestActionName(${TestActionName}) ; 
    $self->conditionEnabled(${Enabled}) ; 
    $self->conditionVerbose(${Verbose}) ; 

  
    return ;
    
}

sub testConditionType {
    my $self    = shift;
    return 'ExpectedSchema' ;
}

sub testConditionMSType {
    return 'ExpectedSchemaCondition' ;
}

sub check {
    local $_                = undef ;
    my $self                = shift ;
    my $ra_res              = shift ;

#warn Dumper $ra_res ;

    if ( $self->conditionISEnabled() ) {
#say 'Condition is ', $self->conditionName() ;
#say 'value    is  ', '"'.$ra_res->[$self->conditionResultSet()-1]->[$self->conditionRowNumber()-1]->[$self->conditionColumnNumber()-1].'"'  ;
#say 'expected was ', $self->conditionExpectedValue()  ;
        return scalar 1 ; 
    }
    else {
#say 'Condition ', $self->conditionName(), ' is disabled' ;
        return scalar -1 ; 
    }
} 

## local override for unstorable attribute - when called upon - just derive it.
## luckily we can get away with this it's the same for vb and c#

sub conditionApplyResources {
    local $_                = undef ;
    my $self                = shift ;
    my $ra_res              = shift ;
    return "resources.ApplyResources(" . $self->conditionName() . ', "' . $self->conditionName() . '")' ;
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

    perldoc VSGDR::UnitTest::TestSet::Test::TestCondition::ExpectedSchema


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

1; # End of VSGDR::UnitTest::TestSet::Test::TestCondition::ExpectedSchema
