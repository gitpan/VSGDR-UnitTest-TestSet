package VSGDR::SQLServer::DataType::Generic ;

use Modern::Perl;
use parent qw(VSGDR::SQLServer::DataType);


our $VERSION    = "1.00";

sub getValue {
    local $_ ;
    my $self                = shift ;
    return                  $self->{VALUE} ;
}

sub quoteValue {
    local $_ ;
    my $self                = shift ;
    my $value               = shift ;
    $value =~ s{"}{\\"}gms; #" -- kill Textpad highlighting
    return                  $value ;
}

sub unQuoteValue {
    local $_ ;
    my $self                = shift ;
    my $value               = shift ;
    $value =~ s{\\"}{"}gms; #" -- kill Textpad highlighting
    return                  $value ;
}

1 ;

__DATA__

