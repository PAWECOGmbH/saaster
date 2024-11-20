jQuery.fn.toggleInput = function () {
	var $ = jQuery;
	var _container = this;

	_container.addClass('has-toggle-input');
	_container.find( 'input' ).hide();

	_initLabel = $('label[for="'+ _container.find('input:checked').attr('id') +'"]');
	if (!_initLabel.length) {
		_initLabel = _container.find('input:checked').parent('label');
	}
	_initLabel.addClass('active');

	this.on( 'click', 'label', function ( e ) {
		e.preventDefault();

		// Add active class to labels
		_container.find('label.active').removeClass('active');
		var _label = $(e.currentTarget);
		_label.addClass('active');

		// Add checked state to inputs
		var _input = $( "#" + _label.htmlFor );

		if (!_input.length) {
			_input = _label.find('input');
		}

		$( 'input[name="' + _input.attr( 'name' ) + '"]:checked' ).prop( 'checked', false ).removeAttr( 'checked' );
		_input.prop( 'checked', true ).attr( 'checked', 'checked' );
	} );
};