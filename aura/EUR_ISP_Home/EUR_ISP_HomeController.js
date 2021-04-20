({
	switchTab: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		hlpr.switchTabs(e.target);
		e.preventDefault();
		return false;
	}
})