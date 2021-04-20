({
	showModalOncloseSettlement: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.find('confirmation').showConfirmation($A.get('$Labe.c.EUR_ISP_COMPLETE_INVOICE'));
		e.preventDefault();
		e.stopPropagation();
		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
		return false;
	},
	fireCloseEvent: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.getEvent("closeSettlementEvent").fire();
		e.stopPropagation();
		return false;
	}
})