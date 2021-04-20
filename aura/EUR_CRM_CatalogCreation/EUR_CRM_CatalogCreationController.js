({
    doInit : function(cmp, event, helper) {
        helper.onInitHandler(cmp, helper);
    },

    switchView: function(cmp, event, helper) {
        helper.switchViewHandler(cmp, event);
    },
    
    switchListView: function(cmp, event, helper) {
        helper.switchSelectedProductsView(cmp, null,false);
    },

    switchSelectedProductsView: function(cmp, event, helper) {
        helper.switchSelectedProductsView(cmp, event);
    },

    productsFilterChange: function(cmp, event, helper) {
        helper.productsFilterChangeHandler(cmp, event);
    },
    
    productsFilterChangeDelayed: function(cmp, event, helper) {
    	var timer = cmp.get('v.timer');

        clearTimeout(timer);
        var timer = window.setTimeout($A.getCallback(function() {
	            helper.productsFilterChangeHandler(cmp, event);
	            clearTimeout(timer);
	            cmp.set('v.timer', null);
	            
		    }), 700
		);
        
        cmp.set('v.timer', timer);
    },
    
    nextStep: function(cmp, event, helper) {
        // console.log('nextStep');
        helper.moveToTheNextStep(cmp);
    },

    prevStep: function(cmp, event, helper) {
        helper.moveToThePrevStep(cmp);
    },

    selectTab: function(cmp, event, helper) {
        helper.selectTabActionHandler(cmp, event, helper);
    },

    setSelectedItemsEvent: function(cmp, event, helper) {
        helper.setSelectedItemsEventHandler(cmp, event);
    },
    
    dropEvent: function(cmp, event, helper) {
        helper.dropEventHandler(cmp,event,helper);
    },
    
    onPreventDrop: function(cmp, event, helper) {
    	event.stopPropagation();
        event.preventDefault();
    },
    
	onPreventDragEnter: function(cmp, event, helper) {
		event.dataTransfer.dropEffect = "none";
	},
/* TODO: remove    
    addGroup: function(cmp, event, helper) {
        helper.addGroupHandler(cmp, event, helper);
    },

    reviewGroupEvent: function(cmp, event, helper) {
        helper.reviewGroupEventHandler(cmp, event, helper);
    },
*/
    updateHierarchy: function(cmp, event, helper) {
        helper.updateHierarchyEventHandler(cmp, event, helper);
    },
    
    viewItemsInputChangeEvent: function(cmp, event, helper) {
        helper.viewItemsInputChangeEventHandler(cmp, event, helper);
    },
    
    changeDynamicLevelSelectionEvent: function(cmp, event, helper) {
        helper.changeDynamicLevelSelectionEventHandler(cmp, event);
    },

    checkReturnReason: function(cmp, event, helper) {
        helper.checkReturnReasonHandler(cmp);
    },

    addCollapsedItem: function(cmp, event, helper) {
        helper.addCollapsedItemHandler(cmp, event);
    },

    save: function(cmp, event, helper) {
        helper.saveCatalog(cmp, true);
    },

    saveHeader: function(cmp, event, helper) {
        helper.saveCatalog(cmp, false);
    },

    share: function(cmp, event, helper) {
        $A.util.toggleClass(cmp.find('sharingContainer'), 'slds-hide');
        cmp.set('v.sharingBtnState', !cmp.get('v.sharingBtnState'));
    },
    manageDeliveries : function(cmp, event, helper) {
        $A.util.toggleClass(cmp.find('deliveryContainer'), 'slds-hide');
        var mdBtn = cmp.find('manageDeliveries');
        if(mdBtn){
        	var variant = mdBtn.get('v.variant');
        	if(variant === 'neutral'){
        		mdBtn.set('v.variant','brand');
        	} else {
        		mdBtn.set('v.variant','neutral');
        	}
        }
    },
    cancel: function(cmp, event, helper) {
    	helper.doCancel(cmp,helper);
        //helper.gotoURL('one/one.app#/home');
    },

    openGroupModal: function(cmp, event, helper) {
        cmp.set('v.openGroupModal', true);
    },

    changeProductsCountToShow: function(cmp, event, helper) {
        var auraId = event.getSource().getLocalId();
        helper.changeProductsCountToShowHandler(cmp, auraId);
    },

    next: function(cmp, event, helper) {
        // console.log('next ');
        var auraId = event.getSource().getLocalId();
        helper.setNextPage(cmp, auraId);
    },

    last: function(cmp, event, helper) {
        var auraId = event.getSource().getLocalId();
        helper.setLastPage(cmp, auraId);
    },

    previous: function(cmp, event, helper) {
        var auraId = event.getSource().getLocalId();
        helper.setPreviousPage(cmp, auraId);
    },

    first: function(cmp, event, helper) {
        var auraId = event.getSource().getLocalId();
        helper.setFirstPage(cmp, auraId);
    },

    alertMessageEvent: function(cmp, event, helper) {
        helper.alertMessageEventHandler(cmp, event);
    },

    openProductSelectionModal: function(cmp, event, helper) {
        helper.openProductSelectionModalHandler(cmp);
    },

    closeProductSelectionModal: function(cmp, event, helper) {
        helper.closeProductSelectionModalHandler(cmp);
    },
    
    changeProductsImportSource: function(cmp, event, helper) {
    	// TODO: implement radio-button switcher
        helper.changeProductsImportSourceHandler(cmp, event, helper, event.getSource().getLocalId());
    },

    selectProductsBySAPIds: function(cmp, event, helper) {
        helper.selectProductsBySAPCodesHandler(cmp, helper);
    },
    onSelectDragNode: function(cmp, event, helper) {
    	helper.onSelectDragNodeHandler(cmp,event);
    },
    viewNameChange : function(cmp, event, helper) {
    	var inp = cmp.find('viewName2');
    	var cat = cmp.get('v.catalog');
    	var newVal = inp ? inp.get('v.value') : null;
    	
    	if(cat && inp){
    		
    		if($A.util.isEmpty(newVal) && $A.util.isEmpty(cat.ViewName2__c)){ // cleared
    			cmp.set('v.doUpdateProducts',false);
    		} else if(newVal != cat.ViewName2__c){
    			cmp.set('v.doUpdateProducts',true);
    		} else {
    			cmp.set('v.doUpdateProducts',false);
    		}
    	}
    },
    
    checkHasBegun: function(cmp, event, helper) {
    	helper.checkHasBegun(cmp, event, helper);
    },
    
    doToggleProductPanel : function(cmp, event, helper) {
    	var arrow = cmp.find('bIcon');
    	var direction = arrow.get('v.iconName');
    	if(direction === 'utility:right'){
    		arrow.set('v.iconName','utility:left');
    		cmp.set('v.isPPanelClosed',false);
    	} else {
    		arrow.set('v.iconName','utility:right');
    		cmp.set('v.isPPanelClosed',true);
    	}
    	
    }
})