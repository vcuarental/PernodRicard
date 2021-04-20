/*********************************************************************************
 * Name:        ASI_CRM_MY_AccountAdditionalField_TriggerClass --> ASI_CRM_MY_AccountAdditional_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-16       Introv: Daniel WONG     Created
 * 2015-01-01       Introv: Daniel WONG     Add segmentationCriteriaMap Logic 
 * 2015-01-22       Introv: Twinkle LI      Create an Account when after insert, Update related Account name when update Customer
 * 2017-03-01       Introv:                 Add a picklist allowing user to self define the customer visibility
*********************************************************************************/

public with sharing class ASI_CRM_MY_AccountAdditional_TriggerCls{
    public static String className = 'ASI_CRM_MY_AccountAdditional_TriggerCls';
    
    public static void routineAfterInsert(list<ASI_CRM_AccountsAdditionalField__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            List<Account> listAcc = new List<Account>();
            Id recordTypeId = Global_RecordTypeCache.getRTId('AccountASI_CRM_MY_Outlet');
            map<Id, Account> mapAcc = new map<id, Account>();
            Set<Id> setCustomerId = new Set<Id>();
            List<ASI_CRM_AccountsAdditionalField__c> listCust;
            
            Boolean havePending = false;
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                if(cust.ASI_CRM_MY_GeoConverStatus__c == 'Pending'){
                    havePending = true;
                    break;
                }
            }
            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                Account objAcc = new Account();
                objAcc.recordTypeId = recordTypeId;
                objAcc.name = cust.name;
                objAcc.ASI_HK_CRM_Chinese_Name__c = cust.id;
                listAcc.add(objAcc);
                setCustomerId.add(cust.id);
            }
            if(!listAcc.IsEmpty()){
                insert(listAcc);
            }
            
            for(Account acc : listAcc){
                mapAcc.put(acc.ASI_HK_CRM_Chinese_Name__c, acc);
            }
            
            if(!mapAcc.IsEmpty()){
                listCust = [SELECT id FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN:setCustomerId];
                for(ASI_CRM_AccountsAdditionalField__c cust : listCust){
                    if(mapAcc.get(cust.id) != null)
                        cust.ASI_CRM_Account__c = mapAcc.get(cust.id).id;
                }
                if(!listCust.IsEmpty()){
                    update listCust;
                }
            }
            if(havePending){
                ASI_CRM_MY_AccountAddressBatch batch = new ASI_CRM_MY_AccountAddressBatch();
                DataBase.executeBatch(batch, 20);
            }
         }
    }
    
    public static void routineAfterUpdate(list<ASI_CRM_AccountsAdditionalField__c> trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c > trigger_oldMap){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            List<Account> listAcc = new List<Account>();
            Boolean havePending = false;
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                if(cust.ASI_CRM_MY_GeoConverStatus__c == 'Pending'){
                    havePending = true;
                    break;
                }
            }
            
           	set<Id> s_change_owner_customer = new set<Id>();
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
				Id newOwnerId = cust.OwnerId;
                ASI_CRM_AccountsAdditionalField__c oldAccount = trigger_oldMap.get(cust.Id);
                Id oldOwnerId = oldAccount.OwnerId;
                if(oldOwnerId != newOwnerId){
                    s_change_owner_customer.add(cust.Id);
                }
            }
            
            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                Account objAcc = new Account();
                objAcc.id = cust.ASI_CRM_Account__c;
                objAcc.name = cust.name;
                if(cust.ASI_CRM_Account__c != null){
                    listAcc.add(objAcc);
                }
            }
            if(!listAcc.IsEmpty()){
                upsert listAcc;
            }
            if(havePending){
                ASI_CRM_MY_AccountAddressBatch batch = new ASI_CRM_MY_AccountAddressBatch();
                DataBase.executeBatch(batch, 20);
            }
            if(s_change_owner_customer.size() > 0){
                ASI_CRM_MY_Account_ChangeOwner_Batch change_owner_batch = new ASI_CRM_MY_Account_ChangeOwner_Batch(s_change_owner_customer);
                DataBase.executeBatch(change_owner_batch, 200);
            }
        }    
    }
    
    public static void routineBeforeInsert(list<ASI_CRM_AccountsAdditionalField__c> trigger_new){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            ASI_CRM_MY_RunningNumber_TriggerClass autoNumAssign = null;
            map<Id, ASI_CRM_City__c> mapCityId = new map<Id, ASI_CRM_City__c>();
             map<Id, String> mapOwnerBranch = new map<Id, String>();
            List<ASI_CRM_City__c> listCity = new List<ASI_CRM_City__c>();
            Set<Id> setOwnerId = new Set<Id>();
            set<Id> setCityId = new Set<Id>();
            List<ASI_CRM_AccountsAdditionalField__c> lstUpdateBranch = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            id idRT_OutletPotential = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            id idRT_OutletCold = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletColdCall');
            id idRT_OutletDepletion = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletDepletion');
            
            for(ASI_CRM_AccountsAdditionalField__c i : trigger_new){
                // Only to generate customer number for potential outlet
                setCityId.add(i.ASI_CRM_MY_City__c);
                fieldsUpperCase(i); // Make fields uppercase
                if(i.recordTypeId == idRT_OutletPotential || i.recordTypeId == idRT_OutletCold || i.recordTypeId == idRT_OutletDepletion){
                    if(i.recordTypeId == idRT_OutletPotential){                     
                        autoNumAssign = new ASI_CRM_MY_RunningNumber_TriggerClass('Outlet'); // to Match the Module in Running Number
                    }
                    if(i.recordTypeId == idRT_OutletCold){                      
                        autoNumAssign = new ASI_CRM_MY_RunningNumber_TriggerClass('Outlet-ColdCall'); // to Match the Module in Running Number
                    }
                    if(i.recordTypeId == idRT_OutletDepletion){                     
                        autoNumAssign = new ASI_CRM_MY_RunningNumber_TriggerClass('Outlet-Depletion'); // to Match the Module in Running Number
                    }
                    i.ASI_CRM_MY_CustomerCode__c = autoNumAssign.nextAutoNumStr();
                    autoNumAssign.writeToDB();
                }               
            }
            listCity = [SELECT Id, ASI_CRM_MY_Region__c, ASI_CRM_MY_Branch__c, ASI_CRM_Province_Name__c FROM ASI_CRM_City__c WHERE Id IN: setCityId];
            for(ASI_CRM_City__c city : listCity){
                mapCityId.put(city.id, city);
            }
            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                //Comment that not to use Province's branch //cust.ASI_CRM_MY_Branch__c = mapCityId.get(cust.ASI_CRM_MY_City__c) != null ? mapCityId.get(cust.ASI_CRM_MY_City__c).ASI_CRM_MY_Branch__c : '';
                cust.ASI_CRM_MY_Region__c = mapCityId.get(cust.ASI_CRM_MY_City__c) != null ? mapCityId.get(cust.ASI_CRM_MY_City__c).ASI_CRM_MY_Region__c : '';
                cust.ASI_CRM_PROVINCE__c= mapCityId.get(cust.ASI_CRM_MY_City__c) != null ? mapCityId.get(cust.ASI_CRM_MY_City__c).ASI_CRM_Province_Name__c : '';
                
                setOwnerId.add(cust.OwnerId);
                lstUpdateBranch.add(cust);
            }
            
            if(setOwnerId != NULL && setOwnerId.size() > 0){
                for(User i : [SELECT Id, Name, ASI_KOR_User_Branch_Name__c FROM User WHERE id = :setOwnerId]
                ){
                    mapOwnerBranch.put(i.id, i.ASI_KOR_User_Branch_Name__c);
                }
            }
            
            for(ASI_CRM_AccountsAdditionalField__c i : lstUpdateBranch){
                // PRMY - 2017-03-01 New logic to allow user to set the branch visibility
                if (i.ASI_CRM_MY_BranchOpt__c == null || i.ASI_CRM_MY_BranchOpt__c == 'None') {
                    i.ASI_CRM_MY_Branch__c = mapOwnerBranch.get(i.ownerId);
                    i.ASI_CRM_MY_BranchOpt__c = i.ASI_CRM_MY_Branch__c;
                } else {
                    i.ASI_CRM_MY_Branch__c = String.valueOf(i.ASI_CRM_MY_BranchOpt__c);
                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_AccountsAdditionalField__c> trigger_new, map<id, ASI_CRM_AccountsAdditionalField__c> trigger_oldMap){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            map<Id, ASI_CRM_City__c> mapCityId = new map<Id, ASI_CRM_City__c>();
            map<Id, String> mapOwnerBranch = new map<Id, String>();
            List<ASI_CRM_City__c> listCity = new List<ASI_CRM_City__c>();
            Set<Id> setCityId = new Set<Id>();
            Set<Id> setOwnerId = new Set<Id>();
            List<ASI_CRM_AccountsAdditionalField__c> lstUpdateBranch = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            
            for(ASI_CRM_AccountsAdditionalField__c i : trigger_new){
                setCityId.add(i.ASI_CRM_MY_City__c);
            }
            
            listCity = [SELECT Id, ASI_CRM_MY_Region__c, ASI_CRM_MY_Branch__c, ASI_CRM_Province_Name__c FROM ASI_CRM_City__c WHERE Id IN: setCityId];
            
            for(ASI_CRM_City__c city : listCity){
                mapCityId.put(city.id, city);
            }            
            for(ASI_CRM_AccountsAdditionalField__c cust : trigger_new){
                Id recordId = cust.Id;
                if(cust.ASI_CRM_CN_Address__c != trigger_oldMap.get(recordId).ASI_CRM_CN_Address__c && !String.isBlank(cust.ASI_CRM_CN_Address__c) ){
                    cust.ASI_CRM_MY_GeoConverStatus__c = 'Pending';
                }
                
                fieldsUpperCase(cust); // Make fields uppercase
                if (cust.ASI_CRM_MY_City__c != trigger_oldMap.get(cust.id).ASI_CRM_MY_City__c) {
                    //cust.ASI_CRM_MY_Branch__c = '';
                    cust.ASI_CRM_MY_Region__c = '';
                    cust.ASI_CRM_PROVINCE__c = '';
                    if(mapCityId.get(cust.ASI_CRM_MY_City__c) != null){
                        //cust.ASI_CRM_MY_Branch__c = mapCityId.get(cust.ASI_CRM_MY_City__c) != null ? mapCityId.get(cust.ASI_CRM_MY_City__c).ASI_CRM_MY_Branch__c : '';
                        cust.ASI_CRM_MY_Region__c = mapCityId.get(cust.ASI_CRM_MY_City__c) != null ? mapCityId.get(cust.ASI_CRM_MY_City__c).ASI_CRM_MY_Region__c : '';
                        cust.ASI_CRM_PROVINCE__c = mapCityId.get(cust.ASI_CRM_MY_City__c).ASI_CRM_Province_Name__c;
                    }
                }
                
                if(cust.OwnerId != trigger_oldMap.get(cust.id).OwnerId || cust.ASI_CRM_MY_BranchOpt__c != trigger_oldMap.get(cust.id).ASI_CRM_MY_BranchOpt__c){
                    setOwnerId.add(cust.OwnerId);
                    lstUpdateBranch.add(cust);
                }
            }
            
            if(setOwnerId != NULL && setOwnerId.size() > 0){
                for(User i : [SELECT Id, Name, ASI_KOR_User_Branch_Name__c FROM User WHERE id = :setOwnerId]
                ){
                    mapOwnerBranch.put(i.id, i.ASI_KOR_User_Branch_Name__c);
                }
            }
            
            for(ASI_CRM_AccountsAdditionalField__c i : lstUpdateBranch){
                // PRMY - 2017-03-01 New logic to allow user to set the branch visibility
                if (i.ASI_CRM_MY_BranchOpt__c == null || i.ASI_CRM_MY_BranchOpt__c == 'None') {
                    i.ASI_CRM_MY_Branch__c = mapOwnerBranch.get(i.ownerId);
                } else {
                    i.ASI_CRM_MY_Branch__c = String.valueOf(i.ASI_CRM_MY_BranchOpt__c);
                }
            }
        }
    }

    public static void routineBeforeUpsert(list<ASI_CRM_AccountsAdditionalField__c> trigger_new){
        Map<String, Id> segmentationCriteriaMap = new Map<String, Id>();
        Map<Id, Id> mapOutletsubChannel = new Map<Id, Id>();
        Map<id, id> mapSubChannel_Channel = new Map<id, id>();
        Map<String, String> mapChannel = new Map<String, String>();
        
        Set<Id> setSubChannel = new Set<Id>();
        
        for(ASI_CRM_SegmentationCriteria__c SC : [
            SELECT id, ASI_CRM_Channel__c, ASI_CRM_Outlet_Image__c, ASI_CRM_Outlet_Strategy__c 
            FROM ASI_CRM_SegmentationCriteria__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_SegmentationCriteria__cASI_CRM_MY_Segmentation_Criteria')
        ]){
            String tempKey = String.valueOf(SC.ASI_CRM_Channel__c) + String.valueOf(SC.ASI_CRM_Outlet_Image__c) + String.valueOf(SC.ASI_CRM_Outlet_Strategy__c);
            segmentationCriteriaMap.put(tempKey, SC.id);
        }
        
        for(ASI_TH_CRM_OutletType__c OT : [
            SELECT id, ASI_CRM_Sub_Channel__c
            FROM ASI_TH_CRM_OutletType__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_MY_Outlet_Type')
        ]){
            mapOutletsubChannel.put(OT.id, OT.ASI_CRM_Sub_Channel__c);
            setSubChannel.add(OT.ASI_CRM_Sub_Channel__c);
        }
        
        for(ASI_MFM_Sub_Channel__c SubC : [
            SELECT id, ASI_CRM_CN_Channel__r.id, ASI_CRM_CN_Channel__r.ASI_CRM_Group_Customers__c, ASI_CRM_CN_Channel__r.ASI_CRM_Market_Responsibility__c
            FROM ASI_MFM_Sub_Channel__c
            WHERE id IN :setSubChannel
        ]){
            String strChannelId = string.valueOf(SubC.ASI_CRM_CN_Channel__r.id);
            String strTemp;
            
            mapSubChannel_Channel.put(SubC.id, SubC.ASI_CRM_CN_Channel__r.id);
            strTemp = strChannelId + '_GC';
            mapChannel.put(strTemp, SubC.ASI_CRM_CN_Channel__r.ASI_CRM_Group_Customers__c);
            
            strTemp = strChannelId + '_MR';
            mapChannel.put(strTemp, SubC.ASI_CRM_CN_Channel__r.ASI_CRM_Market_Responsibility__c);
        }
    
        for(ASI_CRM_AccountsAdditionalField__c i : trigger_new){
            if(Global_RecordTypeCache.getRt(i.recordTypeid).developerName.contains('ASI_CRM_MY_')){
                if(i.ASI_CRM_CN_Legal_Name__c == NULL || i.ASI_CRM_CN_Legal_Name__c == '' || i.ASI_CRM_CN_Legal_Name__c == ' '){
                    i.ASI_CRM_CN_Legal_Name__c.addError('You must enter a value');
                }
                
                if(i.ASI_CRM_CN_Eng_Name__c == NULL || i.ASI_CRM_CN_Eng_Name__c == '' || i.ASI_CRM_CN_Eng_Name__c == ' '){
                    i.ASI_CRM_CN_Eng_Name__c.addError('You must enter a value');
                }

                if(i.ASI_CRM_Segmentation_Channel__c != NULL && i.ASI_TH_CRM_OutletImage__c != NULL && i.ASI_CRM_OutletStrategy__c !=NULL) {
                    String tempKey = String.valueOf(i.ASI_CRM_Segmentation_Channel__c) + String.valueOf(i.ASI_TH_CRM_OutletImage__c ) + String.valueOf(i.ASI_CRM_OutletStrategy__c);
                    Id SCID = segmentationCriteriaMap.get(tempKey);
                    i.ASI_CRM_Segmentation_Criteria__c = (SCID != NULL) ? SCID : NULL;
                }
                
                //by ASI_TH_CRM_OutletType__c get the sub-Channel --> Channel --> Group Customers --> Market Resp.
                if(i.ASI_TH_CRM_OutletType__c != NULL){
                    if(mapOutletSubChannel.get(i.ASI_TH_CRM_OutletType__c) != NULL){
                        Id idTemp = mapOutletSubChannel.get(i.ASI_TH_CRM_OutletType__c);
                        if(mapSubChannel_Channel.get(idTemp) != NULL){
                            i.ASI_CRM_Channel__c = mapSubChannel_Channel.get(idTemp);
                        }
                    }
                }
                
                if(i.ASI_CRM_Channel__c != NULL){
                    String strId = string.valueOf(i.ASI_CRM_Channel__c);
                    String strTemp = strId + '_MR';
                    
                    if(mapChannel.get(strTemp) != NULL)
                        i.ASI_CRM_Market_Responsibility__c = mapChannel.get(strTemp);
                }
                
                //if(!String.isBlank(i.ASI_CRM_CN_Address__c)){
                //    i.ASI_CRM_MY_GeoConverStatus__c = 'Pending';                
                //}
                
            }
        }
    }
    
    public static ASI_CRM_AccountsAdditionalField__c fieldsUpperCase(ASI_CRM_AccountsAdditionalField__c obj) {
        if (obj.Name != null) obj.Name = obj.Name.toUpperCase();
        if (obj.ASI_CRM_CN_Legal_Name__c != null) obj.ASI_CRM_CN_Legal_Name__c = obj.ASI_CRM_CN_Legal_Name__c.toUpperCase();
        if (obj.ASI_CRM_CN_Eng_Name__c != null) obj.ASI_CRM_CN_Eng_Name__c = obj.ASI_CRM_CN_Eng_Name__c.toUpperCase();
        if (obj.ASI_CRM_CN_Address__c != null) obj.ASI_CRM_CN_Address__c = obj.ASI_CRM_CN_Address__c.toUpperCase();
        if (obj.ASI_CRM_WHAddress__c != null) obj.ASI_CRM_WHAddress__c = obj.ASI_CRM_WHAddress__c.toUpperCase();
        return obj;
    } 
    
    /****************************************************************************************************************
    public ASI_CRM_JP_AssignAutoNumber_Contract () {
        super('ASI_CRM_JP_AssignAutoNumber_Contract ');
    }
   
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_CRM_Purchase_Contract__c> validContractList = (List<ASI_CRM_Purchase_Contract__c>)sObjList;
        
        ASI_CRM_JP_AutoNumberAssignment autoNumAssign = null;
        for (ASI_CRM_Purchase_Contract__c validContract : validContractList )
        {
           
            if (autoNumAssign == null) 
            {
                autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Contract_No');
                validContract.name = autoNumAssign.nextAutoNumStr();
            }
        }
        
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
    }*****************************************************************************************************************/
}