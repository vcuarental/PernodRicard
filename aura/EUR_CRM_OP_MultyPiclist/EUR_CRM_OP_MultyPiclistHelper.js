/**
 * Created by User on 6/1/2018.
 */
({
    fillMultyPiclist: function (component,event,helper) {
        var options = [
        ];
        var action = component.get("c.getMultyPiclistFields");
        component.set("v.listOptions", options);
        action.setParams({
            devName:component.get('v.devName'),
            recordId: component.get('v.recordId'),
            fieldName: component.get('v.fieldName')
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {
                var resultArray = JSON.parse(response.getReturnValue());
                var options = [];
                resultArray.forEach(function(result)  {
                    options.push({ value: result.fieldApiName, label: result.fieldLabel});
                });
                component.set("v.listOptions", options);
                if(resultArray[0] && resultArray[0].value) {
                    var items = [];
                    var arr = resultArray[0].value.split(',');
                    for (var y = 0; y < arr.length; y++) {
                        items.push(arr[y]);
                    }
                    component.set("v.selectedArray", items);

                    component.getEvent('actionFieldChange').setParams({
                        "fieldName" : component.get('v.fieldName')
                        ,"fieldValue" : items.toString()
                        ,"objName" : "EUR_CRM_OP_Action__c"
                    }).fire();
                }

            } else {
                console.log('Failed with state: ' + state);
            }
        });
        $A.enqueueAction(action);
    }
})