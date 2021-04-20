public with sharing class ASI_MFM_JP_Payment_PDF_PageController
{
    public ASI_MFM_JP_Payment_PDF_PageController(ApexPages.StandardController controller) {
        this.payCurrent = (ASI_MFM_Payment__c)controller.getRecord();
    }
    
    public Id payID {set;get;}
    public ASI_MFM_Payment__c payCurrent{get;set;}
    public ASI_MFM_Plan__c plan{get;set;}
    public ASI_MFM_PO__c PO{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> lineItem{get;set;}
    public boolean isApproved {set;get;}
    public Decimal PaymentAmount {get;set;} {PaymentAmount=0;}
    public Decimal TaxAmount {get;set;} {TaxAmount=0;}
    public Decimal POamount {get;set;} {POamount=0;}
    public String POamountString {get;set;} 
    public Decimal PaymentAmount1 {get;set;} {PaymentAmount1=0;}
    public Decimal TotalPaymentAmount {get;set;} {TotalPaymentAmount=0;}
    public Decimal AllTotalPaymentAmount {get;set;} {AllTotalPaymentAmount=0;}
    public String PaymentAmount2{get;set;}
    public String TaxAmountString{get;set;}
    public String InvoiceAmtString{get;set;}
    public Decimal VAT_Adjustment {get;set;} {VAT_Adjustment=0;}
    public String VAT_Adjustment2{get;set;}
    public String AllTotalPaymentAmountString{get;set;}
    
    private final String object_ApiName = 'ASI_MFM_Payment__c';
    public String approvedName{get;set;}
    public Datetime approvedDatetime{get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    
    public ASI_MFM_JP_Payment_PDF_PageController(){}
    
    public boolean init()
    {
        lineItem = new List<ASI_MFM_Payment_Line_Item__c>();
        
        payCurrent = [SELECT Name,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Submitted_Date__c,ASI_MFM_Invoice_Number__c,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,Owner.name,ASI_MFM_Exchange_Rate__c,CreatedDate,
                      ASI_MFM_Invoice_Date__c,ASI_MFM_Invoice_Due_Date__c,ASI_MFM_G_L_Date__c,ASI_MFM_VAT_Rate__c,ASI_MFM_Supplier_Name__r.ASI_KOR_Wholesaler_Bank_Account_Num__c,
                      ASI_MFM_Payment_Amount__c,ASI_MFM_Currency__c,ASI_MFM_Remarks__c,ASI_MFM_Tax_Code__r.Name,ASI_MFM_BC_Code__c,
                      ASI_MFM_VAT_Adjustment__c,ASI_MFM_Adjustment_Amount__c,ASI_MFM_Plan__c,ASI_MFM_PO__c,
                      ASI_MFM_Payment_Date__c,ASI_MFM_JP_Payment_Date__c, ASI_MFM_Invoice_Amount__c
                      FROM ASI_MFM_Payment__c WHERE id =: payID];
        
        ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper (object_ApiName,payID);
        if (appHistHelper.appHistorySObjList != null && appHistHelper.appHistorySObjList.size() > 0)
        {
            if (appHistHelper.appHistorySObjList[0].StepStatus == 'Approved')
            {
                isApproved = true;
                approvedName = appHistHelper.appHistorySObjList[0].Actor.Name ;
                approvedDatetime = appHistHelper.appHistorySObjList[0].CreatedDate ;
                
                
            }//end if
            else if(appHistHelper.appHistorySObjList.size()>1 && appHistHelper.appHistorySObjList[1].StepStatus == 'Approved'){
                isApproved = true ;
                approvedName = appHistHelper.appHistorySObjList[1].Actor.Name ;
                approvedDatetime = appHistHelper.appHistorySObjList[1].CreatedDate ;            
            }//end else if
            else
                isApproved = false;
        }//end if
        
        if(payCurrent.ASI_MFM_Plan__c != null)
        {
            plan = [SELECT id,Name,ASI_MFM_Plan_Description__c,ASI_MFM_Fiscal_year__c,
                    Owner.Name FROM ASI_MFM_Plan__c WHERE Id =: payCurrent.ASI_MFM_Plan__c ];
        }//end if
        else
        {
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }//end else
        
        if(payCurrent.ASI_MFM_PO__c != null)
        {
            PO = [SELECT id,Name,ASI_MFM_Fiscal_year__c,ASI_MFM_Remarks__c,
                  Owner.Name FROM ASI_MFM_PO__c WHERE Id =: payCurrent.ASI_MFM_PO__c ];
        }//end if
        else
        {
            PO = new ASI_MFM_PO__c();
            PO.Name = '';
            PO.ASI_MFM_Remarks__c = '';
        }//end else
        
        //kammy start: 
        if(this.payCurrent !=null && this.payCurrent.Id !=null  && payCurrent.ASI_MFM_Payment_Amount__c!=null){
            
            if(payCurrent.ASI_MFM_Currency__c=='JPY'){
                AllTotalPaymentAmount = payCurrent.ASI_MFM_Payment_Amount__c + payCurrent.ASI_MFM_VAT_Adjustment__c;
                AllTotalPaymentAmountString = AllTotalPaymentAmount.format();
                
                
                //PaymentAmount=(payCurrent.ASI_MFM_Invoice_Amount__c/(1+payCurrent.ASI_MFM_VAT_Rate__c/100)).setScale(0, roundingMode.half_up);
                PaymentAmount=(payCurrent.ASI_MFM_Invoice_Amount__c/(1+payCurrent.ASI_MFM_VAT_Rate__c/100));
                TaxAmount=(AllTotalPaymentAmount*(payCurrent.ASI_MFM_VAT_Rate__c/100)).setScale(0, roundingMode.half_up);
                
                TaxAmountString = TaxAmount.format();
                
                InvoiceAmtString = payCurrent.ASI_MFM_Invoice_Amount__c.format();
            }else{
                
                AllTotalPaymentAmount = payCurrent.ASI_MFM_Payment_Amount__c + payCurrent.ASI_MFM_VAT_Adjustment__c;
                AllTotalPaymentAmountString = AllTotalPaymentAmount.format()+'.00';
                InvoiceAmtString = payCurrent.ASI_MFM_Invoice_Amount__c.format()+'.00';
                
                //PaymentAmount=(payCurrent.ASI_MFM_Invoice_Amount__c/(1+payCurrent.ASI_MFM_VAT_Rate__c/100));
                //TaxAmount=(PaymentAmount*(payCurrent.ASI_MFM_VAT_Rate__c/100)).setScale(0, roundingMode.half_up);
                
                PaymentAmount=(payCurrent.ASI_MFM_Invoice_Amount__c/(1+payCurrent.ASI_MFM_VAT_Rate__c/100));
                TaxAmount=(AllTotalPaymentAmount*(payCurrent.ASI_MFM_VAT_Rate__c/100)).setScale(2, roundingMode.half_up);
                
                //TaxAmount = (payCurrent.ASI_MFM_Invoice_Amount__c/(1+payCurrent.ASI_MFM_VAT_Rate__c/100)).setScale(0, roundingMode.half_up);
                //AllTotalPaymentAmount*(payCurrent.ASI_MFM_VAT_Rate__c/100).setScale(0, roundingMode.half_up);
                TaxAmountString = TaxAmount.format()+'.00';
            }
            
        }  
        
        //kammy end.
        
        
        
        
        
        List<ASI_MFM_Payment_Line_Item__c> lineItemList = 
            [SELECT Name,ASI_MFM_PO__r.Name,ASI_MFM_PO_Line_Item__r.Name,ASI_MFM_PO_Receipt_Item__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,
             ASI_MFM_Complete_PO__c,ASI_MFM_Payee__r.Name,ASI_MFM_Payment__r.ASI_MFM_Tax_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.Name,
             ASI_MFM_Phase_Code__c,ASI_MFM_Payment_Amount__c,ASI_MFM_VAT_Adjustment__c,ASI_MFM_Payment_List_Item_Description__c, 
             ASI_MFM_Print_Sequence__c,ASI_MFM_AP_Code__r.Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Currency__c, 
             ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name
             FROM ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =: payID ORDER BY ASI_MFM_Print_Sequence__c,Name]; 
        Integer lineNum = 1;
        
        for(ASI_MFM_Payment_Line_Item__c payli : lineItemList)
        {
            if(payli.ASI_MFM_VAT_Adjustment__c == null){
                payli.ASI_MFM_VAT_Adjustment__c =0;
            }
            
            
            if(payli.ASI_MFM_Currency__c=='JPY'){
                
                if(payli.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Amount__c != null){
                    POamount= payli.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Amount__c.setScale(0, roundingMode.half_up);
                    POamountString =       POamount.format();                                                                
                }
                
                PaymentAmount1 = payli.ASI_MFM_Payment_Amount__c.setScale(0, roundingMode.half_up);
                PaymentAmount2 = PaymentAmount1.format();
                VAT_Adjustment = payli.ASI_MFM_VAT_Adjustment__c.setScale(0, roundingMode.half_up);
                
                
                TotalPaymentAmount = PaymentAmount1 + VAT_Adjustment;
                VAT_Adjustment2 = TotalPaymentAmount.format();
                
            }else{
                if(payli.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Amount__c != null){
                    POamountString = (payli.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO_Amount__c).format() + '.00'; 
                }
                
                PaymentAmount1 = payli.ASI_MFM_Payment_Amount__c ;
                PaymentAmount2 = PaymentAmount1.format() +'.00';
                VAT_Adjustment = payli.ASI_MFM_VAT_Adjustment__c;
                VAT_Adjustment2 = VAT_Adjustment.format() +'.00';
                
                TotalPaymentAmount = PaymentAmount1 + VAT_Adjustment;
                VAT_Adjustment2 = TotalPaymentAmount.format()+'.00';
            }
            
            
            
            payli.ASI_MFM_Print_Sequence__c = lineNum ;
            lineNum ++ ;
            lineItem.add(payli);
        }//end for: loop payment line item list
        return true;
    }//end method: init
}//end class: ASI_MFM_JP_Payment_PDF_PageController