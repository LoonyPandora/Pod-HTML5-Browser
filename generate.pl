#!/usr/bin/env perl

use common::sense;
use Data::Dump qw(dump);

use lib 'lib';

use Pod::Simple::Search;
use Pod::Simple::XHTML;
use PodViewer;



find_pod();



sub find_pod {
    my $basedir = '/Users/james/Sites/Dancer';

    my $name2path = Pod::Simple::Search->new->inc(0)->survey($basedir);

    # Parse all the POD into one large data structure, keyed by module name
    my (%allpod, %api_console, @sidebar, @routes);
    for my $module (sort keys %$name2path) {

        # Remove any INC paths from before the module.
        my $module_id = $module;
        for my $inc (@INC) {
            my $colon_inc = $inc;
            $colon_inc =~ s{/}{::}g;
            $colon_inc =~ s{^::}{}g;

            $module_id =~ s{\Q$colon_inc}{}gi;
            $module_id =~ s{^::}{}gi;
        }
                
        my $parser = PodViewer->new();
        $parser->perldoc_url_prefix('https://metacpan.org/module/');
        $parser->html_header('');
        $parser->html_footer('');
        $parser->output_string(\$allpod{$module_id});
        $parser->parse_file($name2path->{$module});
        
        push @sidebar, $parser->new_index($module_id);
    }


    # say dump @sidebar;

    write_output(\@sidebar, $allpod{Dancer});
}

sub write_output {
    my ($index, $content) = @_;
    
    my $basedir = '/Users/james/Sites/docviewer/output';

    open(my $fh, ">", "$basedir/index.html") or die "cannot open > index.html: $!";
        print $fh qq{
<!doctype html public "✰">
<!--[if lt IE 7]> <html lang="en-us" class="no-js ie6"> <![endif]-->
<!--[if IE 7]>    <html lang="en-us" class="no-js ie7"> <![endif]-->
<!--[if IE 8]>    <html lang="en-us" class="no-js ie8"> <![endif]-->
<!--[if IE 9]>    <html lang="en-us" class="no-js ie9"> <![endif]-->
<!--[if gt IE 9]><!--> <html lang="en-us" class="no-js"> <!--<![endif]-->
<head>
    <meta charset="utf-8">
    <title>Perl Doc Viewer</title>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge;chrome=1" >
    <meta http-equiv="imagetoolbar" content="false">
    <meta name="description" content="Perl Doc Viewer">

    <!-- Base Styles -->
    <link href="/css/bootstrap.min.css" rel="stylesheet">
    <link href="/css/style.css" rel="stylesheet">
    <link href="/css/hashgrid.css" rel="stylesheet">
    <link href="/css/github.css" rel="stylesheet">

    <!-- Modernizr needs to be in the head, other JS at the bottom -->
    <script src="/js/modernizr.js"></script>

    <!-- favicon and touch icons -->
    <link rel="shortcut icon"    href="/img/favicon.ico">
    <link rel="apple-touch-icon" href="/img/apple-touch-icon-57x57.png">
    <link rel="apple-touch-icon" href="/img/apple-touch-icon-72x72.png" sizes="72x72">
    <link rel="apple-touch-icon" href="/img/apple-touch-icon-114x114.png" sizes="114x114">
</head>
<body data-spy="scroll" data-offset="21">


<div id="sidebar">   
<ul class="nav nav-list accordion-group">
    <li class="section-filter">
        <input type="text" class="search-query" placeholder="Search Table of Contents">
    </li>
        
    <li class="divider"></li>

    <li><a href="#" class="nav-header" data-toggle="collapse" data-target=".search-results" data-parent="#sidebar">Search Results</a></li>
    <ul class="search-results nav nav-list collapse">
    <li><a href="#">
        <p><i>No Results</i></p>
        <small>No results were found</small>
    </a></li>
    </ul>

    @$index
</ul>
</div>

<div id="content">
    <div class="subhead">
        <h1>Dancer</h1>
        <p>Lightweight, yet powerful web application framework</p>
    </div>

    $content
</div>

<!-- JS at the bottom for faster page load -->
<script src="/js/jquery.min.js"></script>
<script src="/js/jquery.hashgrid.js"></script>
<script src="/js/bootstrap.min.js"></script>
<script src="/js/highlight.min.js"></script>
};

print $fh q{
    <script>
        $(document).ready(function() {
          $('pre code').each(function(i, e) {
              // FIXME: This is an ugly hack because the copy/pasted HTML
              // Has leading spaces on each line of the code blocks
              $(e).text($.trim( $(e).text().replace(/\n    /g,'\n')));

              // TODO: This is slow, parses the code twice...
              var highlighter = hljs.highlightAuto($(e).text());

              // Confidence of the auto-detection that the language is correct
              // TODO: Highlight if the second best language is perl
              if (highlighter.r > 1) {
                  if (highlighter.language == 'perl') {
                      hljs.highlightBlock(e);
                  }
              }
      
          });
        });
    </script>

};

print $fh q{
<!-- Prompt IE 6 users to install Chrome Frame. Remove this to 'support' IE 6. -->
<!-- http://chromium.org/developers/how-tos/chrome-frame-getting-started -->
<!--[if lt IE 7 ]>
    <script src="//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.3/CFInstall.min.js"></script>
    <script>window.attachEvent('onload',function(){CFInstall.check({mode:'overlay'})})</script>
<![endif]-->

</body>
</html>
        };
    close $fh;

}



1;
