package VSGDR::SQLServer::DataType::Bit ;

use Modern::Perl;

use VSGDR::SQLServer::DataType ;
use Data::Dumper ;
use Carp ;

use parent qw(VSGDR::SQLServer::DataType);

our $VERSION    = "1.00";

sub getValue {
    local $_ ;
    my $self                = shift ;
    return                  ( ! defined($self->{VALUE})         ? undef
                            : $self->{VALUE} == 1               ? 'true' 
                            : $self->{VALUE} == 0               ? 'false' 
                            : $self->{VALUE} =~ /\Atrue\z/i     ? 'true' 
                            : $self->{VALUE} =~ /\Afalse\z/i    ? 'false' 
                            : $self->{VALUE} =~ /\A\s*\z/i      ? 'false' 
                            : 'true'
                            ) ;
}


1 ;

__DATA__


