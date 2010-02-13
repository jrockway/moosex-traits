package MooseX::Traits;
use Moose::Role;

use MooseX::Traits::Util qw(new_class_with_traits);

use warnings;
use warnings::register;

use namespace::autoclean;

our $VERSION   = '0.08';
our $AUTHORITY = 'id:JROCKWAY';

has '_trait_namespace' => (
    # no accessors or init_arg
    init_arg => undef,
    isa      => 'Str',
    is       => 'bare',
);

sub new_with_traits {
    my $class = shift;

    my ($hashref, %args) = 0;
    if (ref($_[0]) eq 'HASH') {
        %args    = %{ +shift };
        $hashref = 1;
    } else {
        %args    = @_;
    }

    my $traits = delete $args{traits} || [];
    my $new_class = new_class_with_traits($class, @{ ref($traits) ? $traits : [ $traits ] } );

    my $constructor = $new_class->constructor_name;
    confess "$class ($new_class) does not have a constructor defined via the MOP?"
      if !$constructor;

    return $new_class->name->$constructor($hashref ? \%args : %args);
}

# this code is broken and should never have been added.  i probably
# won't delete it, but it is definitely not up-to-date with respect to
# other features, and never will be.
#
# runtime role application is fundamentally broken.  if you really
# need it, write it yourself, but consider applying the roles before
# you create an instance.

sub apply_traits {
    my ($self, $traits, $rebless_params) = @_;

    # disable this warning with "use MooseX::Traits; no warnings 'MooseX::Traits'"
    warnings::warnif('apply_traits is deprecated due to being fundamentally broken. '.
                     q{disable this warning with "no warnings 'MooseX::Traits'"});

    # arrayify
    my @traits = $traits;
    @traits = @$traits if ref $traits;

    if (@traits) {
        @traits = MooseX::Traits::Util::resolve_traits(
            $self, @traits,
        );

        for my $trait (@traits){
            $trait->meta->apply($self, rebless_params => $rebless_params || {});
        }
    }
}

no Moose::Role;

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

To apply traits to an existing instance:

  $self->apply_traits([qw/Role1 Role2/], { rebless_params => 'go here' });

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

Alternatively, traits can be applied to an instance with C<apply_traits>,
arguments for initializing attributes in consumed roles can be in C<%$self>
(useful for e.g. L<Catalyst> components.)

=head1 METHODS

=over 4

=item B<< $class->new_with_traits(%args, traits => \@traits) >>

C<new_with_traits> can also take a hashref, e.g.:

  my $instance = $class->new_with_traits({ traits => \@traits, foo => 'bar' });

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

