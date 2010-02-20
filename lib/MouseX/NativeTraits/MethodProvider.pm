package MouseX::NativeTraits::MethodProvider;
use Mouse;

our $VERSION = '0.001';

has attr => (
    is       => 'ro',
    isa      => 'Object',
    required => 1,
    weak_ref => 1,
);

has reader => (
    is => 'ro',

    lazy_build => 1,
);

has writer => (
    is => 'ro',

    lazy_build => 1,
);

sub _build_reader {
    my($self) = @_;
    return $self->attr->get_read_method_ref;
}

sub _build_writer {
    my($self) = @_;
    return $self->attr->get_write_method_ref;
}

sub has_generator {
    my($self, $name) = @_;
    return $self->meta->has_method("generate_$name");
}

sub generate {
    my($self, $handle_name, $method_to_call) = @_;

    my @curried_args;
    ($method_to_call, @curried_args) = @{$method_to_call};

    my $code = $self->meta
        ->get_method_body("generate_$method_to_call")->($self);

    if(@curried_args){
        return sub {
            my $instance = shift;
            $code->($instance, @curried_args, @_);
        };
    }
    else{
        return $code;
    }
}

sub get_generators {
    my($self) = @_;

    return grep{ s/\A generate_ //xms } $self->meta->get_method_list;
}

no Mouse;
__PACKAGE__->meta->make_immutable(strict_constructor => 1);
__END__
