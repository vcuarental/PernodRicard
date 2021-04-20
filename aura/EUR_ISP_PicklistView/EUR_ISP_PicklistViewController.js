({
	doInit: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}
		if (!cmp.get('v.values')) {
			return;
		}
		var value = cmp.get('v.value');
		if (!value) {
			cmp.set('v.label', '');
		} else {
			cmp.set('v.label', cmp.get('v.values')[value] || '');
		}
	}
})