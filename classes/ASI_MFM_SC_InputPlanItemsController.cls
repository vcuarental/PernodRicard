public with sharing class ASI_MFM_SC_InputPlanItemsController {
    public ASI_MFM_Plan__c plan {get; private set;}
    // Check if the current user have access to editable fields for Final read only plan
    public boolean isRegionalITAdmin {get;set;}
    // Check if Header is final status
    public boolean isFinal {get;set;}
	public boolean isSubmitted {get;set;}
    public boolean isCurrentUserApprover {get;set;}
    // What group should have IT admin rights
    public final Set<String> groupExceptionList = new Set<String>{'ASI_MFM_CAP_Regional_IT_Dept_Admin'};
    public boolean isCurrentUserOwner {get;set;}
    public boolean isDraft {get; set;}

    public boolean isReadOnly {get;set;}
    
    public ASI_MFM_SC_InputPlanItemsController(apexpages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        plan = database.query(ASI_MFM_function.buildQuery('ASI_MFM_Plan__c') + ' where id = :pid');
        
        this.isFinal = false;
        this.isSubmitted = false;
        this.isCurrentUserApprover = false;
        this.isReadOnly = true;

        if(plan.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SC_Plan_Read_Only') && plan.ASI_MFM_Status__c != 'Submitted')
            this.isFinal = true;
        else if (plan.ASI_MFM_Status__c == 'Submitted')
            this.isSubmitted = true;

        if(this.isSubmitted){
            id userId = getCurrentApprover(pid);
            if(userId == UserInfo.getUserId()){
                //Current User is pending approver
                this.isCurrentUserApprover = true;
            }
        }

        this.isRegionalITAdmin = false;
        List<Group> relatedGroup = getGroupsForUser(userinfo.getuserid());
        for (Group i : relatedGroup)
        {
            if (groupExceptionList.contains(i.DeveloperName))
                this.isRegionalITAdmin = true;
        }
        
        isCurrentUserOwner = false;
        if (userinfo.getuserid() == plan.ownerid) {
            isCurrentUserOwner = true;
        }

        determineReadOnly(isFinal,isSubmitted,isCurrentUserApprover,isRegionalITAdmin,isCurrentUserOwner);
    }

    public void determineReadOnly(boolean finalized, boolean submitted, boolean currentuserapprover, boolean regionalITadmin, boolean currentUserOwner){
        if(finalized || !regionalITadmin || !currentUserOwner){
            isReadOnly = true;
        }
        
        if(submitted){
            if(currentuserapprover){
                isReadOnly = false;
            }else{
                isReadOnly = true;
            }
        }
        else{
            isReadOnly = false;
        }
    }

    public id getCurrentApprover(id TargetObjectId){
    	try{
	        ProcessInstance pi = [  SELECT CompletedDate, CreatedById, CreatedDate,Id,IsDeleted,LastActorId,
	                                LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById
	                                ,SystemModstamp,TargetObjectId, (SELECT ID, ProcessNodeId, StepStatus,
	                                Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending,
	                                OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate
	                                FROM StepsAndWorkitems ) FROM ProcessInstance
	                                where ProcessInstance.TargetObjectId =: TargetObjectId
	                                AND Status = 'Pending' Limit 1];
	        if(pi.StepsAndWorkitems != null){
	            return pi.StepsAndWorkitems[0].ActorId;
	        }
    	}catch(Exception e){
        	
        }
        return null;
    }
   
    // return list of all groups the user belongs to via direct or indirect membership
    public Group[] getGroupsForUser(Id userId){

        Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
     return [
           select Id
            , Name ,
            DeveloperName 
         from Group
        where Id IN: groupIds];

    }

    // return all ids the user belongs to via direct or indirect membership
    public Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){

        Set<Id> output = new Set<Id>();

        Set<Id> nestedGroupIds = new Set<Id>();

        // only query actual groups and not roles and queues
        list<GroupMember> records = [
            select id
                 , GroupId
                 , UserOrGroupId
              from GroupMember
         where UserOrGroupId =: userOrGroupIds
            and UserOrGroupId != null];

        for (GroupMember record:records)
        {
            // found a group, remember for traversal
            if (!(record.UserOrGroupId + '').startsWith('005'))
            {
                nestedGroupIds.add(record.UserOrGroupId);   
            }
            else
            {
                output.add(record.GroupId);
            }
        }

        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }

        return output;
    }
   
}