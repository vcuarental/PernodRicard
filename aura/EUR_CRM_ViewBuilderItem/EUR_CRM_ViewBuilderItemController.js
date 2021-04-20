({
	doInit : function(cmp, event, helper) {
        // Parse item
        var children = helper.parseItem(cmp);
        var collapsed = cmp.get("v.collapsed");
        if(collapsed) {
            cmp.set("v.childrenShown", []);
            helper.toggleNodeExpand(cmp, true);
        } else {
            cmp.set("v.childrenShown", children);
        }
        
	},

    onToggleExpand : function(cmp, event, helper) {
    	// force spinner shown
    	helper.showSpinner(cmp);
    	// then asynchronously expand/collapse section
    	// wait 20ms, FF didn't separate rendering contexts for less?
        window.setTimeout(
		    $A.getCallback(function() {
		        try{
		        	helper.toggleNodeExpand(cmp, false);
		        } catch(er) {
		        	
		        }
		    }), 20
		);
        
        // Prevent accidental node selection
        event.stopPropagation();
	},

    setDroppedItems: function(cmp, event, helper) {
    	
        var params = event.getParam('arguments');
        
        if(!$A.util.isUndefinedOrNull(params.droppedItems) && !params.droppedItems.length){
        	// stringified array in event is whitespace with no length
        	helper.setDroppedItemsHandler(cmp, []);
        	return;
        }
        if(!params || !params.droppedItems || !params.droppedItems.length) return;
        helper.setDroppedItemsHandler(cmp, params.droppedItems);
    },

    onDrop: function(cmp, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        helper.onDropHandler(cmp, event);
    },
    
    onPreventDrop: function(cmp, event, helper) {
    	event.stopPropagation();
        event.preventDefault();
    },
    
	onPreventDragEnter: function(cmp, event, helper) {
		event.dataTransfer.dropEffect = "none";
	},
	
    increaseDepth : function(cmp, event, helper) {
        helper.increaseDepthHandler(cmp);
    },

    removeItem : function(cmp, event, helper) {
        helper.removeItemHandler(cmp,event);
    },

    addCategory : function(cmp, event, helper) {
        helper.addCategoryHandler(cmp);
    },

    removeCategory : function(cmp, event, helper) {
        helper.removeCategoryHandler(cmp);
    },

    updateInputInHierarchy : function(cmp, event, helper) {
    	helper.doValidateBranchName(cmp, event, helper);
        helper.updateInputInHierarchyHandler(cmp);
    },
    
    updateProductInViewM : function(cmp, event, helper) {
        helper.updateProductInViewM(cmp,event);
    },
    /*
    viewItemsInputChangeEvent : function(cmp, event, helper) {
        helper.viewItemsInputChangeEventHandler(cmp, event, helper);
    },
	*/
    moveItemUp : function(cmp, event, helper) {
        helper.moveItemHandler(cmp, event, -1);
    },

    moveItemDown : function(cmp, event, helper) {
        helper.moveItemHandler(cmp, event, 1);
    },

    onDragOver : function(cmp, event, helper) {
    	
        event.preventDefault();
    },

    dragCategory: function(cmp, event, helper) {
        helper.dragCategoryHandler(cmp, event, helper);
    },

    dropCategory: function(cmp, event, helper) {
    	event.preventDefault();
        helper.dropCategoryHandler(cmp, event, helper);
    },

    onMouseOver: function(cmp, event, helper) {
        helper.onMouseOverHandler(event);
    },
    onMouseLeave: function(cmp, event, helper) {
        helper.onMouseLeaveHandler(event);
    },
    
    qtyValidate : function(cmp, event, helper) {
    	helper.updateProductInViewM(cmp,event);
        helper.doValidateQtys(cmp, event, helper);
        helper.doValidateTQtys(cmp, event, helper);
        helper.doValidatePckgs(cmp, event, helper);
    },
    
    tqtyValidate : function(cmp, event, helper) {
        helper.doValidateTQtys(cmp, event, helper);
    },
    
    dtValidate : function(cmp, event, helper) {
        helper.doValidateDates(cmp, event, helper);
    },
    pckgValidate : function(cmp, event, helper) {
    	helper.updateProductInViewM(cmp,event);
        helper.doValidatePckgs(cmp, event, helper);
        helper.doValidateQtys(cmp, event, helper);
    },
    stDValidate : function(cmp, event, helper) {
    	helper.doValidateStDs(cmp, event, helper);
    },
    oosDValidate : function(cmp, event, helper) {
    	helper.doValidateOosDs(cmp, event, helper);
    },
    selectText : function(cmp, event, helper) {
    	// traverse the children, find the input of this lightning input group
    	var thisInp = event.getSource().getElement().getElementsByTagName('input')[0];
    	if(thisInp){
    		// select the content
    		thisInp.select();
    	}
    },
    doValidate : function(cmp, event, helper) {
        return helper.doValidate(cmp, event, helper); 
    },
    onRender : function(cmp, event, helper) {
    	helper.hideSpinner(cmp);
    },
    
    doNext : function(cmp, event, helper) {
    	var pN = cmp.get('v.pageNo');
    	cmp.set('v.pageNo',pN+1);
    	// force lightning inputs validation
    	// relies on additional info-spans to render, so
    	// run validation out of this rendering stack
        window.setTimeout(
        	// bad hack to force validity check after initial rendering
		    $A.getCallback(function() {
		        try{
		        	helper.doValidate(cmp, event, helper);
		        } catch(er) {
		        	console.log('Exception on deterred validation in drop '+er);
		        }
		    }), 1
		);
    },
    doPrevious : function(cmp, event, helper) {
    	var pN = cmp.get('v.pageNo');
    	cmp.set('v.pageNo',pN-1);
    	// force lightning inputs validation
    	// relies on additional info-spans to render, so
    	// run validation out of this rendering stack
        window.setTimeout(
        	// bad hack to force validity check after initial rendering
		    $A.getCallback(function() {
		        try{
		        	helper.doValidate(cmp, event, helper);
		        } catch(er) {
		        	console.log('Exception on deterred validation in drop '+er);
		        }
		    }), 1
		);
    	
    },

    onActionFieldChange: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var fieldValue = event.getParam("fieldValue");
        var productId = event.getSource().get("v.name");
        var droppedItems = component.get('v.droppedItems');

        droppedItems.forEach( function(item) {
            if(item.product.Id == productId) {
                item.product.dynamicfields.forEach( function(dynamicField) {
                    if(dynamicField.fieldApiName == fieldName) {
                        dynamicField.value = fieldValue;
                        item.product.pbi[fieldName] = fieldValue;
                    }
                });
            }
        });

        component.set('v.droppedItems', droppedItems);
    }
})