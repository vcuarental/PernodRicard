({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.get('v.id')) {
			var randomId = cmp.get('v.label') + '-id-' + Math.floor((Math.random() * 10000) + 1);
			randomId = randomId.replace(/\W*\s/gi, '');
			cmp.set('v.id', randomId);
		}
	},
	afterScriptsLoaded: function(cmp, e, hlpr) {
		if (!window.$ || !window.jQuery || !window.$.aljsInit) {
			return;
		}

		if (!$.aljs.scoped) {
			$.aljsInit({
				assetsLocation: '/resource/EUR_ISP_SLDS',
				scoped: true
			});
		}
	},
	setSelection: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams().arguments: e.target.dataset;
		if (params && params.valueId) {
			hlpr.getSelectedItem(cmp, params.valueId, function(item) {
				if (cmp.get('v.isInitialized') && item) {
					hlpr.setSelection(cmp, item);
				}
			});
		} else {
			if (cmp.get('v.isInitialized')) {
				hlpr.setSelection(cmp);				
			}
		}
	}
})