use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;

{ package Foo;
  use Moose;
  with 'MooseX::Traits';

  package Bar;
  use Moose;
  extends 'Foo';

  package Trait;
  use Moose::Role;

  sub foo { return 42 };
}

my $instance;
lives_ok {
    $instance = Bar->new_with_traits( traits => ['Trait'] );
} 'creating instance works ok';

ok $instance->does('Trait'), 'instance does trait';
is $instance->foo, 42, 'trait works';
