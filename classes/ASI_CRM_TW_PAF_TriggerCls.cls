public without sharing class ASI_CRM_TW_PAF_TriggerCls{
    //Bypass user from specific validation
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :curUserId];
        if (users.size() > 0 && users[0].BypassTriggers__c != null) {
            if (users[0].BypassTriggers__c.contains('ASI_CRM_TW_FreeGoodsRequest_TriggerCls')){
                isByPass = true;
        }
    }
        return isByPass;
    }
    
    public static void routineBeforeUpsert (list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new, map<id, ASI_HK_CRM_Pre_Approval_Form__c> trigger_oldMap) {
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            if(paf.ASI_HK_CRM_PAF_End_Date__c < paf.ASI_HK_CRM_PAF_Start_Date__c)
                paf.addError('Start Date should be before End Date.');
            
            Integer numberOfMonths = paf.ASI_HK_CRM_PAF_Start_Date__c.monthsBetween(paf.ASI_HK_CRM_PAF_End_Date__c);
            system.debug('Number Of Months: '+numberOfMonths);
            /*
            if(numberOfMonths  > 11)
                paf.addError('Contract period cannot be longer than 1 year.');
            */
        }
    }
    
    public static void routineBeforeInsert(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new, map<id, ASI_HK_CRM_Pre_Approval_Form__c> trigger_oldMap) {
        retrieveHeaderValue(trigger_new);
        
        //get no. of outlet
        Set<Id> setAccountId = new Set<Id>();    
        Map<Id, Integer> mapNoOfOutlet = new Map<Id, Integer>();
        Id ChannelId;
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            setAccountId.add(paf.ASI_HK_CRM_PAF_Customer__c);
            ChannelId = paf.ASI_CRM_Channel__c;
        }
        List<Account> listChildOutlets = [SELECT Id, Name, ParentId FROM Account WHERE (ParentId IN: setAccountId OR Id IN: setAccountId) AND ASI_HK_CRM_Inactive__c = FALSE];       
        system.debug('Child List Size: '+listChildOutlets.size());
        
        //[SH] 2019-06-11
        ASI_CRM_CN_Channel__c channel = [Select id, ASI_CRM_TW_Channel_Av__c , ASI_CRM_TW_Channel_Av_CATAP_NS__c , ASI_CRM_TW_Channel_Av_Investment_Ratio__c  from ASI_CRM_CN_Channel__c where id = :ChannelId limit 1];
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            for(Account outlet : listChildOutlets){
                if(outlet.Id == paf.ASI_HK_CRM_PAF_Customer__c || outlet.ParentId == paf.ASI_HK_CRM_PAF_Customer__c){
                    if(mapNoOfOutlet != null && mapNoOfOutlet.size() > 0 && mapNoOfOutlet.get(paf.id) != null){
                        Integer num = mapNoOfOutlet.get(paf.id);
                        mapNoOfOutlet.put(paf.id, num++);
                    }
                    else
                        mapNoOfOutlet.put(paf.id, 1);
                }
            }
        }
        system.debug('No. of Outlet Map: '+mapNoOfOutlet);
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            if(paf.ASI_CRM_No_of_Outlets__c == null && mapNoOfOutlet != null && mapNoOfOutlet.size() > 0)
                paf.ASI_CRM_No_of_Outlets__c = mapNoOfOutlet.get(paf.id);
            system.debug('No. of Outlet: '+mapNoOfOutlet.get(paf.id));
            
            //[SH] 2019-06-11
            if(channel != null){
                paf.ASI_CRM_TW_Channel_Av__c = channel.ASI_CRM_TW_Channel_Av__c;
                paf.ASI_CRM_TW_Channel_Av_CATAP_NS__c = channel.ASI_CRM_TW_Channel_Av_CATAP_NS__c;
                paf.ASI_CRM_TW_Channel_Av_Investment_Ratio__c = channel.ASI_CRM_TW_Channel_Av_Investment_Ratio__c;
            }
        }
    }
    
    public static void routineAfterInsert(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new, map<id, ASI_HK_CRM_Pre_Approval_Form__c> trigger_oldMap) {
        generateOutletChild(trigger_new);
    }
    
    public static void routineBeforeUpdate(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new, map<id, ASI_HK_CRM_Pre_Approval_Form__c> trigger_oldMap) {
        retrieveHeaderValue(trigger_new);
        
        //get current user permission sets
        List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :Userinfo.getUserId() AND 
                                                               (PermissionSet.Name = 'ASI_CRM_TW_IT_Admin' OR
                                                               PermissionSet.Name = 'ASI_CRM_TW_Regional_Sales_Assist' OR
                                                               PermissionSet.Name = 'ASI_CRM_TW_TMKT_Users')];
                                                               
        //get no. of outlet
        Set<Id> setAccountId = new Set<Id>();    
        Map<Id, Integer> mapNoOfOutlet = new Map<Id, Integer>();
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            setAccountId.add(paf.ASI_HK_CRM_PAF_Customer__c);
        }
        
        List<Account> listChildOutlets = [SELECT Id, Name, ParentId FROM Account WHERE (ParentId IN: setAccountId OR Id IN: setAccountId) AND ASI_HK_CRM_Inactive__c = FALSE];       
        system.debug('Child List Size: '+listChildOutlets.size());
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            //Empty Plan Converted Date once Draft
            if(paf.ASI_CRM_Commitment_No__c != null && paf.ASI_HK_CRM_PAF_Customer__c != trigger_oldMap.get(paf.id).ASI_HK_CRM_PAF_Customer__c)
                paf.addError('Cannot change Customer if PAF is converted to plan.');

            if(paf.ASI_HK_CRM_PAF_Status__c == 'Draft')
                paf.ASI_CRM_Converted_Date__c = null;
            
            if(trigger_oldMap.get(paf.id).ASI_HK_CRM_PAF_Status__c == 'Cancel'){
                paf.addError('\'Cancel\' PAF cannot be updated anymore.');
            }
            
            if(listCurrentUserPerSet == null || listCurrentUserPerSet.size() <= 0){
                if(trigger_oldMap.get(paf.id).ASI_HK_CRM_PAF_Status__c == 'Complete'){
                    paf.addError('\'Complete\' PAF cannot be updated anymore.');
                }
                else if(paf.ASI_CRM_Commitment_No__c != null && paf.ASI_CRM_Commitment_Status__c != 'Draft'){
                    paf.addError('Cannot edit PAF with converted non-draft Plan.');
                }
            }
            
            if(trigger_oldMap.get(paf.id).ASI_CRM_BA_Comment__c != paf.ASI_CRM_BA_Comment__c){
                if(paf.ASI_HK_CRM_PAF_Status__c == 'Complete')
                    paf.addError('You are not allow to update BA Comment of \'Complete\' PAF.');
                /*else if(paf.ASI_HK_CRM_PAF_Status__c == 'Cancel')
                    paf.addError('\'Cancel\' PAF cannot be updated anymore.');*/
            }
            
            //get no. of outlet
            for(Account outlet : listChildOutlets){
                if(outlet.Id == paf.ASI_HK_CRM_PAF_Customer__c || outlet.ParentId == paf.ASI_HK_CRM_PAF_Customer__c){
                    if(mapNoOfOutlet != null && mapNoOfOutlet.size() > 0 && mapNoOfOutlet.get(paf.id) != null){
                        Integer num = mapNoOfOutlet.get(paf.id);
                        mapNoOfOutlet.put(paf.id, ++num);
                    }
                    else
                        mapNoOfOutlet.put(paf.id, 1);
                }
            }
        }
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            if(trigger_oldMap.get(paf.id).ASI_HK_CRM_PAF_Customer__c != paf.ASI_HK_CRM_PAF_Customer__c && mapNoOfOutlet != null && mapNoOfOutlet.size() > 0)
                paf.ASI_CRM_No_of_Outlets__c = mapNoOfOutlet.get(paf.id);
        }
     }
    
    public static void routineAfterUpdate(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new, map<id, ASI_HK_CRM_Pre_Approval_Form__c> trigger_oldMap) {
        Set<Id> setPAFwithCustomers = new Set<Id>();
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            if(paf.ASI_HK_CRM_PAF_Customer__c != trigger_oldMap.get(paf.id).ASI_HK_CRM_PAF_Customer__c){
                setPAFwithCustomers.add(paf.id);
            }
        }
        
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listDeletePAFCustomer = [SELECT id FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c IN: setPAFwithCustomers];
        delete listDeletePAFCustomer;
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            if(paf.ASI_HK_CRM_PAF_Customer__c != trigger_oldMap.get(paf.id).ASI_HK_CRM_PAF_Customer__c){
                generateOutletChild(paf);
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_old){
        if(!isBypassByCurrentUser()){
            for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_old){
                if(paf.ASI_HK_CRM_PAF_Status__c != 'Draft'){
                    paf.addError('You are not allowed to delete \''+paf.ASI_HK_CRM_PAF_Status__c+'\' request.');
                }
            }
        }
    }
    
    private static void retrieveHeaderValue(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new){
        Map<Id, Account> accMapbyAccId = new Map<Id, Account>();
        Map<Id, ASI_CRM_AccountsAdditionalField__c> custMapbyAccId = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        //Map<Id, User> mapAccOwnerInfo = new Map<Id, User>();
        
        Set<Id> setAccountId = new Set<Id>();    
        //Set<Id> setOwnerId = new Set<Id>();  
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            setAccountId.add(paf.ASI_HK_CRM_PAF_Customer__c);
        } 
        
        /*for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Id IN: setAccountId]){
            accMapbyAccId.put(acc.Id, acc);
            setOwnerId.add(acc.OwnerId);
        }*/
        
        /*for(User u : [SELECT id, ASI_KOR_User_Region_Code__c FROM User WHERE id IN: setOwnerId]){
            mapAccOwnerInfo.put(u.id, u);
        }*/
        
        for(ASI_CRM_AccountsAdditionalField__c cust :  [SELECT Id, Name, ASI_CRM_Account__c, ASI_CRM_Channel__c, ASI_CRM_CN_Sub_Channel__c, ASI_TH_CRM_OutletType__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_Achievement_for_Conditional__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_Achievement_for_Variable__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_Incentives_for_Conditional__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_Incentives_for_Variable__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_T1_Contract_Rebate__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_T2_Contract_Rebate__c,
                                                        ASI_CRM_Channel__r.ASI_CRM_TW_Outlet_Contract_Rebate__c
                                                        FROM ASI_CRM_AccountsAdditionalField__c 
                                                        WHERE ASI_CRM_Account__c IN: setAccountId]){
            custMapbyAccId.put(cust.ASI_CRM_Account__c, cust);
            system.debug('Customer Channel: '+cust.ASI_CRM_Channel__c);
        }
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            ASI_CRM_AccountsAdditionalField__c cust = custMapbyAccId.get(paf.ASI_HK_CRM_PAF_Customer__c);
            
            if(custMapbyAccId != null && cust != null) {
                paf.ASI_CRM_Customer__c = cust.id;
                paf.ASI_CRM_Channel__c = cust.ASI_CRM_Channel__c;
                paf.ASI_CRM_Sub_Channel__c = cust.ASI_CRM_CN_Sub_Channel__c;
                
                if (paf.ASI_CRM_Achievement_for_Conditional__c == null)
                    paf.ASI_CRM_Achievement_for_Conditional__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_Achievement_for_Conditional__c;
                if (paf.ASI_CRM_Achievement_for_Variable__c == null)
                    paf.ASI_CRM_Achievement_for_Variable__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_Achievement_for_Variable__c;
                if (paf.ASI_CRM_Incentives_for_Conditional__c == null)
                    paf.ASI_CRM_Incentives_for_Conditional__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_Incentives_for_Conditional__c;
                if (paf.ASI_CRM_Incentives_for_Variable__c == null)
                    paf.ASI_CRM_Incentives_for_Variable__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_Incentives_for_Variable__c ;
                if (paf.ASI_CRM_TW_T1_Contract_Rebate__c == null)
                    paf.ASI_CRM_TW_T1_Contract_Rebate__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_T1_Contract_Rebate__c;
                if (paf.ASI_CRM_TW_T2_Contract_Rebate__c == null)
                    paf.ASI_CRM_TW_T2_Contract_Rebate__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_T2_Contract_Rebate__c;
                if (paf.ASI_CRM_TW_Outlet_Contract_Rebate__c == null)
                    paf.ASI_CRM_TW_Outlet_Contract_Rebate__c = cust.ASI_CRM_Channel__r.ASI_CRM_TW_Outlet_Contract_Rebate__c;
                //paf.ASI_CRM_Outlet_Type__c = custMapbyAccId.get(paf.ASI_HK_CRM_PAF_Customer__c).ASI_TH_CRM_OutletType__c;
            }
            
            //paf.ASI_CRM_Sales_Representative__c = mapAccOwnerInfo.get(accMapbyAccId.get(paf.ASI_HK_CRM_PAF_Customer__c).OwnerId).id;
            //paf.ASI_CRM_Region__c = mapAccOwnerInfo.get(accMapbyAccId.get(paf.ASI_HK_CRM_PAF_Customer__c).OwnerId).ASI_KOR_User_Region_Code__c;
            system.debug('Customer: '+custMapbyAccId.get(paf.ASI_HK_CRM_PAF_Customer__c));
            system.debug('Channel: '+custMapbyAccId.get(paf.ASI_HK_CRM_PAF_Customer__c).ASI_CRM_Channel__c);
        }
    }
    
    private static void generateOutletChild(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new){
        //generate PAF Customer
        Set<Id> setAccountId = new Set<Id>();    
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            setAccountId.add(paf.ASI_HK_CRM_PAF_Customer__c);
        }
        
        List<Account> listChildOutlets = [SELECT Id, Name, ParentId FROM Account WHERE (ParentId IN: setAccountId OR Id IN: setAccountId) AND ASI_HK_CRM_Inactive__c = FALSE];
        
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listPAFCustomer;
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listInsertPAFCustomer = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
        Map<Id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>> mapPAFCustomer = new Map<Id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>>();
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            listPAFCustomer = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
            for(Account acc : listChildOutlets){
                If(acc.ParentId == paf.ASI_HK_CRM_PAF_Customer__c || acc.id == paf.ASI_HK_CRM_PAF_Customer__c){
                    ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCustomer = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
                    pafCustomer.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_HK_Pre_Approval_Form_Customer__cASI_CRM_TW_Pre_Approval_Form_Customer');
                    pafCustomer.ASI_CRM_HK_Customer__c = acc.id;
                    pafCustomer.ASI_CRM_HK_Pre_Approval_Form__c = paf.id;
                    listPAFCustomer.add(pafCustomer);
                    listInsertPAFCustomer.add(pafCustomer);
                }
            } 
            mapPAFCustomer.put(paf.id, listPAFCustomer);
        } 
        insert listInsertPAFCustomer;
    }
    
    private static void generateOutletChild(ASI_HK_CRM_Pre_Approval_Form__c paf){
        //generate PAF Customer
        List<Account> listChildOutlets = [SELECT Id, Name, ParentId FROM Account WHERE (ParentId =: paf.ASI_HK_CRM_PAF_Customer__c OR Id =: paf.ASI_HK_CRM_PAF_Customer__c) AND ASI_HK_CRM_Inactive__c = FALSE];
        
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listPAFCustomer;
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listInsertPAFCustomer = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
        Map<Id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>> mapPAFCustomer = new Map<Id, List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>>();
 
        listPAFCustomer = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
        for(Account acc : listChildOutlets){
            If(acc.ParentId == paf.ASI_HK_CRM_PAF_Customer__c || acc.id == paf.ASI_HK_CRM_PAF_Customer__c){
                ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCustomer = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
                pafCustomer.ASI_CRM_HK_Customer__c = acc.id;
                pafCustomer.ASI_CRM_HK_Pre_Approval_Form__c = paf.id;
                listPAFCustomer.add(pafCustomer);
                listInsertPAFCustomer.add(pafCustomer);
            }
        }
        mapPAFCustomer.put(paf.id, listPAFCustomer);
        
        insert listInsertPAFCustomer;
    }
}