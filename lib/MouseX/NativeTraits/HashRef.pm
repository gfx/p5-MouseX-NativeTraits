package MouseX::NativeTraits::HashRef;
use Mouse::Role;

with 'MouseX::NativeTraits';

sub method_provider_class {
    return 'MouseX::NativeTraits::MethodProvider::HashRef';
}

sub helper_type {
    return 'HashRef';
}

no Mouse::Role;
1;
__END__

=head1 NAME

MouseX::NativeTraits::HashRef - Helper trait for HashRef attributes

=head1 SYNOPSIS

  package Stuff;
  use Mouse;

  has 'options' => (
      traits    => ['Hash'],
      is        => 'ro',
      isa       => 'HashRef[Str]',
      default   => sub { {} },
      handles   => {
          set_option     => 'set',
          get_option     => 'get',
          has_no_options => 'is_empty',
          num_options    => 'count',
          delete_option  => 'delete',
          pairs          => 'kv',
      },
  );

=head1 DESCRIPTION

This module provides a Hash attribute which provides a number of
hash-like operations.

=head1 PROVIDED METHODS

These methods are implemented in
L<MouseX::NativeTraits::MethodProvider::HashRef>.

=over 4

=item B<get($key, $key2, $key3...)>

Returns values from the hash.

In list context return a list of values in the hash for the given keys.
In scalar context returns the value for the last key specified.

=item B<set($key =E<gt> $value, $key2 =E<gt> $value2...)>

Sets the elements in the hash to the given values.

=item B<delete($key, $key2, $key3...)>

Removes the elements with the given keys.

=item B<exists($key)>

Returns true if the given key is present in the hash.

=item B<defined($key)>

Returns true if the value of a given key is defined.

=item B<keys>

Returns the list of keys in the hash.

=item B<sorted_keys>

Returns the list of sorted keys in the hash.

=item B<values>

Returns the list of values in the hash.

=item B<kv>

Returns the key/value pairs in the hash as an array of array references.

  for my $pair ( $object->options->pairs ) {
      print "$pair->[0] = $pair->[1]\n";
  }

=item B<elements>

Returns the key/value pairs in the hash as a flattened list.

=item B<clear>

Resets the hash to an empty value, like C<%hash = ()>.

=item B<count>

Returns the number of elements in the hash. Also useful for not empty: 
C<< has_options => 'count' >>.

=item B<is_empty>

If the hash is populated, returns false. Otherwise, returns true.

=item B<accessor>

If passed one argument, returns the value of the specified key. If passed two
arguments, sets the value of the specified key.

=back

=head1 METHODS

=over 4

=item B<meta>

=item B<method_provider_class>

=item B<helper_type>

=back

=head1 SEE ALSO

L<MouseX::NativeTraits>

=cut
