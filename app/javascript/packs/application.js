// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import jquery from "jquery";
import "@fortawesome/fontawesome-free/js/all";

global.$ = jQuery;
window.$ = window.jquery = jquery;

require("bootstrap");
require("jquery");
require("jquery-ui");
require ("packs/phone-number-validation")
require ("leads/pipeline_view")

import "../stylesheets/application";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

// import "leads/pipeline_view";

$(document).on('ready turbolinks:load', function() {
  $('.open_nav').click(function(){
		$('.menu').addClass('active');
	});

	$('section').click(function(){
		$('.menu').removeClass('active');
	});
  
	$('.open_nav').on('click', function (event) {
	  event.stopPropagation();
	});
});
