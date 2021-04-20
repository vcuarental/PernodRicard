public with sharing class ASI_MFM_KR_Payment_PDF_PageController {
    public id paymentID {set;get;}
    public string brandCode {set;get;}{brandCode='';}
    public string custCode {set;get;}{custCode='';}
    public string subledger {set;get;}{subledger='';}
    public string POnumber {set;get;}{POnumber='';}
    public decimal VAT {set;get;}{VAT=0;}
    public ASI_MFM_Payment__c paymentCurrent{get;set;}
    //public ASI_eForm_HR_MDM__c mdmDetails{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> paymentLineList{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> payeeList{get;set;}
    public List<List<ASI_MFM_Payment_Line_Item__c>> payment{get;set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
    }//end class
    
    public ASI_MFM_KR_Payment_PDF_PageController(){}
    
    public ASI_MFM_KR_Payment_PDF_PageController(ApexPages.StandardController controller) {
            this.paymentCurrent = (ASI_MFM_Payment__c)controller.getRecord();
            //this.mdmDetails = (ASI_eForm_HR_MDM__c)controller.getRecord();
    }  
    
    public boolean init(){
        paymentCurrent = [select Name, Owner.Name, ASI_MFM_Payment_Date__c,ASI_MFM_KR_VAT_Amount__c, ASI_MFM_Currency__c, ASI_MFM_Supplier_Name__r.ASI_KOR_Wholesaler_Bank_Account_Num__c,ASI_MFM_Remarks__c,ASI_MFM_Supplier_Name__r.ASI_KOR_Wholesaler_Bank__c,
                          ASI_MFM_One_Off_Payee__c, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Supplier_Name__r.Bank__c, ASI_MFM_Payment_Amount__c,CreatedDate, ASI_MFM_Payment_Type__c,ASI_MFM_VAT_Amount__c,
                          ASI_MFM_AP_Code__C,ASI_MFM_Supplier_Name__c,ASI_MFM_Promotion_Code__c ,ASI_CRM_Customer_Code__c ,ASI_MFM_PO_Number__c, owner.UserRole.Name, ASI_MFM_Invoice_Date__c , Owner.id,
                          ASI_MFM_Supplier_Name__r.Bank__r.name, ASI_MFM_Supplier_Name__r.Bank_number__c, ASI_MFM_A_P_Type__c , ASI_MFM_Exchange_Rate__c, ASI_MFM_Company_Code__c,ASI_MFM_Pre_payment__c,ASI_MFM_Venue_Loan_Payment__c,
                          ASI_MFM_Payment_Amount_in_Base_Currency__c,ASI_MFM_KR_TotalPayAmtIncludeVAT__c, ASI_MFM_Payment_Term__c, ASI_MFM_Tax_Code__r.Name, ASI_MFM_Tax_Registration_Number__c 
                          from ASI_MFM_Payment__c where id = :paymentID];//From ASI_MFM_Payment__c  
        
  
        
        
        /*
        string commisionCodeFromOwner;
        commisionCodeFromOwner = [select ASI_KOR_Commission_Code__c from user where id =: paymentCurrent.Owner.id].ASI_KOR_Commission_Code__c;
        
        mdmDetails = [select ASI_eForm_Employee_Bank_Name__c,ASI_eForm_Employee_Bank_Account_Code__c from ASI_eForm_HR_MDM__c where  Name =: commisionCodeFromOwner];   
        
			*/        
        
        paymentLineList =[SELECT Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__r.ASI_KOR_Brand_Code__c, 
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Code__c, 
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.ASI_CRM_CustomerCode__c, //customer code
                          ASI_MFM_Payee__r.Name, 
                          ASI_MFM_Invoice_Number__c, //invoice number
                          ASI_MFM_Invoice_Date__c, //invoice date
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, 
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,
                          ASI_MFM_Payment_List_Item_Description__c, 
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,  
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, 
                          ASI_MFM_Payment_Amount__c,
                          ASI_MFM_Payment_Amount_Distributor__c,  
                          ASI_MFM_Payment__r.ASI_MFM_Company_Code__c,
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c, //AP type
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, //brand code
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c,
                          ASI_MFM_KR_subLedger__c,
                          ASI_MFM_Tax_Confirmed_Cost__c, 
                          ASI_MFM_KR_subLedger__r.name,
                          ASI_MFM_Tax__c,
                          ASI_MFM_Amount_with_Tax__c,
                          ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Purchase_Request__r.ASI_MFM_KR_companyCode__c, //company code
                          ASI_MFM_PO__r.ASI_MFM_Plan__r.Name, //Promoton Code
                          ASI_MFM_PO__r.Name, //PO number
                          ASI_MFM_AP_Remark__c,
                          ASI_MFM_Payee__r.ASI_KOR_Wholesaler_Bank__c, //20160601, Leo@Elufa
                          ASI_MFM_Payee__r.ASI_KOR_Wholesaler_Bank_Account_Num__c //20160601, Leo@Elufa
            from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by Name];// From ASI_MFM_Payment_Line_Item__c            
       
        payeeList =[select ASI_MFM_Payee__r.Name from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by ASI_MFM_Payee__c]; // Payee only
         
        
        for (ASI_MFM_Payment_Line_Item__c paymentLT : paymentLineList){
            brandCode += paymentLT.ASI_MFM_PO_Line_Item__r.ASI_MFM_Product_Item__r.ASI_KOR_Brand_Code__c+'/';
            custCode += paymentLT.ASI_MFM_PO_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.ASI_CRM_CustomerCode__c+'/';
            POnumber +=paymentLT.ASI_MFM_PO__r.name+'/';
            if(paymentLT.ASI_MFM_KR_subLedger__r.name !=null){
           		subledger +=paymentLT.ASI_MFM_KR_subLedger__r.name+'/'; 
            }
            if(paymentLT.ASI_MFM_Amount_with_Tax__c != null){
            	//VAT += paymentLT.ASI_MFM_Amount_with_Tax__c;
            	//VAT += (paymentLT.ASI_MFM_Amount_with_Tax__c - paymentLT.ASI_MFM_Payment_Amount__c);
            	
            	
            	
            	if(paymentCurrent.ASI_MFM_Venue_Loan_Payment__c == true){
            	    
            	    VAT = 0;
            	}
            	else{
            	        decimal MaxTaxRate = 0.0;
            	        
            	        if(paymentLT.ASI_MFM_Tax__c != null && paymentLT.ASI_MFM_Tax__c != 0){
            	            if(paymentLT.ASI_MFM_Tax__c > MaxTaxRate){
                    	        MaxTaxRate =  paymentLT.ASI_MFM_Tax__c;
                    	    	//VAT += (paymentLT.ASI_MFM_Tax_Confirmed_Cost__c - paymentLT.ASI_MFM_Payment_Amount__c); 
                    	    	VAT = paymentCurrent.ASI_MFM_Payment_Amount__c*(MaxTaxRate/100);
            	            }
            	        }
            	}
            } 
            
            
          
        }
            
            
            
        Set<String> myset = new Set<String>();
         List<String> result  = new List<String>();
         for (ASI_MFM_Payment_Line_Item__c pe :payeeList){           
           myset.add(pe.ASI_MFM_Payee__r.Name);  
         }   
        result.addAll(myset);
        System.debug('Payee result ' + result);
         for (String r: result){
             Double subtotal = 0; 
             for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                 if (r == p.ASI_MFM_Payee__r.Name){
                     subtotal += p.ASI_MFM_Payment_Amount__c;
                 }
             }
             for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                 if (r == p.ASI_MFM_Payee__r.Name){
                     p.ASI_MFM_Payment_Amount_Distributor__c = subtotal;
                 }
             }
         }
         
        List<List<ASI_MFM_Payment_Line_Item__c>> tmplist = new List<List<ASI_MFM_Payment_Line_Item__c>>();
         for (String r: result){
             List<ASI_MFM_Payment_Line_Item__c> subList = new List<ASI_MFM_Payment_Line_Item__c>();
             for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                 if (r == p.ASI_MFM_Payee__r.Name){             
                    subList.add(p);
                 }
             }
             tmplist.add(subList);
         }
         payment = tmplist;
         brandCode = brandCode.removeEnd('/');
        custCode = custCode.removeEnd('/');
        POnumber = POnumber.removeEnd('/');
         return true;        
    }
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && paymentID != null)
        {
            List<ProcessInstance> pList = [SELECT Id, 
                                           (SELECT Id,
                                            CreatedDate,
                                            StepStatus,
                                            Comments,
                                            ActorId,
                                            Actor.Name,
                                            OriginalActorId,
                                            OriginalActor.Name
                                            FROM StepsAndWorkitems
                                            ORDER BY CreatedDate DESC,
                                            StepStatus DESC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :paymentID
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList)
            {
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    actoerIdSet.add(his.ActorId);
                }//end for
            }//end for
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList)
            {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 
                   &&(p.StepsAndWorkitems[0].StepStatus == 'Approved'
                      ||p.StepsAndWorkitems[0].StepStatus == 'Rejected'))
                {
                    byPassPending = true;
                }//end if
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    if(his.StepStatus != 'Reassigned'
                       && his.StepStatus != 'NoResponse'
                       &&!(byPassPending && his.StepStatus == 'Pending'))
                    {
                        approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')
                            detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started')
                            detail.status = 'Submitted';
                        else
                            detail.status = his.StepStatus;
                            
                        detail.title = userMap.get(his.ActorId).title;
                        detail.history = his;
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails
}