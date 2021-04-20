({
	fireRenderBrandTable: function(spendId, activityType) {
		$A.get("e.c:EUR_ISP_BrandCmpTableShowEvent").setParams({
			spendId   : spendId,
			objectName: activityType.EUR_ISP_Product_Level_Of_Input__c
		}).fire();
	},
	switchTabs: function(target) {
		var $tabsCmp = $('#activityTabs');
		$tabsCmp.find('li.slds-active').removeClass("slds-active");
		$(target).closest('li').addClass("slds-active");
	},
	showTooltip: function(target) {
		var nubbinHeight = 15;
		var $target = $(target).closest('a');
		var $targetTab = $(target)
			.closest('li')
			.css('overflow', 'visible');
		var $popover = $targetTab.find('div.slds-popover');

		if ($popover.hasClass('slds-show')) {
			return;
		}

		$popover
			.css({
				'position': 'absolute',
				'width': $popover.innerWidth() + 'px',
				'left': ($target.innerWidth() / 2) - ($popover.innerWidth() / 2) + 'px',
				'top': '-' + ($popover.innerHeight() + nubbinHeight) + 'px'
			})
			.removeClass("slds-hide")
			.addClass("slds-show");
	},
	hideTooltip: function(target) {
		$(target)
			.closest('li')
			.css('overflow', 'hidden')
			.find('div.slds-popover')
			.removeClass("slds-show")
			.addClass("slds-hide");
	},
	doActivityDelete: function(cmp, activityId, callback) {
		var action = cmp.get("c.deleteSpendActivity");
		action.setParams({
			activityId: activityId
		});
		action.setCallback(this, function(response) {
			if (cmp.isValid() && response.getState() === "SUCCESS") {
				callback();
			} else {
				callback(response.getError());
			}
			
		});
		$A.enqueueAction(action);
	},
	getSelectedActivity: function(activities, activityId) {
		var selectedActivityArr = activities.filter(function(item) {
			if (item.Id && item.Id === activityId) {
				return true;
			} else {
				return false;
			}
		});
		return selectedActivityArr.length ? selectedActivityArr[0] : null;
	},
	mapStatusToColors: function(activities) {
		var statusToColorMapping = {
			"Pending:Ringfence"           : "tab--blue",
			"Pending:Planned"             : "tab--blue",
			"Pending:Committed"           : "tab--blue",
			"Awaiting Approval:Committed" : "tab--orange",
			"Approved:Committed"          : "tab--green",
			"Approved:Invoiced"           : "tab--green",
			"Rejected:Committed"          : "tab--red"
		};

		activities.forEach(function(item) {
			var aSt = item.EUR_ISP_Approval_Status__c;
			var st = item.EUR_ISP_Status__c;
			item.colorClass = '';

			if (aSt && st && statusToColorMapping[aSt + ':' + st]) {
				item.colorClass = statusToColorMapping[aSt + ':' + st];
			}

			var currString = $A.localizationService.formatCurrency(item.EUR_ISP_Total_Activity_Amount__c || 0);
			currString = currString.replace(/[^\d+\,\.]/g, '');
			item.formattedTotalActivityAmount = item.CurrencyIsoCode + ' ' + currString;
		});
	}
})