package MooseX::Traits;
use Moose::Role;

our $VERSION   = '0.03';
our $AUTHORITY = 'id:JROCKWAY';

has '_trait_namespace' => (
    # no accessors or init_arg
    init_arg => undef,
    isa      => 'Str',
);

# dont pollute the consuming class with methods they don't want
my $transform_trait = sub {
    my ($class, $name) = @_;
    my $namespace = $class->meta->get_attribute('_trait_namespace');
    my $base;
    if($namespace->has_default){
        $base = $namespace->default;
        if(ref $base eq 'CODE'){
            $base = $base->();
        }
    }

    return $name unless $base;
    return $1 if $name =~ /^[+](.+)$/;
    return join '::', $base, $name;
};

sub new_with_traits {
    my ($class, %args) = @_;

    if (my $traits = delete $args{traits}) {

        Class::MOP::load_class($_)
            for map { $_ = $class->$transform_trait($_) } @$traits;

        my $meta = $class->meta->create_anon_class(
            superclasses => [ blessed($class) || $class ],
            roles        => $traits,
            cache        => 1,
        );
        $meta->add_method('meta' => sub { $meta });
        $class = $meta->name;
    }

    return $class->new(%args);
}

1;

__END__

=head1 NAME

MooseX::Traits - automatically apply roles at object creation time

=head1 SYNOPSIS

Given some roles:

  package Role;
  use Moose::Role;
  has foo => ( is => 'ro', isa => 'Int' required => 1 );

And a class:

  package Class;
  use Moose;
  with 'MooseX::Traits';

Apply the roles to the class at C<new> time:

  my $class = Class->new_with_traits( traits => ['Role'], foo => 42 );

Then use your customized class:

  $class->isa('Class'); # true
  $class->does('Role'); # true
  $class->foo; # 42

=head1 DESCRIPTION

Often you want to create components that can be added to a class
arbitrarily.  This module makes it easy for the end user to use these
components.  Instead of requiring the user to create a named class
with the desired roles applied, or applying roles to the instance
one-by-one, he can just pass a C<traits> parameter to the class's
C<new_with_traits> constructor.  This role will then apply the roles
in one go, cache the resulting class (for efficiency), and return a
new instance.  Arguments meant to initialize the applied roles'
attributes can also be passed to the constructor.

=head1 METHODS

=over 4

=item B<new_with_traits (%args, traits => \@traits)>

=back

=head1 ATTRIBUTES YOUR CLASS GETS

This role will add the following attributes to the consuming class.

=head2 _trait_namespace

You can override the value of this attribute with C<default> to
automatically prepend a namespace to the supplied traits.  (This can
be overridden by prefixing the trait name with C<+>.)

Example:

  package Another::Trait;
  use Moose::Role;
  has 'bar' => (
      is       => 'ro',
      isa      => 'Str',
      required => 1,
  );

  package Another::Class;
  use Moose;
  with 'MooseX::Traits';
  has '+_trait_namespace' => ( default => 'Another' );

  my $instance = Another::Class->new_with_traits(
      traits => ['Trait'], # "Another::Trait", not "Trait"
      bar    => 'bar',
  );
  $instance->does('Trait')          # false
  $instance->does('Another::Trait') # true

  my $instance2 = Another::Class->new_with_traits(
      traits => ['+Trait'], # "Trait", not "Another::Trait"
  );
  $instance2->does('Trait')          # true
  $instance2->does('Another::Trait') # false

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

Stevan Little C<< <stevan.little@iinteractive.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

