public  with sharing  class ASI_MFM_JP_PO_PDF_PageController {
     public ASI_MFM_JP_PO_PDF_PageController(ApexPages.StandardController controller) {
            this.poCurrent = (ASI_MFM_PO__c)controller.getRecord();
    }
    
    public id POID {set;get;}
    public ASI_MFM_PO__c poCurrent{get;set;}
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public boolean isApproved {set;get;}
    
    private final String object_ApiName = 'ASI_MFM_PO__c';
    public String approvedName{get;set;}
    public Datetime approvedDatetime{get;set;}
     // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }


    public ASI_MFM_JP_PO_PDF_PageController(){
      
    }
    
    public boolean init(){
        //try{
        //this.Po = (ASI_MFM_PO__c)stdController.getRecord();
        
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
     
        
        poCurrent = [select Name, ASI_MFM_Remarks__c, ASI_MFM_Supplier_Name__c,ASI_MFM_JP_PO_Number__c,ASI_MFM_Plan__c,ASI_MFM_GL_Date__c ,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c
        ,ASI_MFM_PO_Raised_Date__c, ASI_MFM_Responsible_By__r.Name,ASI_MFM_Responsible_By__r.ASI_TnE_Sub_Ledger__c, ASI_MFM_PO_Date_Range__r.Name, ASI_MFM_PO_Date_Range__r.ASI_MFM_Fiscal_Period__c,
        ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Currency__c,ASI_MFM_PO_Amount__c,ASI_MFM_Subledger__c,ASI_MFM_Previous_Approved_By__r.Name,ASI_MFM_Previous_Approved_At__c,ASI_MFM_Previous_Approved_Amount__c,
            ASI_MFM_Payment_Date__c 
           from ASI_MFM_PO__c where id =: POID];
        System.debug('POId ' + POID);
        ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper (object_ApiName , POID );
        if (appHistHelper.appHistorySObjList != null && appHistHelper.appHistorySObjList.size() > 0){
            if (appHistHelper.appHistorySObjList[0].StepStatus == 'Approved')
            {
                isApproved = true;
                approvedName = appHistHelper.appHistorySObjList[0].Actor.Name ;
                approvedDatetime = appHistHelper.appHistorySObjList[0].CreatedDate ;
            }else if(appHistHelper.appHistorySObjList.size()>1 && appHistHelper.appHistorySObjList[1].StepStatus == 'Approved'){
                isApproved = true ;
                approvedName = appHistHelper.appHistorySObjList[1].Actor.Name ;
                approvedDatetime = appHistHelper.appHistorySObjList[1].CreatedDate ;            
            }else
                isApproved = false;
            
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
           
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select Name,ASI_MFM_Print_Sequence__c, ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_SKU_Code__r.ASI_MFM_SKU_Code__c ,ASI_MFM_AP_Code__r.Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,
        ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c ,
        ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, ASI_MFM_BU_Code__r.ASI_MFM_L1__c
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: POID order by ASI_MFM_Print_Sequence__c,name];
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
        
        
          paymentlineItem=[Select name,ASI_MFM_Payment__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,
                                ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Adjustment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_VAT_Rate__c,ASI_MFM_PO_Receipt_Item__r.name,ASI_MFM_Currency__c ,
                                ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment__r.ASI_MFM_Currency__c,ASI_MFM_VAT_Adjustment__c,
                                ASI_MFM_Payment__r.id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :poCurrent.Id];
         
         for(ASI_MFM_Payment_Line_Item__c line : paymentlineItem){
             if(line.ASI_MFM_VAT_Adjustment__c==null){
                 line.ASI_MFM_VAT_Adjustment__c=0;
             }
         }
        
        //catch(exception e){e.getMessage();}
        return true;
    }

    
    public List<ASI_MFM_Payment_Line_Item__c> paymentlineItem {get; set;}
    
}