({
    move : function (cmp, event) {
        var evt = cmp.getEvent('onDetailsCardMove');
        evt.setParams({
            'who' : cmp.get('v.who'),
            'direction' : event.getSource().get('v.name'),
            'position' : cmp.get('v.position')
        });
        evt.fire();
    }
});