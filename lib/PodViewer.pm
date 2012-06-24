package PodViewer;

use base 'Pod::Simple::XHTML';
use common::sense;
use Data::Dump qw(dump);


# lowercases IDs - just looks nicer
sub idify {
    my ($self, $t, $not_unique) = @_;

    # Colons and periods are valid in HTML IDs, but jQuery can't easily 
    # use them in selectors - you have to escape them, and it's a pain
    # So for ease of use on the front end, get rid of them

    $t = lc $t;
    for ($t) {
        s/<[^>]+>//g;            # Strip HTML.
        s/&[^;]+;//g;            # Strip entities.
        s/^\s+//; s/\s+$//;      # Strip white space.
        s/^([^a-zA-Z]+)$/pod$1/; # Prepend "pod" if no valid chars.
        s/^[^a-zA-Z]+//;         # First char must be a letter.
        s/[^-a-zA-Z0-9_]+/-/g;   # All other chars must be valid.
        s/-+/-/g;                # Remove multiple dashes.
        s/-$//g;                 # Remove trailing dashes.
        s/^-//g;                 # Remove leading dashes.
    }

    return $t if $not_unique;
    my $i = '';
    $i++ while $self->{ids}{"$t$i"}++;
    return "$t$i";
}


sub new_index {
    my ($self, $module) = @_;

    my $to_index = $self->{'to_index'};
    if (@{ $to_index } ) {
        my @out;
        my $level  = 0;
        my $indent = -1;
        my $space  = '';

        my $module_id = $self->idify($module, 1);

        my $module_title = $module;
        my $module_path  = $module . ".html";
        $module_path =~ s{::}{/}g;

        for my $h (@{ $to_index }, [0]) {
            my $target_level = $h->[0];
            # Get to target_level by opening or closing ULs
            if ($level == $target_level) {
                $out[-1] .= '</li>';
            } elsif ($level > $target_level) {
                $out[-1] .= '</li>' if $out[-1] =~ /^\s+<li>/;
                while ($level > $target_level) {
                    --$level;
                    push @out, ('  ' x --$indent) . '</li>' if @out && $out[-1] =~ m{^\s+<\/ul};
                    push @out, ('  ' x --$indent) . '</ul>';
                }
                push @out, ('  ' x --$indent) . '</li>' if $level;
            } else {
                while ($level < $target_level) {
                    ++$level;
                    push @out, ('  ' x ++$indent) . '<li>' if @out && $out[-1]=~ /^\s*<ul/;

                    if ($module_id) {
                        push @out, ('  ' x ++$indent) . qq{<li><a href="#" class="nav-header" data-toggle="collapse" data-target="#$module_id" data-parent="#sidebar">$module_title</a></li>};
                        push @out, ('  ' x ++$indent) . qq{<ul id="$module_id" class="collapse nav nav-list">};
                    } else {
                        push @out, ('  ' x ++$indent) . qq{<ul class="nav nav-list">};
                    }

                    $module_id = '';
                }
                ++$indent;
            }
 
            next unless $level;
            $space = '  '  x $indent;
            
            push @out, sprintf '%s<li><a href="/output/%s">%s</a>', $space, $module_path . "#" . $h->[1], $h->[2];
        }
        # Splice the index in between the HTML headers and the first element.
        my $offset = defined $self->html_header ? $self->html_header eq '' ? 0 : 1 : 1;
        splice @{ $self->{'output'} }, $offset, 0, join "\n", @out;

        return join "\n", @out;
    }
 
}


sub emit {
    my ($self) = @_;

    # Wrap todo items in labels
    $self->{scratch} =~ s{FIXME:?}{<span class="label label-important">FIXME</span>}g;
    $self->{scratch} =~ s{TODO:?}{<span class="label label-warning">TODO</span>}g;

    if ($self->index) {
        push @{ $self->{output} }, $self->{scratch};
    } else {
        print { $self->{output_fh} } $self->{scratch}, "\n\n";
    }
    $self->{scratch} = '';
    return;
}

1;
