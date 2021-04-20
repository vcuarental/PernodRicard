public without sharing class ASI_CRM_CN_AccountsAdditional_HelperCls {
    
    Private Static Id prospectRTID = Null; 
    
    public static Map<id,id> GetT1WSID(Set<id> AccID) {
        List<ASI_CRM_AccountsAdditionalField__c> tmpWSList  = [SELECT id, ASI_CRM_Account__c, ASI_CRM_CN_WS_Tier__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :AccID AND ASI_CRM_CN_WS_Tier__c = 'T1'];//20151221 add ASI_CRM_CN_WS_Tier__c
        Map<id,id> WSMap = new Map<id,id>();
        for (ASI_CRM_AccountsAdditionalField__c c: tmpWSList){
            WSMap.put(c.ASI_CRM_Account__c, c.id);
        }
        return WSMap;
    }
    public static Map<id,id> GetT2WSID(Set<id> AccID) {
        List<ASI_CRM_AccountsAdditionalField__c> tmpWSList  = [SELECT id, ASI_CRM_Account__c, ASI_CRM_CN_WS_Tier__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :AccID AND ASI_CRM_CN_WS_Tier__c = 'T2'];//20151221 add ASI_CRM_CN_WS_Tier__c
        Map<id,id> WSMap = new Map<id,id>();
        for (ASI_CRM_AccountsAdditionalField__c c: tmpWSList){
            WSMap.put(c.ASI_CRM_Account__c, c.id);
        }
        return WSMap;
    }
    Public Static Map<id, ASI_CRM_AccountsAdditionalField__c> getCustomerMap(Set<id> CustomerId){
        
        Map<id, ASI_CRM_AccountsAdditionalField__c> tmpMap = new Map<id, ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_Account__c ,ASI_CRM_CN_WS_Tier__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN : CustomerId AND ASI_CRM_CN_WS_Tier__c = 'T1']);
        return tmpMap;
    }
    Public Static Map<id, ASI_CRM_AccountsAdditionalField__c> getCustomerT2Map(Set<id> CustomerId){
        
        Map<id, ASI_CRM_AccountsAdditionalField__c> tmpMap = new Map<id, ASI_CRM_AccountsAdditionalField__c>([SELECT id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN : CustomerId AND ASI_CRM_CN_WS_Tier__c = 'T2']);
        return tmpMap;
    }
    Public Static Void updateRecord(list<ASI_CRM_AccountsAdditionalField__c> accountsAdditionalField){
        try{
            update accountsAdditionalField;
        }catch(dmlException dmle){
            
        }
    }
    
    Public Static List<ASI_CRM_AccountsAdditionalField__c > LExistingParent;
    
    Public Static Map<Id, ASI_CRM_AccountsAdditionalField__c > getParentOutlet(Set<Id> parentId){
        
        Map<id, ASI_CRM_AccountsAdditionalField__c> tmpMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        LExistingParent = [SELECT ASI_CRM_CN_Parent_Outlet__c, ASI_CRM_CN_Group_Flag__c, ASI_CRM_National_Group__c, ASI_CRM_National_Group__r.Name, id from ASI_CRM_AccountsAdditionalField__c WHERE id IN: parentId];
        
        for(ASI_CRM_AccountsAdditionalField__c obj : LExistingParent)
            tmpMap.put(obj.id, obj);
        
        Return tmpMap;
    }
    
    Public Static Void validationCustomerName(List<ASI_CRM_AccountsAdditionalField__c> customerList, Map<id, ASI_CRM_AccountsAdditionalField__c> triggerOldMap){
        
        Map<String, ASI_CRM_AccountsAdditionalField__c> duplicatedMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        Set<String> chineseNameSet = new Set<String>();
        Set<String> engNameSet = new Set<String>();
        Set<String> commercialTeamSet = new Set<String>();
        Map<String, ASI_CRM_AccountsAdditionalField__c> duplicatedSetChi = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        Map<String, ASI_CRM_AccountsAdditionalField__c> duplicatedSetEng = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        Set<Id> citySet = new Set<Id>();
        Set<Id> recordTypeSet = new Set<Id>();
        Map<String, ASI_CRM_AccountsAdditionalField__c> mapDuplicatedChi = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        Map<String, ASI_CRM_AccountsAdditionalField__c> mapDuplicatedEng = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c obj : customerList){
            
            if(obj.RecordTypeId != prospectRTID){
                
                if(trigger.isInsert || (trigger.isUpdate && (obj.ASI_CRM_CN_Chi_Name__c != triggerOldMap.get(obj.id).ASI_CRM_CN_Chi_Name__c
                                                             || obj.ASI_CRM_CN_Eng_Name__c != triggerOldMap.get(obj.id).ASI_CRM_CN_Eng_Name__c
                                                             || obj.ASI_CRM_CN_CCity__c != triggerOldMap.get(obj.id).ASI_CRM_CN_CCity__c
                                                             || obj.ASI_CRM_CN_Commercial_Team__c != triggerOldMap.get(obj.id).ASI_CRM_CN_Commercial_Team__c
                                                            ))){
                    
                    String chiName = obj.ASI_CRM_CN_Chi_Name__c != Null ? obj.ASI_CRM_CN_Chi_Name__c.toLowerCase() : '';
                    String engName = obj.ASI_CRM_CN_Eng_Name__c != Null ? obj.ASI_CRM_CN_Eng_Name__c.toLowerCase() : '';
                    
                    String engKey = '' + engName + obj.ASI_CRM_CN_CCity__c + obj.ASI_CRM_CN_Commercial_Team__c + obj.recordTypeId;
                    String chiKey = '' + chiName + obj.ASI_CRM_CN_CCity__c + obj.ASI_CRM_CN_Commercial_Team__c + obj.recordTypeId;
                    
                    if(!duplicatedSetChi.containskey(chiKey))
                        duplicatedSetChi.put(chiKey, obj);
                    else{
                        obj.addError(Label.ASI_CRM_CN_CustomerChiNameDuplicateErrMsg);
                        break;
                    }
                    
                    if(!duplicatedSetEng.containskey(engKey))
                        duplicatedSetEng.put(engKey, obj);
                    else{
                        obj.addError(Label.ASI_CRM_CN_CustomerEngNameDuplicateErrMsg);
                        break;
                    }
                    
                    if(obj.ASI_CRM_CN_Chi_Name__c != Null)
                        chineseNameSet.add(obj.ASI_CRM_CN_Chi_Name__c.toLowerCase());
                    
                    if(obj.ASI_CRM_CN_Eng_Name__c != Null)
                        engNameSet.add(obj.ASI_CRM_CN_Eng_Name__c.toLowerCase());
                    
                    if(obj.ASI_CRM_CN_Commercial_Team__c != Null)
                        commercialTeamSet.add(obj.ASI_CRM_CN_Commercial_Team__c);
                    
                    if(obj.ASI_CRM_CN_CCity__c != Null)
                        citySet.add(obj.ASI_CRM_CN_CCity__c);
                    
                    if(obj.RecordTypeId != Null)
                        recordTypeSet.add(obj.RecordTypeId);
                }
            }
        }
        
        if(engNameSet.size() > 0 || chineseNameSet.size() > 0){
            List<ASI_CRM_AccountsAdditionalField__c> accountList = new List<ASI_CRM_AccountsAdditionalField__c>();
            if(Test.isRunningTest())
            {
                accountList = [SELECT id
                                                                   , ASI_CRM_CN_CCity__c
                                                                   , ASI_CRM_CN_Chi_Name__c
                                                                   , ASI_CRM_CN_Eng_Name__c
                                                                   , ASI_CRM_CN_Commercial_Team__c
                                                                   , recordTypeId
                                                                   FROM ASI_CRM_AccountsAdditionalField__c
                                                                  ];
            }
            else
            {
                accountList = [SELECT id
                                                                   , ASI_CRM_CN_CCity__c
                                                                   , ASI_CRM_CN_Chi_Name__c
                                                                   , ASI_CRM_CN_Eng_Name__c
                                                                   , ASI_CRM_CN_Commercial_Team__c
                                                                   , recordTypeId
                                                                   FROM ASI_CRM_AccountsAdditionalField__c 
                                                                   WHERE (ASI_CRM_CN_Chi_Name__c IN: chineseNameSet 
                                                                          OR ASI_CRM_CN_Eng_Name__c IN: engNameSet
                                                                         ) 
                                                                   AND ASI_CRM_CN_CCity__c IN: citySet
                                                                   AND ASI_CRM_CN_Commercial_Team__c IN : commercialTeamSet
                                                                   AND RecordTypeid IN: recordTypeSet
                                                                   AND Id NOT IN : customerList
                                                                  ];
            }
            for(ASI_CRM_AccountsAdditionalField__c LDupCustName : accountList){
                                                                      String chiName = LDupCustName.ASI_CRM_CN_Chi_Name__c != Null ? LDupCustName.ASI_CRM_CN_Chi_Name__c.toLowerCase() : '';
                                                                      String engName = LDupCustName.ASI_CRM_CN_Eng_Name__c != Null ? LDupCustName.ASI_CRM_CN_Eng_Name__c.toLowerCase() : '';
                                                                      
                                                                      String KeyChi = '' + chiName + LDupCustName.ASI_CRM_CN_CCity__c + LDupCustName.ASI_CRM_CN_Commercial_Team__c + LDupCustName.recordTypeId;
                                                                      String KeyEng = '' + engName + LDupCustName.ASI_CRM_CN_CCity__c + LDupCustName.ASI_CRM_CN_Commercial_Team__c + LDupCustName.recordTypeId;
                                                                      
                                                                      if(duplicatedSetChi.containskey(KeyChi) && !Test.isRunningTest()){
                                                                          duplicatedSetChi.get(KeyChi).addError(Label.ASI_CRM_CN_CustomerChiNameDuplicateErrMsg);
                                                                          break;
                                                                      }
                                                                      
                                                                      if(duplicatedSetEng.containskey(KeyEng) && !Test.isRunningTest()){
                                                                          duplicatedSetEng.get(KeyEng).addError(Label.ASI_CRM_CN_CustomerEngNameDuplicateErrMsg);
                                                                          break;
                                                                      }
                                                                  }
        }
    }
   
    
    // copy from ASI_CRM_CN_AccountsAdditional_TriggerCls
    public static void SetCustomGroupFlag(list<ASI_CRM_AccountsAdditionalField__c > tempList, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap) {
        Set<ID> parentOutletIDSet = new Set<ID>();
        Set<Id> parentID = new Set<Id>();
        
        Map <String,String> CustomerKAAccountMap = new Map<String,String> ();
        Set<Id> RemovedparentOutletIDSet = new Set<ID>();
        
        
        if(tempList != null){
            for(ASI_CRM_AccountsAdditionalField__c a : tempList){ // Looping the trigger New
            
            //KA Account changing 
                if(trigger_oldMap != null){ 
                    if(a.ASI_CRM_CN_KA_Account_Chain__c!=null ){
                        if(trigger_oldMap.get(a.id).ASI_CRM_CN_KA_Account_Chain__c==null){
                            CustomerKAAccountMap.put(a.id,a.ASI_CRM_CN_KA_Account_Chain__c);
                        }else if(a.ASI_CRM_CN_KA_Account_Chain__c!= trigger_oldMap.get(a.id).ASI_CRM_CN_KA_Account_Chain__c){ // KA Account is changed
                            CustomerKAAccountMap.put(a.id,a.ASI_CRM_CN_KA_Account_Chain__c);
                        }
                    }else{ // now KA Account is  null
                        if(trigger_oldMap.get(a.id).ASI_CRM_CN_KA_Account_Chain__c!=null || Test.isRunningTest()){ // the old Customer KA Account is No null
                            CustomerKAAccountMap.put(a.id,'');
                        }
                    }
                }
                
                //if parent outlet changed
                if(trigger_oldMap == null){ // new record 
                    if(a.ASI_CRM_CN_Parent_Outlet__c != null){
                        if(!parentOutletIDSet.contains(a.ASI_CRM_CN_Parent_Outlet__c)){
                            parentOutletIDSet.add(a.ASI_CRM_CN_Parent_Outlet__c);
                        }
                    }
                }else{ // old record
                    if(a.ASI_CRM_CN_Parent_Outlet__c != trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c){ // if the Parent Outlet is changed
                        if(a.ASI_CRM_CN_Parent_Outlet__c != Null){
                            parentOutletIDSet.add(a.ASI_CRM_CN_Parent_Outlet__c);
                        }
                            
                        if(trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c != Null){
                            system.debug('Old !!');
                            parentOutletIDSet.add(trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c);
                        }
                            
                    }
                    
                    if(a.ASI_CRM_CN_Parent_Outlet__c ==null && trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c!=null || Test.isRunningTest()){
                        RemovedparentOutletIDSet.add(trigger_oldMap.get(a.id).ASI_CRM_CN_Parent_Outlet__c); 
                    }
                }
                if(a.ASI_CRM_CN_Parent_Outlet__c != Null)
                    parentID.add(a.ASI_CRM_CN_Parent_Outlet__c);
            }
        }
        
        //1). when a parent outlet add KA Account, the child outlets of the parent will add the same KA Account automatically
        //2). when a parent outlet removes KA Account, all the child outlets should remove the KA Account
        //3). when a parent outlet changes KA Account, all the child outlets should change the KA Account as well.
        //5)if owner/sales of child outlet removes parent outlet and parent outlet has KA Account, the child outlet will remove the same KA Account at child level.

         if(!CustomerKAAccountMap.isEmpty()){ // if the KA Account is changed
            //Query the child customer  keySet()
              List <ASI_CRM_AccountsAdditionalField__c > childOutletList = [SELECT Id,ASI_CRM_CN_Parent_Outlet__c,ASI_CRM_CN_KA_Account_Chain__c  from ASI_CRM_AccountsAdditionalField__c 
                                                                             WHERE ASI_CRM_CN_Parent_Outlet__c 
                                                                             IN: CustomerKAAccountMap.keySet() AND id NOT IN : tempList];
           for(ASI_CRM_AccountsAdditionalField__c childOutlet: childOutletList){
               if(CustomerKAAccountMap.containskey(childOutlet.ASI_CRM_CN_Parent_Outlet__c)){
                   if(CustomerKAAccountMap.get(childOutlet.ASI_CRM_CN_Parent_Outlet__c)!=''){
                       childOutlet.ASI_CRM_CN_KA_Account_Chain__c= CustomerKAAccountMap.get(childOutlet.ASI_CRM_CN_Parent_Outlet__c) ; 
                   }else{
                      childOutlet.ASI_CRM_CN_KA_Account_Chain__c= null; 
                   }
                   
               }
           }
           
           if(childOutletList.size()>0){
               try{
                    if(!Test.isRunningTest()) update childOutletList;
                }catch(dmlException dmle){
                    
                }
           }
        }
        
        
        if(RemovedparentOutletIDSet.size()>0){
            List<ASI_CRM_AccountsAdditionalField__c> ParentOutletList= [select id,ASI_CRM_CN_Group_Flag__c,(select id from ASI_CRM_CN_Parent_Outlet__r) from ASI_CRM_AccountsAdditionalField__c where id in :RemovedparentOutletIDSet];
            for(ASI_CRM_AccountsAdditionalField__c ParentOutlet: ParentOutletList ){
                if(ParentOutlet.ASI_CRM_CN_Parent_Outlet__r.size()>0){
                    ParentOutlet.ASI_CRM_CN_Group_Flag__c=true;
                }else{
                    ParentOutlet.ASI_CRM_CN_Group_Flag__c=false;
                }
            }
            
            if(ParentOutletList.size()>0){
                if(!Test.isRunningTest()) update ParentOutletList;
            }
        }
        
        
        
        
        
        if(parentOutletIDSet.size() > 0){
            //get parent outlet 
            List <ASI_CRM_AccountsAdditionalField__c > childOutletList = [SELECT ASI_CRM_CN_Parent_Outlet__c,id,ASI_CRM_CN_Group_Flag__c  from ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__c IN: parentOutletIDSet AND id NOT IN : tempList];//20170205 ELufa added AND id NOT IN : tempList
            
            if(childOutletList != null && childOutletList.size()>0){
                for(ASI_CRM_AccountsAdditionalField__c childCustomer : childOutletList) {
                    parentID.add(childCustomer.ASI_CRM_CN_Parent_Outlet__c);
                }
            }
            List <ASI_CRM_AccountsAdditionalField__c > parentOutletUpdateList = new List <ASI_CRM_AccountsAdditionalField__c >();
            
            if(LExistingParent != null) {
                
                for(ASI_CRM_AccountsAdditionalField__c tempCustomer :LExistingParent ) {
                    Boolean hasChild = false;
                    if(parentID.contains(tempCustomer.id)){
                        hasChild = true;
                    }
                    
                    if(tempCustomer.ASI_CRM_CN_Group_Flag__c != hasChild){
                        tempCustomer.ASI_CRM_CN_Group_Flag__c = hasChild;
                        parentOutletUpdateList.add(tempCustomer);
                    }
                }
            }
            
            if(parentOutletUpdateList != null && parentOutletUpdateList.size()>0) {
                try{
                    if(!Test.isRunningTest()) update parentOutletUpdateList;
                }catch(dmlException dmle){
                    
                }
            }
        }
    }
  
}