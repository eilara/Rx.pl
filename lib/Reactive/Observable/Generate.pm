package Reactive::Observable::Generate;

use Moose;

extends 'Reactive::Observable';

has [qw(init_value
        continue_predicate
        step_action
        result_projection
        inter_step_duration)] => (is => 'ro', required => 1);

sub run {
    my ($self, $observer) = @_;
    my $is_first   = 1;
    my $state      = $self->init_value;
    my $duration   = $self->inter_step_duration;
    my $action     = $self->step_action;
    my $projection = $self->result_projection;
    my $continue   = $self->continue_predicate;

    local $_ = $state;
    my $init_duration = $duration->($_);
    my $disposable = $self->schedule_at($init_duration, sub {
        local $_ = $state;
        if ($is_first) { $is_first = 0 }
                  else { $state = $action->($_) }

        $_ = $state;
        my $result = $projection->($_);
        $observer->on_next($result);
        $_ = $state;

        if ($continue->($_)) {
            return $duration->($_)
        } else {
            $observer->on_complete;
            return undef;
        }
    });
    return $disposable;
}

1;

