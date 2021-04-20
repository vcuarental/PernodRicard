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

		hlpr.getSelectedItem(cmp, function(item) {
			cmp.set('v.initialValue', item);

			hlpr.getInitSearchData(cmp, function(data) {
				// var item = cmp.get('v.initialValue');
				hlpr.doInitLookup(cmp, item, data);
				cmp.set('v.isInitialized', true);
				// console.log('INITIALIZED!');
			});
		});
	},
	setSelection: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		if (cmp.get('v.itemId') && !hlpr.getSelection(cmp)) {
			hlpr.getSelectedItem(cmp, function(item) {
				if (cmp.get('v.isInitialized')) {
					// console.log('INITIALIZED! setSelection');
					return hlpr.setSelection(cmp, item);
				}
				cmp.set('v.initialValue', item);
			});
		} else if (!cmp.get('v.itemId')) {
			hlpr.setSelection(cmp, null);
		}
	}
})