public  with sharing  class ASI_MFM_MY_PO_Supplier_PDF_Controller {
    // use  ASI_MFM_MY_PO_Supplier_PDF_Component AS PDF Send To supplier
    //     <c:ASI_MFM_MY_PO_Supplier_PDF_Component po_id="{!ASI_MFM_PO__c.id}"/> 
    public ASI_MFM_MY_PO_Supplier_PDF_Controller(ApexPages.StandardController stdController){
        //try{
        this.Po = (ASI_MFM_PO__c)stdController.getRecord();
    }
    public ASI_MFM_MY_PO_Supplier_PDF_Controller(){

    }
    public ASI_MFM_PO__c poCurrent{get;set;}
    public id POID {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    private final ASI_MFM_PO__c Po;
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    

    public boolean init(){
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        
        //poCurrent = [select Name,ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c from ASI_MFM_PO__c where id =: POID];
        poCurrent = [select Name,ASI_MFM_Plan__r.Name,Owner.name,ASI_MFM_Remarks__c, ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c,ASI_MFM_GL_Date__c ,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c
                     ,ASI_MFM_PO_Raised_Date__c, ASI_MFM_Responsible_By__r.Name,ASI_MFM_PO_Date_Range__r.Name, 
                     ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Supplier_Phone_Number__c,ASI_MFM_Supplier_Fax_Number__c,ASI_MFM_Currency__c,ASI_MFM_PO_Amount__c,ASI_MFM_Subledger__c,
                     ASI_MFM_Payment_Date__c,ASI_MFM_Status__c,ASI_MFM_Supplier_Address_Line_1__c,ASI_MFM_Supplier_Address_Line_2__c ,ASI_MFM_Supplier_Address_Line_3__c,ASI_MFM_Supplier_Address_Line_4__c,ASI_MFM_Sys_Plan_Name__c,
                     ASI_MFM_Reference_1__c,ASI_MFM_Reference_2__c,ASI_MFM_SG_Delivery_To__c,ASI_MFM_Sys_Plan_Amount__c,CreatedBy.name,
                     ASI_MFM_Plan_Balance__c,ASI_MFM_Base_Currency_Amount__c, CreatedDate,ASI_MFM_Delivery_date__c,ASI_MFM_Payment_Term__c from ASI_MFM_PO__c where id =: POID];
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_A_C_Code__r.Name, ASI_MFM_BU_Code__r.ASI_MFM_BU_Description__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c, ASI_MFM_AP_Code__r.Name,
        ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c, 
        ASI_MFM_G_L_Date__c, ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c, ASI_MFM_Customer_Name__r.Name ,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_Base_Currency_Amount__c
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: POID];
        
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            lineItem.add(poli);
        }
        return true;
    }
    
}