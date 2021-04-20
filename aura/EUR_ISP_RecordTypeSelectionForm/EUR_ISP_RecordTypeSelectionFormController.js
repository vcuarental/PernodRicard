({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var sObjectApiName = cmp.get('v.sObjectApiName');
		hlpr.getRecordTypes(cmp, sObjectApiName, function(data) {
			if (data.length === 1) {
				hlpr.setSelectedRecordType(cmp, data, data[0].value);
				hlpr.fireSelectEvent(cmp);
				return;
			}
			cmp.set('v.options', data);
			cmp.set('v.isLoaded', true);
		});
	},
	onSelect: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var options = cmp.get('v.options');
		var selectedId = cmp.get('v.recordTypeId');
		hlpr.setSelectedRecordType(cmp, options, selectedId);
	},
	selectEvent: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.fireSelectEvent(cmp);
	}
})