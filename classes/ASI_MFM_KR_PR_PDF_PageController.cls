public  with sharing  class ASI_MFM_KR_PR_PDF_PageController
{
    public Id prId{set;get;}
    public ASI_MFM_Purchase_Request__c prCurrent{get;set;}
    public List<ASI_MFM_Purchase_Request_Line__c> lineItem{get;set;}
    public Boolean dummyVar { get { if (dummyVar != true){dummyVar = init();} return dummyVar; } set; }
    //public Map<String, interimData> allPRLItemMap{get;set;}{ allPRLItemMap = new Map<String, interimData>();}
    public Decimal TotalLineAmount{get;set;}{TotalLineAmount=0;}
    public Decimal TotalLineVAT{get;set;}{TotalLineVAT=0;}
    //public String TaxYesOrNo{get;set;}
    public Set<Id> prLineId = new Set<Id>(); //PR line id
    public Id planId; //plan id
    public ASI_MFM_Plan__c plan; //plan obj
   // public Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget> resultMap; //budget checking use
    public Map<Id,printOut> printsMap{get;set;} //print obj
    public Integer AttachNumber {get;set;}  {AttachNumber=0;}
    public String ShipToAddress{get;set;}
    
    /*
    public Class interimData
    {
         public ASI_MFM_Purchase_Request_Line__c line{get; set;}
         public Integer sequenceNo{get; set;}
    }
    *///end class: interimData
    
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
    }//end class
    
    public Class printOut
    {
        public ASI_MFM_Purchase_Request_Line__c lineItem{get; set;}
        //public ASI_MFM_KR_BudgetCheckingClass.BrandBudget bb{get;set;}
        public Integer numOfAtt{get;set;}
        public Decimal PlanAmount_PRCurrency{get;set;}
    }//end class: printOut
    
    public ASI_MFM_KR_PR_PDF_PageController(ApexPages.StandardController controller)
    {
        this.prCurrent = (ASI_MFM_Purchase_Request__c)controller.getRecord();
        //this.prlCurrent = (ASI_MFM_Purchase_Request_Line__c)controller.getRecord();
    }//end constrouctor: ASI_MFM_KR_PR_PDF_PageController
    
    public ASI_MFM_KR_PR_PDF_PageController(){}//end constrouctor: ASI_MFM_KR_PR_PDF_PageController
    
    public boolean init()
    {
        lineItem = new List<ASI_MFM_Purchase_Request_Line__c>();
        
        prCurrent = [SELECT Name,ASI_MFM_Raised_Date__c,ASI_MFM_Comment__c,
                     ASI_MFM_PR_Name__c,
                     ASI_MFM_Service_Item_POSM__c,ASI_MFM_Type__c,
                     ASI_MFM_PR_Date__c,
                     ASI_MFM_Exchange_Rate__c,
                     owner.name,
                     ASI_MFM_Ship_To__c,
                     ASI_MFM_Ship_To__r.name,
                     ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_1__c,
                     ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_2__c,
                     ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_3__c,
                     ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_4__c,
                     ASI_MFM_KR_Ship_to_Address__c
                     FROM ASI_MFM_Purchase_Request__c
                     WHERE Id =:prId];
        AttachNumber=[select count() from attachment where parentid=:prId];
        
        if(prCurrent.ASI_MFM_KR_Ship_to_Address__c != null){
            ShipToAddress=prCurrent.ASI_MFM_KR_Ship_to_Address__c;
        }
        if(prCurrent.ASI_MFM_KR_Ship_to_Address__c == null){
            if(prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_1__c  != null){
                ShipToAddress = prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_1__c;
            }
            
            if(prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_2__c != null){
                ShipToAddress += prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_2__c ;
            }
            
            if(prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_3__c !=null){
                ShipToAddress += prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_3__c;
            }
            
            if(prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_4__c !=null){
                ShipToAddress += prCurrent.ASI_MFM_Ship_To__r.ASI_MFM_Address_Line_4__c ;
            }
        }
        
        List<ASI_MFM_Purchase_Request_Line__c> lineItemList 
            = [SELECT Id, Name,
               ASI_MFM_Plan_Line_Item__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c,
               ASI_MFM_Description__c,ASI_MFM_Estimated_PR_budget__c,
               ASI_MFM_Quantity__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.Name,
               ASI_MFM_Tax_Code__r.Name,
               ASI_MFM_UOM__c,
               ASI_MFM_Basic_POSM__c,
               ASI_MFM_Delivery_Date__c,
               ASI_MFM_Sub_ledger__c,
               ASI_MFM_KR_Subledger__r.Name,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c,
               ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,
               ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name
               FROM ASI_MFM_Purchase_Request_Line__c
               WHERE ASI_MFM_Purchase_Request__r.Id =: prId]; 
        
        printsMap = new Map<Id,printOut>();
        for(ASI_MFM_Purchase_Request_Line__c prli : lineItemList)
        {
            prLineId.add(prli.Id); //store pr line id
            planId = prli.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__c; //get plan id
            printOut pri = new printOut(); //new print out obj
            pri.PlanAmount_PRCurrency = prli.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c /prCurrent.ASI_MFM_Exchange_Rate__c;
            pri.numOfAtt = 0; //temp att num
            pri.lineItem = prli; //store pr line into print out obj
            printsMap.put(prli.Id,pri); //put print out into map
            if(prli.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c!=null)
            {
                TotalLineAmount += prli.ASI_MFM_Estimated_PR_budget__c;
               /* if(prli.ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c!=null)
                {
                    TotalLineVAT += prli.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c*prli.ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c/100;
                }//end if
                
                if(prli.ASI_MFM_Tax_Code__r.name !='' & prli.ASI_MFM_Tax_Code__r.name != 'null')
                {
                    TaxYesOrNo = 'Y';
                }//end if
                else
                {
                    TaxYesOrNo = 'N';
                }//end else*/
            }//end if
            lineItem.add(prli);
        }//end for
        
        /*
        if(planId !=null)
        {
        	plan = [SELECT Id FROM ASI_MFM_Plan__c WHERE Id =:planId];
        	ASI_MFM_KR_BudgetCheckingClass bcc = new ASI_MFM_KR_BudgetCheckingClass();
            bcc.GetBudget(plan);
        	resultMap = new Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget>();
        	resultMap = bcc.getResult();
        }//end if
        else
            resultMap = new Map<String,ASI_MFM_KR_BudgetCheckingClass.BrandBudget>();
        */
        List<Attachment> attList = new List<Attachment>([SELECT Id, parentId FROM Attachment WHERE parentId IN: prLineId]);
        Map<Id, Integer> attMap = new Map<Id, Integer>();
        for(Attachment att: attList)
        {
            if(!attMap.containsKey(att.parentId))
                attMap.put(att.parentId, 1);
            else
                attMap.put(att.parentId, attMap.get(att.parentId) + 1);
        }//end for
        //-------------------------------------------------------------------------------------------------------------//
        for(ASI_MFM_Purchase_Request_Line__c prLine : lineItemList)
        {
            printOut pri = new printOut();
            
            pri = printsMap.get(prLine.Id);
            if(attMap.containsKey(prLine.Id))
                pri.numOfAtt = attMap.get(prLine.Id);
            /*if(!resultMap.isEmpty()
               &&resultMap.containsKey(''+prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c
                                     +prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c
                                     +prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c))
                pri.bb = resultMap.get(''+prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c
                                       +prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Budget_Type__c
                                       +prLine.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c);
            printsMap.put(prLine.Id,pri);*/
        }//end for
        //-------------------------------------------------------------------------------------------------------------//*/
        return true;
    }//end method: init
    
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && prId != null)
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
                                           WHERE TargetObjectId = :prId
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList)
            {
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    actoerIdSet.add(his.OriginalActorId);
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
                            
                        detail.title = userMap.get(his.OriginalActorId).title;
                        detail.history = his;
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails
}//end class: ASI_MFM_KR_PR_PDF_PageController