({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.get('v.tableId')) {
			var randomId = 'table-Id-' + Math.floor((Math.random() * 10000) + 1);
			randomId = randomId.replace(/\W*\s/gi, '');
			cmp.set('v.tableId', randomId);
		}
		hlpr.doParseResults(cmp);
	}
})