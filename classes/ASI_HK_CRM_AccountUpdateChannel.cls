public without sharing class ASI_HK_CRM_AccountUpdateChannel extends ASI_HK_CRM_TriggerAbstract {

    private static Boolean recordInsertedFlag = false;
    
    public ASI_HK_CRM_AccountUpdateChannel() {
        super('ASI_HK_CRM_AccountUpdateChannel');
    }
    public static map<string, id> rt_map = new Map<String, id>();  // Added By Alan Wong 20151016
    public static Map<String,String> channelMap = new Map<String,String>();
    //public static Map<String,String> PricingChannelMap = new Map<String,String>(); // Added By Alan Wong 20151016
    //public static Map<id,ASI_CRM_AccountsAdditionalField__c> AdditionalFieldMap = new Map<id, ASI_CRM_AccountsAdditionalField__c>(); // Added By Alan Wong 20151016
    public static Id RT_JDE_ID; 
    public static Id RT_OUT_ID;
    static {
        for(ASI_HK_CRM_Channel_Local_Channel_Map__c channel: [select id, ASI_HK_CRM_Channel__c
        ,ASI_HK_CRM_Local_Channel__c from ASI_HK_CRM_Channel_Local_Channel_Map__c]) {
            channelMap.put(channel.ASI_HK_CRM_Channel__c,channel.ASI_HK_CRM_Local_Channel__c);
        }
        // Added by Alan Wong 20151016 get Pricing Channel Map from Customer Setting
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        //for (ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannel: [SELECT ASI_HK_CRM_Channel__c, ASI_HK_CRM_Pricing_Channel__c From ASI_HK_CRM_Channel_Local_Channel_Map__c]) {
        //    PricingChannelMap.put(PricingChannel.ASI_HK_CRM_Channel__c, PricingChannel.ASI_HK_CRM_Pricing_Channel__c);
        //}
        //
        // Added by Alan Wong 20150610, get AdditionalFields Map
        //for (ASI_CRM_AccountsAdditionalField__c AdditionFields: [SELECT id, ASI_CRM_Account__c, ASI_CRM_Pricing_Channel__c From ASI_CRM_AccountsAdditionalField__c]) {
        //    AdditionalFieldMap.put(AdditionFields.ASI_CRM_Account__c, AdditionFields);
        //}        
        //   
        // Added by Steve 19March2014 modify on Global_RecordTypeCache
        /* RecordType rt = [select id,developerName from recordType where sobjectType = 'Account'
        and developerName = 'ASI_HK_CRM_JDE_Salesman_Cash_Account' ];
        
        RecordType rt2 = [select id,developerName from recordType where sobjectType = 'Account'
        and developerName = 'ASI_HK_CRM_Outlet' ];
        */
        

        RT_JDE_ID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_JDE_Salesman_Cash_Account'); //rt.Id;
        RT_OUT_ID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Outlet'); //rt2.Id;
        System.debug('abc5'+RT_OUT_ID);
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
            && !isBypassByCurrentUser()) {
                
            List<Account> accList = (List<Account>)sObjList; 
            Map<ID, Account> oldMapAccount = (Map<ID, Account>)oldMap;
            //List<ASI_CRM_AccountsAdditionalField__c> AdditionList = new List<ASI_CRM_AccountsAdditionalField__c>();
            /*// Added by Michael 17March2014 to test on Global_RecordTypeCache
            ASI_HK_CRM_AccountUpdateChannel.TestingGenRecType();
            ASI_HK_CRM_AccountUpdateChannel.TestingGenRecType();
            System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
            System.debug('Total Number of records that can be queried  in this apex code context: ' +  Limits.getLimitDmlRows());
            System.debug('Total Number of DML statements allowed in this apex code context: ' +  Limits.getLimitDmlStatements() );
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());*/
            
            
            
            /*
            Set<id> AccountIdSet = new Set<id>(); // Added by Alan Wong (Elufa) Apex share record if owner changed.
            Map<id,id> SharingMap = new Map<id,id>(); // Added by Alan Wong (Elufa) Apex share record if owner changed.
            Map<id,id> OldSharingMap = new Map<id,id>(); // Added by Alan Wong (Elufa) Apex share record if owner changed.
            */
             List<ASI_CRM_Record_Transfer__c> recTransferList = new List<ASI_CRM_Record_Transfer__c>();

            for (Account acc: accList){
                // Auto update the local_channel and channel fields
                System.debug('----------------Trigger: '+acc.Name);
                if ((acc.recordTypeId == RT_JDE_ID || acc.recordTypeId == RT_OUT_ID) && acc.ASI_HK_CRM_Customer_Type__c != null){
                    acc.ASI_HK_CRM_Channel__c = acc.ASI_HK_CRM_Customer_Type__c;
                    acc.ASI_HK_CRM_Local_Channel__c = channelMap.get(acc.ASI_HK_CRM_Customer_Type__c);
                    System.debug('abc');
                }
                // Added by Alan Elufa 20151016 Map Pricing Channel
                if (acc.recordTypeId == rt_map.get('ASI_HK_CRM_Outlet')){
                    /*if (PricingChannelMap.containsKey(acc.ASI_HK_CRM_Channel__c)) { 
                        if (AdditionalFieldMap.containsKey(acc.id)) {
                            //System.debug('----------------Trigger: Pricing Channel Mapped');
                            AdditionalFieldMap.get(acc.id).ASI_CRM_Pricing_Channel__c = PricingChannelMap.get(acc.ASI_HK_CRM_Channel__c);
                            AdditionList.add(AdditionalFieldMap.get(acc.id));
                        } else {
                            //System.debug('----------------Trigger: Pricing Channel X Mapped');
                            ASI_CRM_AccountsAdditionalField__c tmpAF = new ASI_CRM_AccountsAdditionalField__c();
                            tmpAF.ASI_CRM_Account__c = acc.id;
                            tmpAF.ASI_CRM_Pricing_Channel__c = PricingChannelMap.get(acc.ASI_HK_CRM_Channel__c);
                            AdditionList.add(tmpAF);
                        }
                    }*/

                    //Added by Wilken 20160127 Auto create Record Transfer when owner changed, for ETL to update related transactions
                    //Added trigger action = before update checking on 20160129
                    if (tAction == TriggerAction.BEFORE_UPDATE && oldMapAccount.get(acc.id) != null && acc.OwnerID != oldMapAccount.get(acc.id).OwnerID){
                        system.debug('Adding new Record Transfer, Outlet Name = ' + acc.Name);
                        
                        ASI_CRM_Record_Transfer__c recTransfer = new ASI_CRM_Record_Transfer__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_Record_Transfer__cASI_CRM_HK_RT'), ASI_CRM_Outlet__c = acc.id, ASI_CRM_Transfer_To__c = acc.OwnerID,
                            ASI_CRM_Effective_Date__c = System.Today());
                        
                        recTransferList.add(recTransfer);
                    }
                }
                // End //
                // Added by Alan Wong (Elufa) Apex share record if owner changed.
                //System.debug('SharingDebug:: start');
                //System.debug('SharingDebug:: acrt: ' + acc.recordTypeId);
                //System.debug('SharingDebug:: RT_JDE_ID: ' + rt_map.get('ASI_HK_CRM_Outlet'));
                //System.debug('SharingDebug:: RT_OUT_ID: ' + rt_map.get('ASI_HK_CRM_JDE_Salesman_Cash_Account'));
                /*
                if ((acc.recordTypeId == rt_map.get('ASI_HK_CRM_Outlet') || acc.recordTypeId == rt_map.get('ASI_HK_CRM_JDE_Salesman_Cash_Account')) && oldMap != null && oldMap.get(acc.id) != null){
                    //System.debug('SharingDebug:: enter');
                    Account oldAccount = (Account)oldMap.get(acc.id);
                    if(acc.OwnerId != oldAccount.OwnerId)
                    {
                        if (!SharingMap.containsKey(acc.OwnerId)){
                            AccountIdSet.add(acc.id);
                            SharingMap.put(acc.id, acc.OwnerId); // Share from old Owner to new Owner
                            OldSharingMap.put(acc.id, oldAccount.OwnerId);
                        }
                    }
                }
                */
                // End 
                System.debug('abc2'+acc.Name);
            }

                if (recTransferList.size() > 0) {
                    try{ 
                        system.debug('Start evaluate recordInsertedFlag ' + recordInsertedFlag);
                        if (recordInsertedFlag == false){
                            insert recTransferList;
                            recordInsertedFlag = true;
                            system.debug('Insert Record Transfer List to DB, size = ' + recTransferList.size() + 'recordInsertedFlag = ' + recordInsertedFlag);
                        }
                    }
                    catch(Exception e){
                        system.debug('-----------------Insert Error: ----'+e);
                    }
                }   
            // Added by Alan Wong (Elufa) Apex share record if owner changed.
            /*
                System.debug('SharingDebug:: ACIdSet' + AccountIdSet.size());
                System.debug('SharingDebug:: SharingIdSet' + SharingMap.size());
                if (AccountIdSet.size() > 0 && SharingMap.size()>0){
                    
                    // Sharing SO
                    List<ASI_HK_CRM_Sales_Order__c> SOList = [SELECT id, ASI_HK_CRM_Account_PA__c, OwnerId FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_Account_PA__c IN: AccountIdSet];
                    if (SOList.size()>0){
                        List<ASI_HK_CRM_Sales_Order__Share> SOShares = new List<ASI_HK_CRM_Sales_Order__Share>();
                        List<ASI_HK_CRM_Sales_Order__Share> DelSOShares = new List<ASI_HK_CRM_Sales_Order__Share>();
                        Map<id,id> sharingMap0 = new Map<id,id>();
                        List<ASI_HK_CRM_Sales_Order__Share> tmpShareSOList = [SELECT id, ParentId FROM ASI_HK_CRM_Sales_Order__Share WHERE RowCause = :Schema.ASI_HK_CRM_Sales_Order__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c];    
                        for (ASI_HK_CRM_Sales_Order__Share tmp: tmpShareSOList){
                            sharingMap0.put(tmp.parentID,tmp.id);
                        }
                        for (ASI_HK_CRM_Sales_Order__c SO : SOList) {   
                            ASI_HK_CRM_Sales_Order__Share shareSO = new ASI_HK_CRM_Sales_Order__Share();
                            ASI_HK_CRM_Sales_Order__Share DelSO = new ASI_HK_CRM_Sales_Order__Share();
                            if (sharingMap0.containsKey(SO.id)){
                                DelSO.Id = sharingMap0.get(SO.id);
                                DelSOShares.add(DelSO);
                            }
                            if(SO.OwnerId == OldSharingMap.get(SO.ASI_HK_CRM_Account_PA__c)){
                                shareSO.ParentId = SO.id;
                                shareSO.UserOrGroupId = SharingMap.get(SO.ASI_HK_CRM_Account_PA__c);
                                shareSO.AccessLevel = 'edit';
                                shareSO.RowCause = Schema.ASI_HK_CRM_Sales_Order__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c;
                                SOShares.add(shareSO);
                            }
                        }
                        if(DelSOShares.size()>0) {
                            Database.DeleteResult[] SODeleteResult = Database.delete(DelSOShares,false); // delete old sharing rule if present
                        }
                        if(SOShares.size()>0) {
                            Database.SaveResult[] SOInsertResult = Database.insert(SOShares,false);
                        }
                    }
                    // Sharing PAF
                    List<ASI_HK_CRM_Pre_Approval_Form__c> PAFList = [SELECT id, ASI_HK_CRM_PAF_Customer__c, OwnerId  FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_HK_CRM_PAF_Customer__c IN: AccountIdSet];
                    if (PAFList.size() > 0){
                        List<ASI_HK_CRM_Pre_Approval_Form__Share> PAFShares = new List<ASI_HK_CRM_Pre_Approval_Form__Share>();
                        List<ASI_HK_CRM_Pre_Approval_Form__Share> DelPAFShares = new List<ASI_HK_CRM_Pre_Approval_Form__Share>();
                        Map<id,id> sharingMap1 = new Map<id,id>();
                        List<ASI_HK_CRM_Pre_Approval_Form__Share> tmpShareList = [SELECT id, ParentId FROM ASI_HK_CRM_Pre_Approval_Form__Share WHERE RowCause = :Schema.ASI_HK_CRM_Pre_Approval_Form__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c];    
                        for (ASI_HK_CRM_Pre_Approval_Form__Share tmp: tmpShareList){
                            sharingMap1.put(tmp.parentID,tmp.id);
                        }
                        for (ASI_HK_CRM_Pre_Approval_Form__c PAF : PAFList) {
                            ASI_HK_CRM_Pre_Approval_Form__Share sharePAF = new ASI_HK_CRM_Pre_Approval_Form__Share();
                            ASI_HK_CRM_Pre_Approval_Form__Share DelPAF = new ASI_HK_CRM_Pre_Approval_Form__Share();
                            if (sharingMap1.containsKey(PAF.id)){
                                DelPAF.Id = sharingMap1.get(PAF.id);
                                DelPAFShares.add(DelPAF);
                            }
                            if(PAF.OwnerId == OldSharingMap.get(PAF.ASI_HK_CRM_PAF_Customer__c)){
                                sharePAF.ParentId = PAF.id;
                                sharePAF.UserOrGroupId = SharingMap.get(PAF.ASI_HK_CRM_PAF_Customer__c);
                                sharePAF.AccessLevel = 'edit';
                                sharePAF.RowCause = Schema.ASI_HK_CRM_Pre_Approval_Form__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c;
                                PAFShares.add(sharePAF);
                            }   
                        }
                        if(DelPAFShares.size()>0) {
                            Database.DeleteResult[] PAFDeleteResult = Database.delete(DelPAFShares,false); // delete old sharing rule if present
                        }
                        if(PAFShares.size()>0) {
                            Database.SaveResult[] PAFInsertResult = Database.insert(PAFShares,false);
                        }
                    }
                    // Sharing FOC
                    List<ASI_FOC_Free_Goods_Request__c> FOCList = [SELECT id, ASI_FOC_Account_DA__c, OwnerId  FROM ASI_FOC_Free_Goods_Request__c WHERE ASI_FOC_Account_DA__c IN: AccountIdSet];
                    if (FOCList.size() > 0) {
                        List<ASI_FOC_Free_Goods_Request__Share> FOCShares = new List<ASI_FOC_Free_Goods_Request__Share>();
                        List<ASI_FOC_Free_Goods_Request__Share> DelFOCShares = new List<ASI_FOC_Free_Goods_Request__Share>();
                        Map<id,id> sharingMap2 = new Map<id,id>();
                        List<ASI_FOC_Free_Goods_Request__Share> tmpShareList2 = [SELECT id, ParentId FROM ASI_FOC_Free_Goods_Request__Share WHERE RowCause = :Schema.ASI_FOC_Free_Goods_Request__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c];    
                        for (ASI_FOC_Free_Goods_Request__Share tmp: tmpShareList2){
                            sharingMap2.put(tmp.parentID,tmp.id);
                        }
                        for (ASI_FOC_Free_Goods_Request__c FOC : FOCList) {
                            ASI_FOC_Free_Goods_Request__Share shareFOC = new ASI_FOC_Free_Goods_Request__Share();
                            ASI_FOC_Free_Goods_Request__Share DelFOC = new ASI_FOC_Free_Goods_Request__Share();
                            if (sharingMap2.containsKey(FOC.id)){
                                DelFOC.Id = sharingMap2.get(FOC.id);
                                DelFOCShares.add(DelFOC);
                            }
                            if(FOC.OwnerId == OldSharingMap.get(FOC.ASI_FOC_Account_DA__c)){
                                shareFOC.ParentId = FOC.id;
                                shareFOC.UserOrGroupId = SharingMap.get(FOC.ASI_FOC_Account_DA__c);
                                shareFOC.AccessLevel = 'edit';
                                shareFOC.RowCause = Schema.ASI_FOC_Free_Goods_Request__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c;
                                FOCShares.add(shareFOC);
                            }
                        }
                        if(DelFOCShares.size()>0) {
                            Database.DeleteResult[] FOCDeleteResult = Database.delete(DelFOCShares,false); // delete old sharing rule if present
                        }
                        if(FOCShares.size()>0) {
                            Database.SaveResult[] FOCInsertResult = Database.insert(FOCShares,false);
                        }
                    }
                    // Sharing PO  
                    List<ASI_MFM_PO_Line_Item__c> POList = [SELECT id, ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_PO__r.OwnerId FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_Customer_Name__c IN: AccountIdSet];
                    if (POList.size() > 0) {
                        Set<id> POSet = new Set<id>();
                        Set<id> DeletePOSet = new Set<id>();
                        List<ASI_MFM_PO__Share> POShares = new List<ASI_MFM_PO__Share>();
                        List<ASI_MFM_PO__Share> DelPOShares = new List<ASI_MFM_PO__Share>();
                        Map<id,id> sharingMap3 = new Map<id,id>();
                        List<ASI_MFM_PO__Share> tmpShareList3 = [SELECT id, ParentId FROM ASI_MFM_PO__Share WHERE RowCause = :Schema.ASI_MFM_PO__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c];    
                        for (ASI_MFM_PO__Share tmp: tmpShareList3){
                            sharingMap3.put(tmp.parentID,tmp.id);
                        }
                        for (ASI_MFM_PO_Line_Item__c POL : POList) {
                            ASI_MFM_PO__Share sharePO = new ASI_MFM_PO__Share();
                            ASI_MFM_PO__Share DelPO = new ASI_MFM_PO__Share();
                            if (sharingMap3.containsKey(POL.ASI_MFM_PO__c)){
                                if(!DeletePOSet.contains(sharingMap3.get(POL.ASI_MFM_PO__c))){
                                    DelPO.Id = sharingMap3.get(POL.ASI_MFM_PO__c);
                                    DelPOShares.add(DelPO);
                                    DeletePOSet.add(DelPO.Id);
                                }
                            }
                            if(!POSet.contains(POL.ASI_MFM_PO__c)){
                                if(POL.ASI_MFM_PO__r.OwnerId == OldSharingMap.get(POL.ASI_MFM_Customer_Name__c)){
                                    sharePO.ParentId = POL.ASI_MFM_PO__c;
                                    sharePO.UserOrGroupId = SharingMap.get(POL.ASI_MFM_Customer_Name__c);
                                    sharePO.AccessLevel = 'edit';
                                    sharePO.RowCause = Schema.ASI_MFM_PO__Share.RowCause.ASI_CRM_HK_Change_Owner_Sharing__c;
                                    POShares.add(sharePO);
                                    POSet.add(POL.ASI_MFM_PO__c);
                                }
                            }  
                        }
                        if(DelPOShares.size()>0) {
                            Database.DeleteResult[] POLDeleteResult = Database.delete(DelPOShares,false); // delete old sharing rule if present
                        }
                        if(POShares.size()>0) {
                            Database.SaveResult[] POLInsertResult = Database.insert(POShares,false);
                        }
                    }
                }
            // End //
            */
        }
    }
    /*// Added by Michael 17March2014 to test on Global_RecordTypeCache
    public static void TestingGenRecType(){
        ASI_HK_CRM_Util.getRecordTypeId('Account');//Global_RecordTypeCache.getRtList('Account');//
    }*/
}