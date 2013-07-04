package Login;
use Dancer;

=head1 Login

API for logging in and out

=head2 Logging in

Every user has an associated username (login), which is used to enter the
website, order new services and access the previously ordered ones.

=head3 POST /login

Loging using your credentials.

=head4 Input

=over

=item username

Username to login with.

=item password

Password to login with.

=back

=head4 Output

=over

=item api_key

API key for the logged in user.

=item error

=over

=item authentication

Authentication failed.

=back

=back

=cut

post '/login' => sub {
    my @responses = (
        { api_key => '123456' },
        { error => { authentication => 1 } },
    );
    return $responses[int(rand 2)];
};

=head3 POST /logout

Log out the current user.

=head4 Output

=over

=item logged_out

The user has been looged out.

=over

=back

=cut

post '/logout' => sub {
    return { logged_out => 1 };
};

1;
