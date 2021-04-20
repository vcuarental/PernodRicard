public with sharing class ASI_CRM_CN_Customer_TriggerClass {
    public static void routineBeforeUpsert(list<ASI_CRM_AccountsAdditionalField__c> trigger_new ,map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap){
        
        Set<ID> parentOutletIDSet = new Set<ID>();
        
        
        for(ASI_CRM_AccountsAdditionalField__c newRecord : trigger_new){
            if(trigger_oldMap==null){ // new record insert
                if(newRecord.ASI_CRM_CN_Parent_Outlet__c!=null){
                    parentOutletIDSet.add(newRecord.ASI_CRM_CN_Parent_Outlet__c);
                }
            }else{ // update 
                if(newRecord.ASI_CRM_CN_Parent_Outlet__c!=null){
                    if(trigger_oldMap.get(newRecord.id).ASI_CRM_CN_Parent_Outlet__c==null){ // new add
                        parentOutletIDSet.add(newRecord.ASI_CRM_CN_Parent_Outlet__c);
                    }else if(newRecord.ASI_CRM_CN_Parent_Outlet__c!= trigger_oldMap.get(newRecord.id).ASI_CRM_CN_Parent_Outlet__c){
                        parentOutletIDSet.add(newRecord.ASI_CRM_CN_Parent_Outlet__c);
                    }
                }else{ // newRecord.ASI_CRM_CN_Parent_Outlet__c==null 
                    //
                    if(trigger_oldMap.get(newRecord.id).ASI_CRM_CN_Parent_Outlet__c!=null){ // parent outlet is removed
                        newRecord.ASI_CRM_CN_KA_Account_Chain__c=null;parentOutletIDSet.add(trigger_oldMap.get(newRecord.id).ASI_CRM_CN_Parent_Outlet__c);
                    }
                }
                
                
                
            }
            
            //if the customer changing KA Account will also check the parent outlet 
            
        }
        
        
        // 4). If a child outlet having a parent outlet, it is NOT allowed to change KA Account field in child outlet. (This logic applies to parent outlet with off KA account or no KA account)
        //6) After a parent outlet linked with a KA Account and user add another child outlet to this parent, system add the same KA Account in the child outlet.
        //7) If a outlet has a KA Account and later link to a parent outlet having another KA Account, the original KA Account in child outlet will be updated the same as parent KA Account. If the parent does not have KA Account, the child outlet KA Account will be removed as empty.
        
        if(parentOutletIDSet.size()>0 ){
            Map <String,String> KAAccountMap = new Map<String,String> ();
            List <ASI_CRM_AccountsAdditionalField__c > ParentOutletList = [SELECT id,ASI_CRM_CN_Parent_Outlet__c,ASI_CRM_CN_KA_Account_Chain__c  from ASI_CRM_AccountsAdditionalField__c 
                                                                           WHERE id IN: parentOutletIDSet AND id NOT IN : trigger_new and ASI_CRM_CN_KA_Account_Chain__c!=null];
            for(ASI_CRM_AccountsAdditionalField__c ParentCustomer : ParentOutletList ){
                KAAccountMap.put(ParentCustomer.Id, ParentCustomer.ASI_CRM_CN_KA_Account_Chain__c);
            }
            
            
            for(ASI_CRM_AccountsAdditionalField__c customer : trigger_new){
                if(customer.ASI_CRM_CN_Parent_Outlet__c!=null){
                    if(KAAccountMap.containskey(customer.ASI_CRM_CN_Parent_Outlet__c)){
                        customer.ASI_CRM_CN_KA_Account_Chain__c= KAAccountMap.get(customer.ASI_CRM_CN_Parent_Outlet__c) ; 
                    }
                }
            }
            
        }
        
    }
}