({
	afterRender: function(cmp, hlpr) {
		var ret = this.superAfterRender();
		hlpr.cmpInit(cmp);
		return ret;
	},
	rerender: function(cmp, hlpr) {
		this.superRerender();
		hlpr.cmpInit(cmp);
	}
})