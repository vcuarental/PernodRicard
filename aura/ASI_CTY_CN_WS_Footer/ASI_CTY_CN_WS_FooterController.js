({
	    init : function(component, event, helper) {
        var action = component.get('c.getHomeLinkMap');

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var rows = response.getReturnValue();
                var keys = [];
                for (var key in rows) {
                    keys.push(key);
                }
                component.set("v.linkMap", rows);

                var size = 100/(rows.size);
                component.set("v.RowPercent", size);
                component.set("v.keyList", keys);
            }else{
                console.log('error getHomeLinkList');
            }
        });
        
        $A.enqueueAction(action);

    }
})