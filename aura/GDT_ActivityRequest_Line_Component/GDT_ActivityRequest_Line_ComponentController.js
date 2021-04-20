({
	doInit : function(component, event, helper) {

		component.set("v.editable",component.get("v.editable") == 'true');
		component.set("v.isAdmin",component.get("v.isAdmin") == 'true');
		if(component.get("v.activityLineJSON") == ''){
			component.set("v.activityLine", {});
		}else{
			var rec = JSON.parse(component.get("v.activityLineJSON"));
			component.set("v.activityLine", rec);
			component.set('v.status', rec.Status__c);
			component.set("v.isNew", rec.Status__c == 'New');

			console.log(rec.Status__c);
		}

		var spinner = component.find("mySpinner");
	    if(spinner != undefined)$A.util.toggleClass(spinner, "slds-hide");

	    helper.showLoading(component);
		var actionGetAttachments = component.get("c.getAttachments");
		actionGetAttachments.setParam("parentId", component.get("v.lineId"));	    		

        actionGetAttachments.setCallback(this, function(atts) {
    		if(actionGetAttachments.getState() ==='SUCCESS'){
    			component.set("v.spinnerShow", "false");
    			var result = atts.getReturnValue();
            	component.set("v.attachments", result);
    		}
    	});
    	$A.enqueueAction(actionGetAttachments);

	},

	onRecordSubmit : function(component, event, helper) {
		helper.showLoading(component);
	    component.find("myForm").submit();
	},

	loaded: function(component, event, helper) {
        helper.serviceLoaded(component,event,helper);
	},

	onRecordSuccess: function(component, event, helper) {        
	    window.location.href = 'GDT_ManageActivity_NewActivityRequest?id=' + component.get("v.activityId");
	},
	onRecordError: function(component, event, helper) {
		var spinner = component.find("mySpinner");
	    if(spinner != undefined)$A.util.toggleClass(spinner, "slds-hide");
	},
    onBack: function(component, event, helper) {        
	    window.location.href = 'GDT_ManageActivity_NewActivityRequest?id=' + component.get("v.activityId");
	},


	onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        console.log(files);
        for (var i = 0; i < files.length; i++) { 
        	helper.readFile(component, helper, files[i]);
        }
	},

	deleteAttachment: function(component, event, helper) {
		var attId = event.target.getAttribute("data-attId");
		var loaded = component.get("v.attachments");
		var newList = loaded.filter(function(ele){
			return ele.Id != attId;
		});
		component.set("v.attachments", newList);

		var actionDelAttachments = component.get("c.deleteAttachments");
		actionDelAttachments.setParam("pId", attId);

        actionDelAttachments.setCallback(this, function(a) {
            if(actionDelAttachments.getState() ==='SUCCESS'){
            	console.log('Attachment deleted');
            }
        });
		$A.enqueueAction(actionDelAttachments);
	},
})