package Domain;
use Dancer;

=head1 Domain

Domain registration API.

=head2 Registering domains

Register a domain by using POST /domain request. HTTP status code reflects
whether the operation was successful or not.

=head3 POST /domain

=head4 Input

=over

=item domain

Name of the domain to register.

=item period

Registration period in years.

=back

=head4 Output

=over

=item success

Domain registered successfully

=item error

Some error occured.

=over

=item domain

=over

=item invalid

Domain name is invalid.

=item not_available

Domain is not available.

=back

=item period

=over

=item invalid

Period is not a valid integer from 1 to 9.

=back

=back

=back

=cut

post '/domain' => sub {
    return create_domain(params->{domain}, params->{period});
};

my %domain;
sub create_domain {
    my ($domain, $period) = @_;

    my %error;
    if ($domain !~ /^ \w+ [.] \w{2,3} $/x) {
        $error{domain} = { invalid => $domain };
    } elsif (exists $domain{$domain}) {
        $error{domain} = { not_available => $domain };
    }
    if (!$period || $period !~ /^\d$/) {
        $error{period} = { invalid => $period };
    }
    return { error => \%error } if %error;

    require DateTime;
    my $created = DateTime->now;
    my $expires = $created->clone->add(years => $period);
    $domain{$domain} = {
        created => $created,
        expires => $expires,
    };
    return { success => 1 };
}

=head2 Getting domains info

You can use one of two calls to retrieve information about your domains: one for
listing all of your domains and getting a basic information about them, another
for getting detailed info about the specified domain.

=head3 GET /domain

List domains of the logged in user.

=head4 Output

=over

=item domains

An arrayref of domains, each domain is represented by a hashref with the
following fields:

=over

=item domain

Domain name.

=back

=back

=cut

get '/domain' => sub {
    return { domains => [ sort keys %domain ] };
};

=head3 GET /domain/:domain

Get extended info of a specified domain.

=head4 Output

=over

=item created

Registration date of a domain.

=item expires

Expiry date of a domain.

=item error

=over

=item domain

=over

=item not_found

Domain not found.

=back

=back

=back

=cut

get '/domain/:domain' => sub {

    my $domain = params->{domain};
    if (exists $domain{$domain}) {
        my ($created, $expires) = @{ $domain{$domain} }{qw(created expires)};
        return {
            domain  => $domain,
            created => join(' ', $created->ymd, $created->hms),
            expires => join(' ', $expires->ymd, $expires->hms),
        };
    }
    return { domain => { not_found => params->{domain} } };
};

=head3 GET /domain/:domain/nameservers

Get nameservers of a specified domain.

=head4 Output

=over

=item nameservers

An array of nameservers.

=item error

=over

=item domain

=over

=item not_found

Domain not found.

=back

=back

=back

=cut

1;
