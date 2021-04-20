/*Filename:     ASI_CRM_TW_SKUPriceCost_TriggerCls.cls
* Author:       Twinkle LI (Introv Limited)
* Purpose:      Handle TW SKU Price/Cost Trigger Logic
* Created Date: 26th May 2017
*
*/
public with sharing class ASI_CRM_TW_SKUPriceCost_TriggerCls {
    public static void routineBeforeUpdate(list<ASI_CRM_MY_SKUPriceCost__c> trigger_new, map<id, ASI_CRM_MY_SKUPriceCost__c> trigger_oldMap){ 
        for(ASI_CRM_MY_SKUPriceCost__c skuPC : trigger_new){
            String strCurrentYear = String.valueOf(System.Today().Year());
            String strYearFrom = strCurrentYear.substring(0,2) + skuPC.ASI_CRM_Fiscal_Year__c.substring(0,2);
            String strYearTo = strCurrentYear.substring(0,2) + skuPC.ASI_CRM_Fiscal_Year__c.substring(2,4);
            
            Date dateFromFY = Date.valueOf(strYearFrom+'-7-1');
            Date dateToFY = Date.valueOf(strYearTo+'-6-30');
            
            if(skuPC.ASI_CRM_EffectiveDate__c < dateFromFY || skuPC.ASI_CRM_EffectiveDate__c > dateToFY){
                skuPC.addError('Please enter a valid Effective Date.');
            }
        }
    }
}