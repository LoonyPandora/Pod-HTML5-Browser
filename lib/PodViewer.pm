package PodViewer;

use base 'Pod::Simple::XHTML';
use common::sense;
use Data::Dump qw(dump);


sub _end_head {
    my ($self) = @_;
    
    my $h = delete $self->{in_head};
    
    $self->{in_head_description} = 1;
 
    my $add = $self->html_h_level;
    $add = 1 unless defined $add;
    $h += $add - 1;
 
    my $id = $self->idify($self->{scratch});
    my $text = $self->{scratch};

    $self->{"current_h$h"} = $id;

    $self->{scratch} = qq{<h$h id="$id">$text</h$h>\n};

    $self->emit;

    push @{ $self->{to_index} }, [$h, $id, $text];
}

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

sub module_name {
    my ($self, $module) = @_;

    if (defined $module) {
        $self->{module_name} = $module;
        return;
    }

    return $self->{module_name};
}


sub module_abstract {
    my ($self, $abstract) = @_;

    if (defined $abstract) {
        $self->{module_abstract} = $abstract;
        return;
    }

    return $self->{module_abstract};
}


sub search_results {
    my ($self, $description) = @_;

    if (defined $description) {
        $self->{header_description} = $description;
        return;
    }

    return $self->{header_description};
}



sub new_index {
    my ($self, $module) = @_;

    # die Data::Dump::dump $self->{to_index_description};

    my $to_index = $self->{to_index};
    if (@{ $to_index } ) {
        my @out;
        my $level  = 0;
        my $indent = -1;
        my $space  = '';

        my $module_id = $self->idify($module, 1);

        my $module_title = $module;
        my $module_path  = $module . ".html";
        $module_path =~ s{::}{/}g;

        for (my $i = 0; $i <= (@{ $to_index }); $i++) {
            my $h = ${ $to_index }[$i];
            
            my $target_level = $h->[0] // 0;
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
            
            push @out, sprintf '%s<li><a href="/output/%s"><p>%s</p><small>%s</small></a>', $space, $module_path . "#" . $self->idify($module, 1) . "-" . $h->[1], $h->[2], $self->{to_index_description}[$i];
        }
        # Splice the index in between the HTML headers and the first element.
        my $offset = defined $self->html_header ? $self->html_header eq '' ? 0 : 1 : 1;
        splice @{ $self->{'output'} }, $offset, 0, join "\n", @out;

        return join "\n", @out;
    }
 
}


sub handle_text {
    my ($self, $text) = @_;

    if ($self->{in_head_description}) {
        my $one_line_text = $text =~ s/\n+/ /rg;
        $one_line_text =~ s/\s+/ /g;
        $one_line_text =~ s/<|>//g;

        push @{ $self->{to_index_description} }, substr($one_line_text, 0, 64);
        $self->{in_head_description} = 0;
    }

    $self->SUPER::handle_text($text);
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

    # Try and find an abstract
    if ($self->{current_h1} =~ m/^name$/i) {
        if ($self->{scratch} =~ m/$self->{module_name}/i) {
            
            my $abstract = $self->{scratch};
            
            $abstract =~ s{<p>}{}ig;
            $abstract =~ s{</p>}{}ig;
            $abstract =~ s{$self->{module_name}}{}ig;
            $abstract =~ s{^[\s|-]+}{}ig;

            $self->module_abstract($abstract);
        }
    }
    
    $self->{scratch} = '';
    return;
}

1;
