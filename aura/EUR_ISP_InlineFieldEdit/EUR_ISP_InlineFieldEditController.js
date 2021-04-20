({
	doInitInlineEdit: function(cmp, e, hlpr) {
		if (!cmp.get('v.cmpId')) {
			var randomId = 'cmpId-' + Math.floor((Math.random() * 100000) + 1);
			randomId = randomId.replace(/\W*\s/gi, '');
			cmp.set('v.cmpId', randomId);
		}
	},
	doneRendering: function(cmp, e, hlpr) {
		if (!cmp.isValid() || !(window.$ && window.jQuery) || !window.$.fn.editable) {
			return;
		}
		hlpr.cmpInit(cmp);
	}
})