package doc;

use common::sense;
use Dancer ':syntax';
use Pod::Simple::Search;

use lib::abs '../../../lib';
use Doc::Tree;

my $app_dir= lib::abs::path('..');
setting(
    public      => "$app_dir/static",
    views       => "$app_dir/views",
    layout      => 'main',
);

my $source_dir = lib::abs::path('../../API/lib');


# TODO clean up the following 2 routes
# Not running with nginx in front of us, so send static files manually
get qr{^ /doc/ (?<staticfile> (?: css | scripts | img ) /.+) $}x => sub {
    send_file captures->{staticfile}
};

# The only route of any significance
get '/doc/' => sub {

    my $pod = process_pod($source_dir);
    template 'index', {
        routes  => $pod->{routes},
        allpod  => $pod->{allpod},
        sidebar => join "\n", @{$pod->{sidebar}},
    };
};


# Be nice if people don't use a trailing slash
get '/doc' => sub {
    redirect '/doc/';
};

# Index page also redirects to /doc/
get '/' => sub {
    redirect '/doc/';
};

# We use hashbangs, so redirect non hashbang URL to hashbang URL
get '/doc/:module' => sub {
    redirect '/doc/#!/' . params->{module};
};

sub process_pod {
    my ($source_dir) = @_;

    my $name2path = Pod::Simple::Search->new->inc(0)->survey($source_dir);

    # Parse all the POD into one large data structure, keyed by module name
    my (%allpod, %api_console, @sidebar, @routes, %ids_used);
    for my $module (sort keys %$name2path) {
        my $tree = Doc::Tree->new_from_file($name2path->{$module});
        $tree->ids_used(\%ids_used);

        $allpod{$tree->module_id} = $tree->render_as_html($tree->pod_tree);
        push @sidebar, $tree->index;
        push @routes,  $tree->routes;

        %ids_used = %{$tree->ids_used};
    }

    return {
        sidebar => \@sidebar,
        routes  => \@routes,
        allpod  => \%allpod,
    }
}

1;
