public with sharing class ASI_MFM_HK_GenPOItemsController {
    ASI_MFM_PO__c po = new ASI_MFM_PO__c();

    public ASI_MFM_HK_GenPOItemsController (apexpages.standardController sc) {
        po = [select ASI_MFM_Plan__c, ASI_MFM_PO_Raised_Date__c from ASI_MFM_PO__c where id = :sc.getId()];
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
        qs = qs + ' from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = :po_id';
        return qs;
    }
    
    public pageReference genPOItems() {
        string mode = apexpages.currentPage().getParameters().get('mode');  
        id po_id = po.ASI_MFM_Plan__c;
        list<ASI_MFM_Plan_Line_Item__c> pni_list = database.query(buildPlanItemSoql());
        list<ASI_MFM_PO_Line_Item__c> poi_list = new list<ASI_MFM_PO_Line_Item__c>();
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
        for (ASI_MFM_Plan_Line_Item__c pni:pni_list) {
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c();
            poi.ASI_MFM_A_C_Code__c = pni.ASI_MFM_A_C_Code__c;
            poi.ASI_MFM_AP_Code__c = pni.ASI_MFM_AP_Code__c;
            poi.ASI_MFM_BU_Code__c = pni.ASI_MFM_BU_Code__c;
            poi.ASI_MFM_customer_name__c = pni.ASI_MFM_customer_name__c;
            poi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_Raised_Date__c;
            poi.ASI_MFM_PO__c = po.id;
            poi.ASI_MFM_SKU_Code__c = pni.ASI_MFM_SKU_Code__c;
            poi.ASI_MFM_Sub_brand_Code__c = pni.ASI_MFM_Sub_brand_Code__c;
            poi.ASI_MFM_List_Item_Description__c = pni.ASI_MFM_List_Item_Description__c;
            if (mode == 'full') {
                poi.ASI_MFM_Quantity__c = pni.ASI_MFM_Quantity__c;
                poi.ASI_MFM_Unit_Price__c = pni.ASI_MFM_Unit_Cost__c;
                poi.ASI_MFM_Amount__c = pni.ASI_MFM_Total_Cost__c;
                poi.ASI_MFM_Original_Amount__c = pni.ASI_MFM_Original_Total_Cost__c;                                                                    
            }
            //if (test.isRunningTest()) {
            //Wilken: 20130816 Always need to assign Record Type for PO Line item as Permission Set cannot grant default record type
                poi.recordTypeId = rt_map.get('ASI_MFM_HK_PO_Line_Item');
            //}           
            System.debug('PO Line Item Record Type ID: ' + poi.recordTypeId);
            poi_list.add(poi);          
        }
        if (poi_list.size() > 0) {
            insert poi_list;
        }
        return new pageReference('/apex/ASI_MFM_HK_InputPOItemsPage?id=' + po.id);
    }
}