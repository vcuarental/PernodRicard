/*********************************************************************************
* Name:ASI_CRM_Price_And_Approval_Ctrl
* Test Class: ASI_CRM_Price_And_Approval_Ctrl_Test 
* Description: 

* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2020-12-21       Wilken Lee               [WL 1.0] Split "Exclude Rebate" to 4 checkbox for individual rebate type
*********************************************************************************/
public class ASI_CRM_Price_And_Approval_Ctrl {
    public String recordId{get;set;}
    public string actionName{get;set;}
    Public ASI_CRM_Price_And_Discount__c priceAndDiscount{set;}
    public List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetails {set;}
    public  ASI_CRM_Price_And_Approval_Ctrl(){
        system.debug('@#@#'+recordId);
        if(recordId != null){
            priceAndDiscount = [Select Id, Name, Owner.Name, ASI_CRM_SG_Price_Group_Name__c,ASI_CRM_SG_Benchmark_Price_Type__c, ASI_CRM_SG_Effective_Date__c,ASI_CRM_SG_Expiry_Date__c,ASI_CRM_SG_Product_Grouping__r.Name,ASI_CRM_SG_Master_Price_Group__c,ASI_CRM_SG_Master_Price_Group__r.ASI_CRM_SG_Wholesaler_Code__c,ASI_CRM_SG_Price_Group_Description__c from ASI_CRM_Price_And_Discount__c where id = :recordId limit 1];
            priceAndDiscountDetails = [Select id, ASI_CRM_SG_SKU_MFM__c, ASI_CRM_SG_Exclude_Rebate__c , 
                ASI_CRM_Exclude_Portfolio_Rebate__c, ASI_CRM_Exclude_OOM_Rebate__c, ASI_CRM_Exclude_Bottle_Rebate__c,   //WL 1.0
                ASI_CRM_SG_Bottle_Rebate_Per_Bottle__c,ASI_CRM_OOM_Rebate_Per_Bottle__c,ASI_CRM_SG_Portfolio_Rebate_Per_Bottle__c,ASI_CRM_SG_FWO_Rebate_Per_Bottle__c, ASI_CRM_SG_SKU_MFM__r.Name,ASI_CRM_SG_SKU_Benchmark_Price1__c,ASI_CRM_SG_Base_Price_Comments__c,ASI_CRM_SG_Price_to_Wholesaler_Outlet__c,ASI_CRM_SG_Indicator__c,ASI_CRM_SG_Existing_Net_Price__c,ASI_CRM_SG_Net_Price__c,ASI_CRM_SG_Budget_Net_Price__c,ASI_CRM_SG_Vs_Existing_Price__c,ASI_CRM_SG_Vs_Budget__c from ASI_CRM_Price_And_Discount_Detail__c where ASI_CRM_Price_And_Discount__c = :recordId];
        }
   }
    
    public ASI_CRM_Price_And_Discount__c getpriceAndDiscount(){
            return [Select Id, Name, Owner.Name, ASI_CRM_SG_Price_Group_Name__c,ASI_CRM_SG_Benchmark_Price_Type__c, ASI_CRM_SG_Effective_Date__c,ASI_CRM_SG_Expiry_Date__c,ASI_CRM_SG_Product_Grouping__r.Name,ASI_CRM_SG_Master_Price_Group__c,ASI_CRM_SG_Master_Price_Group__r.ASI_CRM_SG_Wholesaler_Code__c,ASI_CRM_SG_Price_Group_Description__c from ASI_CRM_Price_And_Discount__c where id = :recordId limit 1];
    }
    
    public List<ASI_CRM_Price_And_Discount_Detail__c> getpriceAndDiscountDetails(){
           return [Select id, Name, ASI_CRM_SG_SKU_MFM__c,ASI_CRM_SG_Exclude_Rebate__c, 
            ASI_CRM_Exclude_Portfolio_Rebate__c, ASI_CRM_Exclude_OOM_Rebate__c, ASI_CRM_Exclude_Bottle_Rebate__c, //WL 1.0
            ASI_CRM_SG_Bottle_Rebate_Per_Bottle__c,ASI_CRM_OOM_Rebate_Per_Bottle__c,ASI_CRM_SG_Portfolio_Rebate_Per_Bottle__c,ASI_CRM_SG_FWO_Rebate_Per_Bottle__c, ASI_CRM_SG_SKU_MFM__r.Name,ASI_CRM_SG_SKU_Benchmark_Price1__c,ASI_CRM_SG_Base_Price_Comments__c,ASI_CRM_SG_Price_to_Wholesaler_Outlet__c,ASI_CRM_SG_Indicator__c,ASI_CRM_SG_Existing_Net_Price__c,ASI_CRM_SG_Net_Price__c,ASI_CRM_SG_Budget_Net_Price__c,ASI_CRM_SG_Vs_Existing_Price__c,ASI_CRM_SG_Vs_Budget__c from ASI_CRM_Price_And_Discount_Detail__c where ASI_CRM_Price_And_Discount__c = :recordId];

    }
}