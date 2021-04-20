/*********************************************************************************
* Name:ASI_CRM_SG_PnD_TriggerClass 
* Description: 
* Test Class: ASI_CRM_Price_And_Approval_Ctrl_Test

* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2020-05-04       Ceterna                  Created
* 2020-12-03       Wilken Lee               [WL 1.0] Add validation to allow delete for Draft/Rejected price only
*********************************************************************************/
public class ASI_CRM_SG_PnD_TriggerClass {
    public static void checkEffectiveDate (List<ASI_CRM_Price_And_Discount__c> trigger_new) {        
        for (ASI_CRM_Price_And_Discount__c newPricenDiscount :trigger_new){
            newPricenDiscount.ASI_CRM_SG_Rebate_Start_Date__c = String.valueOf(newPricenDiscount.ASI_CRM_SG_Effective_Date__c);    
        }
    }
    
    /*[WL 1.0] BEGIN*/
    public static void validateRebateDelete (List<ASI_CRM_Price_And_Discount__c> trigger_old) {        
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id=:profileId].Name;
        
        for (ASI_CRM_Price_And_Discount__c rebate:trigger_old){
            if (!profileName.contains('Administrator'))
                rebate.addError('Please contact System Administrator to delete the record');
        }
    }
    /*[WL 1.0] END*/
}