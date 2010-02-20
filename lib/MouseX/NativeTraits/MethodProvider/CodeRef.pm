package MouseX::NativeTraits::MethodProvider::CodeRef;
use Mouse;

our $VERSION = '0.001';

extends qw(MouseX::NativeTraits::MethodProvider);

sub generate_execute {
    my($self)  = @_;
    my $reader = $self->reader;

    return sub {
        my ($self, @args) = @_;
        $reader->($self)->(@args);
    };
}

no Mouse;
__PACKAGE__->meta->make_immutable(strict_constructor => 1);

__END__

=head1 NAME

MouseX::NativeTraits::MethodProvider::CodeRef - Provides methods for CodeRef

=head1 DESCRIPTION

This class provides method generators for the C<Code> trait.
See L<Mouse::Meta::Attribute::Custom::Trait::Code> for details.

=head1 METHOD GENERATORS

=over 4

=item generate_execute

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>

=cut
