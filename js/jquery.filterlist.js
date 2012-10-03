
(function( $ ){
	$.fn.filterList = function() {
		// Case-insensitive "contains"
		jQuery.expr[':'].Contains = function(a,i,m){
			return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
		};
		
		// Hide list items that do not contain filter term/show ones that do
		$(this).keyup(function() {
			var filterListTerm = $(this).val();

			if(filterListTerm) {
				$('.nav-list ul li').find("a:not(:Contains(" + filterListTerm + "))").slideUp();
				$('.nav-list ul li').find("a:Contains(" + filterListTerm + ")").slideDown();
			} else {
				// Input is blank; show all
				$('.nav-list ul li').children('a').slideDown();
			}
			return false;
		});
		
		return this;
	
	};
})( jQuery );

