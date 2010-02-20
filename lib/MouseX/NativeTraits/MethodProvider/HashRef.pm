package MouseX::NativeTraits::MethodProvider::HashRef;
use Mouse;

extends qw(MouseX::NativeTraits::MethodProvider);

sub generate_keys {
    my($self) = @_;
    my $reader = $self->reader;

    return sub { return keys %{ $reader->( $_[0] ) } };
}

sub generate_sorted_keys {
    my($self) = @_;
    my $reader = $self->reader;

    return sub { return sort keys %{ $reader->( $_[0] ) } };
}

sub generate_values {
    my($self) = @_;
    my $reader = $self->reader;

    return sub { return values %{ $reader->( $_[0] ) } };
}

sub generate_kv {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        my($instance) = @_;
        my $hash_ref = $reader->( $instance );
        return map { [ $_ => $hash_ref->{$_} ] } keys %{ $hash_ref };
    };
}

sub generate_elements {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        return %{ $reader->( $_[0] ) };
    };
}

sub generate_count {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        return scalar keys %{ $reader->( $_[0] ) };
    };
}

sub generate_is_empty {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        return scalar(keys %{ $reader->( $_[0] ) }) == 0;
    };
}

sub generate_exists {
    my($self) = @_;
    my $reader = $self->reader;

    return sub { return exists $reader->( $_[0] )->{ $_[1] } };
}

sub generate_defined {
    my($self) = @_;
    my $reader = $self->reader;

    return sub { return defined $reader->( $_[0] )->{ $_[1] } };
}

__PACKAGE__->meta->add_method(generate_get => \&generate_fetch);
sub generate_fetch {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        if ( @_ == 2 ) {
            return $reader->( $_[0] )->{ $_[1] };
        }
        else {
            my ( $self, @keys ) = @_;
            return @{ $reader->($self) }{@keys};
        }
    };
}


__PACKAGE__->meta->add_method(generate_set => \&generate_store);
sub generate_store {
    my($self) = @_;

    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ($constraint->__is_parameterized){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my ( $self, @kv ) = @_;

            my ( @keys, @values );

            while (my($key, $value) = splice @kv, 0, 2 ) {
                $container_type_constraint->assert_valid($value);
                push @keys,   $key;
                push @values, $value;
            }

            if ( @values > 1 ) {
                @{ $reader->($self) }{@keys} = @values;
            }
            else {
                $reader->($self)->{ $keys[0] } = $values[0];
            }
        };
    }
    else {
        return sub {
            my ( $instance, @kv ) = @_;

            my $hash_ref = $reader->($instance);

            while (my($key, $value) = splice @kv, 0, 2) {
                $hash_ref->{$key} = $value;
            }
        };
    }
}

sub generate_accessor {
    my($self) = @_;

    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ($constraint->__is_parameterized){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my $self = shift;

            if ( @_ == 1 ) {    # reader
                return $reader->($self)->{ $_[0] };
            }
            elsif ( @_ == 2 ) {    # writer
                $container_type_constraint->assert_valid( $_[1] );
                $reader->($self)->{ $_[0] } = $_[1];
            }
            else {
                confess "One or two arguments expected, not " . @_;
            }
        };
    }
    else {
        return sub {
            my $self = shift;

            if ( @_ == 1 ) {    # reader
                return $reader->($self)->{ $_[0] };
            }
            elsif ( @_ == 2 ) {    # writer
                $reader->($self)->{ $_[0] } = $_[1];
            }
            else {
                confess "One or two arguments expected, not " . @_;
            }
        };
    }
}

sub generate_clear {
    my($self) = @_;

    my $reader  = $self->reader;

    return sub { %{ $reader->( $_[0] ) } = () };
}

sub generate_delete {
    my($self) = @_;

    my $reader  = $self->reader;

    return sub {
        my $instance = shift;
        return delete @{ $reader->($instance) }{@_};
    };
}

sub generate_for_each_key {
    my($self) = @_;

    my $reader     = $self->reader;

    return sub {
        my($instance, $block) = @_;

        foreach my $key(keys %{$reader->($instance)}){
            $block->($key);
        }

        return $instance;
    };
}

sub generate_for_each_value {
    my($self) = @_;

    my $reader     = $self->reader;

    return sub {
        my($instance, $block) = @_;

        foreach my $value(values %{$reader->($instance)}){
            $block->($value);
        }

        return $instance;
    };
}

sub generate_for_each_pair {
    my($self) = @_;

    my $reader     = $self->reader;

    return sub {
        my($instance, $block) = @_;

        my $hash_ref = $reader->($instance);
        foreach my $key(keys %{$hash_ref}){
            $block->($key, $hash_ref->{$key});
        }

        return $instance;
    };
}


no Mouse;
__PACKAGE__->meta->make_immutable(strict_constructor => 1);

__END__

=head1 NAME

MouseX::NativeTraits::MethodProvider::HashRef - Provides methods for HashRef

=head1 DESCRIPTION

This class provides method generators for the C<Hash> trait.
See L<Mouse::Meta::Attribute::Custom::Trait::Hash> for details.

=head1 METHOD GENERATORS

=over 4

=item generate_keys

=item generate_sorted_keys

=item generate_values

=item generate_kv

=item generate_elements

=item generate_count

=item generate_is_empty

=item generate_exists

=item generate_defined

=item generate_fetch

=item generate_get

The same as C<generate_fetch>.

=item generate_store

=item generate_set

The same as C<generate_store>.

=item generate_accessor

=item generate_clear

=item generate_delete

=item generate_for_each_key

=item generate_for_each_value

=item generate_for_each_pair

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>

=cut
