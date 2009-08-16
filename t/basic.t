use strict;
use warnings;
use Test::More tests => 34;
use Test::Exception;

use MooseX::Traits; # for "no warnings ..."

{ package Trait;
  use Moose::Role;
  has 'foo' => (
      is       => 'ro',
      isa      => 'Str',
      required => 1,
  );

  package Class;
  use Moose;
  with 'MooseX::Traits';

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

}

{
    my $instance = Class->new_with_traits( traits => ['Trait'], foo => 'hello' );
    isa_ok $instance, 'Class';
    can_ok $instance, 'foo';
    is $instance->foo, 'hello';
}

throws_ok {
    Class->new_with_traits( traits => ['Trait'] );
} qr/required/, 'foo is required';

{
    my $instance = Class->new_with_traits;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo'), 'this one cannot foo';
}
{
    my $instance = Class->new_with_traits( traits => [] );
    isa_ok $instance, 'Class';
    ok !$instance->can('foo'), 'this one cannot foo either';
}
{
    my $instance = Another::Class->new_with_traits( traits => ['Trait'], bar => 'bar' );
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'bar';
    is $instance->bar, 'bar';
}
# try hashref form
{
    my $instance = Another::Class->new_with_traits({ traits => ['Trait'], bar => 'bar' });
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'bar';
    is $instance->bar, 'bar';
}
{
    my $instance = Another::Class->new_with_traits(
        traits   => ['Trait', '+Trait'],
        foo      => 'foo',
        bar      => 'bar',
    );
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'foo';
    can_ok $instance, 'bar';
    is $instance->foo, 'foo';
    is $instance->bar, 'bar';
}

# deprecated features!  do not use!

{
    no warnings 'MooseX::Traits';

    my $instance = Class->new;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo');

    lives_ok {
        $instance->apply_traits('Trait' => { foo => 'bar' } );
    };

    isa_ok $instance, 'Class';
    can_ok $instance, 'foo';
    is $instance->foo, 'bar';
}

{
    no warnings 'MooseX::Traits';

    my $instance = Class->new;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo');
    ok !$instance->can('bar');

    lives_ok {
        $instance->apply_traits(['Trait', 'Another::Trait']
                                  => { foo => 'bar', bar => 'baz' } );
    };

    isa_ok $instance, 'Class';
    can_ok $instance, 'foo';
    can_ok $instance, 'bar';
    is $instance->foo, 'bar';
    is $instance->bar, 'baz';
}
