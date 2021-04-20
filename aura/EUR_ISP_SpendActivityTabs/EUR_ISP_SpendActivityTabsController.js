({
	switchTab: function(cmp, e, hlpr) {
		if (!cmp.isValid() || !e.target.dataset ||  !e.target.dataset.activityId) {
			return;
		}
		if (cmp.get('v.isTabSelected') !== true) {
			cmp.set('v.isTabSelected', true);
		}

		var activityId = e.target.dataset.activityId;
		if (activityId === cmp.get('v.activityId')) {
			return;
		}

		hlpr.switchTabs(e.target);
		hlpr.fireRenderBrandTable(cmp.get('v.Spend').Id, cmp.get('v.SpendActivityType'));

		cmp.set('v.activityId', activityId);
		var activities = cmp.get('v.activities') || [];
		var selectedActivity = hlpr.getSelectedActivity(activities, activityId);
		cmp.set('v.SpendActivity', selectedActivity);

		$A.get('e.c:EUR_ISP_SpendActivityShowEvent').fire();
		e.preventDefault();
		return false;
	},
	updateActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var SpendActivity = e.getParams().SpendActivity;
		var SpendActivityType = cmp.get('v.SpendActivityType');
		var TreeData = cmp.get('v.activitiesTree') || [];
		var activities = [];

		TreeData.forEach(function(Node) {
			Node.children.forEach(function(child) {
				if (child.Type.Id === SpendActivityType.Id) {
					var isNew = true;
					for (var i = 0; i < child.activities.length; i ++) {
						if (child.activities[i].Id === SpendActivity.Id) {
							child.activities[i] = SpendActivity;
							isNew = false;
						}
					}

					if (isNew) {
						Node.__count++;
						child.Type.__count++;
						child.activities.push(SpendActivity);
					}
					activities = child.activities;
				}
			});
		});

		hlpr.mapStatusToColors(activities);
		cmp.set('v.activitiesTree', TreeData);
		cmp.set('v.activityId', SpendActivity.Id);
		cmp.set('v.activities', activities);
		cmp.set('v.SpendActivity', SpendActivity);
	},
	confirmOnDelete: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var params = e.target.dataset;
		if (!params || !params.activityId) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions');
		if (!UserPermissions.EUR_ISP_Spend_Activity__c.theObject.isDeletable) {
			return;
		}

		//'Are you sure you want to delete Spend Activity ' + (params.activityName || '') + '?'
		////'This performance will release ' + (params.activityAmount || 'Activity amount') + ' to budget, click DELETE to continue'
		var msg = $A.get('$Label.c.EUR_ISP_ACTIVITY_DELETE') + ' ' + (params.activityName || '') + '?';
		msg += '<br/>';
		msg += $A.util.format($A.get('$Label.c.EUR_ISP_DELETE_ACTIVITY_TEXT'), (params.activityAmount || ' Activity amount '));

		cmp.set('v.activityToDeleteId', params.activityId);
		cmp.find('confirmation').showConfirmation(msg, 'Cancel', 'Delete');

		e.preventDefault();
		e.stopPropagation();
		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
		return false;
	},
	deleteActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid() || !cmp.get('v.activityToDeleteId')) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions');
		if (!UserPermissions.EUR_ISP_Spend_Activity__c.theObject.isDeletable) {
			return;
		}

		cmp.set('v.isLoading', true);
		var activityId = cmp.get('v.activityToDeleteId');
		hlpr.doActivityDelete(cmp, activityId, function(results) {
			if (results && results.length) {
				return;
			}

			var SpendActivityType = cmp.get('v.SpendActivityType');
			var TreeData = cmp.get('v.activitiesTree') || [];
			var activities = [];

			TreeData.forEach(function(Node) {
				Node.children.forEach(function(child) {
					if (child.Type.Id === SpendActivityType.Id) {
						Node.__count--;
						child.Type.__count--;
						child.activities.forEach(function(activity) {
							if (activity.Id !== activityId) {
								activities.push(activity);
							}
						});
						child.activities = activities;
					}
				});
			});

			cmp.set('v.activitiesTree', TreeData);
			cmp.set('v.activities', activities);
			if (activities.length && activities[0].Id !== cmp.get('v.activityId')) {
				cmp.set('v.activityId', activities[0].Id);
				cmp.set('v.SpendActivity', activities[0]);
			} else {
				cmp.set('v.activityId', null);
				cmp.set('v.SpendActivity', {sobjectType:'EUR_ISP_Spend_Activity__c'});
			}
			cmp.set('v.isLoading', false);
			$A.get('e.c:EUR_ISP_SpendActivityShowEvent').fire();
			$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
		});
		e.stopPropagation();
		return false;
	},
	doRenderActivityCreateForm: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions');
		if (!UserPermissions.EUR_ISP_Spend_Activity__c.theObject.isCreateable) {
			return;
		}

		cmp.set('v.activityId', null);
		cmp.set('v.SpendActivity', {sobjectType:'EUR_ISP_Spend_Activity__c'});
		$A.get('e.c:EUR_ISP_SpendActivityShowEvent').fire();
		hlpr.switchTabs(e.target);

		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	showTooltip: function(cmp, e, hlpr) {
		hlpr.showTooltip(e.target);
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	hideTooltip: function(cmp, e, hlpr) {
		hlpr.hideTooltip(e.target);
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	doActivitiesInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var params = e.getParams().arguments;
		if (!params || !params.activityTypeId) {
			return;
		}

		cmp.set('v.isTabSelected', true);

		var Spend = cmp.get('v.Spend');
		var SpendActivityType = cmp.get('v.SpendActivityType');
		var activities = [];

		;(cmp.get('v.activitiesTree') || []).forEach(function(Node) {
			Node.children.forEach(function(child) {
				if (child.Type.Id === params.activityTypeId) {

					SpendActivityType = child.Type;
					cmp.set('v.SpendActivityType', child.Type);
					activities = child.activities;
					cmp.set('v.activities', child.activities);
				}
			});
		});

		hlpr.fireRenderBrandTable(Spend.Id, SpendActivityType);
		if (!activities.length) {
			cmp.set('v.SpendActivity', {sobjectType:'EUR_ISP_Spend_Activity__c'});
			$A.get('e.c:EUR_ISP_SpendActivityShowEvent').fire();
			return;
		}

		hlpr.mapStatusToColors(activities);
		var activityId = cmp.get('v.activityId') || activities[0].Id;
		var selectedActivity = hlpr.getSelectedActivity(activities, activityId);
		selectedActivity = selectedActivity ? selectedActivity: activities[0];
		activityId = selectedActivity ? activityId : activities[0].Id;

		cmp.set('v.activityId', activityId);
		cmp.set('v.SpendActivity', selectedActivity);
		$A.get('e.c:EUR_ISP_SpendActivityShowEvent').fire();
	},
	doActivitiesRefresh: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var params = e.getParams().arguments;
		if (!params || !params.activities) {
			return;
		}

		var fieldsToRefresh = [
			'EUR_ISP_Status__c',
			'EUR_ISP_Approval_Status__c',
			'EUR_ISP_Total_Spend_Items_Amount__c',
			'EUR_ISP_Total_Spend_Activities_Amount__c',
			'colorClass',
			'formattedTotalActivityAmount'
		];
		var TreeData = cmp.get('v.activitiesTree') || [];
		hlpr.mapStatusToColors(params.activities);

		TreeData.forEach(function(Node) {
			Node.children.forEach(function(child) {
				params.activities.forEach(function(item) {
					child.activities.forEach(function(activity) {
						if (activity.Id === item.Id) {
							fieldsToRefresh.forEach(function(field) {
								activity[field] = item[field];
							});
						}
					});
				});
			});
		});

		cmp.set('v.activitiesTree', TreeData);
		if (cmp.get('v.isTabSelected')) {
			cmp.set('v.isTabSelected', false);
			cmp.set('v.isTabSelected', true);
			$A.get('e.c:EUR_ISP_SpendActivityShowEvent').fire();
		}
	},
	showLoading: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.isLoading', true);
		return false;
	},
	hideLoading: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.isLoading', false);
		return false;
	}
})