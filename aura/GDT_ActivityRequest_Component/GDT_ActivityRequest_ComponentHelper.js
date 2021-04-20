({
    readFile: function(component, helper, file) {
    	console.log(file);
        if (!file) return;
        //if (!file.type.match(/(image.*)/)) {
  		//	return alert('Image file not supported');
		//}
		var attachmentsLoaded = component.get("v.attachmentsLoaded");
		var att = {};
		att.Name = file.name;
		attachmentsLoaded.push(att);
		component.set("v.attachmentsLoaded", attachmentsLoaded);

        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
	},

	showLoading : function(component){
		component.set("v.spinnerShow", "true");
	},

	serviceLoaded: function(component, event, helper) {
		console.log(component.get("v.iterationLoaded") == true);
		if(component.get("v.iterationLoaded") == true){
			if(component.find("loadingDiv") != undefined){
				console.log("loaded");
				if(component.get("v.spinnerShow")){
					setTimeout(function() {
		        		component.set("v.spinnerShow", "false");
		            }, 1000);
				}
			}else{
				setTimeout(function() {
					helper.serviceLoaded(component, event, helper);
		        }, 1000);
			}
		}
	},

	getFields: function(component, event, helper,serSelected, setHtml) {
		console.log('get Fields');
		var actionGetFields = component.get("c.getFields");
		actionGetFields.setParam("fieldSetName", serSelected);

        actionGetFields.setCallback(this, function(a) {
            if(actionGetFields.getState() ==='SUCCESS' && setHtml){
            	var result = a.getReturnValue();
            	component.set("v.fields", JSON.parse(result));
            }
            console.log(actionGetFields.getState());
        });
        $A.getCallback(function() {
			 $A.enqueueAction(actionGetFields);
		})();
	},

	setStatus: function(component, event, helper,status, redirect) {
		helper.showLoading(component);
		var actionStatus = component.get("c.setStatus");
		actionStatus.setParam("pId", component.get("v.relatedId"));
		actionStatus.setParam("pStatus", status);

        actionStatus.setCallback(this, function(a) {
            if(actionStatus.getState() ==='SUCCESS'){
            	component.set("v.status", status);
				helper.setEditableAttr(component,event,helper);
            	component.find("myForm").submit();
            }
        });
		$A.enqueueAction(actionStatus);
	},

	setEditableAttr: function(component,event,helper){
		var status = component.get('v.status');
		var release = component.get('v.releaseRequest');
		component.set("v.editable", component.get("v.isNew") || status == 'Created' || status == 'Rejected' || status == 'Waiting for user' || component.get("v.isAdmin"));
		component.set("v.submittable", !component.get("v.isNew") && !component.get("v.isAdmin") && (status == 'Created' || status == 'Rejected' || status == 'Waiting for user' || (status == 'Resolved' && release)));
		console.log(status + ' ' + component.get("v.isNew"));
	},


    
    upload: function(component, file, base64Data) {
    	try{
		    var action = component.get("c.saveAttachment"); 
		    action.setParams({
		        parentId: component.get("v.relatedId"),
		        fileName: file.name,
		        base64Data: base64Data, 
		        contentType: file.type
		    });
		    action.setCallback(this, function(a) {
		    	if(action.getState() === 'SUCCESS'){
		    		var loaded = component.get("v.attachmentsLoaded");
		    		var newList = loaded.filter(function(ele){
		    			console.log(ele.Name + ' ' + file.name);
		    			return ele.Name != file.name;
		    		});
		    		component.set("v.attachmentsLoaded", newList);
		    		console.log(newList);

		            var atts = component.get("v.attachments");
		            atts.push(a.getReturnValue());
		            component.set("v.attachments", atts);
		    	}else{
		    		var loaded = component.get("v.attachmentsLoaded");
		    		var newList = loaded.filter(function(ele){
		    			if(ele.Name == file.name)ele.error = true;
		    			return true;
		    		});
		    		component.set("v.attachmentsLoaded", newList);
		    	}
		    });
		    $A.getCallback(function() {
		        $A.enqueueAction(action); 
		    })();
    	}catch (ex){
    		console.log('Error ' + ex);
    	}
        
    }

})