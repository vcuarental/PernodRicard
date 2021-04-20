({
	doInit : function(component, event, helper) {

		component.set("v.isNew", component.get("v.relatedId") == '');
		component.set("v.editable",component.get("v.editable") == 'true');
		component.set("v.isAdmin",component.get("v.isAdmin") == 'true');
		if(component.get("v.activityRequestJSON") == ''){
			component.set("v.activityRequest", {});
		}else{
			var rec = JSON.parse(component.get("v.activityRequestJSON"));
			component.set("v.activityRequest", rec);
			component.set('v.status', rec.Status__c);
			console.log(rec.Status__c);
		}
		if(component.get("v.relatedType") != ''){
			component.set("v.selectedService" , component.get("v.relatedType"));
		}
		helper.setEditableAttr(component,event,helper);

		component.set("v.releaseRequest" , component.get("v.selectedService") == 'SFDC-S02');

		var spinner = component.find("mySpinner");
	    if(spinner != undefined)$A.util.toggleClass(spinner, "slds-hide");

	    helper.showLoading(component);
		var actionGetAuditTrails = component.get("c.getServiceOptions");
		var actionGetAttachments = component.get("c.getAttachments");
		actionGetAttachments.setParam("parentId", component.get("v.relatedId"));

        actionGetAuditTrails.setCallback(this, function(a) {
            if(actionGetAuditTrails.getState() ==='SUCCESS'){
            	var result = a.getReturnValue();
            	component.set("v.serviceOptions", result);
	    		component.set("v.spinnerShow", "false");

	    		var ids = {};
	    		for (var i = 0; i < result.length; i++) {
		        	ids[result[i].Code__c] = result[i].Id;
		        }
		        console.log(ids);
	    		component.set("v.serviceIds", ids);

	    		helper.getFields(component,event,helper,'SFDC_S01',false);

	    		if(component.get("v.relatedId") != '' && component.get("v.relatedId") != undefined){
	    			$A.enqueueAction(actionGetAttachments);
	    		}
            }
        });

        actionGetAttachments.setCallback(this, function(atts) {
    		if(actionGetAttachments.getState() ==='SUCCESS'){
    			var result = atts.getReturnValue();
            	component.set("v.attachments", result);
    		}
    	});
        $A.enqueueAction(actionGetAuditTrails);
	},

	changeService : function(component, event, helper) {
		try{
	        helper.showLoading(component);
	        var serSelected = component.get("v.selectedService");
	        component.set("v.releaseRequest" , serSelected == 'SFDC-S02');
	        component.set("v.iterationLoaded", "false");
			if(serSelected == 'SFDC_S00'){
				component.set("v.fields", []);
			}else if(serSelected != ''){
				helper.getFields(component,event,helper,serSelected,true);
			}
	    }catch(Ex){
	    	console.log(Ex);
    		//if(spinner != undefined)$A.util.toggleClass(spinner, "slds-hide");
    	}
	},

	newRequest: function(component, event, helper) {
		console.log(component.get("v.activityRequest").GDT_Activity_LineItems__r);
		var rec = component.get("v.activityRequest");
		helper.showLoading(component);
		
		var actionSubmit = component.get("c.createLine");
		actionSubmit.setParam("parentId", component.get("v.relatedId"));

        actionSubmit.setCallback(this, function(a) {
            if(actionSubmit.getState() ==='SUCCESS'){
            	rec.GDT_Activity_LineItems__r = {};
				rec.GDT_Activity_LineItems__r.records = [];
				rec.GDT_Activity_LineItems__r.records = a.getReturnValue();
				component.set("v.activityRequest",rec);
            	console.log('Line created ' + a.getReturnValue());
            }
            component.set("v.spinnerShow", "false");
        });
		$A.enqueueAction(actionSubmit);

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

	deleteLine: function(component, event, helper) {
		helper.showLoading(component);
		var lineId = event.target.getAttribute("data-lineId");
		var rec = component.get("v.activityRequest");

		var actionDelLine = component.get("c.deleteLineCtr");
		actionDelLine.setParam("lineId", lineId);
		actionDelLine.setParam("parentId", component.get("v.relatedId"));

        actionDelLine.setCallback(this, function(a) {
        	console.log(actionDelLine.getState());
           if(actionDelLine.getState() ==='SUCCESS'){
            	rec.GDT_Activity_LineItems__r = {};
				rec.GDT_Activity_LineItems__r.records = [];
				rec.GDT_Activity_LineItems__r.records = a.getReturnValue();
				component.set("v.activityRequest",rec);
            	console.log('Line deleted ' + a.getReturnValue());
            }
            component.set("v.spinnerShow", "false");
        });
		$A.enqueueAction(actionDelLine);
	},

	editLine: function(component, event, helper) {
		var lineId = event.target.getAttribute("data-lineId");
		window.location.href = 'GDT_ManageActivity_NewRequestLine?id=' + lineId + '&activityId='+component.get("v.relatedId");

	},
	

	submitApproval: function(component, event, helper) {
		helper.setStatus(component,event,helper,'Pending Approval', false);
	},


	delete: function(component, event, helper) {
		helper.showLoading(component);
		var recordId = component.get("v.relatedId")
		
		var actionSubmit = component.get("c.deleteActivity");
		actionSubmit.setParam("recordId", recordId);

        actionSubmit.setCallback(this, function(a) {
            if(actionSubmit.getState() ==='SUCCESS'){
            	console.log('Activity deleted');
            	window.location.href = 'GDT_ManageActivity_ListRequests';
            }
            component.set("v.spinnerShow", "false");
        });
		$A.enqueueAction(actionSubmit);
	},

	inProgress: function(component, event, helper) {
		helper.setStatus(component,event,helper,'In Progress', false);

	},

	approve: function(component, event, helper) {
		helper.setStatus(component,event,helper,'On queue', false);

	},

	reject: function(component, event, helper) {
		helper.setStatus(component,event,helper,'Rejected', false);
	},

	resolved: function(component, event, helper) {
		helper.setStatus(component,event,helper,'Resolved', false);
	},

	waitingForUser: function(component, event, helper) {
		helper.setStatus(component,event,helper,'Waiting For User', false);
	},

	closed: function(component, event, helper) {
		helper.setStatus(component,event,helper,'Closed',false);
	},

	

	goBack: function(component, event, helper) {
        window.location.href = 'GDT_ManageActivity_ListRequests';
	},

	loaded: function(component, event, helper) {
        helper.serviceLoaded(component,event,helper);
	},

	onRecordSubmit : function(component, event, helper) {
		helper.showLoading(component);
		var servicesArray = {"SFDC-S01": "New SandBox (include Q&amp;A environment)","SFDC-S02": "Request of release","SFDC-S03": "Sandbox Refresh","SFDC-S04": "Standard object custom fields request","SFDC-S05": "Appexchange install and setup","SFDC-S06": "Incident Resolution","SFDC-S07": "Creation of power of delegation","SFDC-S08": "Creation of new role and profile","SFDC-S09": "Data Backup","SFDC-S10": "Data Restore","SFDC-S11": "Training on development standard","SFDC-S12": "User Assignments","SFDC-S13": "Data Update"};
		event.preventDefault(); // stop form submission
		console.log("submitting");
		var eventFields = event.getParam("fields");
		if(component.get("v.status") == ''){
			component.set("v.status", 'Created');
	   		eventFields["Status__c"] = "Created";
		}
	    eventFields["Services__c"] = servicesArray[component.get("v.selectedService")];
	    eventFields["Service_Code__c"] = component.get("v.selectedService");
	    eventFields["Date_Request__c"] = new Date();
	    eventFields["GDT_Services__c"] = component.get("v.serviceIds")[eventFields["Service_Code__c"]];
	    event.setParam("fields", eventFields);
	    component.find("myForm").submit(eventFields);
	},

	onRecordSuccess: function(component, event, helper) {
		component.set("v.isNew", false);
		var spinner = component.find("mySpinner");
	    if(spinner != undefined)$A.util.toggleClass(spinner, "slds-hide");
	    component.set("v.reloadForm", false);
        component.set("v.reloadForm", true);
        var payload = event.getParams().response;
        component.set("v.relatedId" , payload.id);
        console.log(payload.fields.Activity_Name__c.value);
        var rec = component.get("v.activityRequest");
		rec.Activity_Name__c = payload.fields.Activity_Name__c.value;
		rec.Services__c = payload.fields.Services__c.value;
		component.set("v.activityRequest",rec);

        helper.setEditableAttr(component,event,helper);
	    //window.location.href = 'GDT_ManageActivity_ListRequests';
	},
	onRecordError: function(component, event, helper) {
		var spinner = component.find("mySpinner");
	    if(spinner != undefined)$A.util.toggleClass(spinner, "slds-hide");
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
	}


})