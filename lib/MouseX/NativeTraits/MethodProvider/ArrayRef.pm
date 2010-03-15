package MouseX::NativeTraits::MethodProvider::ArrayRef;
use Mouse;

use List::Util;

extends qw(MouseX::NativeTraits::MethodProvider);

sub generate_count {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        return scalar @{ $reader->( $_[0] ) };
    };
}

sub generate_is_empty {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        return scalar(@{ $reader->( $_[0] ) }) == 0;
    };
}

sub generate_first {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $predicate ) = @_;
        return List::Util::first(\&{$predicate}, @{ $reader->($instance) });
    };
}

sub generate_any {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $predicate ) = @_;
        foreach (@{ $reader->($instance) }){
            if($predicate->($_)){
                return 1;
            }
        }
        return 0;
    };
}

sub generate_apply {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $block ) = @_;
        my @values = @{ $reader->($instance) };
        foreach (@values){
            $block->();
        }
        return @values;
    };
}

sub generate_map {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $block ) = @_;
        return map { $block->() } @{ $reader->($instance) };
    };
}

sub generate_reduce {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $block ) = @_;
        our ($a, $b);
        return List::Util::reduce { $block->($a, $b) } @{ $reader->($instance) };
    };
}

sub generate_sort {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $compare ) = @_;

        if ($compare) {
            return sort { $compare->( $a, $b ) } @{ $reader->($instance) };
        }
        else {
            return sort @{ $reader->($instance) };
        }
    };
}

sub generate_sort_in_place {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        my ( $instance, $compare ) = @_;

        my $array_ref = $reader->($instance);

        if($compare){
            @{$array_ref} = sort { $compare->($a, $b) } @{$array_ref};
        }
        else{
            @{$array_ref} = sort @{$array_ref};
        }

        return $instance;
    };
}


# The sort_by algorithm comes from perlfunc/sort
# See also perldoc -f sort and perldoc -q sort

sub generate_sort_by {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $block, $compare ) = @_;

        my $array_ref = $reader->($instance);
        my @idx;
        foreach (@{$array_ref}){ # intentinal use of $_
            push @idx, scalar $block->($_);
        }

        # NOTE: scalar(@idx)-1 is faster than $#idx
        if($compare){
            return @{ $array_ref }[
                sort { $compare->($idx[$a], $idx[$b]) }
                    0 .. scalar(@idx)-1
            ];
        }
        else{
            return @{ $array_ref }[
                sort { $idx[$a] cmp $idx[$b] }
                    0 .. scalar(@idx)-1
            ];
        }
    };
}


sub generate_sort_in_place_by {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        my ( $instance, $block, $compare ) = @_;

        my $array_ref = $reader->($instance);
        my @idx;
        foreach (@{$array_ref}){
            push @idx, scalar $block->($_);
        }

        if($compare){
            @{ $array_ref } = @{ $array_ref }[
                sort { $compare->($idx[$a], $idx[$b]) }
                    0 .. scalar(@idx)-1
            ];
        }
        else{
            @{ $array_ref } = @{ $array_ref }[
                sort { $idx[$a] cmp $idx[$b] }
                    0 .. scalar(@idx)-1
            ];
        }
        return $instance;
    };
}


sub generate_shuffle {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance ) = @_;
        return List::Util::shuffle @{ $reader->($instance) };
    };
}

sub generate_grep {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $predicate ) = @_;
        return grep { $predicate->() } @{ $reader->($instance) };
    };
}

sub generate_uniq {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance ) = @_;
        my %seen;
        my $seen_undef;
        return  grep{ (defined($_) ? ++$seen{$_} : ++$seen_undef) == 1 } @{ $reader->($instance) };
    };
}

sub generate_elements {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ($instance) = @_;
        return @{ $reader->($instance) };
    };
}

sub generate_join {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        my ( $instance, $separator ) = @_;
        return join $separator, @{ $reader->($instance) };
    };
}

sub generate_push {
    my($self) = @_;
    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ( $constraint->__is_parameterized ){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my $instance = shift;
            foreach my $value(@_){
                $container_type_constraint->assert_valid($value)
            }
            push @{ $reader->($instance) }, @_;
            return $instance;
        };
    }
    else {
        return sub {
            my $instance = shift;
            push @{ $reader->($instance) }, @_;
            return $instance;
        };
    }
}

sub generate_pop {
    my($self) = @_;
    my $reader = $self->reader;
    return sub {
        return pop @{ $reader->( $_[0] ) };
    };
}

sub generate_unshift {
    my($self) = @_;
    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ( $constraint->__is_parameterized ){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my $instance = shift;
            foreach my $value(@_){
                $container_type_constraint->assert_valid($value)
            }
            unshift @{ $reader->($instance) }, @_;
            return $instance;
        };
    }
    else {
        return sub {
            my $instance = shift;
            unshift @{ $reader->($instance) }, @_;
            return $instance;
        };
    }
}

sub generate_shift {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        return shift @{ $reader->( $_[0] ) };
    };
}

__PACKAGE__->meta->add_method(generate_get => \&generate_fetch); # alias
sub generate_fetch {
    my($self, $handle_name) = @_;
    my $reader = $self->reader;

    return sub {
        return $reader->( $_[0] )->[ $_[1] ];
    };
}

__PACKAGE__->meta->add_method(generate_set => \&generate_store); # alias
sub generate_store {
    my($self) = @_;
    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ( $constraint->__is_parameterized ){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            $container_type_constraint->assert_valid( $_[2] );
            $reader->( $_[0] )->[ $_[1] ] = $_[2];
        };
    }
    else {
        return sub {
            $reader->( $_[0] )->[ $_[1] ] = $_[2];
        };
    }
}

sub generate_accessor {
    my($self) = @_;
    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ( $constraint->__is_parameterized ){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my $instance = shift;

            if ( @_ == 1 ) {    # reader
                return $reader->($instance)->[ $_[0] ];
            }
            elsif ( @_ == 2 ) {    # writer
                $container_type_constraint->assert_valid( $_[1] );
                $reader->($instance)->[ $_[0] ] = $_[1];
            }
            else {
                confess "One or two arguments expected, not " . @_;
            }
        };
    }
    else {
        return sub {
            my $instance = shift;

            if ( @_ == 1 ) {    # reader
                return $reader->($instance)->[ $_[0] ];
            }
            elsif ( @_ == 2 ) {    # writer
                $reader->($instance)->[ $_[0] ] = $_[1];
                return $instance;
            }
            else {
                confess "One or two arguments expected, not " . @_;
            }
        };
    }
}

sub generate_clear {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        @{ $reader->( $_[0] ) } = ();
        return $_[0];
    };
}

__PACKAGE__->meta->add_method(generate_delete => \&generate_remove); # alias
sub generate_remove {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        return splice @{ $reader->( $_[0] ) }, $_[1], 1;
    };
}

sub generate_insert {
    my($self) = @_;
    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ( $constraint->__is_parameterized ){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my($instance, $index, $value) = @_;
            $container_type_constraint->assert_valid( $value );
            splice @{ $reader->( $instance ) }, $index, 0, $value;
            return $instance;
        };
    }
    else {
        return sub {
            my($instance, $index, $value) = @_;
            splice @{ $reader->( $instance ) }, $index, 0, $value;
            return $instance;
        };
    }
}

sub generate_splice {
    my($self) = @_;
    my $reader     = $self->reader;
    my $constraint = $self->attr->type_constraint;

    if ( $constraint->__is_parameterized ){
        my $container_type_constraint = $constraint->type_parameter;
        return sub {
            my ( $self, $i, $j, @elems ) = @_;

            foreach my $value(@elems){
                $container_type_constraint->assert_valid($value);
            }
            return splice @{ $reader->($self) }, $i, $j, @elems;
        };
    }
    else {
        return sub {
            my ( $self, $i, $j, @elems ) = @_;
            return splice @{ $reader->($self) }, $i, $j, @elems;
        };
    }
}

sub generate_for_each {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        my ( $instance, $block ) = @_;

        foreach my $element(@{ $reader->instance($instance) }){
            $block->($element);
        }
        return $instance;
    };
}

sub generate_for_each_pair {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        my ( $instance, $block ) = @_;

        my $array_ref = $reader->($instance);
        for(my $i = 0; $i < @{$array_ref}; $i += 2){
            $block->($array_ref->[$i], $array_ref->[$i + 1]);
        }
        return $instance;
    };
}

no Mouse;
__PACKAGE__->meta->make_immutable();

__END__

=head1 NAME

MouseX::NativeTraits::MethodProvider::ArrayRef - Provides methods for ArrayRef

=head1 DESCRIPTION

This class provides method generators for the C<Array> trait.
See L<Mouse::Meta::Attribute::Custom::Trait::Array> for details.

=head1 METHOD GENERATORS

=over 4

=item generate_count

=item generate_is_empty

=item generate_first

=item generate_any

=item generate_apply

=item generate_map

=item generate_reduce

=item generate_sort

=item generate_sort_in_place

=item generate_sort_by

=item generate_sort_in_place_by

=item generate_shuffle

=item generate_grep

=item generate_uniq

=item generate_elements

=item generate_join

=item generate_push

=item generate_pop

=item generate_unshift

=item generate_shift

=item generate_fetch

=item generate_get

The same as C<generate_fetch>

=item generate_store

=item generate_set

The same as C<generate_store>

=item generate_accessor

=item generate_clear

=item generate_remove

=item generate_delete

The same as C<generate_remove>. Note that it is different from C<CORE::delete>.

=item generate_insert

=item generate_splice

=item generate_for_each

=item generate_for_each_pair

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>

=cut
