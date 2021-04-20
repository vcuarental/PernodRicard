/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoiceItemTgrHdlr
 * Description: Payment Invoice Line Item Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_PaymentInvoiceItemTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_PaymentInvoiceItemTgrHdlr() {
        super('ASI_CRM_JP_PaymentInvoiceItemTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)sObjList;
        Set<Id> contItemIdSet = new Set<Id>();
        Set<Id> itemGroupIdSet = new Set<Id>();
        Set<Id> headerIdSet = new Set<Id>();
        if (oldMap == null) {
            for (ASI_CRM_Payment_Invoice_Line_Item__c item: itemList) {
                if (Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item') ||
                    Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item')) {
                    item.ASI_CRM_Payment_Invoice_Item_Owner__c = UserInfo.getUserId();
                }
                if (Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('FOC') && !headerIdSet.Contains(item.ASI_CRM_Payment_Invoice__c)) {
                    headerIdSet.add(item.ASI_CRM_Payment_Invoice__c);
                }
                contItemIdSet.add(item.ASI_CRM_Purchase_Contract_Line_Item__c);
            }
        }
        else {
            Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c> oldItemMap = (Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c>) oldMap;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item: itemList) {
                if (item.ASI_CRM_Purchase_Contract_Line_Item__c != oldItemMap.get(item.id).ASI_CRM_Purchase_Contract_Line_Item__c || 
                        item.ASI_CRM_SKU_Selection__c != oldItemMap.get(item.id).ASI_CRM_SKU_Selection__c) {
                    contItemIdSet.add(item.ASI_CRM_Purchase_Contract_Line_Item__c);
                }
                if (item.ASI_CRM_Purchase_Contract_Line_Item__c != oldItemMap.get(item.id).ASI_CRM_Purchase_Contract_Line_Item__c && 
                        Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('FOC') && !headerIdSet.Contains(item.ASI_CRM_Payment_Invoice__c)) {
                    headerIdSet.add(item.ASI_CRM_Payment_Invoice__c);
                }
            }
        }
        Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> contItemMap = new Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c>([Select ASI_CRM_Purchase_Contract__c, 
                                                                                                                                  ASI_CRM_Item_Group__c,
                                                                                                                                  ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c,
                                                                                                                                  ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c,
                                                                                                                                  ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c
                                                                                                                                  From ASI_CRM_Purchase_Contract_Line_Item__c 
                                                                                                                                  Where Id In :contItemIdSet]);
        Map<Id, ASI_CRM_Payment_Invoice__c> paymentMap = new Map<Id, ASI_CRM_Payment_Invoice__c>([Select Id,
                                                                                                         (Select ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c
                                                                                                          From Payment_Invoice_Lines__r)
                                                                                                  From ASI_CRM_Payment_Invoice__c
                                                                                                  Where Id In :headerIdSet]);
        for(ASI_CRM_Purchase_Contract_Line_Item__c item:contItemMap.values()){
            itemGroupIdSet.add(item.ASI_CRM_Item_Group__c);    
        }
        Map<Id, String> skuMap = new Map<Id, String>();
        for(ASI_MFM_Item_Group__c grp:[Select Id, ASI_CRM_Representative_SKU_Code__c From ASI_MFM_Item_Group__c Where Id In :itemGroupIdSet]){
            skuMap.put(grp.Id, grp.ASI_CRM_Representative_SKU_Code__c);    
        }
        if (oldMap == null) {
            Boolean previousAP = null;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item: itemList) {
                item.ASI_CRM_Contract_No__c = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Purchase_Contract__c;
                item.ASI_CRM_Representative_SKU_Code__c = skuMap.get(contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Item_Group__c);
                if(item.ASI_CRM_SKU_Selection__c == 'Representative SKU'){
                    item.ASI_CRM_SKU__c = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c;
                }else if(item.ASI_CRM_SKU_Selection__c == 'Alternative SKU'){
                    item.ASI_CRM_SKU__c = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c;
                }
                if(Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('FOC') && !checkFocAPCode(item.ASI_CRM_Payment_Invoice__c, paymentMap,item,contItemMap)) {
                    item.addError(System.Label.ASI_CRM_JP_APCodeError);
                    break;
                }
                if(previousAP == null){
                    previousAP = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c;
                }else if(previousAP != contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c){
                    item.addError(System.Label.ASI_CRM_JP_APCodeError);
                    break;
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c> oldItemMap = (Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c>) oldMap;
            Boolean previousAP = null;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item: itemList) {
                if (item.ASI_CRM_Purchase_Contract_Line_Item__c != oldItemMap.get(item.id).ASI_CRM_Purchase_Contract_Line_Item__c) {
                    item.ASI_CRM_Contract_No__c = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Purchase_Contract__c;    
                }
                if(item.ASI_CRM_SKU_Selection__c != oldItemMap.get(item.id).ASI_CRM_SKU_Selection__c ||
                        item.ASI_CRM_Purchase_Contract_Line_Item__c != oldItemMap.get(item.id).ASI_CRM_Purchase_Contract_Line_Item__c){
                    if(item.ASI_CRM_SKU_Selection__c == 'Representative SKU'){
                        item.ASI_CRM_SKU__c = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c;
                    }else if(item.ASI_CRM_SKU_Selection__c == 'Alternative SKU'){
                        item.ASI_CRM_SKU__c = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c;
                    }
                }
                if (item.ASI_CRM_Purchase_Contract_Line_Item__c != oldItemMap.get(item.id).ASI_CRM_Purchase_Contract_Line_Item__c && 
                        Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('FOC') && 
                        !checkFocAPCode(item.ASI_CRM_Payment_Invoice__c, paymentMap,item,contItemMap)) {
                    item.addError(System.Label.ASI_CRM_JP_APCodeError);
                    break;
                }
                if (item.ASI_CRM_Purchase_Contract_Line_Item__c != oldItemMap.get(item.id).ASI_CRM_Purchase_Contract_Line_Item__c && 
                        Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('FOC') && !headerIdSet.Contains(item.ASI_CRM_Payment_Invoice__c)) {
                    if(previousAP == null){
                        previousAP = contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c;
                    }else if(previousAP != contItemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c){
                        item.addError(System.Label.ASI_CRM_JP_APCodeError);
                        break;
                    }
                }
            }
        }
    }
    
    Public Boolean checkFocAPCode(Id pmtID, Map<Id, ASI_CRM_Payment_Invoice__c> pmtMap,ASI_CRM_Payment_Invoice_Line_Item__c item,Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> itemMap){
        Boolean previousApCode = null;
        system.debug('Line List: ' + pmtMap.get(pmtId).Payment_Invoice_Lines__r);
        for(ASI_CRM_Payment_Invoice_Line_Item__c pmt:pmtMap.get(pmtId).Payment_Invoice_Lines__r){
            if(previousApCode == null){
                previousApCode = pmt.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c;
            }else if(previousApCode != pmt.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c){
                return false;
            }
        }
        if(previousApCode != null && previousApCode != itemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c){
            system.debug('Previous: ' + previousApCode + ' Current: ' + itemMap.get(item.ASI_CRM_Purchase_Contract_Line_Item__c).ASI_CRM_AP_Code__r.ASI_CRM_Exclusive_Flag__c);
            return false;
        }
        return true;
    }
}