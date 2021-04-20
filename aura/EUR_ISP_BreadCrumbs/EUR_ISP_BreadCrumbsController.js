({
	renderNavigation: function(cmp, e) {
		var config = e.getParams();
		cmp.set('v.prevPageTitle', config.prevPageTitle);
		cmp.set('v.curPageTitle', config.curPageTitle);
		cmp.set('v.prevPage', config.prevPageAPI);
	},
	navigateToHome: function(cmp, e) {
		$A.get('e.c:EUR_ISP_NavigateToPrevPageEvent').setParams({
			prevPageAPI: 'HOME'
		}).fire();
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	navigateToSearch: function(cmp, e) {
		$A.get('e.c:EUR_ISP_NavigateToPrevPageEvent').setParams({
			prevPageAPI: 'SPEND'
		}).fire();
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	navigateToCreate: function(cmp, e) {
		$A.get('e.c:EUR_ISP_NavigateToPrevPageEvent').setParams({
			prevPageAPI: 'SPENDCREATE'
		}).fire();
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	navigateToPrev: function(cmp, e) {
		$A.get('e.c:EUR_ISP_NavigateToPrevPageEvent').setParams({
			prevPageAPI: cmp.get('v.prevPage')
		}).fire();
		e.preventDefault();
		e.stopPropagation();
		return false;
	}
})