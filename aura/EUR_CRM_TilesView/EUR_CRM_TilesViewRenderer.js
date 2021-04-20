({
    rerender : function(cmp, helper){
        this.superRerender();
        if (!cmp.get('v.isReady')) {
            window.setTimeout($A.getCallback(function () {
                cmp.set('v.viewLimit', cmp.get('v.viewLimit') + cmp.get('v.pageViewSize'));
                cmp.set('v.isReady', true);
            }), 10);
        }
    },
});