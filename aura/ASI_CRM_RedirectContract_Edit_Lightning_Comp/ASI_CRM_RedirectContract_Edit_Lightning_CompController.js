({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            
            if(data){
                console.log('@#'+JSON.stringify(data));
                if(data.RecordType.DeveloperName=='ASI_TH_CRM_Contract'){
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
                else if(data.RecordType.DeveloperName=='ASI_CRM_CN_Contract'){
                    if(data.ASI_CRM_CN_Status__c != 'Draft'){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/apex/ASI_CRM_CN_HeavyErrorPage"
                        });
                        urlEvent.fire();
                    }
                    else if(data.ASI_TH_CRM_Promotion_Type__c != null && data.ASI_TH_CRM_Promotion_Type__c != 'Heavy Contract On'){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/apex/ASI_CRM_CN_HeavyContractHeaderEditPage?id="+component.get("v.recordId")
                        });
                        urlEvent.fire();
                    }
                        else if (data.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract' || data.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO') {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/apex/ASI_CRM_CN_OffContractHeaderEditPage?id="+component.get("v.recordId")
                            });
                            urlEvent.fire();
                        }
                            else{
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": "/apex/ASI_CRM_CN_EditContractPage?RecordType="+data.RecordTypeId+'&id='+component.get("v.recordId") 
                                });
                                urlEvent.fire();
                            }
                }
                    else if(data.RecordType.DeveloperName == 'ASI_CRM_PH_Contract' || data.RecordType.DeveloperName == 'ASI_CRM_PH_Contract_Read_Only'){
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
                        else if(data.RecordType.DeveloperName == 'ASI_CRM_CN_Group_Contract'){
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
                            else if(data.RecordType.DeveloperName == 'ASI_CRM_CN_Local_Group_Contract' || data.RecordType.DeveloperName=='ASI_CRM_CN_Local_Group_Contract_Final'){
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
                                else if(data.RecordType.DeveloperName =='ASI_CRM_SG_Contract'){
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
                                    else if(data.RecordType.DeveloperName == 'ASI_CRM_SG_Proposal'){
                                        var evt = $A.get("e.force:navigateToComponent");
                                        evt.setParams({
                                            componentDef: "c:ASI_CRM_SG_EditContractPage_Comp",
                                            componentAttributes: {
                                                // Attributes here.
                                                "recordTypeId" : data.RecordTypeId,
                                                "recordId" : component.get("v.recordId")
                                            }
                                        });
                                        evt.fire();
                                    }
                                        else if(data.RecordType.DeveloperName == 'ASI_CRM_SG_Proposal_Read_Only'){
                                            var evt = $A.get("e.force:navigateToComponent");
                                            evt.setParams({
                                                componentDef: "c:ASI_CRM_SG_EditContractPage_Comp",
                                                componentAttributes: {
                                                    // Attributes here.
                                                    "recordTypeId" : data.RecordTypeId,
                                                    "recordId" : component.get("v.recordId")
                                                }
                                            });
                                            evt.fire();                               
                                        }
                                            else if(data.RecordType.DeveloperName.startsWith('ASI_CRM_MY_Contract')){
                                                console.log("@#MY"); 
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
                                                else if(data.RecordType.DeveloperName.startsWith('ASI_CRM_MO_Contract')){
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
                                                    else{
                                                        
                                                        var evt = $A.get("e.force:navigateToComponent");
                                                        evt.setParams({
                                                            componentDef: "c:ASI_CRM_Record_Edit_Comp",
                                                            componentAttributes: {
                                                                // Attributes here.
                                                                "record" : data,
                                                                "recordId" : component.get("v.recordId")
                                                            }
                                                        });
                                                        evt.fire();                                                        }
            }
        });
        $A.enqueueAction(action);
    }
})