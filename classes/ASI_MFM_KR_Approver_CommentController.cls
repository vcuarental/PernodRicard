public class ASI_MFM_KR_Approver_CommentController {
    
    
    public ASI_MFM_KR_Approver_CommentController(){ }
    public id currentHeaderId {set;get;}
      
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
        
        if (details.size() == 0 && 
            currentHeaderId != null)
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
                                            ORDER BY 
                                                CreatedDate DESC,
                                                StepStatus DESC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :currentHeaderId
                                           ORDER BY 
                                                CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            
            //system.assertEquals(pList,null);   //added by kammy for testing
            if(pList.size() > 0){
                for (ProcessInstance p:pList)
                {
                    //system.assertEquals(pList,null);   //added by kammy for testing
                    for (ProcessInstanceHistory his:p.StepsAndWorkitems)  { actoerIdSet.add(his.ActorId); }//end for
                }//end for
            }
            
            Map<Id, User> userMap = new Map<Id, User>([Select Id, 
                                                    title,
                                                    profileid,
                                                    CompanyName,
                                                    UserRoleid,
                                                    ASI_MFM_Country__c
                                                    From User 
                                                    Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList)
            {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 &&(p.StepsAndWorkitems[0].StepStatus == 'Approved'||p.StepsAndWorkitems[0].StepStatus == 'Rejected')){ byPassPending = true; }//end if
                for (ProcessInstanceHistory his:p.StepsAndWorkitems){
                    if(his.StepStatus != 'Reassigned'&& his.StepStatus != 'NoResponse'&&!(byPassPending && his.StepStatus == 'Pending')){
                        approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')  detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started') detail.status = 'Submitted';
                        else detail.status = his.StepStatus;
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