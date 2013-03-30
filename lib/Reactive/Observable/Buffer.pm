package Reactive::Observable::Buffer;

use Moose;

has size   => (is => 'ro', required => 1);
has skip   => (is => 'ro', required => 1);

extends 'Reactive::Observable::Wrapper';

augment observer_args => sub {
    my ($self) = @_;
    return (size => $self->size, skip => $self->skip, inner(@_));
};

package Reactive::Observable::Buffer::Observer;

use Moose;

has size   => (is => 'ro', required => 1);
has skip   => (is => 'ro', required => 1);
has buffer => (is => 'rw', default  => sub { [] });

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $value) = @_;
    my $buffer = $self->buffer;
    push @$buffer, $value;
    return unless @$buffer == $self->size;

    my @buffer = @$buffer;
    my @value  = @buffer; # copy list cause must complete all internal
                          # computes so on_next is a tail call
    @buffer = @buffer[-$self->skip..-1];
    $self->buffer(\@buffer);        
    $self->wrap->on_next(\@value);
}

1;

