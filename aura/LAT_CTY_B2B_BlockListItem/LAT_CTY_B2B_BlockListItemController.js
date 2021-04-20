({
    activateInterval : function(objComponent, objEvent, objHelper) {
        var objBlock = null;
        var strRecordId = null;
        var boolStatus = null;

        objBlock = objComponent.get('v.block');
        if(objBlock !== undefined && objBlock !== null && objBlock.Id !== undefined && objBlock.Id !== null && objBlock.Id.length > 0) {
            strRecordId = objBlock.Id;
            boolStatus = true;

            objHelper.changeStatus(objComponent, strRecordId, boolStatus);
        }
    },
    deactivateInterval : function(objComponent, objEvent, objHelper) {
        var objBlock = null;
        var strRecordId = null;
        var boolStatus = null;

        objBlock = objComponent.get('v.block');
        if(objBlock !== undefined && objBlock !== null && objBlock.Id !== undefined && objBlock.Id !== null && objBlock.Id.length > 0) {
            strRecordId = objBlock.Id;
            boolStatus = false;

            objHelper.changeStatus(objComponent, strRecordId, boolStatus);
        }
    }
})