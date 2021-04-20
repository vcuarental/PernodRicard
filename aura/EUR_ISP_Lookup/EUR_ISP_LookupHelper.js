({
	doInitLookup: function(cmp, selectedItem, initData) {
		var that = this;

		$('#' + cmp.get('v.id')).lookup({
			objectPluralLabel: cmp.get('v.pluralLabel'),
			objectLabel: cmp.get('v.label'),
			customObjectIcon: false,
			objectIconUrl: cmp.get('v.iconXlinkHref'),
			objectIconClass: cmp.get('v.iconClass'),
			initialSelection: selectedItem,
			emptySearchTermQuery: function(callback) {
				$A.run(function() {
					that.setSelectedItemId(cmp);
					callback(initData);
				});
			},
			filledSearchTermQuery: function(searchTerm, callback) {
				if (!searchTerm || searchTerm.length < 2) {
					return callback([]);
				}

				$A.run(function() {
					that.getSearchResults(cmp, searchTerm, function(results) {
						if (cmp.isValid()) {
							callback(results.filter(function(result) {
								return (result.label || '').toLowerCase().match((searchTerm || '').toLowerCase()) !== null;
							}));
						}
					});
				});
			},
			onChange: function(selection) {
				$A.run(function() {
					that.setSelectedItemId(cmp, selection)
				});
			}
		});
	},
	getSearchResults: function(cmp, searchTerm, callback) {
		if (!cmp.isValid()) {
			return callback([]);
		}

		var action = null;
		var sObjectAPIName = cmp.get('v.sObjectAPIName');
		if (sObjectAPIName === 'EUR_CRM_Account__c') {
			action = cmp.get('c.getAccounts');
			action.setParams({
				searchString: searchTerm
			});
		} else {
			action = cmp.get('c.getSelectionData');
			action.setParams({
				searchString: searchTerm,
				sObjectAPIName: cmp.get('v.sObjectAPIName')
			});
		}

		action.setCallback(this, function(response) {
			callback((cmp.isValid() && response.getState() === 'SUCCESS') ? response.getReturnValue() : []);
		});

		$A.enqueueAction(action);
	},
	getSelectedItem: function(cmp, callback) {
		if (!cmp.get('v.itemId')) {
			return callback(null);
		}

		var action = cmp.get('c.getSelectedData');
		action.setParams({
			sObjectId: cmp.get('v.itemId'),
			sObjectAPIName: cmp.get('v.sObjectAPIName')
		})
		action.setCallback(this, function(response) {
			callback((cmp.isValid() && response.getState() === 'SUCCESS') ? response.getReturnValue() : null);
		});

		$A.enqueueAction(action);
	},
	getInitSearchData: function(cmp, callback) {
		if (!cmp.isValid()) {
			return callback([]);
		}

		var action = null;
		var sObjectAPIName = cmp.get('v.sObjectAPIName');
		if (sObjectAPIName === 'EUR_CRM_Account__c') {
			action = cmp.get('c.getAccounts');
			action.setParams({
				searchString: ''
			});
		} else {
			action = cmp.get('c.getInitSelectionData');
			action.setParams({
				sObjectAPIName: sObjectAPIName
			});
		}

		action.setCallback(this, function(response) {
			callback((cmp.isValid() && response.getState() === 'SUCCESS') ? response.getReturnValue() : []);
		});

		$A.enqueueAction(action);
	},
	setSelectedItemId: function(cmp, selection) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.itemId', selection ? selection.id : null);
		this.setInputElementValue('#' + cmp.get('v.id'), selection)
	},
	setSelection: function(cmp, selection) {
		var elementId = '#' + cmp.get('v.id');
		if (selection) {
			$(elementId).lookup('setSelection', [selection]);
		}
		this.setInputElementValue(elementId, selection);
	},
	getSelection: function(cmp) {
		return $('#' + cmp.get('v.id')).lookup('getSelection');
	},
	setInputElementValue: function(elementId, selection) {
		$(elementId).val(selection ? selection.id : '');
	}
})