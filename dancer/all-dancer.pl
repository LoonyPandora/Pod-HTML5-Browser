#!/usr/bin/env perl
use common::sense;
use lib::abs '../lib';
use Dancer 1.3096;
use File::Spec;

# Start the doc app
my $rootdir = lib::abs::path('.');
push @INC, "$rootdir/doc/lib";
load_app('doc');

# Load API
my $api_dir = "$rootdir/API/lib";
for my $app_path (glob "$api_dir/*.pm") {
    my (undef, $dir, $app) = File::Spec->splitpath($app_path);
    $app =~ s/[.]pm$//;
    warn "Loading $app from $dir";
    push @INC, $dir;
    load_app($app);
}

# Get this show on the road.
dance();
