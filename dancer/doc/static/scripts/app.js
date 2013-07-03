
$(document).ready(function() {

    // We'll show content if we have entered via a deep link
    // Else show a blank screen TODO put a nice logo here
    $('#content').children().hide();

    initQuickSearch();
    initHashChange();

    // Expand the sidebar once on page-load, the data-attr handle other expansions
    defaultSidebarSection();

    convertRoutePlaceholders();
    convertIOPlaceholders();

    $('.send-request').click(function(event) {
        sendAPIRequest(this, event);
    });
});


// The box that filters routes
function initQuickSearch() {
    $('#route-filter').quicksearch('.route-list li', {
        'delay': 100,
        'onBefore': function() {
            // Open all sections, so we can see if there is anything in them
            $('.collapse').addClass('in').height('auto');
        },
        'onAfter': function() {
            // Collapse all sections when we have an empty filter field
            if (!$('#route-filter').val()) {
                 $('.collapse').removeClass('in').height('0');
            }

        }
    });

}


// Watches for changes in the URL hashbang and updates the #content pane accordingly
// Also updates the hash when we click on a link
function initHashChange() {
    // Bind an event to window.onhashchange that, when the hash changes, gets the
    // hash and adds the class "selected" to any matching nav link.
    $(window).hashchange(function(){
        var hash = window.location.hash.replace( /^#!\//, '' );

        if (hash == '') { return; }

        // All routes follow the method-route format, or end in -pod
        // Other links aren't connected to panels, they are just links
        if (hash.match(/^get|^post|^put|^patch|^delete|-pod$/)) {
            showPanel(hash);
        }

        // Highlights the item in the list, deselects all other routes
        $('.showpanel').removeClass('selected');
        $('#'+hash).addClass('selected');
    })

    // Since the event is only triggered when the hash changes, we need to trigger
    // the event now, to handle the hash the page may have loaded with.
    $(window).hashchange();
}


// Converts :placeholders to input fields in the route
// Also adds the "submit" button for the request
function convertRoutePlaceholders() {
    $('.route-panel h3').each(function(index) {
        var sections = $(this).text().split('/');

        var full_route = [];
        var method;
        $.each(sections, function(idx, section) {
            if (idx == 0) {
                method = section
            } else {
                full_route.push(section);
            }

            if (section.match(/^:/)) {
                // Change the placeholders in-place - colons are valid characters in names
                sections[idx] =  '<input type="text" placeholder="' + section + '" name="' + section + '" class="url-slug"/>';
            }
        });

        var full_route_input = '<input type="hidden" value="/' + full_route.join('/') + '" class="full-route">';
        var method_input = '<input type="hidden" value="' + method + '" class="method">';
        var submit = '<a href="#" class="btn btn-primary send-request">Send API Request</a>';

        $(this).html(sections.join('/') + ' ' + method_input + full_route_input + submit);
    });
}


// Convetrs :placeholders in Input / Output boxes
function convertIOPlaceholders() {
    $('.route-panel').each(function(index) {
        var input  = $(this).children('.input-params');
        var output = $(this).children('.output-params');

        // Replace placeholders with input fields
        $(input).children('dt').each(function(index) {
            var name = $(this).text();

            $(this).html('<input type="text" placeholder=":' + name + '" name="' + name + '" />')
        });

        $(this).children('.pill-content').children('.input-panel').html(input);
        $(this).children('.pill-content').children('.output-panel').html(output);
    });
}


// Show panel in the content area, based on the id sent
function showPanel(id) {
    $('#content').children().hide();
    $('#' + id + '-panel').show();
}


// Show the relevant section in the sidebar from the anchor in the URL
function defaultSidebarSection() {
    var selector = window.location.hash.replace( /^#!\//, '' );

    if (selector == '') { return; }

    if ($('#' + selector + '-panel').length > 0){
        // We have an anchor in the URL for a specific route, show the route
        showPanel(selector);

        // Open it's sidebar section, even if it's a full pod link
        if ( selector.match(/\-pod$/) ) {
            var parent_class = selector.replace( /\-pod$/, '' );
            $('.' + parent_class).addClass('in').height('auto');
        }
    } else {
        // We have an anchor for a header, so open it.
        $('.' + selector).addClass('in').height('auto');
    }
}


// Serializes the form, and submits to the relevant route
function sendAPIRequest(button, event) {
    event.preventDefault();

    // Set the loading state on the button - acts as a spinner, and
    // Prevents multiple requests being sent for doubleclick etc
    $(button).button('loading');

    var method       = $(button).siblings('.method').val().replace(/\W+/,''),
        full_route   = $(button).siblings('.full-route').val(),
        url_slugs    = $(button).siblings('.url-slug'),
        inputs       = $(button).parent().siblings('.pill-content').children('.input-panel').find('input'),
        request_box  = $(button).parent().siblings('.pill-content').find('.tryapi-request'),
        response_box = $(button).parent().siblings('.pill-content').find('.tryapi-response');

    // Iterate over each field in the route and replace
    // the placeholder value with the value we've specified
    $.each(url_slugs, function(index, url_slug) {
        var placeholder = $(url_slug).attr('name');
        var regex       = new RegExp(placeholder);

        full_route = full_route.replace(regex, $(url_slug).val());
    });

    // Iterate over the inputs to serialize and send as JSON later
    // TODO: Should we serializeArray, that will send the empty string
    // for form inputs that have no value, is the what we want?
    var form_data = {};
    $.each(inputs, function(index, input) {
        if ($(input).val()) {
            form_data[$(input).attr('name')] = $(input).val();
        }
    });

    // GET requests cannot send JSON
    // Don't submit blank JSON if we have no data to send
    var json_for_api = '';
    if (method != 'GET' && Object.keys(form_data).length > 0) {
        // If someone puts JSON in a field, we should convert it to a real
        // JS object, so it doesn't just stringify it as plaintext
        $.each(form_data, function(index, value) {
            try {
                var jsonSubKey = jQuery.parseJSON(value);
                form_data[index] = jsonSubKey;
            } catch (error) {
                // Fail Silently, because 99.9% of fields will be
                // plaintext and not valid JSON
            }
        });
        
        // extra options are for pretty-printing.
        json_for_api = JSON.stringify(form_data, null, 4);
    }

    // Print the request, including method and route
    // TODO: Headers, cookies etc
    $(request_box).text(method +' '+ full_route + '\n\n' + json_for_api);

    // Clear the the response, as we will have to wait for it from the server
    $(response_box).html('');

    // If we are accessing the docs from a web box, we need the /api prefix
    // location.port doesn't default to 80 if it's not defined in the URL
    if (location.href.match(/web\./) || !location.port) {
        full_route = '/api' + full_route;
    }

    // Send request to the API - now behind nginx
    $.ajax(full_route, {
        "contentType": "application/json",
        "data":        json_for_api,
        "cache":       false,
        "dataType":    "json",
        "type":        method,
        "error":       function(jqXHR, textStatus, errorThrown) {
            console.log(jqXHR, textStatus, errorThrown);

            $(response_box).text(jqXHR.responseText);
        },
    	"complete":    function (jqXHR, textStatus) {
            $(response_box).text(jqXHR.responseText);

            // Re-enable send button
            $(button).button('reset');

            // Colorizes the JSON for request / response
            prettyPrint();
    	}
    });
}

