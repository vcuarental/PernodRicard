({
    getsObjectFieldList: function(component, helper, callback){
        var action = component.get("c.getSObjectFieldList");
        action.setParam('sObjectName',component.get("v.listsObjectName"));
        action.setCallback(this, helper.callbackHandlerGenerator(callback));
        $A.enqueueAction(action);
    },

    callbackHandler: function(response, callback)
    {
        var state = response.getState();
        if (state === "SUCCESS")
        {
            callback(null, response.getReturnValue());
        }
        else
        {
            callback(response.getError());
        }
    },

    callbackHandlerGenerator: function(callback)
    {
        return function(response)
        {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                callback(null, response.getReturnValue());
            }
            else
            {
                callback(response.getError());
            }
        }
    },

    getParentData: function(component, event)
    {
        var action = component.get("c.getParent");
        action.setParam("parentId", component.get("v.recordId"));

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set( "v.parent", response.getReturnValue() );
            }
        });

         $A.enqueueAction(action);
    },
})