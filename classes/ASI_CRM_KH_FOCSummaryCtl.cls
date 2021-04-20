public with sharing class ASI_CRM_KH_FOCSummaryCtl {
    
    private ApexPages.StandardController standardController {get;set;}
    public Id FOCId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
   
    public list<ASI_FOC_Request_Item__c> getFOCItem(){    
        List<ASI_FOC_Request_Item__c> lstFOCItem = [
            SELECT id, ASI_FOC_SKU__c, ASI_FOC_SKU__r.Name, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SG_Unit_Price__c, 
            ASI_FOC_SKU__r.ASI_HK_CRM_Available_Quantity__c,ASI_FOC_SKU__r.ASI_CRM_Available_Quantity_Carton__c,
                    ASI_CRM_KH_AP_Code__c,ASI_CRM_SG_FOC_Type__c,ASI_FOC_Request_Quantity_Bottle__c,ASI_FOC_Cancel_Quantity_PC_BT__c 
                  
            FROM ASI_FOC_Request_Item__c
            WHERE ASI_FOC_Request_Order__c = :FOCId 
            //ORDER BY ASI_CRM_SKU__r.name ASC
        ];
        
             
        return lstFOCItem;
    }
        
    public ASI_CRM_KH_FOCSummaryCtl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if(FOCId != NULL){
        }
    }
}