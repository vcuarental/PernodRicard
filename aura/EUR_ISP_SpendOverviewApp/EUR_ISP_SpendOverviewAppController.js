({
	afterScriptsLoaded: function(cmp) {
		if (!(window.$ && window.jQuery) || !window.$.aljsInit) {
			return;
		}

		if (!$.aljs.scoped) {
			$.aljsInit({
				assetsLocation: '/resource/EUR_ISP_SLDS',
				scoped: true
			});
		}
		cmp.set('v.isScriptsLoaded', true);
	},
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		hlpr.getSystemConfig(cmp, function(config) {
			if (!config) {
				return;
			}

			if (config.theUser) {
				cmp.set('v.User', config.theUser);
			}
			if (config.settings && config.settings.length) {
				cmp.set('v.SystemSettings', config.settings[0]);
			}
			var UserPermissions = {};
			if (config.objectPermissions) {
				UserPermissions = config.objectPermissions;
			}
			UserPermissions.PROJECT_NAME = config.projectName ? config.projectName: '';
			cmp.set('v.UserPermissions', UserPermissions);
		});

		if (cmp.get('v.viewName')) {
			return;
		}

		if (cmp.get('v.settlementId')) {
			return hlpr.showSettlement(cmp);
		}
		cmp.set('v.viewName', 'HOME');
	},
	doShowScreen: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var prevPage = e.getParams().prevPageAPI;
		if (prevPage === 'HOME') {
			return hlpr.showHome(cmp);
		}
		if (prevPage === 'SPEND') {
			return hlpr.showSpend(cmp);
		}
		if (prevPage === 'SPENDCREATE') {
			return hlpr.showCreate(cmp);
		}
	},
	doShowSettlement: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.settlementId', e.getParams().settlementId);
		hlpr.showSettlement(cmp);
	},
	doShowSpendRecord: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams();
		cmp.set('v.viewName', 'SPENDINFO');
		cmp.find('spendInfo').renderSpendItem(params);
	},
	doShowSpendOverview: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.showSpend(cmp);
	}
})