public without sharing class ASI_MFM_KR_POLineItem_TriggerClass {
    
    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        //Get changed pr Line ID if new insert or changed amount 
        
        set<id> prlidset= new set<id>();
        set<id> customerIdSet = new set<id>();
        
        Map<id, ASI_MFM_Purchase_Request_Line__c> MapPR= NEW Map<id, ASI_MFM_Purchase_Request_Line__c>();
        /*
        if(trigger_oldMap==null){ //New insert 
            for (ASI_MFM_PO_Line_Item__c pol:trigger_new) {       
                if(pol.ASI_MFM_Purchase_Request_Line__c!=null){
                    prlidset.add(pol.ASI_MFM_Purchase_Request_Line__c);
                }                                
            }
        }// End 
        */
        for(ASI_MFM_PO_Line_Item__c pol: trigger_new){
            if(pol.ASI_MFM_AccountsAdditionalField__c != null){
                system.debug('Linus: get Customer');
                customerIdSet.add(pol.ASI_MFM_AccountsAdditionalField__c);            
            }
            
            if(trigger_oldMap == null){  //New insert
                if(MapPR.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){
                    MapPR.get(pol.ASI_MFM_Purchase_Request_Line__c).ASI_MFM_PO_Amount_in_PR_Currency__c+=pol.ASI_MFM_PO_Amount_in_PR_Currency__c;
                }else{
                  MapPR.put(pol.ASI_MFM_Purchase_Request_Line__c, new ASI_MFM_Purchase_Request_Line__c( id=pol.ASI_MFM_Purchase_Request_Line__c,
                                                                    ASI_MFM_Estimated_PR_budget__c=pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Estimated_PR_budget__c,
                                                                    ASI_MFM_PO_Amount_in_PR_Currency__c=pol.ASI_MFM_PO_Amount_in_PR_Currency__c));  
                }
            }//End construct Map
        }
        /*
        if(prlidset.size()>0){
            List<ASI_MFM_PO_Line_Item__c> POLList= [select id,ASI_MFM_Purchase_Request_Line__c,ASI_MFM_PO_Amount_in_PR_Currency__c,name,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Estimated_PR_budget__c,ASI_MFM_Purchase_Request_Line__r.ASI_MFM_PO_Amount_in_PR_Currency__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_Purchase_Request_Line__c in : prlidset] ;
           
            for(ASI_MFM_PO_Line_Item__c pol: POLList){
                if(MapPR.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){
                    MapPR.get(pol.ASI_MFM_Purchase_Request_Line__c).ASI_MFM_PO_Amount_in_PR_Currency__c+=pol.ASI_MFM_PO_Amount_in_PR_Currency__c;
                }else{
                  MapPR.put(pol.ASI_MFM_Purchase_Request_Line__c, new ASI_MFM_Purchase_Request_Line__c( id=pol.ASI_MFM_Purchase_Request_Line__c,
                                                                    ASI_MFM_Estimated_PR_budget__c=pol.ASI_MFM_Purchase_Request_Line__r.ASI_MFM_Estimated_PR_budget__c,
                                                                    ASI_MFM_PO_Amount_in_PR_Currency__c=pol.ASI_MFM_PO_Amount_in_PR_Currency__c));  
                }
                
            }
        }//End construct Map        
        */
        
        Map<Id, boolean> MapCus = new Map<Id, boolean>();
        if(customerIdSet.size() > 0){
            for(ASI_CRM_AccountsAdditionalField__c cus: [Select id , ASI_CRM_CN_Inactive_Flag__c from ASI_CRM_AccountsAdditionalField__c where id IN: customerIdSet] ){
                MapCus.put(cus.id, cus.ASI_CRM_CN_Inactive_Flag__c);
            }
        }
        
        for (ASI_MFM_PO_Line_Item__c pol:trigger_new) {
            if(pol.ASI_MFM_Purchase_Request_Line__c!=null){
                if(MapPR.containsKey(pol.ASI_MFM_Purchase_Request_Line__c)){
                    if(MapPR.get(pol.ASI_MFM_Purchase_Request_Line__c).ASI_MFM_Estimated_PR_budget__c<MapPR.get(pol.ASI_MFM_Purchase_Request_Line__c).ASI_MFM_PO_Amount_in_PR_Currency__c){
                        pol.addError('Purchase Request Over Budget!');
                    }
                }
            }//Finsihed checking 
            
            
            // Check not allow selecting inactive customer except PO is Closed   ******** 2018-03-20 Linus@introv
            if(pol.ASI_MFM_PO_Status__c != null && pol.ASI_MFM_PO_Status__c != 'Closed'){
                if(MapCus.get(pol.ASI_MFM_AccountsAdditionalField__c) == true){
                    pol.addError('Not allow selecting inactive customer');
                }
            }
            // END - 2018-03-20 Linus@introv
            
        }
        
    }
    
    
    
    
}