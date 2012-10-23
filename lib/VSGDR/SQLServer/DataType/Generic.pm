package VSGDR::SQLServer::DataType::Generic ;

=head1 NAME

VSGDR::SQLServer::DataType::Generic - Sealed class for Microsoft Visual Studio Database Edition UnitTest Utility Suite by Ded MedVed

=head1 VERSION

Version 1.00

=cut

our $VERSION    = "1.00";

use parent qw(VSGDR::SQLServer::DataType);


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

    perldoc VSGDR::SQLServer::DataType::Generic


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

1; # End of VSGDR::SQLServer::DataType::Generic



