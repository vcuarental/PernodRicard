({
	doInit : function(cmp, event, helper) {
        var itemData = helper.parseItem(cmp);
        if(itemData.children.length > 0) helper.changeIcon(cmp, "utility:chevrondown");
        if(itemData.checked) cmp.find('selectProductChbx').set('v.checked', itemData.checked);
        if(itemData.collapsed) {
            cmp.set("v.itemData", itemData);
            helper.toggleNodeExpand(cmp, true);
        } else {
            itemData.childrenRendered = itemData.children;
            cmp.set("v.itemData", itemData);
        }
        
        if(cmp.get("v.draggable")){
        	var draggedProducts = cmp.get("v.draggedProducts");
        	var item = cmp.get("v.item");
	        var isBuffered = helper.checkIsInBuffer(cmp,draggedProducts,itemData);
	        window.setTimeout($A.getCallback(function() {
                cmp.set("v.isDragSelected",isBuffered);
            }), 1);
        }
        
	},

    onToggleExpand : function(cmp, event, helper) {
        helper.toggleNodeExpand(cmp, false);
        event.stopPropagation();
	},

    onItemSelect: function(cmp, event, helper) {
        helper.handleSelectItems(cmp, event, helper);
    },

    itemSelectionEvent: function(cmp, event, helper) {
        helper.itemSelectionEventHandler(cmp, event);
    },

    checkItem: function(cmp, event, helper) {
        helper.checkItemHandler(cmp, event, helper);
    },

    setDroppedProducts: function(cmp, event, helper) {
        helper.setDroppedProductsHandler(cmp, event, helper);
    },
    
    onDrag: function(cmp, event, helper) {
        helper.onDragHandler(cmp, event);
    },
    
    onDrop: function(cmp, event, helper) {
        event.stopPropagation();
        event.preventDefault();
    },

    onDragOver : function(cmp, event, helper) {
        event.preventDefault();
    },
    onNodeClick : function(cmp, event, helper) {
    	var isDraggable = cmp.get("v.draggable");
    	if(isDraggable){
    		if (event.shiftKey){
	    		/* Would be desirable to add straight
				*  to the buffer, but can't since this 
				*  element can't pick out a product, so
				*  delegate to root component containing
				*  the list of products
				*/
	    		var isDSel = cmp.get("v.isDragSelected");
				var selDragEvt = cmp.getEvent("selectDragNode");
	    		var dId = event.currentTarget.dataset.id;
	    		console.log('Setting data id '+dId); 
	    		selDragEvt.setParams({"data-id" : dId, "doAdd" :!isDSel });
	    		selDragEvt.fire();
	    		
	    	} else {
	    		cmp.set("v.draggedProducts",[]);
	    	}
    	}    	
    },
    onDragBufferChange : function(cmp, event, helper){
        if(cmp.get("v.draggable")){
        	var draggedProducts = cmp.get("v.draggedProducts");
        	var itemData = cmp.get("v.itemData");
	        var isBuffered = helper.checkIsInBuffer(cmp,draggedProducts,itemData);
	        cmp.set("v.isDragSelected",isBuffered);
        }
    }
})