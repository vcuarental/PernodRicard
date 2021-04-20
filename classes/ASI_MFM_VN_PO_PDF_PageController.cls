/***************************************************************************************************************************
 * Name:        ASI_MFM_VN_PO_PDF_PageController
 * Description: Controller for ASI_MFM_VN_PO_PDF_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-02-22       Calvin Chiu (LAPUTA)    Cloned from ASI_MFM_PH_PO_PDF_PageController
 ****************************************************************************************************************************/
public  with sharing  class ASI_MFM_VN_PO_PDF_PageController {
    public ASI_MFM_VN_PO_PDF_PageController(ApexPages.StandardController controller) {
        this.poCurrent = (ASI_MFM_PO__c)controller.getRecord();
    }
    public id POID {set;get;}
    public ASI_MFM_PO__c poCurrent{get;set;}
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public Decimal VatRate {get;set;}{VatRate=0;}
    
    
    private final String object_ApiName = 'ASI_MFM_PO__c';
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    
    public ASI_MFM_VN_PO_PDF_PageController(){
        
    }
    
    public boolean init(){        
        lineItem = new List<ASI_MFM_PO_Line_Item__c>(); 
        
        
        poCurrent = [select Name,Owner.Name, ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Remarks__c, ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c,ASI_MFM_GL_Date__c ,
                     ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Plan__r.name,ASI_MFM_Objectives__c,ASI_MFM_Mechanics__c,ASI_MFM_Other_Remark__c,
                     ASI_MFM_PO_Raised_Date__c, ASI_MFM_Responsible_By__r.Name, ASI_MFM_PO_Date_Range__r.Name, ASI_MFM_Sys_Local_Currency__c,
                     ASI_MFM_PO_Date_Range__r.ASI_MFM_Fiscal_Period__c,ASI_MFM_Tax_Rate__c,ASI_MFM_VAT__c,ASI_MFM_Plan__r.ASI_MFM_Base_Plan_Amount__c,
                     ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Currency__c,ASI_MFM_PO_Amount__c,ASI_MFM_Subledger__c,ASI_MFM_Previous_Approved_By__r.Name,
                     ASI_MFM_Previous_Approved_At__c,ASI_MFM_Previous_Approved_Amount__c,RecordType.DeveloperName,ASI_MFM_Plan_Balance_in_PO_Currency__c,
                     ASI_MFM_Payment_Date__c,ASI_MFM_Status__c,ASI_MFM_Supplier_Address_Line_1__c,ASI_MFM_Supplier_Address_Line_2__c ,ASI_MFM_Supplier_Address_Line_3__c,
                     ASI_MFM_Supplier_Address_Line_4__c,ASI_MFM_Market__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Base_Plan_Balance__c,
                     ASI_MFM_SG_Customer__c,ASI_MFM_Reference_1__c,ASI_MFM_Reference_2__c,ASI_MFM_SG_Delivery_To__c,ASI_MFM_Sys_Plan_Amount__c,CreatedBy.name,
                     ASI_MFM_Plan_Balance__c,CreatedDate,ASI_MFM_SG_Customer__r.name,ASI_MFM_Payment_Term__c, 	ASI_MFM_Plan_Amount_in_PO_Currency__c, ASI_MFM_Reason_Choose_Supplier__c
                     from ASI_MFM_PO__c where id =: POID];
        if(poCurrent.ASI_MFM_VAT__c!=null){
            VatRate=poCurrent.ASI_MFM_VAT__c;
        }else{
            VatRate=0;
        }
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,ASI_MFM_Fiscal_year__c,
                    owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_Print_Sequence__c, ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
                                                      ASI_MFM_Amount__c,ASI_MFM_AP_Code__r.Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_Base_Currency_Amount__c,
                                                      ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,ASI_MFM_A_C_Code__r.Name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c , ASI_MFM_Sub_brand_Code__r.Name,
                                                      ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, ASI_MFM_BU_Code__r.ASI_MFM_L1__c, ASI_MFM_AP_Description__c 
                                                      from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: POID AND ASI_MFM_Amount__c > 0 order by ASI_MFM_Print_Sequence__c,name];
        Integer lineNum = 1;
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
            poli.ASI_MFM_Print_Sequence__c = lineNum ;
            lineNum ++ ;
            lineItem.add(poli);
        }
        
        
        return true;
    }
    
}