// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require angular
//= require angular-resource
//= require angular-route
//= require underscore
//= require_tree .

$(function(){
	//removes notifications after 3 seconds
    $('.notice').delay(3000).fadeOut();

	//formats telephone numbers.
	//nested presenter fields can be added to a proposal by the user after the DOM is loaded
	//attaching the handler through live ensures those phone numbers are formatted too
	$('.phone_number').on("blur", function(e){
		$(this).val(sanitizePhoneNumber(e.target.value));
	});

  	//date picker
    $('.datepicker').on("mousedown", function(){
    	$(this).datepicker({ dateFormat: 'yy-mm-dd' });
    });

    $('.add_fields').addClass("btn btn-primary");
});

function sanitizePhoneNumber(input){
	return input.replace(/\D/g,'')
};
