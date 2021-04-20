({
	refreshView: function(cmp, e, hlpr) {
		var params = e.getParams().arguments.config;
		hlpr.refreshTreeParams(cmp, params);
	},
	setNewActivities: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.set('v.isRefreshing', true);
		hlpr.setNewActivities(cmp, function(treeData) {
			cmp.set('v.activitiesTree', treeData);
			if (cmp.get('v.selectedTypeId')) {
				hlpr.setActivityType(cmp, treeData, cmp.get('v.selectedTypeId'));
			}
			cmp.set('v.isRefreshing', false);
		});
	},
	selectActivityType: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams() : e.target.dataset;
		if (params.activityTypeId) {
			var treeData = cmp.get('v.activitiesTree');
			hlpr.setActivityType(cmp, treeData, params.activityTypeId);
		}
	},
	refreshTreeData: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.find('tabs').showLoading();
		hlpr.getSpendActivityTypesByRecType(cmp, function(types) {
			hlpr.getActivitiesByType(cmp, types, function(typeToActivities) {
				var treeData = [];
				for (var id in typeToActivities) {
					if (typeToActivities.hasOwnProperty(id)) {
						treeData = treeData.concat(typeToActivities[id])
					}
				}

				var tabsCmp = cmp.find('tabs');
				tabsCmp.doActivitiesRefresh(treeData);
				tabsCmp.hideLoading();
			});
		});
	}
})