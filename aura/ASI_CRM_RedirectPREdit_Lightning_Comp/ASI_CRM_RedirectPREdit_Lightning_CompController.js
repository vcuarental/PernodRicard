({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(data){
			 if(data.RecordType.DeveloperName == 'ASI_CRM_CN_Payment_Request'){
                 if(data.ASI_CRM_CN_Promotion_Type__c != null && data.ASI_CRM_CN_Promotion_Type__c == 'Heavy Contract On'){
                     if(data.Name.length > 3){
                         if(data.Name.substr(data.Name.length()-3, data.Name.length()) == '000'){
                             var urlEvent = $A.get("e.force:navigateToURL");
                             urlEvent.setParams({
                                 "url": "/apex/ASI_CRM_CN_EditPayment_Header_Page?RecordType="+data.RecordTypeId + "&id=" + component.get("v.recordId")
                             });
                             urlEvent.fire();
                         }else{
                              var urlEvent = $A.get("e.force:navigateToURL");
                             urlEvent.setParams({
                                 "url": "/apex/ASI_CRM_CN_EditHeavyPayment_Header_Page?id=" + component.get("v.recordId")
                             });
                             urlEvent.fire();
                         }
                     }
                  }
                 else{
                        var urlEvent = $A.get("e.force:navigateToURL");
                             urlEvent.setParams({
                                 "url": "/apex/ASI_CRM_CN_EditPayment_Header_Page?RecordType="+data.RecordTypeId + "&id=" + component.get("v.recordId")
                             });
                             urlEvent.fire();
                         }
                }else{
                         var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef: "c:ASI_CRM_Record_Edit_Comp",
                            componentAttributes: {
                                // Attributes here.
                                "record" : data,
                                "recordId" : component.get("v.recordId")
                            }
                        });
                        evt.fire();
                }
            }else{
                $A.get("e.force:closeQuickAction");
            }
        });
        $A.enqueueAction(action);
	}
})