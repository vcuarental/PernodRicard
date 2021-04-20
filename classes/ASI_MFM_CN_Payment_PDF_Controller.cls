public with sharing class ASI_MFM_CN_Payment_PDF_Controller {
//Versino: 0.0.11
//Modified at: 2013/7/17
//1.Do not handle the multiple plan situation
//2.Change the value of vat finished
//3.Fix the looping of different plan
//4.Fix the null value problem of PoAmt line 113
//5.Fix the PaymentTotalAmount at the part under remark
//6.Change the percentage to non-calculated value
//7.Fix the missing sub_brand
    public ASI_MFM_Payment__c Payment {get;set;}
    public List<SObject> PaymentLineItems {get;set;}    //for test Only
    public List<ASI_MFM_Payment_Line_Item__c> PaymentList_start{get;set;}
    public List<ASI_MFM_PO__c> PoList{get;set;} 
    public List<ASI_MFM_Plan__c> PlanList{get;set;} 
    public List<Payment_WrapperClass> WrapList{get;set;}
    public List<PaymentLineItem_WrapperClass>WrapItemList{get;set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public Set<Id> PayeeNameSet;
    
    public decimal wpSubTotal{get;set;}
    public decimal subTotal{get;set;}
    public decimal vatPercentage{get;set;}
    public decimal wtPercentage{get;set;}
    public decimal insurPercentage{get;set;}
    public decimal total{get;set;}
    public decimal totalTax{get;set;}
    public decimal totalPayment{get;set;}
    
    public boolean isOnePlan;
    public boolean isShowVat{get;set;}
    public boolean isShowWt{get;set;}
    public boolean isShowInsur{get;set;}
    
    public string planNumber{get;set;}
    public string planStatus{get;set;}
    public decimal totalPlanAmount{get;set;}
    public decimal totalActualAmount{get;set;}
    public decimal totalPOAmount{get;set;}
    
    public string poStatus{get;set;}
    public string payeeNameConcat{get;set;}   
   
    public string labelPlanStatus{get;set;}
    public string labeltotalPlanAmount{get;set;}
    public string labeltotalActualAmount{get;set;}
    public string labeltotalPOAmount{get;set;}
    public string labelPOStatus{get;set;}
    
    //****** approval history: variables/constants - by leo (start) ******
    public List<ProcessInstanceHistory> processInstList {get;set;}
    public List<ASI_ApprHist_LineItem > appHistList {get;set;}
    public ASI_ApprHist_LineItem appHistSubmitter {get;set;}
    public boolean hasHistroy {get;set;}
    private final String object_ApiName = 'ASI_MFM_Payment__c';
    //****** approval history: variables/constants - by leo (end) ******
    
    public ASI_MFM_CN_Payment_PDF_Controller(){ 
    }
    
    /*
    public boolean init(){
        //this.Payment = (ASI_MFM_Payment__c)stdController.getRecord();
        List<ASI_MFM_Payment__c> LPayment = [SELECT ASI_MFM_Approved__c, ASI_MFM_BU__c, ASI_MFM_Bank_Details__c, CreatedById, 
            CreatedDate, ASI_MFM_Currency__c, CurrencyIsoCode, IsDeleted, ASI_MFM_ETL__c, 
            ASI_MFM_Exchange_Rate__c, ASI_MFM_Cashflow_Date__c, 
            ASI_MFM_G_L_Date__c, ASI_MFM_Insurance_Percentage__c, ASI_MFM_Insurance_Amount__c, ASI_MFM_Invoice_Date__c,
             ASI_MFM_Invoice_Number__c, ASI_MFM_Is_Retainer_Agency__c, LastActivityDate, LastModifiedById,
              LastModifiedDate, ASI_MFM_One_Off_Payee__c, OwnerId,
              ASI_MFM_Payment_Amount__c, ASI_MFM_Payment_External_ID__c, Name, ASI_MFM_Payment_Term__c, 
              ASI_MFM_Pre_payment__c, ASI_MFM_Prefix__c, Id, RecordTypeId, ASI_MFM_Remarks__c, ASI_MFM_Payment_Date__c, 
              ASI_MFM_SYS_Approver_7__c, ASI_MFM_SYS_Approver_8__c, ASI_MFM_SYS_Approver_9__c, 
              ASI_MFM_Status__c, 
              ASI_MFM_Supplier_Name__c, ASI_MFM_Sys_Local_Currency__c, ASI_MFM_Sys_Approver_1__c, 
              ASI_MFM_Sys_Approver_2__c, ASI_MFM_Sys_Approver_3__c, ASI_MFM_Sys_Approver_4__c, 
              ASI_MFM_Sys_Approver_5__c, ASI_MFM_Sys_Approver_6__c, ASI_MFM_Sys_Approver_Email_Address__c, 
              ASI_MFM_Sys_Reject_Comments__c, ASI_MFM_Sys_Rejected__c, ASI_MFM_Sys_Submitter_Email_Address__c,
               ASI_MFM_Sys_Sync_Time__c, SystemModstamp, ASI_MFM_Tax_Code__c, ASI_MFM_Urgent__c, 
               ASI_MFM_Urgent_Text__c, ASI_MFM_VAT_Amount__c, ASI_MFM_VAT_Rate__c, ASI_MFM_VAT_Percentage__c, 
               ASI_MFM_WT_Amount__c, ASI_MFM_WT_Percentage__c, ASI_MFM_Web_Service_Error_Message__c, 
               ASI_MFM_Web_Service_Failed__c, Owner.Name, ASI_MFM_Supplier_Name__r.Name,
               ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c,
               ASI_MFM_Budget_Owner__r.name,
               ASI_MFM_CN_Finance__c              
               FROM ASI_MFM_Payment__c where id = :paymentid limit 1];
        if(LPayment != null && LPayment.size()>0){
        this.payment = LPayment[0];
        ASI_MFM_Payment__c Payment2 = [select ASI_MFM_VAT_Percentage__c,ASI_MFM_One_Off_Payee__c
        , ASI_MFM_Supplier_Name__r.Name,ASI_MFM_WT_Percentage__c
        , ASI_MFM_Insurance_Percentage__c,ASI_MFM_VAT_Amount__c
        , ASI_MFM_WT_Amount__c, ASI_MFM_Insurance_Amount__c from ASI_MFM_Payment__c
        where id =: Payment.id
        ];
        
        //System.debug('Vat Percentage ' + vatPercentage);
        //try{
        //System.debug('Vat Percentage string' + Payment2.ASI_MFM_VAT_Percentage__c);
        //}
        //catch(exception e){
        //  e.getMessage();
        //}
        
        System.debug('lga');
        isShowVat = true;
        isShowWt = true;
        isShowInsur = true;
        labelPlanStatus = 'Plan Status:';
        labeltotalPlanAmount = 'Total Plan Amount:';
        labeltotalActualAmount = 'Total Actual Amount';
        labeltotalPOAmount = 'Total PO amount';
        labelPOStatus = 'PO status';
        payeeNameConcat = null;
        
        if(Payment2.ASI_MFM_Supplier_Name__r.Name != null ){
            payeeNameConcat = Payment2.ASI_MFM_Supplier_Name__r.Name;
            
            if(Payment2.ASI_MFM_One_Off_Payee__c != null){
                payeeNameConcat = payeeNameConcat + ', ' + Payment2.ASI_MFM_One_Off_Payee__c;
            }
        }
        else{
            if(Payment2.ASI_MFM_One_Off_Payee__c != null){
                payeeNameConcat = Payment2.ASI_MFM_One_Off_Payee__c;
            }
        }
        
        //Percentage 
        if(Payment2.ASI_MFM_Insurance_Percentage__c == null){
            insurPercentage = 0;
            isShowInsur = false;
        }
        else{
            Integer startIndex_insur = Payment2.ASI_MFM_Insurance_Percentage__c.indexOf('(',0) + 1;
            Integer endIndex_insur = Payment2.ASI_MFM_Insurance_Percentage__c.indexOf('%',0);
            insurPercentage = decimal.valueOf(Payment2.ASI_MFM_Insurance_Percentage__c.subString(startIndex_insur,endIndex_insur));
            //System.debug('vatPercentage967 ' + vatPercentage);
            //vatPercentage = 9;
        }  
        
        
        if(Payment2.ASI_MFM_WT_Percentage__c == null){
            wtPercentage = 0;
            isShowWt = false;
        }
        else{
            Integer startIndex_wt = Payment2.ASI_MFM_WT_Percentage__c.indexOf('(',0) + 1;
            Integer endIndex_wt = Payment2.ASI_MFM_WT_Percentage__c.indexOf('%',0);
            wtPercentage = decimal.valueOf(Payment2.ASI_MFM_WT_Percentage__c.subString(startIndex_wt,endIndex_wt));
            //System.debug('vatPercentage967 ' + vatPercentage);
            //vatPercentage = 9;
        }        
        
        if(Payment2.ASI_MFM_VAT_Percentage__c == null){
            vatPercentage = 0;
            isShowVat = false;
        }
        else{
            Integer startIndex = Payment2.ASI_MFM_VAT_Percentage__c.indexOf('(',0) + 1;
            Integer endIndex = Payment2.ASI_MFM_VAT_Percentage__c.indexOf('%',0);
            vatPercentage = decimal.valueOf(Payment2.ASI_MFM_VAT_Percentage__c.subString(startIndex,endIndex));
            System.debug('vatPercentage967 ' + vatPercentage);
            //vatPercentage = 9;
        }
        
        
        //isOnePlan = true;
        wpSubTotal = 0;
        subTotal = 0;
        total = 0;
        totalTax = 0;
        totalPayment = 0;
        totalActualAmount = 0;
        totalPoAmount = 0;
        
        
        
        PaymentList_start =[
        select 
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.id,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.Name,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c,
        ASI_MFM_Payment_Amount__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Status__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,   //Total Plan Amount    
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.id,
        ASI_MFM_SKU_Code__c,
        ASI_MFM_PO__r.name,
        ASI_MFM_Invoice_Number__c,
        ASI_MFM_Payee__c,
        ASI_MFM_Payee__r.Name,
        ASI_MFM_Invoice_Date__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Remarks__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_Currency__c,
        ASI_MFM_Payment_List_Item_Description__c,
        ASI_MFM_Po_Line_Item__r.ASI_MFM_PO_Remark__c,
        ASI_MFM_Po_Line_Item__r.ASI_MFM_Amount__c,
        ASI_MFM_Tax_Amount__c, 
        ASI_MFM_Payment_Amount_Net_of_Tax__c
        from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =: this.Payment.id
        ];
        
        
        //Instantiate the value of payment line item
        if(PaymentList_start.size() != 0){   //bracket 9
            ASI_MFM_Payment_Line_Item__c payLineItem = PaymentList_start[0]; 
            
            
            //PlanSetId (Used to save the number of plan)
            Set<Id> planId = new Set<Id>();
            
            //Return the subTotal
            for(ASI_MFM_Payment_Line_Item__c eachPay:PaymentList_start){
                
                //Add the id to planId
                planId.add(eachPay.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.id);
                
                if(eachPay.ASI_MFM_Payment_Amount__c != null){
                    subTotal += eachPay.ASI_MFM_Payment_Amount__c;
                }
                if(eachPay.ASI_MFM_Tax_Amount__c != null){
                    totalTax += eachPay.ASI_MFM_Tax_Amount__c;
                }
                if(eachPay.ASI_MFM_Payment_Amount_Net_of_Tax__c != null){
                    totalPayment += eachPay.ASI_MFM_Payment_Amount_Net_of_Tax__c;
                }
                //Set the PoAmt = 0 for null value
                if(eachPay.ASI_MFM_Payment_Amount__c == null){
                    eachPay.ASI_MFM_Payment_Amount__c = 0;
                }
            }
            
           
            //Retrun total
            total = subTotal;
            if(isShowVat && payment2.ASI_MFM_VAT_Amount__c != null){total -= payment2.ASI_MFM_VAT_Amount__c;}
            if(isShowWt && payment2.ASI_MFM_WT_Amount__c != null){total -= payment2.ASI_MFM_WT_Amount__c;}
            if(isShowInsur && payment2.ASI_MFM_Insurance_Amount__c != null){total -= payment2.ASI_MFM_Insurance_Amount__c;}

            //PaymentItemList GroupBy Payee            
            PayeeNameSet = new Set<Id>();
            WrapItemList = new List<PaymentLineItem_WrapperClass>();
            for(ASI_MFM_Payment_Line_Item__c payline12: PaymentList_start){
                PayeeNameSet.add(payline12.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.id);
            } 
            
            for(Id payeeName : PayeeNameSet){
                PaymentLineItem_WrapperClass wp = new PaymentLineItem_WrapperClass(payeeName);
                for(ASI_MFM_Payment_Line_Item__c payline13: PaymentList_start){
                    if(payline13.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.id == payeeName){
                        if(payline13.ASI_MFM_Payment_Amount__c != null){
                            wpSubTotal += payline13.ASI_MFM_Payment_Amount__c;
                        }
                        wp.paylineList_wrap.add(payline13); 
                    }
                    
                }
                wp.subTotal = wpSubTotal;
                wrapItemList.add(wp);
                wpSubTotal = 0;
            }
            
            
            //Many Plan Situation
            //Retrieve all the plans from the payment line item list
            wrapList = new List<Payment_WrapperClass>();
            
            planList = new List<ASI_MFM_Plan__c>();
            planList = [select id,name,ASI_MFM_Status__c,ASI_MFM_Actual_Amount__c,
            ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where id in : planId];
            
            //System.debug('plan List size ' + planList.size());
            
            for(ASI_MFM_Plan__c plan1 : planList){
                //System.debug('lgv plan name' + plan1.Name);
                
                Payment_WrapperClass wc = new Payment_WrapperClass(plan1);
                
                for(ASI_MFM_Payment_Line_Item__c payline7: PaymentList_start){
                    if(payline7.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.id == plan1.id){
                        if(payline7.ASI_MFM_Payment_Amount__c != null){
                            totalActualAmount += payline7.ASI_MFM_Payment_Amount__c; 
                        }
                        //wc.paylineList.add(payline7);
                    }
                }
                
                //if(paylineList.size() != 0){
                //    wc.planline_firstItem = wc.paylineList[0];
                //    wc.paylineList.remove(0);
                //}
                
                wc.totalActualAmount = totalActualAmount;
                wrapList.add(wc);
                totalActualAmount = 0;     //Initialize the paymentActualAmount to 0
            }
            


            
        }//bracket 9    
        }
        
        
        //****** generate approval history - by leo (start) ******
        ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper (object_ApiName , payment.Id );
        
        if (appHistHelper.appHistorySObjList != null) {
            this.processInstList = appHistHelper.appHistorySObjList;
            hasHistroy=true;
            
            appHistList  = new List<ASI_ApprHist_LineItem >();
            Boolean isExit = false;
            
            for (ProcessInstanceHistory li : this.processInstList ) {
                  //---- check is included in the approval history list ----
                  if(li.StepStatus != 'Approved')
                  {                      
                    if(li.StepStatus == 'Rejected')
                    {
                        if(li.OriginalActor.Id == this.payment.ASI_MFM_CN_Finance__c)
                            isExit = false;
                        else
                            isExit = true;
                    }
                    else
                    {
                        isExit = true;
                    }
                  }
                  else
                  {

                    addToApprHistList(li);

                    if(this.payment.ASI_MFM_Sys_Approver_1__c != null)
                    {
                        if(li.OriginalActor.Id == this.payment.ASI_MFM_Sys_Approver_1__c)
                            isExit = true;
                    }
                  }

                  if(isExit) break;
                  
            }
             
            if (appHistList.size() <=0)
                hasHistroy=false;
        }
        else
        {
            hasHistroy=false;
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'my error msg');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No Approval History in this record'));
        }
        // ****** generate approval history - by leo (end) ******
        
        
        return true;   
                       
    }  */ 
    
    public boolean init(){
        isShowVat = true;
        isShowWt = true;
        isShowInsur = true;
        labelPlanStatus = 'Plan Status:';
        labeltotalPlanAmount = 'Total Plan Amount:';
        labeltotalActualAmount = 'Total Actual Amount';
        labeltotalPOAmount = 'Total PO amount';
        labelPOStatus = 'PO status';
        payeeNameConcat = null;
        
        if(Payment.ASI_MFM_Supplier_Name__r.Name != null ){
            payeeNameConcat = Payment.ASI_MFM_Supplier_Name__r.Name;
            
            if(Payment.ASI_MFM_One_Off_Payee__c != null){
                payeeNameConcat = payeeNameConcat + ', ' + Payment.ASI_MFM_One_Off_Payee__c;
            }
        }
        else{
            if(Payment.ASI_MFM_One_Off_Payee__c != null){
                payeeNameConcat = Payment.ASI_MFM_One_Off_Payee__c;
            }
        }
        
        //Percentage 
        if(Payment.ASI_MFM_Insurance_Percentage__c == null){
            insurPercentage = 0;
            isShowInsur = false;
        }
        else{
            Integer startIndex_insur = Payment.ASI_MFM_Insurance_Percentage__c.indexOf('(',0) + 1;
            Integer endIndex_insur = Payment.ASI_MFM_Insurance_Percentage__c.indexOf('%',0);
            insurPercentage = decimal.valueOf(Payment.ASI_MFM_Insurance_Percentage__c.subString(startIndex_insur,endIndex_insur));
            //System.debug('vatPercentage967 ' + vatPercentage);
            //vatPercentage = 9;
        }  
        
        
        if(Payment.ASI_MFM_WT_Percentage__c == null){
            wtPercentage = 0;
            isShowWt = false;
        }
        else{
            Integer startIndex_wt = Payment.ASI_MFM_WT_Percentage__c.indexOf('(',0) + 1;
            Integer endIndex_wt = Payment.ASI_MFM_WT_Percentage__c.indexOf('%',0);
            wtPercentage = decimal.valueOf(Payment.ASI_MFM_WT_Percentage__c.subString(startIndex_wt,endIndex_wt));
            //System.debug('vatPercentage967 ' + vatPercentage);
            //vatPercentage = 9;
        }        
        
        if(Payment.ASI_MFM_VAT_Percentage__c == null){
            vatPercentage = 0;
            isShowVat = false;
        }
        else{
            Integer startIndex = Payment.ASI_MFM_VAT_Percentage__c.indexOf('(',0) + 1;
            Integer endIndex = Payment.ASI_MFM_VAT_Percentage__c.indexOf('%',0);
            vatPercentage = decimal.valueOf(Payment.ASI_MFM_VAT_Percentage__c.subString(startIndex,endIndex));
            System.debug('vatPercentage967 ' + vatPercentage);
            //vatPercentage = 9;
        }
        
        
        //isOnePlan = true;
        wpSubTotal = 0;
        subTotal = 0;
        total = 0;
        totalTax = 0;
        totalPayment = 0;
        totalActualAmount = 0;
        totalPoAmount = 0;
        
        
        
        /*PaymentList_start =[
        select 
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_Type__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.id,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.Name,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c,
        ASI_MFM_Payment_Amount__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Status__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,   //Total Plan Amount    
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.id,
        ASI_MFM_SKU_Code__c,
        ASI_MFM_PO__r.name,
        ASI_MFM_Invoice_Number__c,
        ASI_MFM_Payee__c,
        ASI_MFM_Payee__r.Name,
        ASI_MFM_Invoice_Date__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Remarks__c,
        ASI_MFM_PO_Line_Item__r.ASI_MFM_Currency__c,
        ASI_MFM_Payment_List_Item_Description__c,
        ASI_MFM_Po_Line_Item__r.ASI_MFM_PO_Remark__c,
        ASI_MFM_Po_Line_Item__r.ASI_MFM_Amount__c,
        ASI_MFM_Tax_Amount__c, 
        ASI_MFM_Payment_Amount_Net_of_Tax__c
        from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =: this.Payment.id
        ];*/
        
        PaymentList_start = PaymentLineItems == null? Payment.Payment_Line_Items__r : PaymentLineItems;
        
        
        //Instantiate the value of payment line item
        if(PaymentList_start.size() != 0){   //bracket 9
            ASI_MFM_Payment_Line_Item__c payLineItem = PaymentList_start[0]; 
            
            
            //PlanSetId (Used to save the number of plan)
            Set<Id> planId = new Set<Id>();
            
            //Return the subTotal
            for(ASI_MFM_Payment_Line_Item__c eachPay:PaymentList_start){
                
                //Add the id to planId
                planId.add(eachPay.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.id);
                
                if(eachPay.ASI_MFM_Payment_Amount__c != null){
                    subTotal += eachPay.ASI_MFM_Payment_Amount__c;
                }
                if(eachPay.ASI_MFM_Tax_Amount__c != null){
                    totalTax += eachPay.ASI_MFM_Tax_Amount__c;
                }
                if(eachPay.ASI_MFM_Payment_Amount_Net_of_Tax__c != null){
                    totalPayment += eachPay.ASI_MFM_Payment_Amount_Net_of_Tax__c;
                }
                //Set the PoAmt = 0 for null value
                if(eachPay.ASI_MFM_Payment_Amount__c == null){
                    eachPay.ASI_MFM_Payment_Amount__c = 0;
                }
            }
            
           
            //Retrun total
            total = subTotal;
            if(isShowVat && payment.ASI_MFM_VAT_Amount__c != null){total -= payment.ASI_MFM_VAT_Amount__c;}
            if(isShowWt && payment.ASI_MFM_WT_Amount__c != null){total -= payment.ASI_MFM_WT_Amount__c;}
            if(isShowInsur && payment.ASI_MFM_Insurance_Amount__c != null){total -= payment.ASI_MFM_Insurance_Amount__c;}

            //PaymentItemList GroupBy Payee            
            PayeeNameSet = new Set<Id>();
            WrapItemList = new List<PaymentLineItem_WrapperClass>();
            for(ASI_MFM_Payment_Line_Item__c payline12: PaymentList_start){
                PayeeNameSet.add(payline12.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.id);
            } 
            
            for(Id payeeName : PayeeNameSet){
                PaymentLineItem_WrapperClass wp = new PaymentLineItem_WrapperClass(payeeName);
                for(ASI_MFM_Payment_Line_Item__c payline13: PaymentList_start){
                    if(payline13.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.id == payeeName){
                        if(payline13.ASI_MFM_Payment_Amount__c != null){
                            wpSubTotal += payline13.ASI_MFM_Payment_Amount__c;
                        }
                        wp.paylineList_wrap.add(payline13); 
                    }
                    
                }
                wp.subTotal = wpSubTotal;
                wrapItemList.add(wp);
                wpSubTotal = 0;
            }
            
            
            //Many Plan Situation
            //Retrieve all the plans from the payment line item list
            wrapList = new List<Payment_WrapperClass>();
            
            planList = new List<ASI_MFM_Plan__c>();
            planList = [select id,name,ASI_MFM_Status__c,ASI_MFM_Actual_Amount__c,
            ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where id in : planId];
            
            //System.debug('plan List size ' + planList.size());
            
            for(ASI_MFM_Plan__c plan1 : planList){
                //System.debug('lgv plan name' + plan1.Name);
                
                Payment_WrapperClass wc = new Payment_WrapperClass(plan1);
                
                for(ASI_MFM_Payment_Line_Item__c payline7: PaymentList_start){
                    if(payline7.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.id == plan1.id){
                        if(payline7.ASI_MFM_Payment_Amount__c != null){
                            totalActualAmount += payline7.ASI_MFM_Payment_Amount__c; 
                        }
                        //wc.paylineList.add(payline7);
                    }
                }
                /*
                if(paylineList.size() != 0){
                    wc.planline_firstItem = wc.paylineList[0];
                    wc.paylineList.remove(0);
                }
                */
                wc.totalActualAmount = totalActualAmount;
                wrapList.add(wc);
                totalActualAmount = 0;     //Initialize the paymentActualAmount to 0
            }
            


            
        }
        
        
        //****** generate approval history - by leo (start) ******
        ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper (object_ApiName , payment.Id );
        
        /*if (appHistHelper.appHistorySObjList != null) {
            this.processInstList = appHistHelper.appHistorySObjList;
            hasHistroy=true;
            
            appHistList  = new List<ASI_ApprHist_LineItem >();
            Boolean isExit = false;
            
            for (ProcessInstanceHistory li : this.processInstList ) {
                  //---- check is included in the approval history list ----
                  if(li.StepStatus != 'Approved')
                  {                      
                    if(li.StepStatus == 'Rejected')
                    {
                        if(li.OriginalActor.Id == this.payment.ASI_MFM_CN_Finance__c)
                            isExit = false;
                        else
                            isExit = true;
                    }
                    else
                    {
                        isExit = true;
                    }
                  }
                  else
                  {

                    addToApprHistList(li);

                    if(this.payment.ASI_MFM_Sys_Approver_1__c != null)
                    {
                        if(li.OriginalActor.Id == this.payment.ASI_MFM_Sys_Approver_1__c)
                            isExit = true;
                    }
                  }

                  if(isExit) break;
                  
            }
             
            if (appHistList.size() <=0)
                hasHistroy=false;
        }*/
         // Edited by Michael Yip (Introv) 15Sep2014 to include submitter and submit date
            appHistSubmitter = new ASI_ApprHist_LineItem();
            appHistSubmitter.oriActorName=this.payment.Owner.Name;
            appHistSubmitter.CreatedDateString = '';
            if(this.payment.CreatedDate != null)
            appHistSubmitter.CreatedDateString=this.payment.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
            if (appHistHelper.appHistorySObjList != null) {
                this.processInstList = appHistHelper.appHistorySObjList;
                hasHistroy=true;
                
                System.Debug('appHistHelper.appHistorySObjList: ' + appHistHelper.appHistorySObjList);
                
                appHistList  = new List<ASI_ApprHist_LineItem >();
                Boolean isExit = false;
                
                
                for (ProcessInstanceHistory li : this.processInstList ) {
                    //---- check is included in the approval history list ----
                    addToApprHistList(li); // Daniel WONG 20121212
                    System.Debug('ProcessInstanceHistory li: ' + li);
                    /*
                    if(li.StepStatus != 'Approved')
                    {                      
                        if(li.StepStatus == 'Rejected')
                        {
                            if(li.OriginalActor.Id == this.Payment.ASI_MFM_CN_Finance__c)
                                isExit = false;
                            else
                                isExit = true;
                            
                        }
                        else if(li.StepStatus == 'Started'){
                            addToSubmitter(li);
                            isExit = true;
                        }
                        else
                        {
                            isExit = true;
                        }
                    }
                    else
                    {
                        
                        addToApprHistList(li);
                        
                        if(this.Payment.ASI_MFM_Sys_Approver_1__c != null)
                        {
                            if(li.OriginalActor.Id == this.Payment.ASI_MFM_Sys_Approver_1__c)
                                isExit = true;
                        }
                    }
                    
                    if(isExit) break; */
                    
                }
                for (ProcessInstanceHistory li : this.processInstList ) {
                    if(li.StepStatus == 'Started'){
                            addToSubmitter(li);
                            break;
                    }
                }
                
                if (appHistList.size() <=0)
                    hasHistroy=false;
            }
        else
        {
            hasHistroy=false;
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'my error msg');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No Approval History in this record'));
        }
        //****** generate approval history - by leo (end) ******
        
        
        return true;   
                       
    }  
    
    public class PaymentLineItem_WrapperClass {
        public decimal subTotal{get;set;}
        public List<ASI_MFM_Payment_Line_Item__c> paylineList_wrap{get;set;}
        public string payeeName{get;set;}

        public PaymentLineItem_WrapperClass(String p)
        {   
            this.payeeName = p;
            this.subTotal = 0;
            this.paylineList_wrap = new List<ASI_MFM_Payment_Line_Item__c>();
    
        }   
    }
   
    
    //The bottom table
    public class Payment_WrapperClass {
        public ASI_MFM_Plan__c plan{get;set;}
        public ASI_MFM_PO__c poline_firstItem{get;set;}
        public List<ASI_MFM_Payment_Line_Item__c> paylineList{get;set;}
        public List<ASI_MFM_PO__c> PoList{get;set;} 
        public decimal totalPoAmount{get;set;}
        public decimal totalActualAmount{get;set;}      
        
        public Payment_WrapperClass(ASI_MFM_Plan__c p)
        {   
            totalPoAmount = 0;
            plan = p;
            //paylineList = new List<ASI_MFM_Payment_Line_Item__c>();
            poline_firstItem = new ASI_MFM_PO__c();
            PoList = new List<ASI_MFM_PO__c>();
            PoList = [select ASI_MFM_PO_Amount__c, Name,ASI_MFM_Remarks__c,CurrencyIsoCode,
            ASI_MFM_VAT__c,
            ASI_MFM_Status__c from ASI_MFM_PO__c where ASI_MFM_Plan__c =: plan.id];
            
            //Calculate the total PO Amt
            for(ASI_MFM_PO__c po1:PoList){      
                if(po1.ASI_MFM_PO_Amount__c != null){
                    totalPoAmount += po1.ASI_MFM_PO_Amount__c;
                }
            }
             if(POList.size()>0){
            poline_firstItem = PoList[0];
            PoList.remove(0);   }   
            ////////////////////

        }
    }
    
    //################################################################
        
    //****** generate approval history: functions - by leo (start) ******
    public static User getApprDetailInfo(String userId) {
        String queryStr = '';
        User appHistoryApprover = new User();
        queryStr = 'select id, name, title, department from user ';
        queryStr += ' where id =\'' +userId+ '\'';
        System.debug('ahh3' + queryStr);    
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
    }

    public class ASI_ApprHist_LineItem {
        public String id { get; set; }
        public String StepStatus{ get; set; }
        public String Comments{ get; set; }
        public DateTime CreatedDate{ get; set; }
        public String CreatedDateString{ get; set; }
        public String oriActorId { get; set; }
        public String oriActorName { get; set; }
        public String oriActorTitle { get; set; }
        public String oriActorDepartment { get; set; }
        public String actActorId { get; set; }
        public String actActorName { get; set; }
        public String actActorTitle { get; set; }
        public String actActorDepartment { get; set; }
      
    }
    
    private void addToApprHistList(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
      
        tempLi.oriActorId =  li.OriginalActor.Id;
        User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
        tempLi.oriActorName =  oriApprover .Name;
        tempLi.oriActorTitle =  oriApprover .Title;
      
        tempLi.actActorId =  li.Actor.Id;
        User actApprover = getApprDetailInfo(li.Actor.Id);
        tempLi.actActorName =  actApprover.Name;
        tempLi.actActorTitle =  actApprover.Title;
        tempLi.actActorDepartment = actApprover.Department;
        if (appHistList.size() <=0)
            appHistList.add(tempLi);
        else
            appHistList.add(0, tempLi);
    }
    
     // Added by Michael Yip (Introv) 15Sep2014 to include submitter and submit date
    private void addToSubmitter(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
      
        tempLi.oriActorId =  li.OriginalActor.Id;
        User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
        tempLi.oriActorName =  oriApprover .Name;
        tempLi.oriActorTitle =  oriApprover .Title;
      
        tempLi.actActorId =  li.Actor.Id;
        User actApprover = getApprDetailInfo(li.Actor.Id);
        tempLi.actActorName =  actApprover.Name;
        tempLi.actActorTitle =  actApprover.Title;
        tempLi.actActorDepartment = actApprover.Department;
        appHistSubmitter = tempLi; 
    }
    //****** generate approval history: functions - by leo (end) ******
}