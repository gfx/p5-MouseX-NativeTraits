package MouseX::NativeTraits::MethodProvider::Str;
use Mouse;

extends qw(MouseX::NativeTraits::MethodProvider);

sub generate_append {
    my($self) = @_;
    my $reader     = $self->reader;
    my $writer     = $self->writer;

    return sub {
        my($instance, $value) = @_;
        $writer->( $instance, $reader->( $instance ) . $value );
    };
}

sub generate_prepend {
    my($self) = @_;
    my $reader     = $self->reader;
    my $writer     = $self->writer;

    return sub {
        my($instance, $value) = @_;
        $writer->( $instance, $value . $reader->( $instance ) );
    };
}

sub generate_replace {
    my($self) = @_;
    my $reader     = $self->reader;
    my $writer     = $self->writer;

    return sub {
        my( $instance, $regexp, $replacement ) = @_;
        my $v = $reader->( $instance );

        if ( ref($replacement) eq 'CODE' ) {
            $v =~ s/$regexp/$replacement->()/e;
        }
        else {
            $v =~ s/$regexp/$replacement/;
        }

        $writer->( $instance, $v );
    };
}

sub generate_replace_globally {
    my($self) = @_;
    my $reader = $self->reader;
    my $writer = $self->writer;

    return sub {
        my( $instance, $regexp, $replacement ) = @_;
        my $v = $reader->( $instance );

        if ( ref($replacement) eq 'CODE' ) {
            $v =~ s/$regexp/$replacement->()/eg;
        }
        else {
            $v =~ s/$regexp/$replacement/g;
        }

        $writer->( $instance, $v );
    };
}

sub generate_match {
    my($self) = @_;
    my $reader = $self->reader;

    return sub { $reader->( $_[0] ) =~ $_[1] };
}

sub generate_chop {
    my($self) = @_;
    my $reader = $self->reader;
    my $writer = $self->writer;

    return sub {
        my($instance) = @_;
        my $v = $reader->( $instance );
        chop($v);
        $writer->( $instance, $v );
    };
}

sub generate_chomp {
    my($self) = @_;
    my $reader = $self->reader;
    my $writer = $self->writer;

    return sub {
        my($instance) = @_;
        my $v = $reader->( $instance );
        chomp($v);
        $writer->( $instance, $v );
    };
}

sub generate_inc {
    my($self) = @_;
    my $reader = $self->reader;
    my $writer = $self->writer;

    return sub {
        my($instance) = @_;
        my $v = $reader->( $instance );
        $v++;
        $writer->( $instance, $v );
    };
}

sub generate_clear {
    my($self) = @_;
    my $writer = $self->writer;

    return sub {
        my($instance) = @_;
        $writer->( $instance, '' );
    };
}

sub generate_length {
    my($self) = @_;
    my $reader = $self->reader;

    return sub {
        return length( $reader->($_[0]) );
    };
}

sub generate_substr {
    my($self) = @_;
    my $reader = $self->reader;
    my $writer = $self->writer;

    return sub {
        my($instance, $offset, $length, $replacement) = @_;

        my $v = $reader->($instance);

        $offset = 0          if !defined $offset;
        $length = length($v) if !defined $length;

        my $ret;
        if ( defined $replacement ) {
            $ret = substr( $v, $offset, $length, $replacement );
            $writer->( $self, $v );
        }
        else {
            $ret = substr( $v, $offset, $length );
        }

        return $ret;
    };
}

no Mouse;
__PACKAGE__->meta->make_immutable(strict_constructor => 1);

__END__

=head1 NAME

MouseX::NativeTraits::MethodProvider::Str - Provides methods for Str

=head1 DESCRIPTION

This class provides method generators for the C<String> trait.
See L<Mouse::Meta::Attribute::Custom::Trait::String> for details.

=head1 METHOD GENERATORS

=over 4

=item generate_append

=item generate_prepend

=item generate_replace

=item generate_replace_globally

=item generate_match

=item generate_chop

=item generate_chomp

=item generate_inc

=item generate_clear

=item generate_length

=item generate_substr

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>.

=cut

