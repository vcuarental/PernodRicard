({
    parseItem : function(component) {
        var config = component.get("v.config");
        var item = component.get("v.item");
        var label;
        var collapsed;
        var children = [];
        
        if (typeof item === 'string')
            label = item;
        else if (Array.isArray(item) && item.length > 0) {
            label = this.getLabelFromArray(item);
            children = item;
        }
        else if (typeof item === 'object') {
            label = this.getLabelFromObject(item, config.labelProperties);
            children = this.getChildrenFromObject(item, config.expandProperties);
            collapsed = this.getBoolFromObject(item, config.collapsed);
        }
        else
            throw "Unknown node type: "+ typeof item;

        component.set("v.collapsed", collapsed);
        component.set("v.label", label);
        component.set("v.children", children);
        return children;
    },

    getLabelFromArray : function(item) {
        if (item.length == 1)
            return "List of one item";
        return "List of "+ item.length +" items";
    },

    getLabelFromObject : function(item, labelProperties) {
        var label = null;
        for (var i=0; label == null && i<labelProperties.length; i++) {
            var value = item[labelProperties[i]];
            if (value !== undefined && typeof value === 'string')
                label = value;
        }
        return (label == null) ? 'Undefined label' : label;
	},

    getBoolFromObject : function(item, labelProperties) {
        var label = null;
        for (var i=0; label == null && i<labelProperties.length; i++) {
            var value = item[labelProperties[i]];
            if (value !== undefined && typeof value === 'boolean')
                label = value;
        }
        return (label == null) ? false : label;
	},

    getChildrenFromObject : function(item, expandProperties) {
        var children = null;
        for (var i=0; children == null && i<expandProperties.length; i++) {
            var value = item[expandProperties[i]];
            if (value !== undefined)
                children = value;
        }
        return (children == null) ? [] : children;
	},

    toggleNodeExpand : function(component, isInit) {
        var mode = component.get('v.mode');
        var toggleExpandIcon = component.get("v.toggleExpandIcon");
        var subTree = component.find('subTree');
        var isCollapsed;
        if (toggleExpandIcon == "utility:chevrondown") {
            $A.util.addClass(subTree, 'collapsed');
            this.changeIcon(component, "utility:chevronright");
            isCollapsed = true;
        }
        else {
			$A.util.removeClass(subTree, 'collapsed');
            this.changeIcon(component, "utility:chevrondown");
            isCollapsed = false;
        }
        component.set('v.collapsed', isCollapsed);
        
        if(!isInit) {
            var childrenShown = component.get('v.childrenShown');
            if(!isCollapsed && !childrenShown.length) {
                component.set('v.childrenShown', component.get('v.children'));
                this.setDroppedItemsHandler(component, component.get('v.droppedItems'));
            }
            if(mode == 'create') {
                this.changeViewItemCollapsedState(component, isCollapsed);
            }
        }

    },
       
    showSpinner: function(cmp, event, helper) {
        var spinner = cmp.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function(cmp, event, helper) {
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    },
    changeIcon : function(component, svgIcon) {
        component.set("v.toggleExpandIcon", svgIcon);
    },

    onDropHandler: function(cmp, event) {
        var
            viewName = cmp.get('v.viewName'),
            branchIndex = cmp.get('v.branchIndex'),
            productIdentifier = event.dataTransfer.getData("Text"),
            productsDropEvent = cmp.getEvent("productsDropEvent");

        productsDropEvent.setParams({
            eventView: viewName,
            itemIdentifier: productIdentifier,
            branchIndex: branchIndex,
            action: 'drop'
        });
        productsDropEvent.fire();
    },

    increaseDepthHandler: function(cmp) {
        var
            level = cmp.get('v.level'),
            children = cmp.get('v.children'),
            branchIndex = cmp.get("v.branchIndex"),
            indexes = branchIndex.split('-'),
            viewName = cmp.get("v.viewName"),
            collapsed = cmp.get('v.collapsed'),
            items = JSON.parse(JSON.stringify(cmp.get('v.items'))),
            branch = items[parseInt(indexes[1])];

        if(level >= 4) return;

        if($A.util.isUndefinedOrNull(children) || $A.util.isEmpty(children)) {
            children = [];
            children.push({
                LevelName: '',
                SubLevels: [],
                collapsed: false,
            });
            cmp.set('v.children', children);
            cmp.set('v.childrenShown', children);
            if(collapsed) {
                cmp.set('v.collapsed', false);
                this.toggleNodeExpand(cmp, true);
            }
            var eventBranch = {
                LevelName: cmp.find('branchName').get('v.value'),
                collapsed: false,
                SubLevels: children
            };
            this.hierarchyChangeEventHandler(cmp, viewName, items, branchIndex, eventBranch, true);
        }
    },

    removeItemHandler: function(cmp,event) {
        var
            branchIndex = cmp.get('v.branchIndex'),
            droppedItems = JSON.parse(JSON.stringify(cmp.get('v.droppedItems'))),
            //droppedItems = cmp.get('v.droppedItems'),
            viewName = cmp.get('v.viewName'),
            productsDropEvent = cmp.getEvent("productsDropEvent"),
            //el = event.srcElement;
            el = event.getSource();
            
        /* Doesn't work in FF

        console.log('droppedItems', droppedItems);
        while ((el = el.parentElement) && !el.classList.contains('slds-grid'));
        if(!el) return;
        var id = el.getAttribute('data-id');
        */
        
        var id = el.get("v.name");
        droppedItems.forEach( function(item, index) {
            if(item.product.Id == id) {
                droppedItems.splice(index, 1);
                return;
            }
        });
        cmp.set('v.droppedItems', droppedItems);
        productsDropEvent.setParams({
            eventView: viewName,
            itemIdentifier: id,
            action: 'remove'
        });
        productsDropEvent.fire();
    },

    addCategoryHandler: function(cmp) {
        this.changeCategoryEvent(cmp, true);
    },

    removeCategoryHandler: function(cmp) {
        this.changeCategoryEvent(cmp, false);
    },

    changeCategoryEvent: function(cmp, isCreate, isDrop, sourceBranchIndex) {
        var
            level = cmp.get('v.level'),
            branchIndex = cmp.get('v.branchIndex'),
            viewName = cmp.get("v.viewName"),
            currentDepth = parseInt(cmp.get('v.hierarchyDepth')),
            addCategoryEvent = cmp.getEvent("addCategoryEvent");

        addCategoryEvent.setParams({
            "isCreate" : isCreate,
            "viewName" : viewName,
            "level" : level,
            "currentDepth" : currentDepth,
            "branchIndex" : branchIndex,
            "isDrop" : isDrop,
            "sourceBranchIndex" : sourceBranchIndex
        });
        addCategoryEvent.fire();
    },

    changeViewItemCollapsedState: function(cmp, isCollapsed) {
         var
             branchIndex = cmp.get("v.branchIndex"),
             viewName = cmp.get("v.viewName"),
             items = JSON.parse(JSON.stringify(cmp.get('v.items'))),
             indexes = branchIndex.split('-'),
             branch = items[parseInt(indexes[1])];

         for(let i = 2; i < indexes.length; i++) {
              branch = branch.SubLevels[parseInt(indexes[i])];
         }
         branch.collapsed = isCollapsed;
         this.hierarchyChangeEventHandler(cmp, viewName, items, branchIndex, branch);
    },

    updateInputInHierarchyHandler: function(cmp) {
         var
             branchIndex = cmp.get("v.branchIndex"),
             viewName = cmp.get("v.viewName"),
             items = JSON.parse(JSON.stringify(cmp.get('v.items'))),
             branchInput = cmp.find('branchName'),
             indexes = branchIndex.split('-'),
             branch = items[parseInt(indexes[1])];

         for(let i = 2; i < indexes.length; i++) {
              branch = branch.SubLevels[parseInt(indexes[i])];
         }
         branch.LevelName = branchInput.get('v.value');
         this.hierarchyChangeEventHandler(cmp, viewName, items, branchIndex, branch);
    },

    hierarchyChangeEventHandler: function(cmp, viewName, items, branchIndex, branch, increaseIndexes) {
         var hierarchyChangeEvent = cmp.getEvent("hierarchyChangeEvent");
         hierarchyChangeEvent.setParams({
             source: 'viewBuilderItemCmp',
             viewName: viewName,
             hierarchy: items,
             branchIndex: branchIndex,
             branch: branch,
             increaseIndexes: increaseIndexes
         });
         hierarchyChangeEvent.fire();
    },
    
    updateProductInViewM: function(cmp,event) {
    	var viewName = cmp.get("v.viewName");
    	
    	var iId = event.getSource().get("v.name");

    	var dis = cmp.get('v.droppedItems');  // all the items for this view
    	
    	var changedItem;
    	
    	if(dis){
    		for (var i = 0; i < dis.length; i++) {
    			if(dis[i].product.Id == iId){
    				//console.log('Found prod '+JSON.stringify(dis[i].product));
    				changedItem = dis[i].product;
    				break;
    			}
    		}
    	}
    	//console.log('Setting changed item '+JSON.stringify(changedItem));
    	if(changedItem){
    		cmp.set('v.droppedItems',dis);
    		var viewItemsInputChangeEvent = cmp.getEvent("viewItemsInputChangeEvent");
            viewItemsInputChangeEvent.setParams({
                viewName: viewName,
                productId: iId,
                product: changedItem
            });
            viewItemsInputChangeEvent.fire();
    	}
    },

    moveItemHandler: function(cmp, event, moveByIndex) {
        var
            branchIndex = cmp.get('v.branchIndex'),
            droppedItems = JSON.parse(JSON.stringify(cmp.get('v.droppedItems'))),
            //droppedItems = cmp.get('v.droppedItems'),
            viewName = cmp.get('v.viewName'),
            productsDropEvent = cmp.getEvent("productsDropEvent"),
            //el = event.srcElement;
            el = event.getSource();
          
        /*    
        while ((el = el.parentElement) && !el.classList.contains('slds-grid'));
        if(!el) return;
        var id = el.getAttribute('data-id');
         */
        var id = el.get("v.name");
        var itemIndex;
        
        droppedItems.forEach( function(item, index) {
            if(item.product.Id == id) {
                itemIndex = index;
                return;
            }
        });
        
        if(itemIndex !== undefined && itemIndex+moveByIndex >= 0 && itemIndex+moveByIndex < droppedItems.length) {
            productsDropEvent.setParams({
                eventView: viewName,
                itemIdentifier: id,
                moveByIndex: moveByIndex,
                action: 'replace'
            });
            productsDropEvent.fire();
        }
    },

    setDroppedItemsHandler: function(cmp, droppedItems) {
    	var branchIndex = cmp.get('v.branchIndex');
        var childrenShown = cmp.get('v.childrenShown');
        
        if(!childrenShown.length) {
            cmp.set('v.droppedItems', droppedItems);
            
        } else {
            var currentBranchItems = [];
            droppedItems.forEach(function(item) {
                if(item.branchIndex == branchIndex) {
                    currentBranchItems.push(item);
                }
            });
            cmp.set('v.droppedItems', currentBranchItems);
            if(!droppedItems.length) return;
            var viewItemsCmpList = [];
            viewItemsCmpList = viewItemsCmpList.concat(cmp.find('viewBuilderItemCmp'));
            viewItemsCmpList.forEach(function(viewItemBuilder) {
                if(viewItemBuilder) {
                    var cmpBranchIndex = viewItemBuilder.get('v.branchIndex');
                    var itemsToSet = [];
                    droppedItems.forEach(function(item) {
                        if(item.branchIndex == cmpBranchIndex || item.branchIndex.startsWith(cmpBranchIndex)) {
                            itemsToSet.push(item);
                        }
                    });
                    if(itemsToSet.length) {
                        viewItemBuilder.setDroppedItems(itemsToSet);
                    }
                }
            });
        }
        // force lightning inputs validation
        window.setTimeout(
        	// bad hack to force validity check after initial rendering
		    $A.getCallback(function() {
		        try{
		        	cmp.doValidate();
		        } catch(er) {
		        	console.log('Exception on deterred validation in drop '+er);
		        }
		    }), 1
		);
    },

    dragCategoryHandler: function(cmp, event, helper) {
        var branchIndex = cmp.get('v.branchIndex');
        event.dataTransfer.setData("Text", branchIndex);
    },

    dropCategoryHandler: function(cmp, event, helper) {
        var branchIndex = cmp.get('v.branchIndex');
        var mode = cmp.get('v.mode');
        if(mode != 'create') return;
        var data = event.dataTransfer.getData("Text");
        var currentIndexes = branchIndex.split('-');
        currentIndexes.splice(currentIndexes.length - 1, 1);
        var dataIndexes = data.split('-');
        dataIndexes.splice(dataIndexes.length - 1, 1);
        if(dataIndexes.join() == currentIndexes.join() && data != branchIndex) {
            helper.changeCategoryEvent(cmp, false, true, data);
        }
        
        try{
        	helper.doValidate(cmp, event, helper);
        } catch(er) {
        	console.log('Exception on deterred validation in item drop handler '+er);
        }
    },

    onMouseOverHandler: function(event) {
        var draggableBlock = this.findAncestor(event.target, 'slds-tree__item');
        if(draggableBlock) draggableBlock.setAttribute('draggable', false);
    },

    onMouseLeaveHandler: function(event) {
        var draggableBlock = this.findAncestor(event.target, 'slds-tree__item');
        if(draggableBlock) draggableBlock.setAttribute('draggable', true);
    },

    findAncestor: function(el, cls) {
        while ((el = el.parentElement) && !el.classList.contains(cls));
        return el;
    },
    
    doValidateDates: function(cmp, event, helper) {
    	var isTemplate = cmp.get("v.isTemplate");
    	var doClear = true;
    	//if(isTemplate === true){
	    	doClear = helper.doValidateLInput(cmp,"inpD");
    	//}
    	return doClear;
    },
    doValidateBranchName : function(cmp, event, helper) {
    	var bNameInp = cmp.find('branchName');
    	if(bNameInp){
    		var bName = bNameInp.get('v.value');
    		if($A.util.isEmpty(bName) || $A.util.isEmpty(bName.trim())){
    			bNameInp.set("v.errors", [{message: $A.get("$Label.c.EUR_CRM_EmptyFieldError")}]);
    		} else {
    			bNameInp.set("v.errors", null);
    		}
    	}
    },
    doValidateStDs : function(cmp, event, helper) {
    	return helper.doValidateLInput(cmp,"stD");
    },
    doValidateOosDs : function(cmp, event, helper) {
    	return helper.doValidateLInput(cmp,"oosD");
    },

    doValidateQtys: function(cmp, event, helper) {
    	var dts = [];
    	
    	if(event && event.getSource() && event.getSource().getLocalId() == 'inpQ' || event.getSource().getLocalId() == 'inpP'){
    		// this function may be called onblur from the input itself
    		// find both min/max q-tys for this product
    		var src = event.getSource();
    		var prodId = src.get('v.name');
    		
    		var qtys = cmp.find('inpQ');
    		if(qtys){
    			for(var i=0; i<qtys.length; i++){
    				var thisQty = qtys[i];
    				if(thisQty.get('v.name') == prodId){
    					dts.push(thisQty);
    				}
    			}
    		}
    	} else {
    		// else this function may be called from catalog builder
    		// itself, then check all inputs
    		dts = cmp.find('inpQ');
    	}
    	
    	var errMsgs = cmp.find('minQtyErr'); 
    	var isValid = true;
    	var validMap = {};
		// skip validation for multiples of packaging for return
    	if(cmp.get('v.isReturn') != true){
    		[].concat(dts).forEach(function(dt) {
	    		if(dt && errMsgs){ 
	    		
	    			if(validMap[dt.get('v.name')] == null){
	    				validMap[dt.get('v.name')] = true;
	    			}
	    			
	    			var thisMsg;
	    			[].concat(errMsgs).forEach(function(errMsg) {
	    				if(errMsg.getElements()[0]){
	    					if(dt.get('v.name') == errMsg.getElements()[0].dataset.id){ // match by product id
		    					thisMsg = errMsg;
		    				}
	    				}
	    			});
	    			if(thisMsg){
	    				if(dt.get('v.value') && thisMsg.getElements()[0].dataset.pckg && thisMsg.getElements()[0].dataset.pckg != 0 && (dt.get('v.value') % thisMsg.getElements()[0].dataset.pckg !== 0)){
			            	$A.util.removeClass(thisMsg, 'slds-hide');
			            	$A.util.addClass(dt, 'slds-has-error'); // add red border
				            $A.util.removeClass(dt, 'hide-error-message'); // add error message
				            isValid = false;
				            validMap[thisMsg.getElements()[0].dataset.id] = false;
			            } else {
			            	if(validMap[thisMsg.getElements()[0].dataset.id] === true){ // account that there are several quantity outputs
			            		$A.util.addClass(thisMsg, 'slds-hide');
			            		$A.util.removeClass(dt, "slds-has-error"); // remove red border
			            		$A.util.addClass(dt, "hide-error-message"); // hide error message
			            	}
			            }
	    			}
	    		}
	        });
    	}
		
        
	    if(isValid ){
	    	return helper.doValidateLInput(cmp,"inpQ",dts);
	    }   else {
	    	return false;
	    } 
	    
    	//return helper.doValidateLInput(cmp,"inpQ");
    },
    
    doValidateTQtys: function(cmp, event, helper) {
    	return helper.doValidateLInput(cmp,"inpT");
    },
    
    doValidatePckgs: function(cmp, event, helper) {
    	// skip this validation for return
    	if(cmp.get('v.isReturn') == true){
    		return true;
    	}
    	
    	var dts;
    	
    	if(event && event.getSource() && event.getSource().getLocalId() == 'inpP'){
    		// this function may be called onblur from the input itself
    		// then check only the source
    		dts = event.getSource();
    	} else {
    		// else this function may be called from catalog builder
    		// itself, then check all inputs
    		dts = cmp.find('inpP');
    	}
    	
    	var errMsgs = cmp.find('pckgErr'); 
    	var isValid = true;
		// packaging from product
		[].concat(dts).forEach(function(dt) {
    		if(dt && dt.get('v.placeholder')){ // placeholder contains value from product
    			var thisMsg;
    			[].concat(errMsgs).forEach(function(errMsg) {
    				if(dt.get('v.name') == errMsg.getElements()[0].dataset.id){ // match by product id
    					thisMsg = errMsg;
    				}
    			});
    			if(thisMsg){
    				if(dt.get('v.value') && dt.get('v.placeholder') != 0 && (dt.get('v.value') % dt.get('v.placeholder') !== 0)){
	            		$A.util.removeClass(thisMsg, 'slds-hide');
		            	$A.util.addClass(dt, 'slds-has-error'); // add red border
			            $A.util.removeClass(dt, 'hide-error-message'); // add error message
			            isValid = false;
		            } else {
		            	$A.util.addClass(thisMsg, 'slds-hide');
		            }
    			}
    		}
        });
        
	    if(isValid ){
	    	return helper.doValidateLInput(cmp,"inpP",dts);
	    }   else {
	    	// prevent addition checking, since it will set the non-multiple
	    	// input to valid and remove red border
	    	return false;
	    } 
	    //return helper.doValidateLInput(cmp,"inpP",dts);
    	
    },
    
    doValidatePrice: function(cmp, event, helper) {
    	return helper.doValidateLInput(cmp,"inpPr");
    },
    doValidateLInput: function(cmp,inpAuraId,inps) {
    	var doClear = true;
    	var dts;
    	
    	if(inps){
    		dts = inps;
    	} else {
    		dts = cmp.find(inpAuraId);
    	}
    	
    	[].concat(dts).forEach(function(dt) {
    		if(dt){
    			dt.showHelpMessageIfInvalid();
	            if(dt.get("v.validity") && dt.get("v.validity").valid != true){
	            	doClear = false;
	            	$A.util.addClass(dt, "slds-has-error"); // add red border
		            $A.util.removeClass(dt, "hide-error-message"); // add error message
	            } else {
		        	$A.util.removeClass(dt, "slds-has-error"); // remove red border
		        	$A.util.addClass(dt, "hide-error-message"); // hide error message
		        }
    		}
        	
        });
    	return doClear;
    },
    
    doValidate : function(cmp, event, helper) {
    	var doClear = true;
    	
    	helper.doValidateBranchName(cmp, event, helper);
    	doClear = helper.doValidateQtys(cmp, event, helper);
    	doClear = helper.doValidatePckgs(cmp, event, helper);
    	doClear = helper.doValidateDates(cmp, event, helper);
    	doClear = helper.doValidateTQtys(cmp, event, helper);
    	doClear = helper.doValidatePrice(cmp, event, helper);
    	doClear = helper.doValidateStDs(cmp, event, helper);
    	doClear = helper.doValidateOosDs(cmp, event, helper);
        
        var children = cmp.find("viewBuilderItemCmp");
        [].concat(children).forEach(function(child) {
        	if(child){
        		var childValid = child.doValidate();
	            if(!childValid){
	            	doClear = false;
	            }
        	}
        	
        });
        
        return doClear; 

    }
    
})