use inc::Module::Install;

name 'MooseX-Traits';
all_from 'lib/MooseX/Traits.pm';

requires 'Class::MOP'   => '0.84';
requires 'Moose'        => '0.84';
requires 'Moose::Role';

build_requires 'Moose';
build_requires 'Test::Exception';
build_requires 'Test::More';
build_requires 'ok';

WriteAll();
