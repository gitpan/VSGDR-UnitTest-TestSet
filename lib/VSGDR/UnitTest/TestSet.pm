package VSGDR::UnitTest::TestSet;

use 5.010;
use strict;
use warnings;

=head1 NAME

VSGDR::UnitTest::TestSet - Sealed class for Microsoft Visual Studio Database Edition UnitTest Utility Suite by Ded MedVed

=head1 VERSION

Version 1.18

=cut

our $VERSION = '1.18';


use autodie qw(:all);

#TODO 1. Add support for test method attributes eg new vs2010 exceptions  ala : -[ExpectedSqlException(MessageNumber = nnnnn, Severity = x, MatchFirstError = false, State = y)]

use VSGDR::UnitTest::TestSet::Representation ;
use Data::Dumper ;
use Carp ;

use Clone;

use base qw(Clone) ;

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


