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

=back

=head4 Output

=over

=item success

Domain registered successfully

=item error

Some error occured.

=over

=item not_available

Domain is not available.

=back

=back

=cut

post '/domain' => sub { ... };

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

get '/domain' => sub { ... };

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

=item not_found

Domain not found.

=back

=back

=cut

get '/domain/:domain' => sub { ... };

1;
