({
    render: function(cmp, hlpr){
        return this.superRender();
    },
    afterRender: function(cmp, hlpr) {
        var ret = this.superAfterRender();
       	hlpr.cmpInit(cmp);
        return ret;
    },
    rerender: function(cmp, hlpr) {
        return this.superRerender();
    }
})