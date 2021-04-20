({
	showLoading : function(component){
		component.set("v.spinnerShow", "true");
	},

	serviceLoaded: function(component, event, helper) {
		component.set("v.spinnerShow", "false");
	},

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

	 upload: function(component, file, base64Data) {
    	try{
		    var action = component.get("c.saveAttachment"); 
		    action.setParams({
		        parentId: component.get("v.lineId"),
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