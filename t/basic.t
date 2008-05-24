use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

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
  
}

my $instance = Class->new( traits => ['Trait'], foo => 'hello' );
isa_ok $instance, 'Class';
can_ok $instance, 'foo';
is $instance->foo, 'hello';

throws_ok {
    Class->new( traits => ['Trait'] );
} qr/required/, 'foo is required';

