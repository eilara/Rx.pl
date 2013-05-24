package Reactive::Observable::CombineLatest;

use Moose;

extends 'Reactive::Observable::DoubleWrapper';

sub map_o1 { shift->o1->map(sub{ [1, $_] }) }
sub map_o2 { shift->o2->map(sub{ [2, $_] }) }

package Reactive::Observable::CombineLatest::Observer;

use Moose;

has num_completed => (is => 'rw', default => 0);
has last_value_1  => (is => 'rw');
has last_value_2  => (is => 'rw');

extends 'Reactive::Observer::Wrapper';

sub on_next {
    my ($self, $notification) = @_;

    my ($child, $value) = @$notification;
    my $other_child  = $child == 1? 2: 1;
    my $this_method  = "last_value_$child";
    my $other_method = "last_value_$other_child";

    if (!exists $self->{$other_method}) {
        $self->$this_method($value);
        return;
    }

    $self->$this_method($value);
    local $_ = [$self->last_value_1, $self->last_value_2];
    $self->wrap->on_next($_);

}

sub on_complete {
    my $self = shift;
    $self->wrap->on_complete;
    $self->unwrap;
}

1;

