public class ASI_MFM_HK_PO_PDF_PageController {
    
     public id POID {set;get;}
    private final ASI_MFM_PO__c Po;
    public ASI_MFM_Plan__c plan{get;set;}
    
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
        
    public ASI_MFM_PO__c poCurrent{get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Boolean isFOC {get;set;}

    public ASI_MFM_HK_PO_PDF_PageController(){
      
    }
    
     public boolean init(){
        //try{
        //this.Po = (ASI_MFM_PO__c)stdController.getRecord();
        
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        poCurrent = [select Name,ASI_MFM_Status__c, ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Supplier_Address_Line_1__c,ASI_MFM_Supplier_Address_Line_2__c,ASI_MFM_Supplier_Address_Line_3__c,ASI_MFM_Supplier_Address_Line_4__c,
        ASI_MFM_Supplier_Phone_Number__c, ASI_MFM_Supplier_Fax_Number__c,
        ASI_MFM_Plan__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c,ASI_MFM_Plan__r.Name,
        ASI_MFM_PO_Raised_Date__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c,ASI_MFM_Payment_Date__c,ASI_MFM_Payment_Terms__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Total_Quantity__c,
        ASI_MFM_Delivery_Address_Line_1__c,ASI_MFM_Delivery_Address_Line_2__c,ASI_MFM_Delivery_Address_Line_3__c,ASI_MFM_Delivery_Address_Line_4__c,
        ASI_MFM_Remarks__c,owner.name, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Responsible_By__r.Name, ASI_MFM_Is_FOC_PO__c  
        from ASI_MFM_PO__c where id =:POID];
        System.debug('POId ' + POID);
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ];          
        }        
        
         // Check FOC PO?
        isFOC = poCurrent.ASI_MFM_Is_FOC_PO__c == true? true:false;
        
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_SKU_Code__r.ASI_MFM_SKU_Code__c ,ASI_MFM_Base_Currency_Amount__c, ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,  ASI_MFM_AP_Code_Only__c,ASI_MFM_AP_Description__c,
        ASI_MFM_BU_Code__c,ASI_MFM_BU_Code__r.Name,ASI_MFM_Customer_Name__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_Customer_Code__c,
        ASI_MFM_Pay_Acc__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_Brand_Code_Only__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,ASI_MFM_G_L_Date__c
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: poCurrent.Id order by ASI_MFM_Print_Sequence__c,name];
        
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
        //catch(exception e){e.getMessage();}
    }

}