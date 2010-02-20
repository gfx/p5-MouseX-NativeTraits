package MouseX::NativeTraits::MethodProvider::Counter;
use Mouse;

extends qw(MouseX::NativeTraits::MethodProvider);

sub generate_reset {
    my($self)   = @_;
    my $attr    = $self->attr;
    my $writer  = $self->writer;
    my $builder;
    my $default;

    if($attr->has_builder){
        $builder = $attr->builder;
    }
    else {
        $default = $attr->default;
        if(ref $default){
            $builder = $default;
        }
    }

    if(ref $builder){
        return sub {
            my($instance) = @_;
            $writer->($instance, $instance->$builder());
        };
    }
    else{
        return sub {
            my($instance) = @_;
            $writer->($instance, $default);
        };
    }
}

sub generate_set{
    my($self)  = @_;
    my $writer = $self->writer;
    return sub { $writer->( $_[0], $_[1] ) };
}

sub generate_inc {
    my($self) = @_;

    my $reader     = $self->reader;
    my $writer     = $self->writer;
    my $constraint = $self->attr->type_constraint;

    return sub {
        my($instance, $value) = @_;
        if(@_ > 1){
            $constraint->assert_valid($value);
        }
        else{
            $value = 1;
        }
        $writer->($instance, $reader->($instance) + $value);
    };
}

sub generate_dec {
    my($self) = @_;

    my $reader     = $self->reader;
    my $writer     = $self->writer;
    my $constraint = $self->attr->type_constraint;

    return sub {
        my($instance, $value) = @_;
        if(@_ > 1){
            $constraint->assert_valid($value);
        }
        else{
            $value = 1;
        }
        $writer->($instance, $reader->($instance) - $value);
    };
}

no Mouse;
__PACKAGE__->meta->make_immutable(strict_constructor => 1);

__END__

=head1 NAME

MouseX::NativeTraits::MethodProvider::Counter - Provides methods for Counter

=head1 DESCRIPTION

This class provides method generators for the C<Counter> trait.
See L<Mouse::Meta::Attribute::Custom::Trait::Counter> for details.

=head1 METHOD GENERATORS

=over 4

=item generate_reset

=item generate_set

=item generate_inc

=item generate_dec

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>

=cut
