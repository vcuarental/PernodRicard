/**
 * Created by User on 6/7/2018.
 */
({
    searchHelper: function (component, event, getInputkeyWord) {
        // call the apex class method
        var action = component.get("c.fetchAccount");
        var objName = component.get("v.objName");
        var recordId = component.get("v.recordId");
        // set param to method
        action.setParams({
            'objName': objName,
            'searchKeyWord': getInputkeyWord,
            'recordId': recordId
        });
        // set a callBack
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }

                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);

    },
    searchHelperById: function (component, event, getInputkeyWord) {
        // call the apex class method
        var action = component.get("c.getNameById");
        var objId = component.get("v.objId");
        var objName = component.get("v.objName");
        var lookupField = component.get("v.lookupField");
        // set param to method
        action.setParams({
            'objName': objName,
            'objId': objId,
            'lookupField': lookupField
        });
        // set a callBack
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('resp=', storeResponse);
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length > 0) {
                    component.set("v.selectedRecord", storeResponse[0]);

                    var forclose = component.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');


                    var forclose = component.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');

                    var lookUpTarget = component.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);

    },

    changeDataInObject: function (component, event, heplper) {
        var id = null;
        if (component.get('v.selectedRecord')) {
            id = component.get('v.selectedRecord').Id;
        }
        console.log('id = ',id);
        var fieldName = component.get('v.lookupField');
        component.getEvent('actionFieldChange').setParams({
            "fieldName": fieldName
            , "fieldValue": id
            , "objName": component.get('v.objName')
        }).fire();
    }

})