/*********************************************************************************
 * Name:ASI_CRM_JP_ContractClone
 * Description: Purchase Contract Custom Clone for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 8/12/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ContractClone extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_ContractClone() {
        super('ASI_CRM_JP_ContractClone');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Purchase_Contract__c> conList = (List<ASI_CRM_Purchase_Contract__c>)sObjList;
        Set<Id> conCloneIdSet = new Set<Id>();
        Set<Id> conUpdateIdSet = new Set<Id>();
        //Set<Id> conIdForUpdateSet = new Set<Id>();
        Map<Id, Id> conCloneIdMap = new Map<Id, Id>();
        List<ASI_CRM_Purchase_Contract_Line_Item__c> lineItemCloneList = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        String theQuery = 'Select ';
        Id shipToId;
        Boolean isSPTD = false;
        if (oldMap == null) {
            for (ASI_CRM_Purchase_Contract__c con : conList) {
                if (con.ASI_CRM_Clone_Id__c != null && ((con.ASI_CRM_Clone_Id__c).length() == 15 || (con.ASI_CRM_Clone_Id__c).length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', con.ASI_CRM_Clone_Id__c)) {
                    conCloneIdSet.add(con.ASI_CRM_Clone_Id__c);
                    conCloneIdMap.put(con.ASI_CRM_Clone_Id__c, con.Id);
                    shipToId = con.ASI_CRM_BS_Retailer_Ship_To__c;
                    if(Global_RecordTypeCache.getRt(con.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Contract')){
                        isSPTD = true;
                    }
                    //conIdForUpdateSet.add(con.Id);
                } else {
                    //For clone all line items
                    //conIdForUpdateSet.add(con.Id);
                }
            }
            
            //Set clone Id = Contract Id for new inserted records
            //if (conIdForUpdateSet.size() > 0) {
            //    List<ASI_CRM_Purchase_Contract__c> conListForUpdate = [Select Id, ASI_CRM_Clone_Id__c From ASI_CRM_Purchase_Contract__c Where Id In :conIdForUpdateSet];
            //    for (ASI_CRM_Purchase_Contract__c c:conListForUpdate) {
            //        c.ASI_CRM_Clone_Id__c = c.Id;
            //    }
            //    update conListForUpdate;
            //}
            
            //Clone line items for Contract
            if (conCloneIdSet.size() > 0) {
                Map<String, Schema.SObjectField> contractLineItemFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract_Line_Item__c.fields.getMap();
                for(String fields  : contractLineItemFieldMap.keySet()){
                    theQuery += fields + ' ,';
                }
                thequery = theQuery.subString(0,theQuery.length()-1);
                thequery += ', ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__c, ASI_CRM_Item_Group__r.Name, ASI_CRM_Pay_To__r.Name From ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c In :conCloneIdSet order by ASI_CRM_Purchase_Contract__c';
                List<ASI_CRM_Purchase_Contract_Line_Item__c> lineItemList = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)Database.query(theQuery);
                Map<Id, ASI_CRM_Purchase_Contract__c> conOldMap = new Map<Id, ASI_CRM_Purchase_Contract__c>([Select Id, ASI_CRM_Start_Date__c, ASI_CRM_End_Date__c From ASI_CRM_Purchase_Contract__c Where Id In :conCloneIdSet]);
                List<ASI_CRM_Direct_Rebate_Data__c> directRebateList = [SELECT Name, ASI_CRM_Item_Group__c, ASI_CRM_Unit_Price__c, ASI_CRM_Item_Group__r.name, 
                                                               ASI_CRM_End_Date__c, ASI_CRM_Pay_To__c, ASI_CRM_Pay_To__r.name,
                                                               ASI_CRM_Ship_To__c, ASI_CRM_Start_Date__c, ASI_CRM_Ship_To__r.ASI_CRM_Customer_Headquarter__c
                                                               FROM ASI_CRM_Direct_Rebate_Data__c
                                                               WHERE ASI_CRM_Ship_To__c = :shipToId
                                                               AND recordtype.developername = 'ASI_CRM_JP_Direct_Rebate_Data'];
                Map<String, List<ASI_CRM_Direct_Rebate_Data__c>> directRebateDataMap = new Map<String, List<ASI_CRM_Direct_Rebate_Data__c>>();
                for(ASI_CRM_Direct_Rebate_Data__c data:directRebateList){
                    if(shipToId != null){
                        if(System.today() < data.ASI_CRM_End_Date__c){
                            if(isSPTD){
                                if(directRebateDataMap.get(data.ASI_CRM_Item_Group__r.name) != null){
                                    directRebateDataMap.get(data.ASI_CRM_Item_Group__r.name).add(data);
                                }else{
                                    List<ASI_CRM_Direct_Rebate_Data__c> tempList = new List<ASI_CRM_Direct_Rebate_Data__c>();
                                    tempList.add(data);
                                    directRebateDataMap.put(data.ASI_CRM_Item_Group__r.name, tempList);
                                }
                            }else{
                                String itemName = data.ASI_CRM_Item_Group__r.name == null?'':data.ASI_CRM_Item_Group__r.name;
                                String payToName = data.ASI_CRM_Pay_To__r.name == null?'':data.ASI_CRM_Pay_To__r.name;
                                String itemPayToName = itemName+payToName;
                                if(directRebateDataMap.get(itemPayToName) != null){
                                    directRebateDataMap.get(itemPayToName).add(data);
                                }else{
                                    List<ASI_CRM_Direct_Rebate_Data__c> tempList = new List<ASI_CRM_Direct_Rebate_Data__c>();
                                    tempList.add(data);
                                    directRebateDataMap.put(itemPayToName, tempList);
                                }
                            }
                        }
                    }
                }         
                
                for (ASI_CRM_Purchase_Contract_Line_Item__c item:lineItemList) {
                    //system.debug('Check 1');
                    for (ASI_CRM_Purchase_Contract__c con : conList) {
                        //system.debug('Check 2');
                        if (con.ASI_CRM_Clone_Id__c == item.ASI_CRM_Purchase_Contract__c) {
                            //system.debug('Check 3: ' + item.ASI_CRM_Target_Volume__c + con.ASI_CRM_Start_Date__c.month() + conOldMap.get(con.ASI_CRM_Clone_Id__c).ASI_CRM_Start_Date__c.month() + con.ASI_CRM_End_Date__c.month() + conOldMap.get(con.ASI_CRM_Clone_Id__c).ASI_CRM_End_Date__c.month());
                            ASI_CRM_Purchase_Contract_Line_Item__c itemClone = new ASI_CRM_Purchase_Contract_Line_Item__c();
                            itemClone = item.clone(true,true);
                            itemClone.Id = null;
                            itemClone.ASI_CRM_Current_Indirect_Rebate__c = 0;
                            String itemName = item.ASI_CRM_Item_Group__r.Name == null?'':item.ASI_CRM_Item_Group__r.Name;
                            itemClone.ASI_CRM_Current_Direct_Rebate__c = 0;
                            if(!isSPTD){
                                itemName += (item.ASI_CRM_Pay_To__r.Name == null?'':item.ASI_CRM_Pay_To__r.Name);
                            }
                            if(directRebateDataMap.get(itemName) != null){
                                for(ASI_CRM_Direct_Rebate_Data__c data:directRebateDataMap.get(itemName)){
                                    itemClone.ASI_CRM_Current_Direct_Rebate__c += data.ASI_CRM_Unit_Price__c;
                                }
                            }
                            
                            itemClone.ASI_CRM_Purchase_Contract__c = conCloneIdMap.get(item.ASI_CRM_Purchase_Contract__c);
                            if (itemClone.ASI_CRM_Target_Volume__c != null && (con.ASI_CRM_Start_Date__c.month() != conOldMap.get(con.ASI_CRM_Clone_Id__c).ASI_CRM_Start_Date__c.month() || con.ASI_CRM_End_Date__c.month() != conOldMap.get(con.ASI_CRM_Clone_Id__c).ASI_CRM_End_Date__c.month() ||
                                    con.ASI_CRM_Start_Date__c.year() != conOldMap.get(con.ASI_CRM_Clone_Id__c).ASI_CRM_Start_Date__c.year() || con.ASI_CRM_End_Date__c.year() != conOldMap.get(con.ASI_CRM_Clone_Id__c).ASI_CRM_End_Date__c.year() )) {
                                system.debug('Check 4');
                                Integer numOfMonths = con.ASI_CRM_Start_Date__c.monthsBetween(con.ASI_CRM_End_Date__c) + 1;
                                Integer monthlyCost = Integer.valueOf(itemClone.ASI_CRM_Target_Volume__c) / numOfMonths;
                                Integer roundingErr = monthlyCost * numOfMonths - Integer.valueOf(itemClone.ASI_CRM_Target_Volume__c);
                                map<Integer, Integer> mcMap = new map<Integer, Integer>();
                                for (integer i = 1; i < 13; i++) {
                                   mcMap.put(i, null);
                                }
                                Integer startMonth = con.ASI_CRM_Start_Date__c.month();
                                Integer endMonth = startMonth + numOfMonths - 1;
                                if (startMonth < 7) {
                                   startMonth += 12;
                                   endMonth += 12;
                                }
                                Integer monthlyCostX, cumCost;
                                Integer idx;
                                for (Integer i = startMonth; i<=endMonth; i++){
                                   monthlyCostX = monthlyCost;
                                   if (i == endMonth) {
                                       monthlyCostX -= roundingErr;
                                   }
                                   idx = i - 6;
                                   if (idx < 13) {
                                       mcMap.put(idx, monthlyCostX);
                                   }else{
                                       cumCost = mcMap.get(12) + monthlyCostX;
                                       mcMap.put(12, cumCost);
                                   }
                               }
                               itemClone.ASI_CRM_Month_1_Cost__c = mcMap.get(1); 
                               itemClone.ASI_CRM_Month_2_Cost__c = mcMap.get(2); 
                               itemClone.ASI_CRM_Month_3_Cost__c = mcMap.get(3); 
                               itemClone.ASI_CRM_Month_4_Cost__c = mcMap.get(4); 
                               itemClone.ASI_CRM_Month_5_Cost__c = mcMap.get(5); 
                               itemClone.ASI_CRM_Month_6_Cost__c = mcMap.get(6);                 
                               itemClone.ASI_CRM_Month_7_Cost__c = mcMap.get(7); 
                               itemClone.ASI_CRM_Month_8_Cost__c = mcMap.get(8); 
                               itemClone.ASI_CRM_Month_9_Cost__c = mcMap.get(9); 
                               itemClone.ASI_CRM_Month_10_Cost__c = mcMap.get(10);   
                               itemClone.ASI_CRM_Month_11_Cost__c = mcMap.get(11);   
                               itemClone.ASI_CRM_Month_12_Cost__c = mcMap.get(12);    
                            }
                            lineItemCloneList.add(itemClone);
                        }
                    }
                }
                insert lineItemCloneList;
            }
        } else {
            Map<Id, ASI_CRM_Purchase_Contract__c> oldConMap = (Map<Id, ASI_CRM_Purchase_Contract__c>) oldMap;
            for (ASI_CRM_Purchase_Contract__c con : conList) {
                if (con.ASI_CRM_Start_Date__c != null && oldConMap.get(con.Id).ASI_CRM_Start_Date__c != null && con.ASI_CRM_End_Date__c != null && oldConMap.get(con.Id).ASI_CRM_End_Date__c != null && 
                        (con.ASI_CRM_Start_Date__c.month() != oldConMap.get(con.Id).ASI_CRM_Start_Date__c.month() || con.ASI_CRM_End_Date__c.month() != oldConMap.get(con.Id).ASI_CRM_End_Date__c.month() ||
                        con.ASI_CRM_Start_Date__c.year() != oldConMap.get(con.Id).ASI_CRM_Start_Date__c.year() || con.ASI_CRM_End_Date__c.year() != oldConMap.get(con.Id).ASI_CRM_End_Date__c.year())) {
                    conUpdateIdSet.add(con.Id);                    
                }
            }
            
            if (conUpdateIdSet.size() > 0) {
                system.debug('Check 1');
                Map<String, Schema.SObjectField> contractLineItemFieldMap = Schema.SObjectType.ASI_CRM_Purchase_Contract_Line_Item__c.fields.getMap();
                for(String fields  : contractLineItemFieldMap.keySet()){
                    theQuery += fields + ' ,';
                }
                thequery = theQuery.subString(0,theQuery.length()-1);
                thequery += 'From ASI_CRM_Purchase_Contract_Line_Item__c where ASI_CRM_Purchase_Contract__c In :conUpdateIdSet order by ASI_CRM_Purchase_Contract__c';
                List<ASI_CRM_Purchase_Contract_Line_Item__c> lineItemList = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)Database.query(theQuery);
                for (ASI_CRM_Purchase_Contract_Line_Item__c item:lineItemList) {
                    system.debug('Check 2');
                    for (ASI_CRM_Purchase_Contract__c con : conList) {
                        system.debug('Check 3');
                        if (con.Id == item.ASI_CRM_Purchase_Contract__c && item.ASI_CRM_Target_Volume__c != null) {
                             system.debug('Check 4');
                             Integer numOfMonths = con.ASI_CRM_Start_Date__c.monthsBetween(con.ASI_CRM_End_Date__c) + 1;
                             Integer monthlyCost = Integer.valueOf(item.ASI_CRM_Target_Volume__c) / numOfMonths;
                             Integer roundingErr = monthlyCost * numOfMonths - Integer.valueOf(item.ASI_CRM_Target_Volume__c);
                             map<Integer, Integer> mcMap = new map<Integer, Integer>();
                             for (integer i = 1; i < 13; i++) {
                                mcMap.put(i, null);
                             }
                             Integer startMonth = con.ASI_CRM_Start_Date__c.month();
                             Integer endMonth = startMonth + numOfMonths - 1;
                             if (startMonth < 7) {
                                startMonth += 12;
                                endMonth += 12;
                             }
                             Integer monthlyCostX, cumCost;
                             Integer idx;
                             for (Integer i = startMonth; i<=endMonth; i++){
                                monthlyCostX = monthlyCost;
                                if (i == endMonth) {
                                   monthlyCostX -= roundingErr;
                                }
                                idx = i - 6;
                                if (idx < 13) {
                                    mcMap.put(idx, monthlyCostX);
                                }else{
                                    cumCost = mcMap.get(12) + monthlyCostX;
                                    mcMap.put(12, cumCost);
                                }
                             }
                             item.ASI_CRM_Month_1_Cost__c = mcMap.get(1); 
                             item.ASI_CRM_Month_2_Cost__c = mcMap.get(2); 
                             item.ASI_CRM_Month_3_Cost__c = mcMap.get(3); 
                             item.ASI_CRM_Month_4_Cost__c = mcMap.get(4); 
                             item.ASI_CRM_Month_5_Cost__c = mcMap.get(5); 
                             item.ASI_CRM_Month_6_Cost__c = mcMap.get(6);                 
                             item.ASI_CRM_Month_7_Cost__c = mcMap.get(7); 
                             item.ASI_CRM_Month_8_Cost__c = mcMap.get(8); 
                             item.ASI_CRM_Month_9_Cost__c = mcMap.get(9); 
                             item.ASI_CRM_Month_10_Cost__c = mcMap.get(10);   
                             item.ASI_CRM_Month_11_Cost__c = mcMap.get(11);   
                             item.ASI_CRM_Month_12_Cost__c = mcMap.get(12);      
                        }
                    }
                }
                update lineItemList;        
            }
        }
    }
}