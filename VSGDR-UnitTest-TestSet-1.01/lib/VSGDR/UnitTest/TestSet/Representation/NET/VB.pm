package VSGDR::UnitTest::TestSet::Representation::NET::VB;

use 5.010;
use strict;
use warnings;

=head1 NAME

VSGDR::UnitTest::TestSet::Representation::NET::VB - Sealed class for Microsoft Visual Studio Database Edition UnitTest Utility Suite by Ded MedVed

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';


use parent qw(VSGDR::UnitTest::TestSet::Representation::NET) ;

#TODO 1. Add support for test method attributes eg new vs2010 exceptions  ala : -[ExpectedSqlException(MessageNumber = nnnnn, Severity = x, MatchFirstError = false, State = y)]
#TODO 2. Add checking support in the parser, etc that the bits of code we don't care about match our expectations.  Otherwise we risk screwing non-standard test classes
#TODO 3: If a condition has the same name as a test ( ie like the prefix of a test action, the check to determine resource or test condition fails.  We've strengthened it, but it might not ultimately be fixable.
#TODO 4: Noticed that VS2010 generated tests update some functions to have empty trailing () as for C#.  Need to pick this up as an optional parse element.

use Data::Dumper ;
use Carp ;
use Parse::RecDescent;

use VSGDR::UnitTest::TestSet;
use VSGDR::UnitTest::TestSet::Test;
use VSGDR::UnitTest::TestSet::Representation;
use VSGDR::UnitTest::TestSet::Representation::NET;

#my  %Globals ; ## temp
our $VERSION    = "0.99";


use Time::HiRes qw(usleep ualarm gettimeofday tv_interval);

#use Smart::Comments ;

#use re 'debug';

#$::RD_HINT=1;
#$::RD_AUTOACTION=q { [@item] };
#$::RD_TRACE        = 1;
#$::RD_WARN =1;
#$::RD_NO_HITEM =1;



#$::RD_HINT=1;
$::RD_AUTOACTION=q { [@item] };
#$::RD_TRACE        = 1;
#$::RD_WARN =1;

my $grammar_pass1 = q{
            
        { my %testConditions   = () ; 
          my %testConditions_2 = () ; 
          my %resources = () ; 
             $resources{CONDITIONS} = () ;
          my %TESTACTIONS           = () ;             
          my %actions = () ; 
          my %globals = () ; 
          }


            start:  m{(?>\A.*? (?=Public \s Class) )}sx { %testConditions   = () ; 
                                                        %testConditions_2 = () ; 
                                                        %resources = () ; 
                                                        $resources{CONDITIONS} = () ;
                                                        %TESTACTIONS            = () ;                                                        
                                                        %actions = () ; 
                                                        %globals = () ; 

#VSGDR::UnitTest::TestSet::Dump(@_) ;                                                                         
                                                      }
                class

                    m{(?>.*?(?=\<TestMethod\(\)\>\s*_))}sx

                testmethod(s)


                m{ .* (?= \z )  }xsm 

                m{ \z }sx    { $return = { GLOBALS => \%globals, RESOURCES => \%resources, ACTIONS => \%actions, TESTCONDITIONS => \%testConditions, TESTCONDITIONS_DETAILS => \%testConditions_2, TESTACTIONS => \%TESTACTIONS } ;
                             }

                    
        class_name: m{\w++}sx       { $globals{CLASSNAME} = $item[1]; $globals{NAMESPACE} = $globals{CLASSNAME} ; $globals{CLEANUPACTION} = 'testCleanupAction'; $globals{INITIALIZEACTION} = 'testInitializeAction' ;
                      [@item] ;
                    }   
        class: /Public Class / class_name



        testmethodname: m{\w++}sx       { $globals{TESTS}{$item[1]}{NAME} = $item[1];
                              [@item] ;
                            } 
        testdata_name: m{\w++}sx        { if ( defined $arg[0] and $arg[0] ne '' ) { $globals{TESTS}{$arg[0]}{ACTION} = $item[1] } ; 
                              [@item] ;
                            } 

        testdata:       /Dim testActions As DatabaseTestActions = Me\./ testdata_name[ $arg[0] ] 

        testmethod:     /\<TestMethod\(\)\>\s*_\s+Public\s+Sub/ testmethodname /\(\)/  testdata[ $item[2][1] ] /.*?(?=(?:\<TestMethod\(\)\>\s*_)|(?:End Class))/s 
        
                                    
               };


my $grammar_pass2 = q{
            
        { my %testConditions   = () ; 
          my %testConditions_2 = () ; 
          my %resources = () ; 
             $resources{CONDITIONS} = () ;
          my %TESTACTIONS           = () ;             
          my %actions = () ; 
          my %globals = () ; 
          }


            start:  m{(?>\A.*? (?=Public \s Class) )}sx { %testConditions       = () ; 
                                                        %testConditions_2       = () ; 
                                                        %resources              = () ; 
                                                        $resources{CONDITIONS}  = () ;
                                                        %TESTACTIONS            = () ;                                                        
                                                        %actions                = () ; 
                                                        %globals                = %{$arg[0]} ; 
                                                      }
                class

                #    m{(?>.*?(?=\<TestMethod\(\)\>\s*_))}sx

                #testmethod(s)

                    m{(?> .*?  (?:Private \s+ Sub \s+ InitializeComponent\(\) \s+ ) )}sx 
                    
                condition_or_testaction(s)

                    m{.*?(?=\s*[''])}s
                    
                resource_test_action(s)

                    m{ .* (?= \z )  }xsm 

                    m{ \z }sx    { $return = { GLOBALS => \%globals, RESOURCES => \%resources, ACTIONS => \%actions, TESTCONDITIONS => \%testConditions, TESTCONDITIONS_DETAILS => \%testConditions_2, TESTACTIONS => \%TESTACTIONS } ;
                                    }


        condition_or_testaction: condition | testaction | resourcemanager
        testaction:             /Dim/ m{\w++}sx /As/ /Microsoft\.Data\.Schema\.UnitTesting\.DatabaseTestAction/
        resourcemanager:        /Dim/ m{\w++}sx /As/ /System\.ComponentModel\.ComponentResourceManager/ /=/ /New/ /System\.ComponentModel\.ComponentResourceManager\(GetType\(\w++\)\)/


        resource_test_action: resource | test | action 

        class_name: m{\w++}sx       { $globals{CLASSNAME} = $item[1]; $globals{NAMESPACE} = $globals{CLASSNAME} ; $globals{CLEANUPACTION} = 'testCleanupAction'; $globals{INITIALIZEACTION} = 'testInitializeAction' ;
                      [@item] ;
                    }   
        class: /Public Class / class_name



        testmethodname: m{\w++}sx       { $globals{TESTS}{$item[1]}{NAME} = $item[1];
                              [@item] ;
                            } 
        testdata_name: m{\w++}sx        { if ( defined $arg[0] and $arg[0] ne '' ) { $globals{TESTS}{$arg[0]}{ACTION} = $item[1] } ; 
                              [@item] ;
                            } 

        testdata:       /Dim testActions As DatabaseTestActions = Me\./ testdata_name[ $arg[0] ] 

        testmethod:     /\<TestMethod\(\)\>\s*_\s+Public\s+Sub/ testmethodname /\(\)/  testdata[ $item[2][1] ] /.*?(?=(?:\<TestMethod\(\)\>\s*_)|(?:#Region "Designer support code"))/s 


        condition_type: m{\w++}sx     
        condition_name: m{\w++}sx     
        condition:      /Dim/ condition_name /As/ /Microsoft\.Data\.Schema\.UnitTesting\.Conditions\./ condition_type   
                         { $testConditions{$item[2][1]} = $item[5][1];
                           [@item] ;
                         } 

        test_comment:   m{\s*'[^']*'[^']*['']\s*}
        testname:       m{\w++}sx
        testproperty:   /ColumnNumber|Enabled|ExpectedValue|Name|NullExpected|ResultSet|RowNumber|RowCount|ExecutionTime|Checksum|Verbose/
        
        testvalue_string: / (?: \"(?:(?:[\\\\][\"])|(?:[^\"]))*?\" )/x 
                    { #VSGDR::UnitTest::TestSet::Dump(@item) ;
                      $item[1] ;
                    }
        testvalue:      testvalue_string
                 |      /System\.TimeSpan\.Parse\("[\d:]*"\)/x
                 |      /(?: \w+ ) /x 

        test_element: testname /\./ testproperty /=/ testvalue 
                    { $testConditions_2{$item[1][1]}{$item[3][1]} = $item[5][1];
                      [@item] ;
                    } 
        test_element: /resources\.ApplyResources\(\w+,/ testvalue_string /\)/ 
                   { [@item] ;
                   }
        test:   test_comment test_element(s)

 
        action_comment: m{\s*'[^']*'[^']*['']\s*}
        action_type:    /PosttestAction|PretestAction|TestAction/      
        action_name:    m{\w++}sx 
        action_element: /Me\./ testdata_name /\./ action_type /=/ action_name 
                { $actions{$item[2][1]}{$item[4][1]}=$item[6][1];
                  my $testAction = $item[2][1] ;
                  my $testActionDataValue = $item[6][1] ;
                  $testActionDataValue =~ s{ _ (?: PosttestAction|PretestAction|TestAction ) }{}x;
                  $TESTACTIONS{$testActionDataValue} = $testAction if $testActionDataValue !~ m{\A nothing \z}ix ;
                  [@item] ;
                } 

        action: action_comment action_element(s) 

        resource_comment:   m{\s*'[^']*'[^']*['']\s*}
        resource_name:      m{\w++}sx
        resource_name_string: m{"\w++"}sx
        resource_element:   /resources\.ApplyResources\(/ resource_name /,/ resource_name_string /\)/ 

        # reject this parse if it doesn't apply to some testaction resource.
        # relies on us being able to parse the test name first !!!!!!!
        # if we don't do this then the test condition resource can get mixed up with it
        # leading to early parse condition 2 termination
        # at fault is the optionality of resource_condition below.
        # viz resource_condition(s?)
        #
        # BUT ** If a condition has the same name as a test ( ie like the prefix of a test action, 
        # the check to determine resource or test condition fails.  
        # We've strengthened it, but it might not ultimately be fixable.  
        # A better way may be to check the final element of $item[2][1]
        # to see if it is TestAction/PretestAction/PostTestaction, AFAIK
        # this can't be meddled with by the user.  However somefool might name a test or
        # condition TestAction etc, so it still isn't fool-proof in isolation.
        
                { my $x = $item[2][1] ;
                 $x =~ s/[_][^_]*$// ;
#VSGDR::UnitTest::TestSet::Dump(@item) ;                 
#VSGDR::UnitTest::TestSet::Dump($x) ;                 
                 if ( exists($testConditions{$x}) && ! exists($globals{TESTS}{$x})) {
                    undef ;                
                 }
                 else {
                      $resources{$item[2][1]}=1;
                  [@item] ;
                   } 
                }
                
        resource_condition: resource_name /\.Conditions\.Add\(/ condition_name /\)/ 
                    { push (@{$resources{CONDITIONS}{$item[1][1]}},$item[3][1]);
                      [@item] ;
                    } 
        resource: resource_comment resource_condition(s?) resource_element

               };
               
               
sub _init {

    local $_ = undef ;

    my $self                = shift ;
    my $class               = ref($self) || $self ;
    my $ref                 = shift or croak "no arg";

    my $parser1             = new Parse::RecDescent($grammar_pass1);
    my $parser2             = new Parse::RecDescent($grammar_pass2);
    $self->{PARSER1}        = $parser1 ;
    $self->{PARSER2}        = $parser2 ;
#    $self->{PARSER} = \&VSGDR::UnitTest::TestSet::Representation::NET::VB ;

    return ;
    
}

sub representationType {
    local $_    = undef;
    my $self    = shift or croak 'no self';
    return 'VB' ;
}


# ** ########################################################################################

sub trim {
    local $_    = undef;
    my $self    = shift or croak 'no self';
    my $code    = shift or croak 'no code' ;
#
#    $code =~ s/\A.*?Public Class/Public Class/ms;
    $code =~ s{" \s? & \s _\s*"}{}msgx;                       # join split strings
    $code =~ s{resources\.GetString\(("[^""]*?")\)}{$1}msgx;  # strip out usage of resources.GetString() and just keep the string

#    $code =~ s{  Dim\s+[\w]+\s+As\s+                         # strip out variable declarations that we aren't interested in
#                                     (?:
#                                       (?: Microsoft\.Data\.Schema\.UnitTesting\.DatabaseTestAction)
#                                     | (?: System\.ComponentModel\.ComponentResourceManager\s+=\s+New\s+System\.ComponentModel\.ComponentResourceManager\(GetType\([\w]+\)\))
#                                     )
#              }{}msgx  ;

#    $code =~ s{Microsoft\.Data\.Schema\.UnitTesting\.Conditions}
#              {MS\.D\.S\.UT\.C}msgx;  # shorten file

                                 
#    $code =~ s/End\sSub\s+#End\sRegion\s+#Region\s"Additional\stest\sattributes".*\z//ms;
#warn Dumper $code ;
    return $code ;
}

# ** ########################################################################################

## -- ** ---


sub declareVariable {
    local $_                    = undef;
    my $self                    = shift or croak 'no self' ;
    my $type                    = shift or croak 'no type' ; # $condition->conditionName()
    my $var                     = shift or croak 'no var' ; # $condition->conditionName()
    my $res = "" ;
    $res .=  "Dim " . $var . " As " . $type ;   
    return $res;
}

sub declareAndCreateVariable {
    local $_                    = undef;
    my $self                    = shift or croak 'no self' ;
    my $type                    = shift or croak 'no type' ; 
    my $var                     = shift or croak 'no var' ; 
    my $constructor             = shift or croak 'no $constructor' ; 
    my $res = "" ;
    $res .=  "Dim" . " " . $var . " As " . $type . " = " . $self->newKeyWord() . " " . $constructor ;
    return $res;
}





# ** ####################################################################

sub icHeader {

    local $_ = undef;
    my $self        = shift or croak 'no self' ;

return <<"EOF";

#Region "Designer support code"

    'NOTE: The following procedure is required by the Designer
    'It can be modified using the Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
EOF
#'
}


sub icFooter {

    local $_ = undef;
    my $self        = shift or croak 'no self' ;

return <<"EOF";

    End Sub

#End Region

EOF
}



sub Tests {

    local $_ = undef ;

    my $self        = shift or croak 'no self' ;
    my $ra_tests    = shift or croak 'no tests' ;
    my @tests       = @$ra_tests ;

    my $p1 = '    ';
    my $p2 = '        ';
    my $p3 = '            ';
    my $res = "" ;

    foreach my $test ( @tests) {
    
        $res .= "${p1}<TestMethod()> _\n";
        $res .= "${p1}Public Sub ".$test->testName()."()\n";
        $res .= "${p2}Dim testActions As DatabaseTestActions = Me.".$test->testActionDataName()."\n";

        $res .= $self->Lang_testsection('pre-test','PretestAction','pretestResults','Executing pre-test script...','PrivilegedContext') ;
        $res .= $self->Lang_testsection('test','TestAction','testResults','Executing test script...','ExecutionContext') ;
        $res .= $self->Lang_testsection('post-test','PosttestAction','posttestResults','Executing post-test script...','PrivilegedContext') ;

        $res .= "${p1}End Sub\n";
        $res .= "\n";
        
    }

    return $res;
}


sub Lang_testsection {

    local $_    = undef ;
    
    my $self    = shift or croak 'no self' ;
    my $arg1    = shift or croak 'no comment';
    my $arg2    = shift or croak 'no method';
    my $arg3    = shift or croak 'no results';
    my $arg4    = shift or croak 'no text';
    my $arg5    = shift or croak 'no context';

    my $p1 = '    ';
    my $p2 = '        ';
    my $p3 = '            ';
    my $res     = "" ;

#print Dumper ${arg2} ;

    $res .= "${p2}'Execute the ${arg1} script\n";
    $res .= "${p2}'\n";

    $res .= "${p2}System.Diagnostics.Trace.WriteLineIf((Not (testActions.".${arg2}.") Is Nothing), \"${arg4}\")\n";
    $res .= "${p2}Dim ".${arg3}."() As ExecutionResult = TestService.Execute(Me.".${arg5}.", Me.PrivilegedContext, testActions.".${arg2}.")\n";

    return $res ;

}

# ** ######################################################################################


sub Header {

    local $_        = undef ;
    my $self        = shift or croak 'no self' ;
    my $namespace   = shift or croak "No namespace supplied" ;
    my $class       = shift or croak "No Class" ;


return <<"EOF";
Imports System
Imports System.Text
Imports System.Collections.Generic
Imports Microsoft.VisualStudio.TestTools.UnitTesting
Imports Microsoft.Data.Schema.UnitTesting
Imports Microsoft.Data.Schema.UnitTesting.Conditions


<TestClass()> _
Public Class ${class}
    Inherits DatabaseTestClass

    Sub New()
        InitializeComponent()
    End Sub

    <TestInitialize()> _
    Public Sub TestInitialize()
        InitializeTest()
    End Sub

    <TestCleanup()> _
    Public Sub TestCleanup()
        CleanupTest()
    End Sub

EOF

}


sub Footer {

    local $_        = undef ;
    my $self        = shift or croak 'no self' ;
    my $ra_tests    = shift or croak 'no tests' ;
    my @tests       = @$ra_tests ;

    my $p1 = '    ';
    my $p2 = '        ';
    my $res = "" ;
              
    foreach my $test (@tests) {
        $res .= "${p2}Private " . $test->testActionDataName() . " As DatabaseTestActions()\n";
    }

return <<"EOF";

#Region "Additional test attributes"
    '
    ' You can use the following additional attributes as you write your tests:
    '
    ' Use ClassInitialize to run code before running the first test in the class
    ' <ClassInitialize()> Public Shared Sub MyClassInitialize(ByVal testContext As TestContext)
    ' End Sub
    '
    ' Use ClassCleanup to run code after all tests in a class have run
    ' <ClassCleanup()> Public Shared Sub MyClassCleanup()
    ' End Sub
    '
#End Region

${res}
End Class

EOF
#'

}


sub typeExtractor {
    my $self        = shift or croak 'no self' ;
    return "GetType"
}

sub newKeyWord {
    my $self        = shift or croak 'no self' ;
    return "New" ;
}
sub selfKeyWord {
    my $self        = shift or croak 'no self' ;
    return "Me" ;
}
sub functionOpenDelimiter {
    my $self        = shift or croak 'no self' ;
    return "" ;
}
sub functionCloseDelimiter {
    my $self        = shift or croak 'no self' ;
    return "" ;
}

sub functionDelimiters {
    my $self        = shift or croak 'no self' ;
    return "" ;
}
sub lineTerminator {
    my $self        = shift or croak 'no self' ;
    return "" ;
}

sub quoteChars {
    my $self        = shift or croak 'no self' ;
    return "'" ;
}
sub true {
    my $self        = shift or croak 'no self' ;
    return 'True' ;
}
sub false {
    my $self        = shift or croak 'no self' ;
    return 'False' ;
}
sub null {
    my $self        = shift or croak 'no self' ;
    return 'Nothing' ;
}

sub convertKeyWord {
    my $self        = shift or croak 'no self' ;
    my $KW          = shift ;
    croak 'No key word' if not defined ($KW) ; 
    
    return 'True' if $KW =~ m{^true$}ix ;
    return 'False' if $KW =~ m{^false$}ix ;
    return 'Nothing' if $KW =~ m{^(?:"nothing"|nothing|null)$}ix ;
    return $KW ; # otherwise
    
}


sub start {

#warn Dumper @_ ;
### Start
    my $self        = shift or croak 'no self' ;
    my $code        = shift ; 
    croak 'no code' if ! defined $code ;

    my %testConditions   = () ; 
    my %testConditions_2 = () ; 
    my %resources = () ; 
    keys %resources        = 8192 ;
    $resources{CONDITIONS} = {} ;
    keys %{$resources{CONDITIONS}} = 8192 ;

    my %actions = () ; 
    my %globals = () ; 

    keys %testConditions   = 8192 ;
    keys %testConditions_2 = 8192 ;



    $code =~ s{(?>\A.*? (?=Public \s Class) )}{}sx ;
    my $class_name;
    
### ClassName    
    $class_name = $1 if $code =~ m{Public \s Class \s+ (\w++)}sx ;
    { $globals{CLASSNAME} = $class_name; $globals{NAMESPACE} = $globals{CLASSNAME} ; $globals{CLEANUPACTION} = 'testCleanupAction'; $globals{INITIALIZEACTION} = 'testInitializeAction' ; }

    $code =~ s{(:? .*? (?=\<TestMethod \(\) \> \s*_))}{}sx ;

### Strip Methods
    while ( $code =~ m{ \<TestMethod \(\) \> \s* _ \s+ Public \s+ Sub \s+ (?<testmethodname>\w+) \s* \(\) \s*
                        Dim \s testActions \s As \s DatabaseTestActions \s = \s Me \. (?<testdata_name>\w+) 

                        .*? (?= (?: (?: \<TestMethod \(\) \> \s* _ ) 
                                |   (?: \#Region \s "Designer \s support \s code" ) 
                                ) 
                            ) 

                      }gcsmx
          ) {
            $globals{TESTS}{$+{testmethodname}}{NAME} = $+{testmethodname} ;
            $globals{TESTS}{$+{testmethodname}}{ACTION} = $+{testdata_name} ;
    }

### Builder

    $code =~ s{(?> .*?  (?:Private \s+ Sub \s+ InitializeComponent\(\) \s+ ) )}{}sx ;

    my ($part1,$part2) = ( $1,$2 ) if $code =~ m{ ( .*? )  (?= \s* ['']) (.*)  }smx ;

    while ( $part1 =~ 
        m{   Dim \s (?<condition_name>\w++) \s As \s Microsoft\.Data\.Schema\.UnitTesting\.Conditions\. (?<condition_type>\w++) \s*
          }xmsgc 
        ) 
    { $testConditions{$+{condition_name}}    = $+{condition_type};
    }                     

### Builder 2

    my $found = 1 ;
    while ( $found ) 
        { 
        if ( $part2 =~ m{ \G       
                         (?: 
                         (?<conditionname>\w++) 
                         \. (?<conditiontype>\w++) \s = \s 
                                                     (?<conditionvalue> (?: " .*? " )
                                                                        | (?: System\.TimeSpan\.Parse\( "[\d:]++" \) )
                                                                        | (?: \w++ )
                                                     ) 

                         )      ## test condition
                          \s*+  
                        }gcmsx ) 
            
            {   $testConditions_2{$+{conditionname}}{$+{conditiontype}} = $+{conditionvalue} ;
            }
        elsif ( $part2 =~ m{ \G
                             (?<commentblock> \s*+ '[^']*+ \s*+ '[^']*+ \s*+ ['']\s*+ )
                              \s*+  
#warn "@\n";
#warn $part2 ;
#die;

              }gcmsx ) {}
        elsif ( $part2 =~ m{ \G    
             (?:
             (?<testname2>\w++) 
             \.Conditions\.Add\(  (?<conditionname2>\w++) \)
             )      ## adding test condition to test action
              \s*+  
              }gcmsx ) 
            {   unshift (@{$resources{CONDITIONS}{$+{testname2}}},$+{conditionname2}) ;
            }
        elsif ( $part2 =~ m{ \G
                     Me \. (?<testname>\w++) 
                     \. (?<testactiontype>(?:TestAction|PosttestAction|PretestAction)) \s = \s (?<testaction>\w++)
                      \s*+  
              }gcmsx ) 
            {   $actions{$+{testname}}{$+{testactiontype}} = $+{testaction} ;
            }
        elsif ( $part2 =~ m{ \G
             (?:     
             resources\.ApplyResources\( (?<resourcetestaction>\w++)  
             , \s (?<quotedresourcetestaction>"\w++") \)
             )      ## end of build-up of test action resources
                      \s*+  
              }gcmsx ) 
            {   unshift (@{$resources{$+{resourcetestaction}}},$+{quotedresourcetestaction}) ;
            }
        elsif ( $part2 =~ m{ \G
             (?:  
             (?<endsub> End \s Sub )
             )
              }gcmsx ) 
            { $found =0 ; last } 

         else {
warn "UNMATCHED CODE!\n";
my $first = substr($part2,0,100);
warn $first ;
die;
        }
    }
    return { GLOBALS => \%globals, RESOURCES => \%resources, ACTIONS => \%actions, TESTCONDITIONS => \%testConditions, TESTCONDITIONS_DETAILS => \%testConditions_2 } ;
                                                           
                    
};



1;

__DATA__





<ROOT>
    <SECTIONS>
    

        <SECTION Name="TestClass">
    Sub New()
        InitializeComponent()
    End Sub
        </SECTION>
    

        <SECTION Name="TestInitialize">
    <TestInitialize()> _
    Public Sub TestInitialize()
        InitializeTest()
    End Sub
        </SECTION>

        <SECTION Name="TestCleanup">
    <TestCleanup()> _
    Public Sub TestCleanup()
        CleanupTest()
    End Sub
        </SECTION>
    
    
    
        <SECTION Name="TestMethod">
    <TestMethod()> _
    Public Sub <@MethodName@>()
        Dim testActions As DatabaseTestActions = Me.<@MethodName@>Data
        'Execute the pre-test script
        '
        System.Diagnostics.Trace.WriteLineIf((Not (testActions.PretestAction) Is Nothing), "Executing pre-test script...")
        Dim pretestResults() As ExecutionResult = TestService.Execute(Me.PrivilegedContext, Me.PrivilegedContext, testActions.PretestAction)
        'Execute the test script
        '
        System.Diagnostics.Trace.WriteLineIf((Not (testActions.TestAction) Is Nothing), "Executing test script...")
        Dim testResults() As ExecutionResult = TestService.Execute(Me.ExecutionContext, Me.PrivilegedContext, testActions.TestAction)
        'Execute the post-test script
        '
        System.Diagnostics.Trace.WriteLineIf((Not (testActions.PosttestAction) Is Nothing), "Executing post-test script...")
        Dim posttestResults() As ExecutionResult = TestService.Execute(Me.PrivilegedContext, Me.PrivilegedContext, testActions.PosttestAction)
    End Sub
        </SECTION>

        <SECTION Name="Additional test attributes">
#Region "Additional test attributes"
    '
    ' You can use the following additional attributes as you write your tests:
    '
    ' Use ClassInitialize to run code before running the first test in the class
    ' <ClassInitialize()> Public Shared Sub MyClassInitialize(ByVal testContext As TestContext)
    ' End Sub
    '
    ' Use ClassCleanup to run code after all tests in a class have run
    ' <ClassCleanup()> Public Shared Sub MyClassCleanup()
    ' End Sub
    '
#End Region
        </SECTION>
        
    </SECTIONS>
</ROOT>


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

    perldoc VSGDR::UnitTest::TestSet::Representation::NET::VB


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

1; # End of VSGDR::UnitTest::TestSet::Representation::NET::VB
