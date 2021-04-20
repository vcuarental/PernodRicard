/*Filename:    ASI_CRM_TW_GenFOCRequestItems_Ctrl.cls
* Modified By: Twinkle LI (Introv Limited)
* Purpose:     Controller Class to copy Plan Line for generating FOC Line
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_GenFOCRequestItems_Ctrl {
    ASI_FOC_Free_Goods_Request__c header = new ASI_FOC_Free_Goods_Request__c();
    
    public ASI_CRM_TW_GenFOCRequestItems_Ctrl(apexpages.standardController sc) {
        header = [SELECT id, ASI_CRM_Plan__c, ASI_CRM_Receiver__c, ASI_FOC_Delivery_Remarks__c, ASI_CRM_Target_Outlet__c, 
                  ASI_CRM_SG_Delivery_Instructions__c, ASI_CRM_Delivery_To__c FROM ASI_FOC_Free_Goods_Request__c
                  WHERE id = :sc.getId()];        
    }
    
    public string buildPlanItemSoql() {
        string qs = 'select ';      
        boolean start = true;
        for (string f:schema.sobjectType.ASI_MFM_Plan_Line_Item__c.fields.getMap().keySet()) {
            if (start) {
                qs = qs + f;
                start = false;
            }
            else {
                qs = qs + ', ' + f;
            }
        }
        //qs = qs + ' from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = :plan_id AND ASI_MFM_A_C_Code__c != null AND ASI_MFM_List_Item_Description__c LIKE \'%FOC%\'';
        qs = qs + ' from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = :plan_id AND ASI_MFM_A_C_Code__c != null';
        system.debug('Plan Line Item SOQL: '+qs);
        
        return qs;
    }
    
    public pageReference GenFOCItems() {
        //string mode = apexpages.currentPage().getParameters().get('mode');  
        id plan_id = header.ASI_CRM_Plan__c;
        list<ASI_MFM_Plan_Line_Item__c> pni_list = database.query(buildPlanItemSoql());
        system.debug('Plan Line Item: '+pni_list);
        
        list<ASI_FOC_Request_Item__c> foci_list = new list<ASI_FOC_Request_Item__c>();
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_FOC_Request_Item__c');
        
        for (ASI_MFM_Plan_Line_Item__c pni : pni_list) {
            ASI_FOC_Request_Item__c foci = new ASI_FOC_Request_Item__c();
            
            foci.ASI_FOC_Request_Order__c = header.id;
            foci.ASI_CRM_Plan_Line_Item__c = pni.id;
            foci.ASI_FOC_Request_Quantity_Bottle__c = 0;
            foci.ASI_CRM_Receiver__c = header.ASI_CRM_Receiver__c;
            foci.ASI_FOC_Remark__c = header.ASI_FOC_Delivery_Remarks__c;
            foci.ASI_CRM_Delivery_Instruction__c = header.ASI_CRM_SG_Delivery_Instructions__c;
            foci.ASI_CRM_Delivery_To__c = header.ASI_CRM_Delivery_To__c;
			foci.ASI_CRM_Target_Outlet__c = header.ASI_CRM_Target_Outlet__c;
            //foci.ASI_CRM_Target_Outlet__c  = pni.ASI_MFM_Customer_Name__c;
            //foci.ASI_FOC_SKU__c = pni.ASI_MFM_SKU_Code__c;
            
            /*poi.ASI_MFM_A_C_Code__c = pni.ASI_MFM_A_C_Code__c;
            poi.ASI_MFM_AP_Code__c = pni.ASI_MFM_AP_Code__c;
            poi.ASI_MFM_BU_Code__c = pni.ASI_MFM_BU_Code__c;
            poi.ASI_MFM_customer_name__c = pni.ASI_MFM_customer_name__c;
            poi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_Raised_Date__c;
            poi.ASI_MFM_PO__c = po.id;
            poi.ASI_MFM_SKU_Code__c = pni.ASI_MFM_SKU_Code__c;
            poi.ASI_MFM_Sub_brand_Code__c = pni.ASI_MFM_Sub_brand_Code__c;
            poi.ASI_MFM_List_Item_Description__c = pni.ASI_MFM_List_Item_Description__c;*/  
              
            /*if (mode == 'full') {
            poi.ASI_MFM_Quantity__c = pni.ASI_MFM_Quantity__c;
            poi.ASI_MFM_Unit_Price__c = pni.ASI_MFM_Unit_Cost__c;
            poi.ASI_MFM_Amount__c = pni.ASI_MFM_Total_Cost__c;
            poi.ASI_MFM_Original_Amount__c = pni.ASI_MFM_Original_Total_Cost__c;                                  
            }*/
            
            if (test.isRunningTest()) {
              foci.recordTypeId = rt_map.get('ASI_CRM_TW_FOC_Request_Item');
            }   
             
            foci_list.add(foci);      
        }
        if (foci_list.size() > 0) {
            insert foci_list;
        }
        return new pageReference('/apex/ASI_CRM_TW_InputFOCItemsPageWithPaging?id=' + header.id);
    }
}