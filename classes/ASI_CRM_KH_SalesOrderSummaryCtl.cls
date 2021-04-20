/*********************************************************************************
 * Name: ASI_CRM_KH_SalesOrderSummaryCtl
 * Description: Controller class for ASI_CRM_KH_SalesOrderSummaryPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-12-02       Ceterna                 Created 
 */


public with sharing class ASI_CRM_KH_SalesOrderSummaryCtl{
        
    private ApexPages.StandardController standardController {get;set;}
    private Id recordId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    
    public String region {get; set;} {region = 'KH';}
    
    public ASI_CRM_KH_SalesOrderSummaryCtl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        if(recordId != NULL){
            List <ASI_KOR_Sales_Order_Request__c > soRequest = [SELECT Id, RecordType.DeveloperName,Name, ASI_CRM_SG_Customer__c, ASI_CRM_SG_Customer__r.Name,
                ASI_CRM_Customer_Address__c, ASI_KOR_Customer_PO_No__c, ASI_CRM_KH_Delivery_Instruction_2__c, 
            OwnerId,Owner.Name, ASI_KOR_Order_Status__c, ASI_CRM_SG_Order_Date__c, ASI_CRM_SG_Total_Request_Quantity_Bottle__c,
                ASI_CRM_SG_Ship_To__r.Name, ASI_KOR_Ship_To_Wholesaler_Address__c, ASI_CRM_SG_Total_Request_Quantity_Carton__c, 
                ASI_CRM_SG_Total_Price__c, ASI_KOR_JDE_Sales_Order_Type__c, ASI_KOR_JDE_Sales_Order_Number__c 
                    FROM ASI_KOR_Sales_Order_Request__c WHERE id =:recordId];
            
            region = soRequest[0].RecordType.DeveloperName.contains('KH')?'KH':'';
        }
    }
    
    public list<ASI_KOR_Sales_Order_Transaction__c> getSalesOrderRequestItems(){
        return [Select Id, ASI_CRM_SG_SKU__c, ASI_CRM_SG_SKU__r.Name, 
                ASI_CRM_SG_Request_Quantity_Bottle__c, ASI_CRM_SG_Request_Quantity_Carton__c,ASI_CRM_SG_SKU__r.ASI_CRM_Available_Quantity_Carton__c,
                ASI_CRM_SG_Unit_Price__c, ASI_CRM_KH_Cancelled_Quantity__c, ASI_CRM_SG_Available_Quantity__c, ASI_CRM_SG_Total_Price_PRS_WS__c 
                FROM ASI_KOR_Sales_Order_Transaction__c
                WHERE ASI_KOR_Sales_Order_Request__c = :recordId 
                and recordType.DeveloperName = 'ASI_CRM_KH_SO_Item'
                ORDER BY ASI_CRM_SG_SKU__r.name ASC
               ];
    }
    
}