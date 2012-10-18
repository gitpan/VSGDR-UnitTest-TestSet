package VSGDR::UnitTest::TestSet;

use 5.010;
use strict;
use warnings;

=head1 NAME

VSGDR::UnitTest::TestSet - The great new VSGDR::UnitTest::TestSet!

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';


use autodie qw(:all);

#TODO 1. Add support for test method attributes eg new vs2010 exceptions  ala : -[ExpectedSqlException(MessageNumber = nnnnn, Severity = x, MatchFirstError = false, State = y)]

use VSGDR::UnitTest::TestSet::Representation ;
use Data::Dumper ;
use Carp ;

use Clone;

use base qw(Clone) ;

our $VERSION    = "0.01";
our $AUTOLOAD ;
my %ok_field ;
# Authorize four attribute fields
{
for my $attr ( qw(nameSpace className __testCleanupAction __testInitializeAction) ) { $ok_field{$attr}++; }
}

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
    my $ref = shift or croak "no arg";

    my ${NameSpace}         = $$ref{NAMESPACE};
    my ${ClassName}         = $$ref{CLASSNAME};

    $self->nameSpace(${NameSpace}) ;
    $self->className(${ClassName}) ;
    $self->initializeConditions([]) ;
    $self->cleanupConditions([]) ;
    return ;

}

sub tests {
    local   $_      = undef ;

    my $self        = shift or croak 'no self';
    my $tests ;
    $tests          = shift if @_;
# try to break refees here
    if ( defined $tests ) {
        $self->{TESTS} = $tests ;
    }
    return $self->{TESTS} ;
}

sub actions {
    local   $_      = undef ;

    my $self        = shift or croak 'no self';
    my $actions ;
    $actions        = shift if @_;
    if ( defined $actions ) {
croak 'obsoleted method';
#        $self->{ACTIONS} = $actions ;
    }
    my %actions = () ;
    my $ra_tests = $self->tests() ;
    foreach my $test ( @$ra_tests ) {
#warn Dumper $test ;
        my $rh_= $test->actions() ;
        foreach my $action ( keys %$rh_ ) {
#warn Dumper $action ;
            $actions{$action} = 1 ;
        }
    }
#warn Dumper %actions ;
    $actions{$self->initializeAction()} = 1 if defined $self->initializeAction() ;
    $actions{$self->cleanupAction()}    = 1 if defined $self->cleanupAction() ;
    return \%actions ;
}


sub initializeConditions {
    local   $_          = undef ;

    my $self            = shift or croak 'no self';
    my $conditions ;
    $conditions         = shift if @_;
    if ( defined $conditions ) {
        $self->{INITIALIZECONDITIONS} = $conditions ;
    }
    return $self->{INITIALIZECONDITIONS} ;
}

sub cleanupConditions {
    local   $_          = undef ;

    my $self            = shift or croak 'no self';
    my $conditions ;
    $conditions         = shift if @_;
    if ( defined $conditions ) {
        $self->{CLEANUPCONDITIONS} = $conditions ;
    }
    return $self->{CLEANUPCONDITIONS} ;
}

sub commentifyAny {
    local   $_  = undef ;

    my $self    = shift;
    my $commentChars    = shift or die 'No Chars' ;
    my $thing   = shift or die 'No thing' ;
    return <<"EOF";
            ${commentChars}
            ${commentChars}${thing}
            ${commentChars}
EOF
}

sub commentifyInitializeAction {
    local   $_  = undef ;

    my $self    = shift;
    my $commentChars    = shift or die 'No Chars' ;
    return <<"EOF";
            ${commentChars}
            ${commentChars}@{[$self->initializeAction()]}
            ${commentChars}
EOF
}

sub commentifyCleanupAction {
    local   $_  = undef ;

    my $self    = shift;
    my $commentChars    = shift or die 'No Chars' ;
    return <<"EOF";
            ${commentChars}
            ${commentChars}@{[$self->cleanupAction()]}
            ${commentChars}
EOF
}

sub commentifyClassName {
    local   $_  = undef ;

    my $self    = shift;
    my $commentChars    = shift or die 'No Chars' ;
    return <<"EOF";
            ${commentChars}
            ${commentChars}@{[$self->className()]}
            ${commentChars}
EOF
}
sub initializeAction {
    local   $_      = undef ;

    my $self        = shift or croak 'no self';
    my $action ;
    $action         = shift if @_;
    if ( defined $action ) {
        $self->__testInitializeAction($action) ;
    }
    return $self->__testInitializeAction() ;
}

sub cleanupAction {
    local   $_      = undef ;

    my $self        = shift or croak 'no self';
    my $action ;
    $action         = shift if @_;
    if ( defined $action ) {
        $self->__testCleanupAction($action) ;
    }
    return $self->__testCleanupAction() ;

}

sub initializeActionLiteral {
    local   $_      = undef ;

    my $self        = shift or croak 'no self';
    return 'testInitializeAction' ;
}

sub cleanupActionLiteral {
    local   $_      = undef ;

    my $self        = shift or croak 'no self';
    return 'testCleanupAction' ;

}

sub allConditionAttributeNames {
    local   $_      = undef ;

    my $self        = shift;
    return ('Type','Name','ResultSet','RowNumber','ColumnNumber','ExpectedValue','RowCount','NullExpected','ExecutionTime','Enabled') ;
}

sub generate {
    local   $_          = undef ;

    my $self            = shift;
    my $generator_type  = shift or croak "No generator supplied" ;
    my $generator       =  VSGDR::UnitTest::TestSet::Representation->make( { TYPE => $generator_type } ) ;
    return $generator->deparse($self);
}

sub AST {
    local   $_          = undef ;

    my $self            = shift or croak "No self" ;
    return { HEAD => { NAMESPACE        => $self->nameSpace()
                     , CLASSNAME        => $self->className()
                     , INITIALIZEACTION => $self->__testInitializeAction()
                     , CLEANUPACTION    => $self->__testCleanupAction()
                     }
           , INITIALIZECONDITIONS   => $self->initializeConditions()
           , CLEANUPCONDITIONS      => $self->cleanupConditions()
           , BODY                   => $self->tests()
           , ACTIONS                => $self->actions()
           }
}

sub renameTest {
    local   $_          = undef ;

    my $self            = shift;
    my $oldTestName     = shift or croak "No old Test Name supplied" ;
    my $newTestName     = shift or croak "No new Test Name supplied" ;

    return ;
}

sub deleteTest {
    local   $_          = undef ;

    my $self            = shift;
    my $testName        = shift or croak "No Test Name supplied" ;

    return ;

}

sub Dump {
    local   $_ = undef ;

    warn "!\n";
    warn Dumper @_ ;
    warn "!\n";
    return ;
}

sub flatten { return map { @$_}  @_ } ;

sub DESTROY {}

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
    $attr =~ s{.*::}{}x;
    return unless $attr =~ m{[^A-Z]}x;  # skip DESTROY and all-cap methods
    croak "invalid attribute method: ->$attr()" unless $ok_field{$attr};
    $self->{uc $attr} = shift if @_;
    return $self->{uc $attr};
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

    perldoc VSGDR::UnitTest::TestSet


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

1; # End of VSGDR::UnitTest::TestSet
