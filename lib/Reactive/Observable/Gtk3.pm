package Reactive::Observable::Gtk3;

package Reactive::Observable;

use aliased 'Reactive::Observable::Gtk3::Mouse';

sub from_mouse_press {
    my ($self, $widget) = @_;
    return Mouse->new(widget => $widget, event => 'button_press_event');
}

sub from_mouse_release {
    my ($self, $widget) = @_;
    return Mouse->new(widget => $widget, event => 'button_release_event');
}

sub from_mouse_motion {
    my ($self, $widget) = @_;
    return Mouse->new(widget => $widget, event => 'motion_notify_event');
}

1;


