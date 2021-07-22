$(function() {
	$('.input_icon.input_show_pwd').on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();

		var item = $('#' + $(this).data('id'));
		if ( item.attr('type') == 'password' ) {
			$('#' + $(this).data('id')).attr('type', 'input');
		} else {
			$('#' + $(this).data('id')).attr('type', 'password');
		}
	})
})