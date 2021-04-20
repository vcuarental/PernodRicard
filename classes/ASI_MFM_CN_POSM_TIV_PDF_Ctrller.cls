public without sharing class ASI_MFM_CN_POSM_TIV_PDF_Ctrller {

    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {Get; Set;}
    public String tivNumber {Get; Set;}
    public Decimal moq {Get; Set;}
    Public ASI_MFM_PO_POSM_Line__c posmLineHeader {Get; Set;}
    public Boolean showScanWordings_RDC {Get; Set;}
    public Boolean showScanWordings_NoRDC {Get; Set;}
    
    public boolean init(){
        showScanWordings_RDC = false;
        showScanWordings_NoRDC = false;
        
        if(currentHeaderID != Null && currentHeaderID != ''){
            List<ASI_MFM_PO_POSM_Line__c> tmpHeader = [SELECT Id, ASI_MFM_SKU__c, ASI_MFM_Item_Group__c
                                                       , ASI_MFM_Item_Group__r.Name
                                                       , ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c 
                                                       , ASI_MFM_Item_Group_Code__c, ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c
                                                       , ASI_MFM_Quantity__c, ASI_MFM_PO__r.Name
                                                       , ASI_MFM_Check_Traceability_Threshold__c, ASI_MFM_Check_Valid_Threshold__c, ASI_MFM_VAS__c
                                                       , ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c, ASI_MFM_Delivery_Address_Outlet__r.ASI_CRM_CN_CRM_Code__c
                                                       , (SELECT id, ASI_MFM_Qty_Per_Bag_Box__c, ASI_MFM_Qty_Per_Box__c, ASI_MFM_TIV_Number__c FROM Stock_In_Requests__r WHERE ASI_MFM_Status__c LIKE 'Confirmed'
                                                          AND ASI_MFM_TIV_Number__c != '' AND ASI_MFM_TIV_Number__c != Null  AND ASI_MFM_TIV_Note_SentFlag__c=false)
                                                       FROM ASI_MFM_PO_POSM_Line__c WHERE Id = : currentHeaderID];
            
            if(tmpHeader.size() > 0)
                posmLineHeader = tmpHeader[0];
            
            if(posmLineHeader != Null){
                if(posmLineHeader.Stock_In_Requests__r.size() > 0){
                    tivNumber = posmLineHeader.Stock_In_Requests__r[0].ASI_MFM_TIV_Number__c;
                    moq = posmLineHeader.Stock_In_Requests__r[0].ASI_MFM_Qty_Per_Bag_Box__c;
                }
                
                if (posmLineHeader.ASI_MFM_Check_Valid_Threshold__c) {
                    showScanWordings_RDC = posmLineHeader.ASI_MFM_Check_Traceability_Threshold__c;
                    showScanWordings_NoRDC = !showScanWordings_RDC;
                }
            }
        }
        
        Return true;
    }
}