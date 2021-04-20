({
	doInit : function(component, event, helper) {
        helper.setup(component);
	},

	onDrag: function(component, event) {
    },

	setDroppedProducts: function(component, event, helper) {
        var params = event.getParam('arguments');
        helper.setDroppedProductsHandler(component, params);
    },
    
    setNoDragSelection : function(component, event, helper) {
    	var treeItemsCmpList = component.find('treeItemCmp');
        if(treeItemsCmpList) {
            [].concat(treeItemsCmpList).forEach(function(treeItemCmp) {
                treeItemCmp.setNoDragSelection();
            });
        }
    },

    onSelectAllProductChbxSelect: function (component, event, helper) {
        helper.onSelectAllProductChbxSelectHandler(component, event);
    },

    itemSelectionEvent: function (component, event, helper) {
        helper.itemSelectionEventHandler(component, event);
    },
})