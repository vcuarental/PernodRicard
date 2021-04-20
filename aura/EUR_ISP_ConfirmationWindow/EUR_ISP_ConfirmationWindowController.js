({
	doInit: function(cmp) {
		if (!cmp.get('v.cmpId')) {
			var randomId = 'cmpId-' + Math.floor((Math.random() * 100000) + 1);
			randomId = randomId.replace(/\W*\s/gi, '');
			cmp.set('v.cmpId', randomId);
		}
	},
	showModal: function(cmp, e) {
		if (!cmp.isValid()) {
			return false;
		}

		var config = e.getParams ? e.getParams().arguments: e.target.dataset;
		if (config && config.text) {
			cmp.set('v.text', config.text);
		}
		if (config && config.noButtonLabel) {
			cmp.set('v.noButtonLabel', config.noButtonLabel);
		}
		if (config && config.yesButtonLabel) {
			cmp.set('v.yesButtonLabel', config.yesButtonLabel);
		}
		if (config && config.eventName) {
			cmp.set('v.eventName', config.eventName);
		}

		$('#' + cmp.get('v.cmpId')).show();
	},
	modalClose: function(cmp) {
		if (!cmp.isValid()) {
			return false;
		}
		$('#' + cmp.get('v.cmpId')).hide();
	},
	modalOk: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.getEvent("confirmationOkEvent").setParams({
			eventName: cmp.get('v.eventName') || ''
		}).fire();
		$('#' + cmp.get('v.cmpId')).hide();

		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
	}
})