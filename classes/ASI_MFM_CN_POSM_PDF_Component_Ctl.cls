public without sharing class ASI_MFM_CN_POSM_PDF_Component_Ctl {
    public id LINEID {get;set;}
    public String tivNumber {get;set;}
    public ASI_MFM_Stock_In_Request__c sirSingle {get;set;}
    public ASI_MFM_PO_POSM_Line__c posmLine {get;set;}
    public List<ASI_MFM_Stock_In_Request__c> sirList {get;set;}
    //Andy@Introv 20181213: add item group image to show - start
    public Boolean posmItemPhotoCheck {get;set;}
    public List<String> posmItemPhoto {get;set;}
    public String domain {get;set;}
    //Andy@Introv 20181213: add item group image to show - end
    public Boolean showScanWordings_RDC {Get; Set;}
    public Boolean showScanWordings_NoRDC {Get; Set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public ASI_MFM_CN_POSM_PDF_Component_Ctl(){
    }
    
    public boolean init(){
        tivNumber = '';
        posmLine = [SELECT id,name,ASI_MFM_Item_Group_Code__c,ASI_MFM_Unit_Price__c,
                      ASI_MFM_PO__c, ASI_MFM_PO__r.name, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_Currency__c,
                      ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Phone,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.gvp__Primary_Contact__c,
                      ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.ASI_CRM_Brand__c,
                      ASI_MFM_Item_Group__r.ASI_MFM_Inspection__c,ASI_MFM_Item_Group__r.ASI_MFM_Unit__c,
                      ASI_MFM_Item_Group__r.ASI_MFM_Safety_Instruction__c,
                      ASI_MFM_Contact_Person__c,ASI_MFM_Phone_Number__c,
                      ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c,
                      ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,
                      ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c,
                      ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c, ASI_MFM_Quantity__c,
                      ASI_MFM_Check_Traceability_Threshold__c, ASI_MFM_Check_Valid_Threshold__c, ASI_MFM_VAS__c,
                      ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c, ASI_MFM_Delivery_Address_Outlet__r.ASI_CRM_CN_CRM_Code__c,
                      ASI_MFM_Province__c, ASI_MFM_City__c, ASI_MFM_Detail_Address__c,
                      (SELECT id,name,ASI_Delivery_Date__c,ASI_MFM_TIV_Number__c, ASI_MFM_Lot_Quantity__c,
                         ASI_MFM_Total_Quantity__c,ASI_MFM_Lot_Number__c,ASI_MFM_Total_Qty_Per_Bag_Box__c,
                         ASI_MFM_Qty_Per_Box__c, ASI_MFM_Total_Number_Of_Box__c, ASI_MFM_Fraction_Qty__c,
                         ASI_MFM_Length__c, ASI_MFM_Width__c, ASI_MFM_Height__c,  ////Andy@Introv 20181214: include length + width + height
                         ASI_MFM_Net_Weight__c, ASI_MFM_Box_Net_Weight__c ,ASI_MFM_Qty_Per_Bag_Box__c, ASI_MFM_Box_Size_M3__c, ASI_MFM_TIV_Note_Sent__c
                         FROM Stock_In_Requests__r
                         WHERE ASI_MFM_Status__c Like 'Confirmed' 
                         AND ASI_MFM_TIV_Note_SentFlag__c=false
                         AND ASI_MFM_TIV_Number__c!=''
                         ORDER BY ASI_Delivery_Date__c)
                    FROM ASI_MFM_PO_POSM_Line__c 
                    WHERE id= :LINEID
                    LIMIT 1];
        showScanWordings_RDC = false;
        showScanWordings_NoRDC = false;
        if (posmLine.ASI_MFM_Check_Valid_Threshold__c) {
            showScanWordings_RDC = posmLine.ASI_MFM_Check_Traceability_Threshold__c;
            showScanWordings_NoRDC = !showScanWordings_RDC;
        }
        sirList = new List<ASI_MFM_Stock_In_Request__c>();
        for(ASI_MFM_Stock_In_Request__c sir : posmLine.Stock_In_Requests__r){
            if(tivNumber==''||tivNumber==sir.ASI_MFM_TIV_Number__c) {
                if(tivNumber=='') {tivNumber = sir.ASI_MFM_TIV_Number__c;}
                sirSingle = sir;
                sir.ASI_MFM_TIV_Note_SentFlag__c = true;
                sir.ASI_MFM_TIV_Note_Sent__c = true;
                sirList.add(sir);
            }
        }
        if(sirList.size() > 0) {
            update sirList; //Enoch@Introv 20191114 remove update in Email Component ctrl
        }

        //Andy@Introv 20181213: add item group image to show - start
        domain=URL.getSalesforceBaseUrl().toExternalForm();
        
        posmItemPhotoCheck = FALSE;
        posmItemPhoto = new List<String>();
        for(ASI_CRM_Product_Warehouse_Photo__c photo : [SELECT ASI_CRM_Item_Group__c, ASI_Image_URL__c 
                                                       FROM ASI_CRM_Product_Warehouse_Photo__c 
                                                       WHERE ASI_CRM_Item_Group__c = :posmLine.ASI_MFM_Item_Group__c
                                                          AND ASI_Image_URL__c != NULL
                                                       ORDER BY ID DESC
                                                       LIMIT 4
                                                      ])
        {
            posmItemPhoto.add(photo.ASI_Image_URL__c);
        }
        if (posmItemPhoto.size() > 0) posmItemPhotoCheck = TRUE;
        //Andy@Introv 20181213: add item group image to show - end
         posmLine.ASI_MFM_Send_TIV__c = false;
        update posmLine;
        

        return true;
    }
}