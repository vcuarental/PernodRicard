({
	cmpInit: function(cmp) {
		if (!cmp.isValid() || !$('#' + cmp.get('v.id')).length) {
			return;
		}

		if (!cmp.get('v.isInitialized')) {
			this.initDatepicker(cmp);
		} else {
			this.setDate(cmp);
		}
	},
	initDatepicker: function(cmp) {
		var initDateValue = moment();
		if (cmp.get('v.dateValueDt')) {
			initDateValue = moment(cmp.get('v.dateValueDt'));
		}
		if (cmp.get('v.dateValueStr')) {
			initDateValue = moment().format(cmp.get('v.dateValueStr'), cmp.get('v.dateFormat'));
		}

		$('#' + cmp.get('v.id')).datepicker({
			format: cmp.get('v.dateFormatView'),
			initDate: initDateValue,
			onChange: function(datepicker) {
				setTimeout($A.getCallback(function() {
					if (!cmp.get('v.isInitialized')) {
						return;
					}

					var momentDate = $('#' + cmp.get('v.id')).datepicker('getDate');
					if (momentDate instanceof moment) {
						if (!momentDate.isSame(cmp.get('v.dateValueStr'))) {
							cmp.set('v.dateValueDt', momentDate.toDate());
							cmp.set('v.dateValueStr', momentDate.format(cmp.get('v.dateFormat')));
						}
					} else {
						cmp.set('v.dateValueDt', null);
						cmp.set('v.dateValueStr', null);
					}
				}), 0);
			}
		});
		cmp.set('v.isInitialized', true);
	},
	setDate: function(cmp) {
		if (!cmp.get('v.isInitialized')) {
			return;
		}

		var dateToSetup;
		if (cmp.get('v.dateValueDt')) {
			dateToSetup = moment(cmp.get('v.dateValueDt'));
		} else if (cmp.get('v.dateValueStr')) {
			dateToSetup = moment().format(cmp.get('v.dateValueStr'), cmp.get('v.dateFormat'));
		}

		if (dateToSetup) {
			setTimeout($A.getCallback(function() {
				//$('#' + cmp.get('v.id')).datepicker('setDate', null);
				$('#' + cmp.get('v.id')).datepicker('setDate', dateToSetup);
			}), 100);
		}
	}
})