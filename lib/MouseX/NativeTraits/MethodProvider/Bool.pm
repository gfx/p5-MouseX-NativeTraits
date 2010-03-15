package MouseX::NativeTraits::MethodProvider::Bool;
use Mouse;

extends qw(MouseX::NativeTraits::MethodProvider);

sub generate_set {
    my($self) = @_;
    my $writer     = $self->writer;
    return sub { $writer->( $_[0], 1 ) };
}

sub generate_unset {
    my($self) = @_;
    my $writer     = $self->writer;
    return sub { $writer->( $_[0], 0 ) };
}

sub generate_toggle {
    my($self) = @_;
    my $reader     = $self->reader;
    my $writer     = $self->writer;

    return sub { $writer->( $_[0], !$reader->( $_[0] ) ) };
}

sub generate_not {
    my($self) = @_;
    my $reader     = $self->reader;
    return sub { !$reader->( $_[0] ) };
}

no Mouse;
__PACKAGE__->meta->make_immutable();

__END__

=head1 NAME

MouseX::NativeTraits::MethodProvider::Bool - Provides methods for Bool

=head1 DESCRIPTION

This class provides method generators for the C<Bool> trait.
See L<Mouse::Meta::Attribute::Custom::Trait::Bool> for details.

=head1 METHOD GENERATORS

=over 4

=item generate_set

=item generate_unset

=item generate_toggle

=item generate_not

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>

=cut
