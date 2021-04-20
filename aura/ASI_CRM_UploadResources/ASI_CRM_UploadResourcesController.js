({
    // -------------------------------------------------------------------------------
    
    initxlsx : function(component){
    },
    init : function(component, event, helper) {
        var uploadResourceId = component.get("v.uploadResourceId");
        
        var action = component.get("c.getUploadResourcesSetting");
        action.setParams({
            uploadResourceId: uploadResourceId,
        });
        action.setCallback(this, function(actionResult) { 
            console.log('init');
            console.log(actionResult);
            var uploadResourcesSettingList = [];
            for(var i=0; i< actionResult.getReturnValue().length;i++){
                console.log(actionResult.getReturnValue()[i]);
                
                var settignItem = {
                    "Excel": actionResult.getReturnValue()[i].Excel_Column_Header__c ,
                    "value": actionResult.getReturnValue()[i].Salesforce_Object_Name__c ,
                };
                uploadResourcesSettingList.push(settignItem);
            }
            component.set("v.uploadResourcesSettingList", uploadResourcesSettingList);
        });
        $A.enqueueAction(action);
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.fileAttacted", true);
        }
        component.set("v.fileName", fileName);
    },
    
    upload: function (component, event, helper) {
        var uploadResourceId = component.get("v.uploadResourceId");
        var recordId = component.get("v.recordId");
        var sobjecttype = component.get("v.sobjecttype");
        var fileAttacted = component.get("v.fileAttacted");
        console.log ('uploadResourceId: '+ uploadResourceId);
        console.log ('recordId: '+ recordId);
        console.log ('sobjecttype: '+ sobjecttype);
        
        
        console.log ('fileAttacted: '+ fileAttacted);
        if (component.find("file").get("v.files") != null && fileAttacted == true) {
            
            var fileInput = component.find("file").get("v.files");
            var file = fileInput[0];
            if (file) {
                console.log("File: "+file);
                
                var reader = new FileReader();
                reader.onload = function(e) {
                    var data = e.target.result;
                    var workbook = XLSX.read(data, {
                        type: 'binary'
                    });
                    workbook.SheetNames.forEach(function(sheetName) {
                        var XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
                        var jsonObject = JSON.stringify(XL_row_object);
                        console.log(jsonObject);
                        component.set("v.fileName", 'No File Selected.');
                		component.set("v.fileAttacted", false);
                        helper.createRecord(component, event, helper, 
                                            jsonObject,
                                            uploadResourceId,
                                            recordId,
                                            sobjecttype
                                           );
                    })
                };
                reader.onerror = function(ex) {
                    console.log(ex);
                };
                reader.readAsBinaryString(file);
            }  
        } else {
            console.log('Please Select a Valid File');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: "Please Select a Valid File",
                type: "warning"
            });
            toastEvent.fire();
        }
    },
    cancel: function (component, event, helper) {
        console.log ('Cancel...');
        component.set("v.fileName", 'No File Selected.');
        component.set("v.fileAttacted", false);
    },  
})