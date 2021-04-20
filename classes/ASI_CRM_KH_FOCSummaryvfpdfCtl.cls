public class ASI_CRM_KH_FOCSummaryvfpdfCtl {
    public Id focRecordId{get;set;}
    public ASI_FOC_Free_Goods_Request__c getfocRecord(){
         system.debug('@#'+focRecordId);
         ASI_FOC_Free_Goods_Request__c focRecord = [select id, Name, ASI_FOC_Request_Status__c, ASI_CRM_Outlet__r.Name,
            Owner.FirstName, Owner.LastName, ASI_CRM_SG_Order_Date__c, ASI_CRM_KH_Total_Amount__c, ASI_FOC_Delivery_Instruction_1__c, ASI_FOC_Delivery_Instruction_2__c,
                    ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_MY_JDE_SO_Type__c, ASI_CRM_JDE_SO_Number__c, 
                    ASI_CRM_Contract__r.name,ASI_FOC_SYS_Owner__c,ASI_CRM_Ship_To__r.Name,ASI_CRM_Outlet_Address__c,ASI_CRM_Ship_To_Address__c,
                    ASI_CRM_FOC_Nature__c,ASI_CRM_AG_Code_Number__c,ASI_CRM_SG_FOC_Type__c,ASI_CRM_KH_PO_Number__c                            
                    from ASI_FOC_Free_Goods_Request__c where id = :focRecordId limit 1];
        return focRecord;
    }
     public ASI_CRM_KH_FOCSummaryvfpdfCtl(){
       
      
    }
     public list<ASI_FOC_Request_Item__c> getFOCItem(){    
        List<ASI_FOC_Request_Item__c> lstFOCItem = [
            SELECT id, ASI_FOC_SKU__c, ASI_FOC_SKU__r.Name, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SG_Unit_Price__c,
                    ASI_FOC_SKU__r.ASI_CRM_Available_Quantity_Carton__c,
                    ASI_CRM_KH_AP_Code__c,ASI_CRM_SG_FOC_Type__c,ASI_FOC_Request_Quantity_Bottle__c,ASI_FOC_Cancel_Quantity_PC_BT__c
                  
            FROM ASI_FOC_Request_Item__c
            WHERE ASI_FOC_Request_Order__c = :focRecordId 
            //ORDER BY ASI_CRM_SKU__r.name ASC
        ];
        
             
        return lstFOCItem;
    }
        
}