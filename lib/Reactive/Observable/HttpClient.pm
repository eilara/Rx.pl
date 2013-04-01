package Reactive::Observable::HttpClient;

package Reactive::Observable;

use aliased 'Reactive::Observable::HttpClient::HttpResponse';

sub from_http_get {
    my ($self, $url, %args) = @_;
    return HttpResponse->new(
        url    => $url,
        args   => {%args},
        method => 'GET',
    );
}

1;


