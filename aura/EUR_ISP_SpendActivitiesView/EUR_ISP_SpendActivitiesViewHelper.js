({
	refreshTreeParams: function(cmp, params) {
		cmp.set('v.selectedTypeId', params && params.spendTypeId ? params.spendTypeId : null);

		if (params && params.spendId  && cmp.get('v.spendId') !== params.spendId) {
			cmp.set('v.spendId', params.spendId);
			cmp.set('v.activitiesTree', []);
		}
		if (params && params.spendTypeId && params.spendActivityId) {
			cmp.find('tabs').set('v.activityId', params.spendActivityId);
		}
		// ;(cmp.find('brands') || []).forEach(function(_cmp) {
		// 	_cmp.hideTable();
		// });
	},
	setNewActivities: function(cmp, callback) {
		var that = this;
		var categoryValues = [];
		var typeSettings = cmp.get('v.UserPermissions.EUR_ISP_Spend_Activity_Type__c');
		typeSettings.fields.EUR_ISP_Category__c.picklistValues.forEach(function(item) {
			categoryValues.push(item.value);
		});

		that.getSpendActivityTypesByRecType(cmp, function(types) {
			that.getActivitiesByType(cmp, types, function(typeToActivities) {
				;(types || []).sort(function(a, b) {
					return categoryValues.indexOf(a.EUR_ISP_Category__c) - categoryValues.indexOf(b.EUR_ISP_Category__c);
				});
				var treeData = that.getActivityTree(types, typeToActivities);
				callback(treeData || []);
			});
		});
	},
	setActivityType: function(cmp, treeData, typeId) {
		cmp.set('v.selectedTypeId', typeId);
		cmp.find('tree').expandNode(typeId);
		cmp.find('tabs').doActivitiesInit(typeId);
	},
	getActivityTree: function(types, typeToActivities) {
		types = types || [];
		typeToActivities = typeToActivities || {};
		var tempTree = {};
		var treeData = [];

		types.forEach(function(type) {
			var Node = tempTree[type.EUR_ISP_Category__c];
			var activities = typeToActivities[type.Id] || [];
			var activitiesLength = activities.length;

			if (!Node) {
				Node = {
					__NodeName : type.EUR_ISP_Category__c,
					__count    : 0,
					children   : []
				};
			}

			type.__Name = type.EUR_ISP_Spend_Activity_Type_Name__c;
			type.__count = activitiesLength;

			Node.__count += activitiesLength;
			Node.children.push({
				Type       : type,
				activities : activities
			});
			tempTree[type.EUR_ISP_Category__c] = Node;
		});

		for (var nodeName in tempTree) {
			if (!tempTree.hasOwnProperty(nodeName)) {
				continue;
			}
			treeData.push(tempTree[nodeName]);
		}
		return treeData;
	},
	getSpendActivityTypesByRecType: function(cmp, callback) {
		var action = cmp.get('c.getActivityTypesBySpendRecType');
		action.setParams({
			spendId : cmp.get('v.spendId')
		});
		action.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}
			callback(response.getReturnValue() || []);
		});
		$A.enqueueAction(action);
	},
	getActivitiesByType: function(cmp, types, callback) {
		var activityTypeIds = [];
		(types || []).forEach(function(type) {
			activityTypeIds.push(type.Id);
		});

		var action = cmp.get('c.getISPendActivitiesByIdAndType');
		action.setParams({
			spendId         : cmp.get('v.spendId'),
			activityTypeIds : activityTypeIds
		});
		action.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}
			callback(response.getReturnValue() || {});
		});
		$A.enqueueAction(action);
	}
})