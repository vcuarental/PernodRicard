({
	removeSettlementLine: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}

		var data = e.target.dataset;
		cmp.set('v.selectedItemId', data.lineItemId);
		cmp.find('confirmation').showConfirmation();

		e.preventDefault();
		e.stopPropagation();
		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
		return false;
	},
	fireDeleteEvent: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.getEvent("deleteLineItemEvent").setParams({
			lineItemId: cmp.get('v.selectedItemId')
		}).fire();

		e.stopPropagation();
		return false;
	}
})