public without sharing class ASI_CRM_CN_DTF_TriggerClass
{
    public static void beforeInsertMethod(List<ASI_CRM_DTF__c> triggerNew)
    {
        List<Group> dtfGroup 
            = [Select Id From Group Where DeveloperName = 'ASI_CRM_CN_DTF_Approver_Group']; //get group id from DTF approver group
        List<GroupMember> memberInGorup = new List<GroupMember>();
        if(dtfGroup.size() > 0)
        {
            memberInGorup = 
                [Select UserOrGroupId From GroupMember Where GroupId =: dtfGroup[0].Id And Group.Type = 'Regular']; //get list of user id from DTF approver group
        }//end if
        
        Integer i = 1;
        String sysApprover = 'ASI_CRM_CN_SysApprover'+i+'__c'; //sys approver 1 - 4
        
        for(ASI_CRM_DTF__c dtf: triggerNew)
        {
            if(memberInGorup.size() > 0)
            {
                for(GroupMember gm: memberInGorup)
                {
                    if(i <= 4)
                    {
                        dtf.put(sysApprover, gm.UserOrGroupId); //update sys approver
                        i++;
                        sysApprover = 'ASI_CRM_CN_SysApprover'+i+'__c'; //update sys approver string
                    }//end if
                    else
                        break;
                }//end for
            }//end if
        }//end for
    }//end method: beforeInsertMethod
    
    public static void afterUpdateMethod(List<ASI_CRM_DTF__c> triggerNew)
    {
        List<Approval.ProcessWorkitemRequest> apwList = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem> workitems = new List<ProcessInstanceWorkitem>();
        Map<String,ProcessInstanceWorkitem> workitemMap = new Map<String,ProcessInstanceWorkitem>();
        
        Set<Id> recordId = new Set<Id>();
        for(ASI_CRM_DTF__c dtf: triggerNew)
        {
            recordId.add(dtf.Id); //store list of records id
        }//end for
        
        if(recordId.size() > 0)
        {
            workitems 
                = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: recordId]; //get records' approval step
        }//end if
        
        if(workitems.size() > 0)
        {
            for(ProcessInstanceWorkitem workItem: workitems)
            {
                workitemMap.put(workItem.ProcessInstance.TargetObjectId, workitem);//put into map, Map<record id, approval step>
            }//end for
        }//end if
        
        for(ASI_CRM_DTF__c dtf: triggerNew)
        {
            if(dtf.ASI_CRM_CN_autoApprove__c
               &&dtf.ASI_CRM_CN_Status__c == 'Submitted'
               &&workitemMap.containsKey(dtf.Id)
               &&workitemMap.get(dtf.Id) != null) //check approal flag not yet check & status still in submitted and contains value in map
            {
                Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
                approvalReq.setWorkitemId(workitemMap.get(dtf.Id).Id);
                approvalReq.setComments('System Auto Approve'); //set auto approve comment
                approvalReq.setAction('Approve'); //approve the record
                apwList.add(approvalReq);
            }//end if
        }//end for
        
        if(apwList.size()>0)
        {
            for(Approval.ProcessWorkitemRequest apw: apwList)
            {
                try
                {
                    Approval.ProcessResult approvalResult = Approval.process(apw);
                }//end try
                catch(exception e)
                {}//end catch
            }//end for
        }
    }//end method: beforeInsertMethod
}//end class