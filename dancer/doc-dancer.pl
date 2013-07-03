#!/usr/bin/env perl
use common::sense;
use lib::abs '../lib';
use Dancer 1.3096;

# Start the doc app
my $rootdir = lib::abs::path('.');
push @INC, "$rootdir/doc/lib";
load_app('doc');

# Get this show on the road.
dance();
