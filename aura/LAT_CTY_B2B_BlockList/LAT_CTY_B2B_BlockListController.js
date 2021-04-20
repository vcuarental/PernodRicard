({
    refreshGrid : function(objComponent, objEvent, objHelper) {
        var datFrom = null;
        var datTo = null;
        var boolActive = null;

        datFrom = objComponent.get('v.datFrom');
        datTo = objComponent.get('v.datTo');
        boolActive = objComponent.get('v.boolActive');

        objHelper.listBlocks(objComponent,datFrom, datTo, boolActive);
    }
})