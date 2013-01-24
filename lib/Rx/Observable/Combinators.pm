package Rx::Observable;

use strict;
use warnings;

sub map {
    my ($self, $map) = @_;
    $self->create_on_parent(sub {
        my $observer = shift;
        (on_next => sub { $observer->on_next($map->($_)) });
    });
}

sub grep {
    my ($self, $predicate) = @_;
    $self->create_on_parent(sub {
        my $observer = shift;
        (on_next => sub {
                $predicate->($_)
             && $observer->on_next($_);
        });
    });
}

sub concat {
    my ($self, $observable) = @_;
    $self->create_on_parent(sub {
        my ($observer, $scheduler, $set_subscription) = @_;
        (on_complete => sub {
            $set_subscription->
                ($observable->subscribe_observer($observer))
        });
    });
}

sub count {
    my ($self) = @_;
    $self->create_with_parent(sub {
        my ($observer, $scheduler) = @_;
        my $counter = 1;
        return $self->subscribe_observer(
            $observer, on_next => sub
                { $observer->on_next($counter++) },
        );
    });
}
#use Devel::Refcount qw( refcount );
sub take {
    my ($self, $take_count) = @_;
    my $class = ref $self;
            my $parent_subscription;
    return $class->new(
        on_subscribe => sub {
            my ($observer, $scheduler) = @_;
            my $taken_count = 0;
            $parent_subscription = $self->subscribe(
                on_next => sub {
                     $observer->on_next($_);
                     $taken_count++;
                     if ($taken_count >= $take_count) {
                         $observer->on_complete;
    print "------------------------------s2=$parent_subscription\n";
#    print "REFCOUNT=".(refcount $parent_subscription)."\n";
                         $parent_subscription = undef;
                     }
                },
                on_complete => sub { $observer->on_complete  },
                on_error    => sub { $observer->on_error($_) },
            );
            print "p=$parent_subscription\n";
#    print "REFCOUNT222=".(refcount $parent_subscription)."\n";
        },
        on_unsubscribe => sub {
            #$parent_subscription = undef;
        },
        scheduler => $self->scheduler,
    );
}

# sub take {
#     my ($self, $take_count) = @_;
#     my $taken_count = 0;
#     $self->create_on_parent(sub {
#         my ($observer, $scheduler, $set_subscription) = @_;
#         (on_next => sub {
#              $observer->on_next($_);
#              $taken_count++;
#              if ($taken_count >= $take_count) {
#                  $observer->on_complete();
#                  $set_subscription->(undef);
#              }
#         });
#     });
# }

1;

__END__
