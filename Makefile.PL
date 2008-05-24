use inc::Module::Install;

name 'MooseX-Traits';
all_from 'lib/MooseX/Traits.pm';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
