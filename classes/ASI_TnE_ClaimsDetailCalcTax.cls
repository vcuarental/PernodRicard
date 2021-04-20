/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailCalcTax
 * Description: Calculate tax for Claims Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 4/8/2015         Laputa: Hank            Created
 * 25/07/2016       Laputa: Hugo Cheung     Updated. Change ASI_TnE_Payment_Amount__c to ASI_TnE_TW_Payment_Amount__c
*********************************************************************************/

public with sharing class ASI_TnE_ClaimsDetailCalcTax extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsDetailCalcTax() {
        super('ASI_TnE_ClaimsDetailCalcTax');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
         system.debug('**DetailCalcTax Limits***' + System.Limits.getQueries());
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        List<ASI_TnE_Tax_Date_Mapping__c> taxMap = ASI_TnE_Tax_Date_Mapping__c.getAll().values();
        Set<Id> categoryIdSet = new Set<Id>();
        Boolean isHk = false;
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                for(ASI_TnE_Tax_Date_Mapping__c tax:taxMap){
                    if(detail.ASI_TnE_Tax_Inclusive__c && tax.ASI_TnE_Record_Type__c == Global_RecordTypeCache.getRt(detail.recordTypeid).developerName &&
                            tax.ASI_TnE_Start_Date__c <= detail.ASI_TnE_Receipt_Date__c &&
                            tax.ASI_TnE_End_Date__c >= detail.ASI_TnE_Receipt_Date__c){
                        detail.ASI_TnE_Tax_Rate__c = tax.ASI_TnE_Tax_Rate__c;
                        if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')){
                            detail.ASI_TnE_Taxable_Amount__c = (detail.ASI_TnE_TW_Payment_Amount__c/(1 + detail.ASI_TnE_Tax_Rate__c/100)).setScale(0, RoundingMode.HALF_UP);
                        }else{
                            detail.ASI_TnE_Taxable_Amount__c = detail.ASI_TnE_HK_Payment_Amount__c/(1 + detail.ASI_TnE_Tax_Rate__c/100);
                        }
                        
                        Decimal paymentAmount = (detail.ASI_TnE_Receipt_Amount__c != null ? detail.ASI_TnE_Receipt_Amount__c : 0) * (detail.ASI_TnE_FX_Rate__c != null ? detail.ASI_TnE_FX_Rate__c : 0);
                        
                        if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')){
                            detail.ASI_TnE_Tax_Amount__c = (paymentAmount - ((paymentAmount/(1+(detail.ASI_TnE_Tax_Rate__c/100))).setScale(0, RoundingMode.HALF_UP))).setScale(0, RoundingMode.HALF_UP);
                        }else{
                            detail.ASI_TnE_Tax_Amount__c = (paymentAmount - ((paymentAmount/(1+(detail.ASI_TnE_Tax_Rate__c/100))).setScale(2, RoundingMode.HALF_UP))).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                    if(!detail.ASI_TnE_Tax_Inclusive__c ){
                        detail.ASI_TnE_Tax_Rate__c = 0;
                        detail.ASI_TnE_Taxable_Amount__c = 0;
                        detail.ASI_TnE_Tax_Amount__c = 0;
                    }
                    //for Greeting Category
                    if(detail.ASI_TnE_Expense_Category__c != null){
                        categoryIdSet.add(detail.ASI_TnE_Expense_Category__c);
                    }
                    if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('HK')){
                        isHk = true;
                    }
                }  
            }
        }else{
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Tax_Inclusive__c && 
                    (detail.ASI_TnE_Receipt_Date__c != detailOldMap.get(detail.Id).ASI_TnE_Receipt_Date__c 
                        || detail.ASI_TnE_Tax_Inclusive__c != detailOldMap.get(detail.Id).ASI_TnE_Tax_Inclusive__c 
                        || detail.ASI_TnE_Receipt_Amount__c != detailOldMap.get(detail.id).ASI_TnE_Receipt_Amount__c 
                        || detail.ASI_TnE_FX_Rate__c != detailOldMap.get(detail.id).ASI_TnE_FX_Rate__c
                        || detail.ASI_TnE_Tax_Rate__c != detailOldMap.get(detail.id).ASI_TnE_Tax_Rate__c)){
                        
                    for(ASI_TnE_Tax_Date_Mapping__c tax:taxMap){
                        if(tax.ASI_TnE_Record_Type__c == Global_RecordTypeCache.getRt(detail.recordTypeid).developerName &&
                                tax.ASI_TnE_Start_Date__c <= detail.ASI_TnE_Receipt_Date__c &&
                                tax.ASI_TnE_End_Date__c >= detail.ASI_TnE_Receipt_Date__c){
                            detail.ASI_TnE_Tax_Rate__c = tax.ASI_TnE_Tax_Rate__c;
                            if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')){
                                detail.ASI_TnE_Taxable_Amount__c = (detail.ASI_TnE_TW_Payment_Amount__c/(1 + detail.ASI_TnE_Tax_Rate__c/100)).setScale(0, RoundingMode.HALF_UP);
                            }else{
                                detail.ASI_TnE_Taxable_Amount__c = detail.ASI_TnE_HK_Payment_Amount__c/(1 + detail.ASI_TnE_Tax_Rate__c/100);
                            }
                            Decimal paymentAmount = (detail.ASI_TnE_Receipt_Amount__c != null ? detail.ASI_TnE_Receipt_Amount__c : 0) * (detail.ASI_TnE_FX_Rate__c != null ? detail.ASI_TnE_FX_Rate__c : 0);
                            if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')){
                                detail.ASI_TnE_Tax_Amount__c = (paymentAmount - ((paymentAmount/(1+(detail.ASI_TnE_Tax_Rate__c/100))).setScale(0, RoundingMode.HALF_UP))).setScale(0, RoundingMode.HALF_UP);
                            }else{
                                detail.ASI_TnE_Tax_Amount__c = (paymentAmount - ((paymentAmount/(1+(detail.ASI_TnE_Tax_Rate__c/100))).setScale(2, RoundingMode.HALF_UP))).setScale(2, RoundingMode.HALF_UP);
                            }
                        }
                    }
                }else if(!detail.ASI_TnE_Tax_Inclusive__c && detail.ASI_TnE_Tax_Inclusive__c != detailOldMap.get(detail.Id).ASI_TnE_Tax_Inclusive__c){
                    detail.ASI_TnE_Tax_Rate__c = 0;
                    detail.ASI_TnE_Taxable_Amount__c = 0;
                    detail.ASI_TnE_Tax_Amount__c = 0;
                }
                if(detail.ASI_TnE_Expense_Category__c != null && detail.ASI_TnE_Expense_Category__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Category__c){
                    categoryIdSet.add(detail.ASI_TnE_Expense_Category__c);
                } 
                if(Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('HK')){
                    isHk = true;
                }
            }
        }
        Map<Id, ASI_JP_TnE_Expense_Category__c> categoryMap= new Map<Id, ASI_JP_TnE_Expense_Category__c>([Select Id, Name, ASI_TnE_Greeting_Category__c, (Select Name From TnE_JP_Expense_Classifications__r Where Name = 'Dispute Item') From ASI_JP_TnE_Expense_Category__c Where Id In :categoryIdSet Or Name = 'Card Expenses Exclusion']);
        ASI_JP_TnE_Expense_Category__c cate;
        ASI_JP_TnE_Expense_Classification__c cls;
        if(isHk){
            for(ASI_JP_TnE_Expense_Category__c c:categoryMap.values()){
                if(c.Name == 'Card Expenses Exclusion'){
                    cate = c;
                    for(ASI_JP_TnE_Expense_Classification__c cl:c.TnE_JP_Expense_Classifications__r){
                        if(cl.Name == 'Dispute Item'){
                            cls = cl;     
                        }
                    }
                }
            }
            //cate = [Select Id From ASI_JP_TnE_Expense_Category__c Where Name = 'Card Expenses Exclusion' Limit 1];
            //cls = [Select Id FROM ASI_JP_TnE_Expense_Classification__c Where Name = 'Dispute Item' Limit 1];
        }
        
        for(ASI_TnE_ClaimDetail__c detail:detailList){
            if(detail.ASI_TnE_Expense_Category__c != null && categoryMap.get(detail.ASI_TnE_Expense_Category__c) != null && categoryMap.get(detail.ASI_TnE_Expense_Category__c).ASI_TnE_Greeting_Category__c){
                detail.ASI_TnE_Expense_Category__c = null;
                detail.ASI_TnE_Expense_Classification__c = null;
            }
            if(detail.ASI_TnE_Expense_Category__c == null && detail.ASI_TnE_Expense_Classification__c == null && detail.ASI_TnE_Dispute__c && Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('HK')){
                detail.ASI_TnE_Expense_Category__c = cate.Id;
                detail.ASI_TnE_Expense_Classification__c = cls.Id;
            }
        }
    }
}