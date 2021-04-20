({
	renderModal: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.set('v.isInitialized', false);

		var config = e.getParams();
		cmp.set('v.title', config.title);
		cmp.set('v.saveEventName', config.saveEventName);
		if (config.width) {
			cmp.set('v.width', config.width);
		}
		if (config.actionButtonLabel) {
			cmp.set('v.buttonLabel', config.actionButtonLabel);
		}
		$A.createComponent('c:' + config.cmpName, config.settings, function(newCmp) {
			if (!cmp.isValid()) {
				return;
			}

			cmp.set('v.body', [newCmp]);
			$('#modal').show();

			setTimeout(function() {
				$A.run(function() {
					cmp.set('v.isInitialized', true);
				});
			}, 1000);
		});
	},
	modalClose: function(cmp, e) {
		$('#error').find('.notify__content').html('');
		$('#error').addClass('slds-hide');
		$('#modal form .required').each(function() {
			$(this).removeClass('slds-has-error');
		});
		$('#modal').hide();
	},
	modalSave: function(cmp, e) {
		var isDataValid = true;
		$('#modal form').find('input.required, select.required, textarea.required').each(function() {
			var $el = $(this);
			
			$el.removeClass('slds-has-error');
			if (!$el.val().length) {
				isDataValid = false;
				$el.addClass('slds-has-error');
			}
		});

		if (!$('#modal form')[0].checkValidity() || !isDataValid) {
			$('#modal form').find('.notify__content').html('<p>Required fields have been left blank</p>');
			$('#error').removeClass('slds-hide');
			return;
		}

		if (cmp.get('v.saveEventName')) {
			$A.get('e.c:' + cmp.get('v.saveEventName')).fire();
		}

		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
	},
	showError: function(cmp, e) {
		$('#modal form').find('.notify__content').html(
			'<p>' + (e.getParams().message || 'Error has been occurred') + '</p>' +
			'<p>' + e.getParams().details + '</p>'
		);
		$('#error').removeClass('slds-hide');
	}
})