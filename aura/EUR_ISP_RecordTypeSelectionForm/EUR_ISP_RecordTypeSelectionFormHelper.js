({
	getRecordTypes: function(cmp, sObjectApiName, callback) {
		var getPicklistValuesAction = cmp.get("c.getPicklistValues");
		getPicklistValuesAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			var data = [];
			if (response.getState() === "SUCCESS") {
				data = response.getReturnValue().RecordType;
			}
			callback(data)
		});
		$A.enqueueAction(getPicklistValuesAction);
	},
	setSelectedRecordType: function(cmp, data, selectedId) {
		;(data || []).forEach(function(item) {
			if (item.value && item.value === selectedId) {
				cmp.set('v.RecordType', {
					sobjectType: 'RecordType',
					Id: item.value,
					Name: item.label
				});
			}
		});
	},
	fireSelectEvent: function(cmp) {
		$A.get('e.c:EUR_ISP_SpendSaveEvent').setParams({
			RecordType: cmp.get('v.RecordType')
		}).fire();
		$A.get('e.c:EUR_ISP_ModalWindowCloseEvent').fire();
	}
})