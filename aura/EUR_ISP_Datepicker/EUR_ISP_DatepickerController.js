({
	doInit: function(cmp, e) {
		if (!cmp.get('v.id')) {
			var randomId = cmp.get('v.label') + '-id-' + Math.floor((Math.random() * 10000) + 1);
			randomId = randomId.replace(/\W*\s/gi, '');
			cmp.set('v.id', randomId);
		}
	},
	setDate: function(cmp, e, hlpr) {
		hlpr.setDate(cmp);
	}
})