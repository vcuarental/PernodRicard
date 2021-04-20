public with sharing class ASI_MFM_CAP_OTH_InputPlanItemsController  {
    public ASI_MFM_Plan__c plan {get; private set;}
    // Check if the current user have access to editable fields for Final read only plan
    public boolean isRegionalITAdmin {get;set;}
    // Check if Header is final status
    public boolean isFinal {get;set;}
    public boolean isSubmitted {get;set;}
    public Id parentRecordTypeId;
    // What group should have IT admin rights
    public final Set<String> groupExceptionList = new Set<String>{'ASI_MFM_CAP_Regional_IT_Dept_Admin'};
    public boolean isCurrentUserOwner {get;set;}
    
    public ASI_MFM_CAP_OTH_InputPlanItemsController(apexpages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        parentRecordTypeId = apexpages.currentPage().getParameters().get('prtId');
        plan = database.query(ASI_MFM_function.buildQuery('ASI_MFM_Plan__c') + ' where id = :pid');
        
        this.isFinal = false;
        this.isSubmitted = false;
        // if(plan.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_TW_Plan') && plan.ASI_MFM_Status__c != 'Submitted')
        if(plan.ASI_MFM_Status__c == 'Final' || plan.ASI_MFM_Status__c == 'Complete')
            this.isFinal = true;
        else if (plan.ASI_MFM_Status__c == 'Submitted')
            this.isSubmitted = true;
        
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