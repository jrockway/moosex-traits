package MooseX::Traits;
use Moose::Role;

our $VERSION   = '0.01';
our $AUTHORITY = 'id:JROCKWAY';

has 'traits' => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    auto_deref => 1,
    default    => sub { [] },
);

has '_trait_namespace' => (
    # no accessors or init_arg
    isa => 'Str',
);

# dont pollute the consuming class with methods they don't want
my $transform_trait = sub {
    my ($self, $name) = @_;
    my $base = $self->meta->get_attribute('_trait_namespace')->get_value($self);
    return $name unless $base;

    return $1 if $name =~ /^[+](.+)$/;
    return join '::', $base, $name;
};

around new => sub {
    my ($next, $class, @args) = @_;
    
    my $self= $class->$next(@args);
    
    my @traits = 
      grep { Class::MOP::load_class($_); 1 }
        map { $self->$transform_trait($_) } $self->traits;

    my @anon_args = (
        superclasses => [$self->meta->name],
        cache        => 1,
    );
    push @anon_args, roles => [@traits] if @traits;

    my $metaclass = $self->meta->meta->name;    
    my $new_class = $metaclass->create_anon_class(@anon_args);
    $new_class->rebless_instance($self, @args);

    return $self;
};

1;

__END__

=head1 NAME

MooseX::Traits - automatically apply roles at object creation time
