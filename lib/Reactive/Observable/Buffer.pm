package Reactive::Observable::Buffer;

use Moose;

has size   => (is => 'ro', required => 1);
has skip   => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

sub build_wrapper_observer {
    my ($self, %args) = @_;
    return Reactive::Observable::Buffer::Observer->new(
        %args,
        size => $self->size,
        skip => $self->skip,
    );
}

package Reactive::Observable::Buffer::Observer;

use Moose;

has size   => (is => 'ro', required => 1);
has skip   => (is => 'ro', required => 1);
has buffer => (is => 'rw', default  => sub { [] });

extends 'Reactive::Observer::Forwarder';

sub on_next {
    my ($self, $value) = @_;
    my $buffer = $self->buffer;
    push @$buffer, $value;
    return unless @$buffer == $self->size;
    my @buffer = @$buffer;
    my @value  = @buffer; # copy list
    @buffer = @buffer[-$self->skip..-1];
    $self->buffer(\@buffer);        
    $self->target->on_next(\@value);
}

1;

