Rx.pl
=====

Microsoft Reactive Extensions clone for Perl

Install from CPAN:
------------------

Moose
aliased
Coro
DateTime
EV
AnyEvent

Examples:
---------

An observable that notifies after 10 seconds of mouse inactivity:

            Rx->from_mouse_move
    ->merge(Rx->from_mouse_click)
    ->map(sub { 1 })
    ->timeout(10->seconds, sub { 0 })
    ->distinct_changes;

An observable for a sketching program, fires with previous and current
coordinates whenever mouse moved and button is down:

    $mouse_move_event->select(sub{ [$_->x, $_->y] })  
                     ->start_with([320,200]) # initial mouse position
                     ->buffer(2)
                     ->combine_latest(
                                         $up_event->select(sub { 0 })
                              ->merge( $down_event->select(sub { 1 }) ))
                     ->grep(sub{ $_->[1] == 1 }) # only when mouse is down
                     ->map(sub{ $_->[1] })       # we only want the coordinates

Then subscribe on this stream to sketch:

    use List::Flatten::Recursive;

    $observable->subscribe(sub{
        my ($x0, y0, $x1, $y1) = flat shift; # map { @$_ } @{$_[0]}
        draw_line_between_two_points(x0, y0, x1, y1);
    })
