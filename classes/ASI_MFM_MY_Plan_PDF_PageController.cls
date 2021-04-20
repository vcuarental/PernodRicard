public class ASI_MFM_MY_Plan_PDF_PageController {
    private final ASI_MFM_Plan__c Plan;
    public List<ASI_MFM_Plan_Line_Item__c> costEstList{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> lineItemList{get;set;}
    public String verifiedBy{get;set;}
    public decimal costEstTotal{get;set;}
    public ASI_MFM_Plan__c planTemp{get;set;}
    
    public ASI_MFM_MY_Plan_PDF_PageController(ApexPages.StandardController stdController){ 
        
        this.Plan = (ASI_MFM_Plan__c)stdController.getRecord();
        //Cost Estimate List
        costEstList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        List<ASI_MFM_Plan_Line_Item__c> costEstListTemp = [select 
        ASI_MFM_List_Item_Description__c,
        ASI_MFM_Quantity__c, ASI_MFM_Unit_Cost__c,
        ASI_MFM_A_C_Code__r.name,
        ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,
        ASI_MFM_Customer_Name__r.ASI_MFM_Customer_Supplier_Number__c,
        ASI_MFM_Customer_Name__r.Name,
        ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,
        ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c
        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: this.Plan.id
        order by ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c
        ];
        
        
        costEstTotal = 0;
        for(ASI_MFM_Plan_Line_Item__c cost: costEstListTemp){
            if(cost.ASI_MFM_Total_Cost__c != null){ 
                costEstTotal += cost.ASI_MFM_Total_Cost__c;
            }
            if(cost.ASI_MFM_Quantity__c == null){
                cost.ASI_MFM_Quantity__c = 0;
            }
            if(cost.ASI_MFM_Total_Cost__c == null){
                cost.ASI_MFM_Total_Cost__c = 0;
            }
            costEstList.add(cost);
        }
    
//Added by Wilken on 2013094 for Plan PDF        
        lineItemList = [select 
        ASI_MFM_List_Item_Description__c,
        ASI_MFM_Quantity__c, ASI_MFM_Unit_Cost__c,
        ASI_MFM_A_C_Code__r.name,
        ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,
        ASI_MFM_Customer_Name__r.ASI_MFM_Customer_Supplier_Number__c,
        ASI_MFM_Customer_Name__r.Name,
        ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,
        ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,
        ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c 
        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: this.Plan.id
        order by ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c
        ];
    }
    
    //20160509, Leo@Elufa
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
    }//end class
    
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && this.Plan.id != null)
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
                                            ORDER BY CreatedDate ASC,
                                            StepStatus ASC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :this.Plan.id
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
                            detail.status = 'Started By:';
                        else if(his.StepStatus == 'Approved')
                            detail.status = 'Approved By:';
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
    //20160509, Leo@Elufa
}