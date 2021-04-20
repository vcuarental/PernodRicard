({    
    parseItem : function(cmp) {
        var
            config = cmp.get("v.config"),
            item = cmp.get("v.item"),
            itemData = {};
        
        if (typeof item === 'string')
            itemData.label = item;
        else if (Array.isArray(item) && item.length > 0) {
            itemData.label = this.getLabelFromArray(item);
            itemData.children = item;
        }
        else if (typeof item === 'object') {
            itemData.label = this.getLabelFromObject(item, config.labelProperties);
            itemData.children = this.getChildrenFromObject(item, config.expandProperties);
            itemData.itemIdentifier = this.getLabelFromObject(item, config.itemIdentifier);
            itemData.sapCode = this.getLabelFromObject(item, config.sapCode);
            itemData.nationalCode = this.getLabelFromObject(item, config.nationalCode);
            itemData.eanCode = this.getLabelFromObject(item, config.eanCode);
            itemData.checked = this.getBoolFromObject(item, config.checked);
            itemData.dropped = this.getBoolFromObject(item, config.dropped);
            itemData.collapsed = this.getBoolFromObject(item, config.collapsed);
        }
        else
            throw "Unknown node type: "+ typeof item;

        return itemData;
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
    
    toggleNodeExpand : function(cmp, init) {
        var
            itemData = cmp.get("v.itemData"),
            isDynamic = cmp.get("v.isDynamic"),
            toggleExpandIcon = cmp.get("v.toggleExpandIcon"),
            subTree = cmp.find('subTree');

        if (toggleExpandIcon == "utility:chevrondown") {
            $A.util.addClass(subTree, 'collapsed');
            this.changeIcon(cmp, "utility:chevronright");
            itemData.childrenRendered = [];
        }
        else {
			$A.util.removeClass(subTree, 'collapsed');
            this.changeIcon(cmp, "utility:chevrondown");
            itemData.childrenRendered = itemData.children;
        }
        cmp.set("v.itemData", itemData);
        if(!init) this.saveItemExpandState(cmp);
    },

    saveItemExpandState : function(cmp) {
        var
            itemData = cmp.get("v.itemData"),
            itemId = itemData.itemIdentifier,
            changeCollapsedItems = cmp.getEvent("changeCollapsedItems");

        changeCollapsedItems.setParams({itemId: itemId});
        changeCollapsedItems.fire();
    },

    changeIcon: function(cmp, svgIcon) {
        cmp.set("v.toggleExpandIcon", svgIcon);
    },
    
    onDragHandler: function(cmp, event) {
    	
        var itemData = cmp.get("v.itemData");
        console.log('==> Dragging '+itemData.itemIdentifier);
        event.dataTransfer.setData("Text", itemData.itemIdentifier);
    },

    checkItemHandler: function(cmp, event, helper) {
        var
            itemData = cmp.get("v.itemData"),
            isDynamic = cmp.get('v.isDynamic'),
            params = event.getParam('arguments'),
            isLastNode = 'ProductSAPcode' in cmp.get("v.item"),
            checked = params.value,
            level = params.level;

        if(!params) return;
        if(helper.isAffectChildCheckState(isDynamic, checked, level, isLastNode)) {
            itemData.checked = checked;
            cmp.set('v.itemData', itemData);
            cmp.find('selectProductChbx').set('v.checked', checked);
            this.setChildrenCheckedHandler(cmp, itemData, level);
        }
    },

    handleSelectItems: function(cmp, event, helper) {
        var
            itemData = cmp.get("v.itemData"),
            checked = cmp.find('selectProductChbx').get('v.checked'),
            level = cmp.get('v.level'),
            isDynamic = cmp.get('v.isDynamic');

        itemData.checked = checked;
        this.setUnRenderedChildrenCheckedHandler(cmp, helper, itemData);
        cmp.set('v.itemData', itemData);
        this.setChildrenCheckedHandler(cmp, itemData, level);
        this.setParentCheckedHandler(cmp, itemData, level);
        if(isDynamic) {
            var changeDynamicLevelSelectionEvent = cmp.getEvent("changeDynamicLevelSelectionEvent");
            changeDynamicLevelSelectionEvent.setParams({
                level: itemData.checked ? level : level - 1,
                productIdentifier: itemData.itemIdentifier
            });
            changeDynamicLevelSelectionEvent.fire();
        }
    },

    setParentCheckedHandler: function(cmp, itemData, level) {
        var itemSelectionEvent = cmp.getEvent("itemSelectionEvent");
        itemSelectionEvent.setParams({
            eventData: itemData,
            level: level
        });
        itemSelectionEvent.fire();
    },

    itemSelectionEventHandler: function(cmp, event) {
        var
            itemData = cmp.get('v.itemData'),
            eventData = event.getParam("eventData"),
            //value = event.getParam("value"),
            level = event.getParam("level"),
            isDynamic = cmp.get('v.isDynamic'),
            componentLevel = cmp.get('v.level');
        // skip self invoke action
        if(level <= componentLevel) return;
        itemData.children.forEach(function(child) {
            if(child.Id == eventData.itemIdentifier) {
                child.checked = eventData.checked;
            }
        });
        if(!isDynamic || (isDynamic && eventData.checked)) {
            var hasChildSelected = false;
            var treeItemCmpList = [];
            var treeItemCmp = cmp.find('treeItemCmp');
            // check if all children are not selected
            if(treeItemCmp) treeItemCmpList = treeItemCmpList.concat(cmp.find('treeItemCmp'));
            treeItemCmpList.forEach(function(treeItemCmp) {
                var checked = treeItemCmp.find('selectProductChbx').get('v.checked');
                if(checked) hasChildSelected = true;
            });
            // set true in any case of false if already no children selected
            if(eventData.checked || !hasChildSelected) {
                itemData.checked = eventData.checked;
                cmp.find('selectProductChbx').set('v.checked', eventData.checked);
            }
        }
        cmp.set('v.itemData', itemData);
    },

    setDroppedProductsHandler: function(cmp, event, helper) {
        var
            itemData = cmp.get('v.itemData'),
            params = event.getParam('arguments'),
            availableCategories = [],
            level = cmp.get('v.level');

        if(!params) return;
        availableCategories = params.availableCategories;
        itemData.dropped = availableCategories.indexOf(itemData.itemIdentifier) == -1;
        if(!itemData.dropped) {
            var treeItemCmpList = cmp.find('treeItemCmp');
            if(treeItemCmpList) {
                [].concat(treeItemCmpList).forEach(function(treeItemCmp) {
                    treeItemCmp.setDroppedProducts(availableCategories);
                });
            }
        }
        if(itemData.children && itemData.children.length) {
            helper.setChildrenDroppedState(helper, itemData.children, availableCategories);
        }
        cmp.set('v.itemData', itemData);
    },

    setChildrenDroppedState: function(helper, children, availableCategories) {
        children.forEach(function(item) {
        	
        	
            if(availableCategories.indexOf(item.Id) == -1) {
                item.dropped = true;
            } else {
                item.dropped = false;
            }
            if(item.SubLevels && item.SubLevels.length) {
                helper.setChildrenDroppedState(helper, item.SubLevels, availableCategories);
            }
        });
    },

    setUnRenderedChildrenCheckedHandler: function(cmp, helper, itemData) {
        var
            itemData = cmp.get('v.itemData'),
            level = cmp.get('v.level'),
            isDynamic = cmp.get('v.isDynamic'),
            isLastNode = 'ProductSAPcode' in cmp.get("v.item");

        if(helper.isAffectChildCheckState(isDynamic, itemData.checked, level, isLastNode)) {
            helper.changeChildrenCheckedState(cmp, helper, itemData.children, itemData.checked);
            cmp.set('v.itemData', itemData);
        }
    },

    changeChildrenCheckedState: function(cmp, helper, children, checked) {
        children.forEach(function(item) {
            item.checked = checked;
            if(item.SubLevels && item.SubLevels.length) {
                helper.changeChildrenCheckedState(cmp, helper, item.SubLevels, checked);
            }
        });
    },

    setChildrenCheckedHandler: function(cmp, itemData, level) {
        var treeItemCmpList = [];
        var treeItemCmp = cmp.find('treeItemCmp');
        if(treeItemCmp) treeItemCmpList = treeItemCmpList.concat(cmp.find('treeItemCmp'));
        treeItemCmpList.forEach(function(treeItemCmp) {
            treeItemCmp.checkItem(itemData.checked, level);
        });
    },

    isAffectChildCheckState: function(isDynamic, checked, level, isLastNode) {
        if(!isDynamic || (isDynamic && !checked && level == 1) ||
                (isDynamic && !checked && level > 1 && !isLastNode) ||
                (isDynamic && checked && isLastNode)) {
            return true;
        }
        return false;
    },

    findAncestor: function(el, cls) {
        while ((el = el.parentElement) && !el.classList.contains(cls));
        return el;
    },
    
    checkIsInBuffer: function(cmp, draggedProducts, item){
    	if($A.util.isEmpty(draggedProducts)){
    		return false;
    	}
    	if(!$A.util.isEmpty(draggedProducts)){
    		for(var i=0; i<draggedProducts.length; i++){
        		if(item.itemIdentifier === draggedProducts[i]){
        			return true;
        		}
	        }
    	}
    	return false;
    }
})