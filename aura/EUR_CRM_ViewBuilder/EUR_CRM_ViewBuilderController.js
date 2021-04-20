({
	doInit : function(component, event, helper) {
        helper.setup(component);
	},

    setCategories : function(component, event, helper) {
        var params = event.getParam('arguments');
        helper.setCategoriesHandler(component, params);
    },

	onDrag: function(component, event) {
        
    },

    onDrop: function(component, event) {
        event.stopPropagation();
        event.preventDefault();
    },

    updateHierarchy: function(cmp, event, helper) {
        helper.updateHierarchyEventHandler(cmp, event, helper);
    },

    changeCategoryEvent: function(cmp, event, helper) {
        helper.changeCategoryEventHandler(cmp, event, helper);
    },
    
    validateItems: function(cmp, event, helper) {
    	var vbis = cmp.find("viewItemsBuilderCmp");
    	var isValid = true;
    	[].concat(vbis).forEach(function(vbi) {
        	var isItemValid = vbi.doValidate();
        	if(isItemValid == false){
        		isValid = false;
        		return isValid;
        	}
        });
        return isValid;
    }
})