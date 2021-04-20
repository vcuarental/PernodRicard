({
	doInit: function(component, event, helper) {
		var today = new Date();
		var from = new Date(today);
		from.setDate(from.getDate() - 7);
        var todayDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        var fromDate = from.getFullYear() + '-' + (from.getMonth() + 1) + '-' + from.getDate();

		component.set("v.toDate" , todayDate);
		component.set("v.fromDate" , fromDate);

		component.set("v.actionSelected" , 'ALL');
		component.set("v.sectionSelected" , 'ALL');
		component.set("v.userSelected" , 'ALL');
		component.set("v.initialized" , true);
		

	},
	runBatchController: function(component, event, helper) {
		var actionRunBatch = component.get("c.runBatch");

		var thisCom = component;
		actionRunBatch.setCallback(this, function(a) {
			console.log(a.getReturnValue());
			var result = a.getReturnValue();
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
	              "message": result,
	        }); 
            if(actionRunBatch.getState() ==='SUCCESS'){
	            toastEvent.setParams({
	              "title": "Info",
	              "type": "success"
	            }); 
            }else{	
            	toastEvent.setParams({
	              "title": "Error",
	              "type": "error"
	            }); 
            }
            toastEvent.fire();


        });
        $A.enqueueAction(actionRunBatch);

	},

	handleValueChange: function(component, event, helper) {
		if(component.get('v.initialized')){
			component.set('v.showActionList', false);
			component.get("v.loading").show();
			var from = component.find("fromDateId").get("v.value");
			var to = component.find("toDateId").get("v.value");

			
			var actionGetAuditTrails = component.get("c.getAuditTrails");
	            actionGetAuditTrails.setParam("fromDate", from);
	            actionGetAuditTrails.setParam("toDate",to);
	            actionGetAuditTrails.setParam("toControl",	component.get("v.toControlSelected"));
	           

	            actionGetAuditTrails.setCallback(this, function(a) {
	                if(actionGetAuditTrails.getState() ==='SUCCESS'){
	                    var result = a.getReturnValue();
	                    component.set("v.allRows" ,result);
	                    component.set("v.backupRows" ,result);
	                    component.set("v.rows" , result.slice(0,100));

	                    component.set("v.actionSelected" , 'ALL');
						component.set("v.sectionSelected" , 'ALL');
						component.set("v.userSelected" , 'ALL');
						component.set("v.displaySelected" , '');
						component.set("v.delegatedSelected" , '');

	                }
	                helper.setActionValues(component);
	                helper.setSectionValues(component);
	                helper.setUserValues(component);
	                component.get("v.loading").hide();
	    	});
			$A.enqueueAction(actionGetAuditTrails);
		}
	}, 

	getActions : function(component, event, helper){
        var selected = component.get('v.actionSelected');
	 	var actionList = component.get('v.actionList');

        var result= actionList.filter(function(item){
	    	return item.label.search(new RegExp(selected, "i")) > -1;
	    });
        component.set('v.actionResult', result);
        component.set('v.showActionList', true);
    },
    setActions : function(component, event, helper) {
        component.set('v.actionSelected', event.currentTarget.dataset.statValue);
        component.set('v.showActionList', false);
       	helper.searchRows(component);
     	
    },
    getToControl : function(component, event, helper){
        //helper.searchRows(component);


    },
    getDisplays : function(component, event, helper){
        helper.searchRows(component);
    },


    hideComponent : function(component, event, helper){
    	setTimeout(function(){
			component.set('v.showActionList', false);
		 }, 300);
	},
	getSections : function(component, event, helper){
        var selected = component.get('v.sectionSelected');
	 	var sectionList = component.get('v.sectionList');
        var result= sectionList.filter(function(item){
	    	return item.label.search(new RegExp(selected, "i")) > -1;
	    });
        component.set('v.sectionResult', result);
        component.set('v.showSectionList', true);
    },
    setSections : function(component, event, helper) {
        component.set('v.sectionSelected', event.currentTarget.dataset.statValue);
        component.set('v.showSectionList', false);
       	helper.searchRows(component);
	     
    },
    hideSectionComponent : function(component, event, helper){
    	setTimeout(function(){
			component.set('v.showSectionList', false);
		 }, 300);
	},

	getUsers : function(component, event, helper){
        var selected = component.get('v.userSelected');
	 	var userList = component.get('v.userList');
        var result= userList.filter(function(item){
	    	return item.label.search(new RegExp(selected, "i")) > -1;
	    });
        component.set('v.userResult', result);
        component.set('v.showUserList', true);
    },
    setUsers : function(component, event,helper) {
         component.set('v.userSelected', event.currentTarget.dataset.statValue);
        component.set('v.showUserList', false);
       	helper.searchRows(component);
	     
    },
    hideUserComponent : function(component, event, helper){
    	setTimeout(function(){
			component.set('v.showUserList', false);
		 }, 300);
	}
	

})