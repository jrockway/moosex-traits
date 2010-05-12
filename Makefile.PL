use inc::Module::Install;
use Module::Install::AuthorRequires;

name 'MooseX-Traits';
all_from 'lib/MooseX/Traits.pm';

requires 'Class::MOP'   => '0.84';
requires 'Moose'        => '0.84';
requires 'Moose::Role';
requires 'Sub::Exporter';
requires 'namespace::autoclean';

build_requires 'Moose';
build_requires 'Test::Exception';
build_requires 'Test::More';
build_requires 'ok';
author_requires 'MooseX::Role::Parameterized' => '0.13';

resources Respository => 'git://github.com/jrockway/moosex-traits.git';

WriteAll();
