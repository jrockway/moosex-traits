package MooseX::Traits::NamespaceManager;
use strict;
use warnings;

use Carp qw(confess);

# note: "$class" throughout is "class name" or "instance of class
# name"

sub transform_trait {
    my ($class, $name) = @_;

    confess "We can't transform traits for a class ($class) ".
      "that does not do MooseX::Traits" unless $class->does('MooseX::Traits');

    my $namespace = $class->meta->find_attribute_by_name('_trait_namespace');
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

sub resolve_traits {
    my ($class, @traits) = @_;

    confess "We can't resolve traits for a class ($class) ".
      "that does not do MooseX::Traits" unless $class->does('MooseX::Traits');

    return map {
        my $orig = $_;
        if(!ref $orig){
            my $transformed = transform_trait($class, $orig);
            Class::MOP::load_class($transformed);
            $transformed;
        }
        else {
            $orig;
        }
    } @traits;
};

1;
