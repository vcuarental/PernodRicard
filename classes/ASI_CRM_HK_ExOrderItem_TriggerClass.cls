public with sharing class ASI_CRM_HK_ExOrderItem_TriggerClass {
    public static void routineAfterInsert(list<ASI_CRM_Exchange_Order_Item__c> trigger_new) {
        Set<id> HKEOISet = new Set<id>();
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_CRM_Exchange_Order_Item__c');   
        for(ASI_CRM_Exchange_Order_Item__c EOI: trigger_new)
        {
            if(EOI.RecordTypeId == rt_map.get('ASI_CRM_HK_Exchange_Order_Item')) {
                HKEOISet.add(EOI.ASI_CRM_Exchange_Order__c);
            }
        }
        system.debug(HKEOISet);
        if(HKEOISet.size() > 0) {
            Map<id, string> EO_JDE_Map = new Map<id, string>();
            Map<string, ASI_HK_CRM_Sales_Order__c> JDE_SO_Map = new Map<string, ASI_HK_CRM_Sales_Order__c>();
            Set<string> JDENo = new Set<string>();
            Set<id> NoSoFound = new Set<id>();
            List<ASI_HK_CRM_Sales_Order__c> SOList = new List<ASI_HK_CRM_Sales_Order__c>();
            List<ASI_CRM_Exchange_Order_Item__c> EOIs = [SELECT id, ASI_CRM_Sales_Order_History_Detail__c, ASI_CRM_Exchange_Order__c,
                                                         ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c, 
                                                         ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c
                                                         From 
                                                         ASI_CRM_Exchange_Order_Item__c
                                                         Where
                                                         ASI_CRM_Exchange_Order__c IN: HKEOISet
                                                         Order by id ASC];
            for (ASI_CRM_Exchange_Order_Item__c EOI: EOIs) {
                if (!JDENo.contains(EOI.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c))
                    JDENo.add(EOI.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c);
                if(!EO_JDE_Map.containsKey(EOI.ASI_CRM_Exchange_Order__c)){
                    EO_JDE_Map.put(EOI.ASI_CRM_Exchange_Order__c, EOI.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c);
                }
            }
            if (JDENo.size() > 0) {
                SOList = [SELECT ASI_HK_CRM_Delivery_Address__c,ASI_HK_CRM_Attention__c, ASI_HK_CRM_Phone_Number__c, ASI_HK_CRM_JDE_Order_No__c FROM ASI_HK_CRM_Sales_Order__c WHERE ASI_HK_CRM_JDE_Order_No__c IN:JDENo];
                for (ASI_HK_CRM_Sales_Order__c SO : SOList) {
                    if(!JDE_SO_Map.containsKey(SO.ASI_HK_CRM_JDE_Order_No__c)) {
                        JDE_SO_Map.put(SO.ASI_HK_CRM_JDE_Order_No__c, SO);
                    } 
                }
            }
            Set<id> keyset = EO_JDE_Map.keySet();
            List<ASI_CRM_Exchange_Order__c> updateList = new List<ASI_CRM_Exchange_Order__c>();
            for(id key: keyset) {
                if(JDE_SO_Map.containsKey(EO_JDE_Map.get(key))) {
                    updateList.add(new ASI_CRM_Exchange_Order__c(id=key, ASI_CRM_Address__c = JDE_SO_Map.get(EO_JDE_Map.get(key)).ASI_HK_CRM_Delivery_Address__c, ASI_CRM_Attention__c= JDE_SO_Map.get(EO_JDE_Map.get(key)).ASI_HK_CRM_Attention__c, ASI_CRM_Phone__c = JDE_SO_Map.get(EO_JDE_Map.get(key)).ASI_HK_CRM_Phone_Number__c));
                } else {
                    NoSOFound.add(key);
                }   
            }
            if(NoSoFound.size() > 0) {
                List<ASI_CRM_Exchange_Order__c> EO_NoJDE = [SELECT id, ASI_CRM_Customer__c FROM ASI_CRM_Exchange_Order__c WHERE id IN: NoSOFound];
                Set<id> AccSet = new Set<id>();
                for (ASI_CRM_Exchange_Order__c EO:EO_NoJDE) {
                    AccSet.add(EO.ASI_CRM_Customer__c);
                }
                List<ASI_CRM_AccountsAdditionalField__c> AccInfo = [SELECT id, ASI_CRM_Account__c, ASI_CRM_HK_Address__c, ASI_CRM_CN_Phone_Number__c, ASI_HK_CRM_Attention__c
                                                          From 
                                                          ASI_CRM_AccountsAdditionalField__c
                                                          Where
                                                          ASI_CRM_Account__c IN: AccSet];
                Map<id, ASI_CRM_AccountsAdditionalField__c> AddtionalFieldMap = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
                for (ASI_CRM_AccountsAdditionalField__c accs: AccInfo) {
                    AddtionalFieldMap.put(accs.ASI_CRM_Account__c, accs);
                }
                for (ASI_CRM_Exchange_Order__c EO: EO_NoJDE) {
                    if(AddtionalFieldMap.containsKey(EO.ASI_CRM_Customer__c)) {
                        EO.ASI_CRM_Address__c = AddtionalFieldMap.get(EO.ASI_CRM_Customer__c).ASI_CRM_HK_Address__c;
                        EO.ASI_CRM_Attention__c = AddtionalFieldMap.get(EO.ASI_CRM_Customer__c).ASI_HK_CRM_Attention__c;
                        EO.ASI_CRM_Phone__c = AddtionalFieldMap.get(EO.ASI_CRM_Customer__c).ASI_CRM_CN_Phone_Number__c;
                        updateList.add(EO);
                    }
                }
            }
            system.debug('EO_JDE_Map::: ' + EO_JDE_Map);
            system.debug('JDE_SO_Map:: ' + JDE_SO_Map);
            system.debug('JDENo:: ' + JDENo);  
            if(updateList.size()>0) {
                update updateList;
            }    
        }
    }
    
    public static void routineAfterAll (list<ASI_CRM_Exchange_Order_Item__c> trigger_new, map<id, ASI_CRM_Exchange_Order_Item__c> trigger_oldMap) {
// Update Total PO Amount in Plan object        
        set<id> pid_set = new set<id>();
        if (trigger_new != null) {
            for (ASI_CRM_Exchange_Order_Item__c item:trigger_new) {
                pid_set.add(item.ASI_CRM_Exchange_Order__c);
            }
        }
        
        System.Debug('pid_set.size =' + pid_set.size());   
        if (pid_set.size() > 0) {
            list<ASI_CRM_Exchange_Order__c> p_list = [select ASI_CRM_Total_Return_Amount__c , (select ASI_CRM_Return_Amount__c from Exchange_Order_Items__r) from ASI_CRM_Exchange_Order__c where id in :pid_set for update];

            // end of Changes
            for (ASI_CRM_Exchange_Order__c p:p_list) {
                p.ASI_CRM_Total_Return_Amount__c = 0;
                for (ASI_CRM_Exchange_Order_Item__c item:p.Exchange_Order_Items__r) {
                    if (item.ASI_CRM_Return_Amount__c > 0) {
                        p.ASI_CRM_Total_Return_Amount__c += item.ASI_CRM_Return_Amount__c; //.setScale(2, roundingmode.half_up);
                    }
                }
            }
            update p_list;
        }
    }

}