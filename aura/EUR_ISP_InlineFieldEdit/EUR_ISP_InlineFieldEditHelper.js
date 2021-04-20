({
	getTMPL: function() {
		return '<a href="javascript:void(0);"></a>';
	},
	getDateTMPL: function() {
		return ['<a href="javascript:void(0);"></a>',
				'<div class="slds-form-element slds-hide">',
					'<div class="slds-input-has-icon slds-input-has-icon--right">',
						'<input class="slds-input" type="text" placeholder="', $A.get('$Label.c.EUR_ISP_PICK_DATE_TEXT'),'" label="Date Picker">',
						'<svg aria-hidden="true" class="slds-input__icon slds-icon-text-default">',
							'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/EUR_ISP_SLDS/assets/icons/utility-sprite/svg/symbols.svg#event"></use>',
						'</svg>',
					'</div>',
				'</div>'
		].join(' ');
	},
	cmpInit: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}
		if (!$('#' + cmp.get('v.cmpId')).length) {
			return;
		}

		if (cmp.get('v.isInit')) {
			switch (cmp.get('v.type')) {
				case 'lookup':
					var val = cmp.get('v.value');
					if (cmp.find('lookup')) {
						var oldVal = cmp.find('lookup').get("v.selectedValue");
						if ((val && oldVal && val.Id !== oldVal.Id) ||
							(!val && oldVal) || (val && !oldVal)) {
							cmp.find('lookup').setValue(val && val.Id ? val.Id : '');
						}
					}

					this.setLookupValue(cmp);
				break;
				case 'date':
					this.setDateValue(cmp);
				break;
				default:
					this.setValue(cmp);
				break;
			}
			return;
		}

		switch (cmp.get('v.type')) {
			case 'lookup':
				this.initLookup(cmp);
			break;
			case 'date':
				this.initDatePicker(cmp);
			break;
			default:
				this.initInlineEdit(cmp);
			break;
		}

		cmp.set('v.isInit', true);
	},
	initInlineEdit: function(cmp) {
		var that = this;
		var options = {
			pk: cmp.get('v.pk') + Math.floor((Math.random() * 10000) + 1),
			value: cmp.get('v.value'),
			emptytext: cmp.get('v.emptytext'),
			title: cmp.get('v.title'),
			type: cmp.get('v.type'),
			mode: cmp.get('v.mode'),
			showbuttons: cmp.get('v.showbuttons'),
			onblur: 'submit',
			params: {
				cmp: cmp
			},
			url:function(params) {
				var d = new $.Deferred;
				setTimeout($A.getCallback(function() {
					if (!params.cmp.isValid()) {
						return;
					}

					params.field = cmp.get('v.pk');
					that.updateFieldValue(params, d);
				}), 0);
				return d.promise();
			}
		};

		switch (cmp.get('v.type')) {
			case 'select':
				options.source = cmp.get('v.source');
			break;
			case 'textarea':
				options.escape = cmp.get('v.escape');
				options.rows = parseInt(cmp.get('v.rows'), 10);
				options.validate = function (value) {
					value = $.trim(value);
					if (value && value.length > 255) {
						return 'This value is too long. Only 255 symbols are allowed.';
					}
					return '';
				};
			break;
			case 'number':
				var IsoCode = cmp.get('v.IsoCode');
				var isCurrencyNumber = !!IsoCode;
				var emptyText = cmp.get('v.emptytext');
				options.type = 'text';
				options.display = function(value) {
					var currString = value;
					if (isCurrencyNumber) {
						if (value && value != 0) {
							currString = $A.localizationService.formatCurrency(value);
							currString = currString.replace(/[^\d+\,\.]/g, '');
							currString = IsoCode + ' ' + currString;
						} else {
							currString = emptyText;
						}
					} else {
						currString = value ? $A.localizationService.formatNumber(value) : emptyText;
					}
					$(this).text(currString);
				};
			break;
		}

		var $tmpl = $(this.getTMPL()).addClass(cmp.get('v.class'));
		$('#' + cmp.get('v.cmpId')).append($tmpl);
		$tmpl.editable(options);
	},
	initDatePicker: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}

		var that = this;
		var $cmp = $('#' + cmp.get('v.cmpId'));
		$cmp.append(this.getDateTMPL());

		var $input = $cmp.find('input');
		var $a = $cmp.find('a');

		$a.text(cmp.get('v.value') ? moment(cmp.get('v.value')).format('DD/MM/YYYY'): cmp.get('v.emptytext'))
			.addClass(cmp.get('v.class'))
			.off('click')
			.on('click', function() {
				$(this).addClass('slds-hide')
				var $div = $(this).next();
				setTimeout(function() {
					$div.removeClass('slds-hide').find('input').focus();
				}, 100);
			});

		$input.datepicker({
			format: 'DD/MM/YYYY'
		})
		.off('aljs.datepicker.close').on('aljs.datepicker.close', function() {
			//console.log('CLOSED');
			$a.removeClass('slds-hide').next().addClass('slds-hide');
		})
		.off('aljs.datepicker.clear').on('aljs.datepicker.clear', function() {
			//console.log('CLEAR');
			if (!cmp.get('v.value')) {
				return;
			}

			cmp.set('v.value', null);
			var defCallback = new $.Deferred;
			that.updateFieldValue({
				field: cmp.get('v.pk'),
				value: null,
				cmp: cmp
			}, defCallback);

			defCallback.promise().done(function() {
				//console.log('results: ', arguments);
			});
		})
		.off('aljs.datepicker.select').on('aljs.datepicker.select', function(e, selection) {
			//console.log('SELECT')
			if (!cmp.get('v.isInit')) {
				return;
			}
			
			var momentDate = $input.datepicker('getDate');
			if (momentDate instanceof moment) {
				//console.log('values', cmp.get('v.value'), momentDate.format('YYYY-MM-DD'));
				if (!momentDate.isSame(cmp.get('v.value'))) {
					var dateValue = momentDate.format('YYYY-MM-DD');
					cmp.set('v.value', dateValue);
					$a.text(momentDate.format('DD/MM/YYYY'));

					var defCallback = new $.Deferred;
					that.updateFieldValue({
						field: cmp.get('v.pk'),
						value: dateValue,
						cmp: cmp
					}, defCallback);

					defCallback.promise().done(function() {
						//console.log('results: ', arguments);
					});
				}
			}
		});
		if (cmp.get('v.value')) {
			this.setDateValue(cmp);
		}
	},
	initLookup: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}

		var that = this;
		var $cmp = $('#' + cmp.get('v.cmpId'));
		$cmp.append(this.getTMPL());

		var initValue = cmp.get('v.value');
		cmp.find('lookup').setValue(initValue && initValue.Id ? initValue.Id : '');
		that.setLookupValue(cmp);

		$cmp.children('a')
			.addClass(cmp.get('v.class'))
			.off('click')
			.on('click', function() {
				$(this).addClass('slds-hide');
				var $div = $cmp.children('div');
				$div.removeClass('slds-hide');

				setTimeout(function() {
					$div.find('input').focus();
				}, 100);
			});

		$cmp.find('input')
		.off('aljs.lookup.close').on('aljs.lookup.close', function() {
			//console.log('CLOSED');
		})
		.off('aljs.lookup.clear').on('aljs.lookup.clear', function() {
			//console.log('CLEAR');
			var defCallback = new $.Deferred;
			that.updateFieldValue({
				field: cmp.get('v.pk'),
				value: null,
				cmp: cmp
			}, defCallback);

			defCallback.promise().done(function() {
				//console.log('lookup results: ', arguments);
			});
			// cmp.set('v.value', null);
		})
		.off('aljs.lookup.blur').on('aljs.lookup.blur', function() {
			//console.log('BLUR');

			that.setLookupValue(cmp);
		})
		.off('aljs.lookup.select').on('aljs.lookup.select', function(e, selection) {
			var val = cmp.find('lookup').get("v.selectedValue");
			//console.log('select', val);
			var oldVal = cmp.get('v.value');
			if ((!val && !oldVal) || 
				(val && oldVal && val.Id === oldVal.Id)) {
				return;
			}

			var defCallback = new $.Deferred;
			that.updateFieldValue({
				field: cmp.get('v.pk'),
				value: val,
				cmp: cmp
			}, defCallback);

			defCallback.promise().done(function() {
				//console.log('lookup results: ', arguments);
			});
		});
	},
	setValue: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}
		// console.log("cmp.get('v.pk')" , cmp.get('v.pk'));
		// console.log("cmp.get('v.value')" , cmp.get('v.value'));
		$('#' + cmp.get('v.cmpId')).find('a').editable('setValue', cmp.get('v.value') ? cmp.get('v.value') : '');
	},
	setDateValue: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}

		var $cmp = $('#' + cmp.get('v.cmpId'));
		$cmp.children().addClass('slds-hide');
		$cmp.children('a').removeClass('slds-hide');

		if (!cmp.get('v.value')) {
			$cmp.find('a').text(cmp.get('v.emptytext'));
			$cmp.find('input').datepicker('setDate', null);
			return;
		}

		$cmp.find('input').datepicker('setDate',  moment(cmp.get('v.value')).format('YYYY-MM-DD') );
		$cmp.find('a').text( moment(cmp.get('v.value')).format('DD/MM/YYYY') );
	},
	setLookupValue: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}

		var initValue = cmp.get('v.value');
		var $cmp = $('#' + cmp.get('v.cmpId'));
		$cmp.children('div').addClass('slds-hide');
		$cmp.children('a').removeClass('slds-hide');

		if (initValue && initValue.Id) {
			if (cmp.get('v.lookupObjectApiName') === 'EUR_ISP_Vendor__c') {
				$cmp.children('a').text(initValue.EUR_ISP_Vendor_Name__c || initValue.Name);
			} else {
				$cmp.children('a').text(initValue.Name);
			}
		} else {
			$cmp.find('a').text(cmp.get('v.emptytext'));
		}
	},
	updateFieldValue: function(params, defCallback) {
		var val = params.value;
		if (params.cmp.get('v.type') === 'number') {
			val = parseFloat(val, 10);
		}
		//console.log(params, val);
		params.cmp.set('v.value', val);
		params.cmp.getEvent("updateEvent").fire();
		setTimeout($A.getCallback(function() {
			defCallback.resolve();
		}), 500);

		// var theObject = {
		// 	sobjectType: params.cmp.get('v.sObjectApiName'),
		// 	Id: params.cmp.get('v.sObjectId'),
		// };
		// theObject[params.pk] = val;

		// console.log('update object: ', theObject);

		// var updateAction = params.cmp.get("c.updateField");
		// updateAction.setParams({
		// 	theObject: theObject
		// });
		// updateAction.setCallback(this, function(response) {
		// 	var errs = response.getReturnValue();
		// 	if (response.getState() === "SUCCESS" && (!errs || !errs.length)) {
		// 		params.cmp.set('v.value', val);
		// 		params.cmp.getEvent("updateEvent").fire();
		// 		return defCallback.resolve();
		// 	}

		// 	if (errs && errs.length) {
		// 		defCallback.reject(errs[0]);
		// 	} else {
		// 		defCallback.reject('Fatal Error!');
		// 	}
		// });
		// $A.enqueueAction(updateAction);
	}
})