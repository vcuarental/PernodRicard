({
	cmpInit: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}

		if (!$('#' + cmp.get('v.id')).length || cmp.get('v.isInitialized')) {
			return;
		}

		var that = this;
		that.getInitSearchData(cmp, function(data) {
			that.doInitLookup(cmp, data);
		});
	},
	doInitLookup: function(cmp, initData) {
		if (!cmp.isValid()) {
			return;
		}

		var that = this;
		var $targetInput = $('#' + cmp.get('v.id')).find('input');
		$targetInput.lookup({
			objectPluralLabel: cmp.get('v.pluralLabel'),
			objectLabel: cmp.get('v.label'),
			customObjectIcon: false,
			objectIconUrl: cmp.get('v.iconXlinkHref'),
			objectIconClass: cmp.get('v.iconClass'),
			emptySearchTermQuery: function(callback) {
				setTimeout($A.getCallback(function() {
					cmp.set('v.selectedValue', null);
					var sObjectAPIName = cmp.get('v.sObjectAPIName');
					if (sObjectAPIName !== 'EUR_ISP_Vendor__c') {
						return callback(initData);
					}

					that.getInitSearchData(cmp, function(data) {
						callback(data);
					});
				}), 0);
			},
			filledSearchTermQuery: function(searchTerm, callback) {
				if (!searchTerm || searchTerm.length < 2) {
					return callback([]);
				}

				setTimeout($A.getCallback(function() {
					that.getSearchResults(cmp, searchTerm, function(results) {
						if (cmp.isValid()) {
							callback(results.filter(function(result) {
								return (result.label || '').toLowerCase().match((searchTerm || '').toLowerCase()) !== null;
							}));
						}
					});
				}), 0);
			},
			onChange: function(selection) {
				// try {
				//setTimeout($A.getCallback(function() {
				if (cmp.isValid()) {
					var tempSelection = cmp.get('v.selectedValue');
					if ((!selection && !tempSelection) || 
						(selection && tempSelection && tempSelection.Id === selection.id)) {
						return;
					}

					if (!selection) {
						cmp.set('v.selectedValue', null);
						return;
					}

					cmp.set('v.selectedValue', {
						sobjectType: cmp.get('v.sObjectAPIName'),
						Id: selection.id,
						Name: selection.label
					});
				}
				//}), 0);
				// } catch (e) {console.error(e);}
			}
		});

		cmp.set('v.isInitialized', true);
	},
	getSearchResults: function(cmp, searchTerm, callback) {
		if (!cmp.isValid()) {
			return callback([]);
		}

		var action = null;
		var sObjectAPIName = cmp.get('v.sObjectAPIName');

		if (sObjectAPIName === 'EUR_ISP_Vendor__c') {
			var dependentValue = cmp.get('v.dependentValue');
			if (!dependentValue || !dependentValue.Id) {
				return callback([]);
			}

			action = cmp.get('c.getVendors');
			action.setParams({
				searchString: '',
				accountId   : dependentValue.Id
			});
		}
		else if (sObjectAPIName === 'EUR_CRM_Account__c') {
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
	getSelectedItem: function(cmp, itemId, callback) {
		var action = cmp.get('c.getSelectedData');
			action.setParams({
				sObjectId: itemId,
				sObjectAPIName: cmp.get('v.sObjectAPIName')
			})
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}

				var data = null;
				if (response.getState() === 'SUCCESS') {
					data = response.getReturnValue();
				}
				callback(data);
			});
		$A.enqueueAction(action);
	},
	getInitSearchData: function(cmp, callback) {
		if (!cmp.isValid()) {
			return callback([]);
		}

		var action = null;
		var sObjectAPIName = cmp.get('v.sObjectAPIName');
		
		if (sObjectAPIName === 'EUR_ISP_Vendor__c') {
			var dependentValue = cmp.get('v.dependentValue');
			if (!dependentValue || !dependentValue.Id) {
				return callback([]);
			}

			action = cmp.get('c.getVendors');
			action.setParams({
				searchString: '',
				accountId   : dependentValue.Id
			});
		}
		else if (sObjectAPIName === 'EUR_CRM_Account__c') {
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
	setSelection: function(cmp, selection) {
		if (!cmp.isValid()) {
			return;
		}

		if (!selection || !selection.id) {
			$('#' + cmp.get('v.id')).find('input').lookup('setSelection', []);
			cmp.set('v.selectedValue', null);
			return;
		}

		$('#' + cmp.get('v.id')).find('input').lookup('setSelection', [selection]);
		cmp.set('v.selectedValue', {
			sobjectType: cmp.get('v.sObjectAPIName'),
			Id: selection.id,
			Name: selection.label
		});
	},
	getSelection: function(cmp) {
		if (cmp.isValid()) {
			return $('#' + cmp.get('v.id')).find('input').lookup('getSelection');
		}
	}
})