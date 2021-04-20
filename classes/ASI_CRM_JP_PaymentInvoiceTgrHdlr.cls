/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoiceTgrHdlr
 * Description: Payment Invoice Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Hank          Created
 * 26/09/2019       Wilken Lee            [WL 1.0] Only use Tax Date Mapping that is marked as Default Tax Rate
 * 30/09/2019       Wilken Lee            [WL 2.0] VAT Changes for Tax Rate and BC Code
 * 01/10/2019       Wilken Lee            [WL 3.0] Change security to without sharing to cater approver need to edit line item
*********************************************************************************/

public without sharing class ASI_CRM_JP_PaymentInvoiceTgrHdlr extends ASI_CRM_JP_TriggerAbstract {//WL 3.0

    public ASI_CRM_JP_PaymentInvoiceTgrHdlr() {
        super('ASI_CRM_JP_PaymentInvoiceTgrHdlr');
    }
    /*[WL 2.0] BEGIN*/
    public static void updatePaymentLineBCCode(List<ASI_CRM_Payment_Invoice__c> trigger_new, Map<Id, ASI_CRM_Payment_Invoice__c> oldMap){
        List<Id> invToUpdate = new List<Id>();
        
        for (ASI_CRM_Payment_Invoice__c inv:trigger_new){
            if (inv.ASI_CRM_Tax_Rate_Area__c != oldMap.get(inv.Id).ASI_CRM_Tax_Rate_Area__c)
                invToUpdate.add(inv.Id);
        }
        
        Map<String,String> pmtTaxRateMap = new Map<String,String>();
        pmtTaxRateMap.put('CP0',null);
        pmtTaxRateMap.put('CP8','B');
        pmtTaxRateMap.put('CP8R','C');
        pmtTaxRateMap.put('CP10','D');
        
        if (invToUpdate.size() > 0){
            List<ASI_CRM_Payment_Invoice_Line_Item__c> payLineList = [SELECT ID, ASI_CRM_Payment_Invoice__c, ASI_CRM_Payment_Invoice__r.ASI_CRM_Tax_Rate_Area__c,
                ASI_CRM_BC_Code__c FROM ASI_CRM_Payment_Invoice_Line_Item__c WHERE ASI_CRM_Payment_Invoice__c IN :invToUpdate];
            
            for (ASI_CRM_Payment_Invoice_Line_Item__c line:payLineList){
                line.ASI_CRM_BC_Code__c = pmtTaxRateMap.get(line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Tax_Rate_Area__c);
            }
            
            update payLineList;
        }
    }
    /*[WL 2.0] END*/
        
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Payment_Invoice__c> pmtList = (List<ASI_CRM_Payment_Invoice__c>)sObjList;
        Set<Id> ownerIdSet = new Set<Id>();
        
        //Insert case
        if (oldMap == null) {
            for (ASI_CRM_Payment_Invoice__c pmt:pmtList) {
                if(Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice') || 
                        Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_Cash_Invoice')){
                    ownerIdSet.add(pmt.ownerId);
                }                
                
                if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice') || 
                        pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only')){
                    pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice');
                }
                else if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice') || 
                        pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice_Read_Only')){
                    pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice');
                }
                else if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice') || 
                        pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice_Read_Only')){
                    pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice');
                }
                else if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice') || 
                        pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice_Read_Only')){
                    pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice');
                }
            }
        }
        else{
            Map<ID, ASI_CRM_Payment_Invoice__c> oldPmtMap = (Map<ID, ASI_CRM_Payment_Invoice__c>) oldMap;
            for (ASI_CRM_Payment_Invoice__c pmt:pmtList) {                
                if ((pmt.ownerId != null && (pmt.ownerId != oldPmtMap.get(pmt.Id).ownerId)) && 
                    (Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice') || 
                        Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_Cash_Invoice'))) {
                    ownerIdSet.add(pmt.ownerId);
                }
                                
                if(pmt.RecordTypeId != oldPmtMap.get(pmt.Id).RecordTypeId){
                    if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice') || 
                            pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only')){
                        pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice');
                    }
                    else if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice') || 
                            pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice_Read_Only')){
                        pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_Cash_Invoice');
                    }
                    else if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice') || 
                            pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice_Read_Only')){
                        pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice');
                    }
                    else if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice') || 
                        pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice_Read_Only')){
                    pmt.ASI_CRM_Clone_Record_Type_Id__c = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice');
                    }
                }
            }
        }
        
        /*[WL 2.0] BEGIN*/
        for (ASI_CRM_Payment_Invoice__c pmt:pmtList) {
            //Indirect Rebate Invoice uses Invoice Period From to get Tax Rate
            //SPTD FOC Invoice uses Payment Date to get Tax Rate
            //Cash Invoice uses Invoice Period From to get Tax Rate
            //SPTD Cash Invoice uses Invoice Date to get Tax Rate
            Date invoiceDate = pmt.ASI_CRM_Invoice_Date__c;
            
            if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice') || 
                pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only') ||
                pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice') || //WL 2.0
                pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice_Read_Only') //WL 2.0
            ){
                
                invoiceDate = pmt.ASI_CRM_From_Month__c; //WL 2.0
            }   
            
            if(pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice') || 
                pmt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice_Read_Only')){
                
                invoiceDate = pmt.ASI_CRM_Payment_Date__c;            
            }  
                    
            if (invoiceDate == null && (oldMap == null || pmt.ASI_CRM_Tax_Rate_Area__c == null)){    //Invoice Date is empty, auto default CP10 and 10% 
                                                                                                    //for insert or if user clear Tax Rate/Area
                pmt.ASI_CRM_Tax_Rate__c = 10;
                pmt.ASI_CRM_Tax_Rate_Area__c  = 'CP10';
            }
            else {  //Invoice Date is not empty
                if (pmt.ASI_CRM_Tax_Rate_Area__c == null){   //Tax Rate/Area is empty, let system default based on setting
                    for (ASI_JP_TnE_Tax_Date_Mapping__c taxmap:ASI_JP_TnE_Tax_Date_Mapping__c.getAll().values()){
                        if (taxmap.ASI_JP_TnE_Start_Date__c <= invoiceDate && invoiceDate <= taxmap.ASI_JP_TnE_End_Date__c
                            && taxmap.ASI_JP_TnE_IsDefault_Tax_Rate__c//WL 1.0
                        ){
                            pmt.ASI_CRM_Tax_Rate__c = 100 * taxmap.ASI_JP_TnE_Tax_Rate__c;
                            pmt.ASI_CRM_Tax_Rate_Area__c = taxmap.ASI_TnE_Tax_Area__c; //WL 2.0
                        }
                    }
                }
                else { //User filled in Tax Rate/Area, sysem default Tax Rate % accordingly
                    if (pmt.ASI_CRM_Tax_Rate_Area__c == 'CP0')
                        pmt.ASI_CRM_Tax_Rate__c = 0;
                    else if (pmt.ASI_CRM_Tax_Rate_Area__c == 'CP8' || pmt.ASI_CRM_Tax_Rate_Area__c == 'CP8R')
                        pmt.ASI_CRM_Tax_Rate__c = 8;
                    else
                        pmt.ASI_CRM_Tax_Rate__c = 10;                       
                }
            }
            system.debug('Tax Rate/Area: ' + pmt.ASI_CRM_Tax_Rate_Area__c + ' Tax Rate: ' + pmt.ASI_CRM_Tax_Rate__c);
        }       
        /*[WL 2.0] END*/
        
                
        Map<Id, User> ownerMap = new Map<Id, User>([Select Id, ASI_KOR_User_Branch_Code__c From User Where Id In :ownerIdSet]);
        if (oldMap == null) {
            for (ASI_CRM_Payment_Invoice__c pmt : pmtList) {
                if(Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice') || 
                        Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_Cash_Invoice')){
                    pmt.ASI_CRM_Sales_Group__c = ownerMap.get(pmt.ownerId).ASI_KOR_User_Branch_Code__c;
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Payment_Invoice__c> oldPmtMap = (Map<ID, ASI_CRM_Payment_Invoice__c>) oldMap;
            for (ASI_CRM_Payment_Invoice__c pmt: pmtList) {
                if ((pmt.ownerId != null && (pmt.ownerId != oldPmtMap.get(pmt.Id).ownerId)) && 
                    (Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice') || 
                        Global_RecordTypeCache.getRt(pmt.recordTypeid).developerName.contains('ASI_CRM_JP_Cash_Invoice'))) {
                    pmt.ASI_CRM_Sales_Group__c = ownerMap.get(pmt.ownerId).ASI_KOR_User_Branch_Code__c;
                }
            }
        }       
    }    
}