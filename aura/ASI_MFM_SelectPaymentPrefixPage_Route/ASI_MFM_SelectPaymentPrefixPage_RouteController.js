({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
      
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");        
		$A.get('e.force:refreshView').fire();
       
    }
})