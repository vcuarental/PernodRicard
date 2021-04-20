/*********************************************************************************
 * Name:ASI_CRM_JP_CustomerTgrHdlr
 * Description: Customer Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_CustomerTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_CustomerTgrHdlr() {
        super('ASI_CRM_JP_CustomerTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
        Set<Id> outletTypeIdSet = new Set<Id>();
        Set<String> postalCodeIdSet = new Set<String>();
        Map<id, Account> MapAccountChild = new Map<id, Account>();
        List<ASI_CRM_AccountsAdditionalField__c> jdeCus = [Select Id From ASI_CRM_AccountsAdditionalField__c Where ASI_CRM_CN_JDE_Code__c = '50000994' And Recordtype.DeveloperName like '%ASI_CRM_JP%' Limit 1];
        if (oldMap == null) {
            for (ASI_CRM_AccountsAdditionalField__c customer : customerList) {
                if (Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet')) {
                    outletTypeIdSet.add(customer.ASI_TH_CRM_OutletType__c);
                    if(customer.ASI_CRM_Customer_Headquarter_2__c == null && jdeCus.size() > 0){
                        customer.ASI_CRM_Customer_Headquarter_2__c = jdeCus[0].Id;
                    }
                }
                if (customer.ASI_CRM_PostalCode__c != null ) {
                    postalCodeIdSet.add(customer.ASI_CRM_PostalCode__c);
                }
                //Create Account
                Account linkedAcct = new Account();
                if(customer.OwnerId != null){
                    linkedAcct.OwnerId = customer.OwnerId;
                }
                linkedAcct.Name = customer.Name;
                //linkedAcct.ASI_KOR_Customer_Code__c = customer.ASI_CRM_CN_CRM_Code__c;
                for (RecordType rc : Global_RecordTypeCache.getRtList('Account')){
                    if (rc.developerName.contains('ASI_CRM_JP_Customer')){
                        linkedAcct.recordTypeid = rc.id;
                    }
                }
                MapAccountChild.put(customer.id, linkedAcct);
            }
            insert MapAccountChild.values();
        }
        else {
            Map<ID, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap = (Map<ID, ASI_CRM_AccountsAdditionalField__c>) oldMap;
            for (ASI_CRM_AccountsAdditionalField__c customer: customerList) {
                if (customer.ASI_TH_CRM_OutletType__c != oldCustomerMap.get(customer.id).ASI_TH_CRM_OutletType__c && Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet')){
                    outletTypeIdSet.add(customer.ASI_TH_CRM_OutletType__c);
                }
                if (customer.ASI_CRM_PostalCode__c != null && (customer.ASI_CRM_PostalCode__c != oldCustomerMap.get(customer.id).ASI_CRM_PostalCode__c)) {
                    postalCodeIdSet.add(customer.ASI_CRM_PostalCode__c);
                }
            }
        }
        
        Map<Id, ASI_TH_CRM_OutletType__c> outletTypeMap = new Map<Id, ASI_TH_CRM_OutletType__c>([Select Id, ASI_CRM_Channel_Group__c, ASI_CRM_PROS_Type__c From ASI_TH_CRM_OutletType__c Where Id In :outletTypeIdSet]);
        Map<String, ASI_CRM_Postal_Code__c> postalCodeMap = new Map<String, ASI_CRM_Postal_Code__c>();
        for(ASI_CRM_Postal_Code__c postal: [Select Id, Name, ASI_CRM_JP_Metropolitan__c, ASI_CRM_Large_Geographical_Area__c, ASI_CRM_JP_Prefecture__c, ASI_CRM_JP_Prefecture_EN__c, ASI_CRM_JP_City__c, ASI_CRM_JP_Town__c From ASI_CRM_Postal_Code__c Where Name In: postalCodeIdSet]){
            postalCodeMap.put(postal.Name, postal);
        }
        if (oldMap == null) {
            for (ASI_CRM_AccountsAdditionalField__c customer : customerList) {
                if (Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet')) {
                    customer.ASI_CRM_VN_Channel__c = outletTypeMap.get(customer.ASI_TH_CRM_OutletType__c).ASI_CRM_Channel_Group__c;
                    //customer.ASI_CRM_SG_Local_Channel__c = outletTypeMap.get(customer.ASI_TH_CRM_OutletType__c).ASI_CRM_Channel_Group__c;
                    customer.ASI_CRM_PROS_Type__c = outletTypeMap.get(customer.ASI_TH_CRM_OutletType__c).ASI_CRM_PROS_Type__c;
                }
                if (customer.ASI_CRM_PostalCode__c != null && postalCodeMap.get(customer.ASI_CRM_PostalCode__c) != null 
                        && (Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') )) {
                    customer.ASI_CRM_Large_Geographical_Area__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_Large_Geographical_Area__c;
                    customer.ASI_CRM_JP_Prefecture__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Prefecture_EN__c;
                    customer.ASI_CRM_JP_City_Ward__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_City__c;
                    customer.ASI_CRM_JP_Town__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Town__c;
                    customer.ASI_CRM_JP_Prefecture_Japanese__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Prefecture__c;
                }
                if(customer.ASI_CRM_PostalCode__c != null && postalCodeMap.get(customer.ASI_CRM_PostalCode__c) != null){
                    customer.ASI_CRM_Metropolitan__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Metropolitan__c;
                }
                customer.ASI_CRM_Account__c = MapAccountChild.get(customer.Id).Id;
                
                ////// 
                if(String.isNotBlank(customer.ASI_CRM_JP_CONCAT_ADDRESS__c) ){
                   customer.ASI_CRM_MY_GeoConverStatus__c = 'Pending'; 
                }
            }
        }
        else {
            Map<ID, ASI_CRM_AccountsAdditionalField__c> oldCustomerMap = (Map<ID, ASI_CRM_AccountsAdditionalField__c>) oldMap;
            for (ASI_CRM_AccountsAdditionalField__c customer: customerList) {
                if (customer.ASI_TH_CRM_OutletType__c != oldCustomerMap.get(customer.id).ASI_TH_CRM_OutletType__c && Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet')){
                    customer.ASI_CRM_VN_Channel__c = outletTypeMap.get(customer.ASI_TH_CRM_OutletType__c).ASI_CRM_Channel_Group__c;
                    //customer.ASI_CRM_SG_Local_Channel__c = outletTypeMap.get(customer.ASI_TH_CRM_OutletType__c).ASI_CRM_Channel_Group__c;
                    customer.ASI_CRM_PROS_Type__c = outletTypeMap.get(customer.ASI_TH_CRM_OutletType__c).ASI_CRM_PROS_Type__c;
                }
                if (customer.ASI_CRM_PostalCode__c != null && (customer.ASI_CRM_PostalCode__c != oldCustomerMap.get(customer.id).ASI_CRM_PostalCode__c) && postalCodeMap.get(customer.ASI_CRM_PostalCode__c) != null 
                        && (Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') )) {
                    customer.ASI_CRM_Large_Geographical_Area__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_Large_Geographical_Area__c;
                    customer.ASI_CRM_JP_Prefecture__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Prefecture_EN__c;
                    customer.ASI_CRM_JP_City_Ward__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_City__c;
                    customer.ASI_CRM_JP_Town__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Town__c;
                    customer.ASI_CRM_JP_Prefecture_Japanese__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Prefecture__c;
                }
                if(customer.ASI_CRM_PostalCode__c != null && (customer.ASI_CRM_PostalCode__c != oldCustomerMap.get(customer.id).ASI_CRM_PostalCode__c) && postalCodeMap.get(customer.ASI_CRM_PostalCode__c) != null){
                    customer.ASI_CRM_Metropolitan__c = postalCodeMap.get(customer.ASI_CRM_PostalCode__c).ASI_CRM_JP_Metropolitan__c;
                }
                if(oldCustomerMap.get(customer.Id).ASI_CRM_JP_CONCAT_ADDRESS__c != customer.ASI_CRM_JP_CONCAT_ADDRESS__c 
                   && String.isNotBlank(customer.ASI_CRM_JP_CONCAT_ADDRESS__c) ){
                   customer.ASI_CRM_MY_GeoConverStatus__c = 'Pending'; 
                } 
                
            }
        }
        
    
    }
    
}