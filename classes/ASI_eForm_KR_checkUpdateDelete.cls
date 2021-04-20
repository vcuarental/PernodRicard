public without sharing class ASI_eForm_KR_checkUpdateDelete
{
    private static String statusDraft = 'Draft';
    private static String statusSubmitted = 'Submitted';
    private static String statusApproved = 'Approved';
    private static String statusCompleted = 'Completed';
    private static Id profileId = userinfo.getProfileId();
    private static String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    private static String admin = 'System Administrator';
    
    public static void checkHeaderDelete(List<sObject> triggerOld,String field)
    {
        Id userid = userinfo.getUserId();
        Boolean IsHR = checkHRTeam(userid);
        if(trigger.isDelete)
        {
            for(sObject obj : triggerOld)
        	{
                if((obj.get(field) == statusApproved || obj.get(field) == statusCompleted) && profileName != admin && !IsHR)
            	{
                    if(!Test.isRunningTest())
                        obj.addError('Delete not allowed for approved or completed requests');
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkHeaderUpdate(List<sObject> triggerNew,List<sObject> triggerOld,String field)
    {
        //added on 2015-08-28
        Boolean inGroup = false;
        Id groupId = [Select Id From Group Where DeveloperName = 'ASI_KOR_IT_Admin'].Id;
        Id roleId = [Select UserRole.Id from User where Id=:userinfo.getUserId()].UserRole.Id;
        Set<Id> gmRelatedId = new Set<Id>();
        List<GroupMember> memberInGorup = new List<GroupMember>
            ([Select UserOrGroupId From GroupMember Where GroupId =: groupId And Group.Type = 'Regular']);
        for(GroupMember gm : memberInGorup)
        {
            gmRelatedId.add(gm.UserOrGroupId);
        }
        List<Group> roleInGroup = new List<Group>
            ([Select RelatedId From Group Where Id In: gmRelatedId]);
        //added on 2015-08-28
        for(Group role : roleInGroup)
        {
            if(role.RelatedId == roleId)
                inGroup=true;
        }
        Boolean IsHR = checkHRTeam(userinfo.getUserId());
        String oldStatus;
        for(sObject obj : triggerOld)
        {
            oldStatus = String.valueOf(obj.get(field));
        }
        if(trigger.isUpdate)
        {
            for(sObject obj : triggerNew)
        	{
                if(oldStatus == statusSubmitted && obj.get(field) == statusApproved
                   ||oldStatus == statusApproved && obj.get(field) == statusCompleted)
                {
                    
                }
                else if((obj.get(field) == statusApproved || obj.get(field) == statusCompleted
                         ||(oldStatus == statusApproved && obj.get(field) == statusDraft)) && profileName != admin && !inGroup && !IsHR)
            	{
                    if(!Test.isRunningTest())
                        obj.addError('Edit not allowed for approved or completed requests');
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkHADetailDelete(List<ASI_eForm_HA_Detail__c> triggerOld)
    {
        set<id> objSet = new set<id>();
        for (ASI_eForm_HA_Detail__c obj:triggerOld) {
            objSet.add(obj.ASI_eForm_Home_Appliance__c);
        }//end for
        map<id, ASI_eForm_Home_Appliance__c> mapObj = new map<id, ASI_eForm_Home_Appliance__c>([select Id from ASI_eForm_Home_Appliance__c where Id IN : objSet AND (ASI_eForm_Status__c =: statusApproved OR ASI_eForm_Status__c =: statusCompleted)]);
        if(trigger.isDelete)
        {
        	for (ASI_eForm_HA_Detail__c obj:triggerOld)
            {
            	if (mapObj.containsKey(obj.ASI_eForm_Home_Appliance__c) && profileName != admin)
            	{
                	if (!Test.isRunningTest())
					{
                		obj.addError('Delete not allowed for approved or completed requests');
                	}//end if
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkCTDetailDelete(List<ASI_eForm_Tuition_Detail__c> triggerOld)
    {
        set<id> objSet = new set<id>();
        for (ASI_eForm_Tuition_Detail__c obj:triggerOld) {
            objSet.add(obj.ASI_eForm_Tuition__c);
        }//end for
        map<id,ASI_eForm_Tuition__c> mapObj = new map<id,ASI_eForm_Tuition__c>([select Id from ASI_eForm_Tuition__c where Id IN : objSet AND (ASI_eForm_Status__c =: statusApproved OR ASI_eForm_Status__c =: statusCompleted)]);
        if(trigger.isDelete)
        {
        	for (ASI_eForm_Tuition_Detail__c obj:triggerOld)
            {
            	if (mapObj.containsKey(obj.ASI_eForm_Tuition__c) && profileName != admin)
            	{
                	if (!Test.isRunningTest())
					{
                		obj.addError('Delete not allowed for approved or completed requests');
                	}//end if
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkLRDetailDelete(List<ASI_eForm_Leave_Request_Line_Item__c> triggerOld)
    {
        set<id> objSet = new set<id>();
        for (ASI_eForm_Leave_Request_Line_Item__c obj:triggerOld) {
            objSet.add(obj.ASI_eForm_Leave_Reuest__c);
        }//end for
        map<id,ASI_eForm_Leave_Request__c> mapObj = new map<id,ASI_eForm_Leave_Request__c>([select Id from ASI_eForm_Leave_Request__c where Id IN : objSet AND (ASI_eForm_Status__c =: statusApproved OR ASI_eForm_Status__c =: statusCompleted)]);
        if(trigger.isDelete)
        {
        	for (ASI_eForm_Leave_Request_Line_Item__c obj:triggerOld)
            {
            	if (mapObj.containsKey(obj.ASI_eForm_Leave_Reuest__c) && profileName != admin)
            	{
                	if (!Test.isRunningTest())
					{
                		obj.addError('Delete not allowed for approved or completed requests');
                	}//end if
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkHADetailUpdate(List<ASI_eForm_HA_Detail__c> triggerNew)
    {
        set<id> objSet = new set<id>();
        for (ASI_eForm_HA_Detail__c obj:triggerNew) {
            objSet.add(obj.ASI_eForm_Home_Appliance__c);
        }//end for
        map<id, ASI_eForm_Home_Appliance__c> mapObj = new map<id, ASI_eForm_Home_Appliance__c>([select Id from ASI_eForm_Home_Appliance__c where Id IN : objSet AND (ASI_eForm_Status__c =: statusApproved OR ASI_eForm_Status__c =: statusCompleted)]);
        if(trigger.isUpdate)
        {
        	for (ASI_eForm_HA_Detail__c obj:triggerNew)
            {
            	if (mapObj.containsKey(obj.ASI_eForm_Home_Appliance__c) && profileName != admin)
            	{
                	if (!Test.isRunningTest())
					{
                		obj.addError('Edit not allowed for approved or completed requests');
                	}//end if
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkCTDetailUpdate(List<ASI_eForm_Tuition_Detail__c> triggerNew)
    {
        set<id> objSet = new set<id>();
        for (ASI_eForm_Tuition_Detail__c obj:triggerNew) {
            objSet.add(obj.ASI_eForm_Tuition__c);
        }//end for
        map<id,ASI_eForm_Tuition__c> mapObj = new map<id,ASI_eForm_Tuition__c>([select Id from ASI_eForm_Tuition__c where Id IN : objSet AND (ASI_eForm_Status__c =: statusApproved OR ASI_eForm_Status__c =: statusCompleted)]);
        if(trigger.isUpdate)
        {
        	for (ASI_eForm_Tuition_Detail__c obj:triggerNew)
            {
            	if (mapObj.containsKey(obj.ASI_eForm_Tuition__c) && profileName != admin)
            	{
                	if (!Test.isRunningTest())
					{
                		obj.addError('Edit not allowed for approved or completed requests');
                	}//end if
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    public static void checkLRDetailUpdate(List<ASI_eForm_Leave_Request_Line_Item__c> triggerNew)
    {
        set<id> objSet = new set<id>();
        for (ASI_eForm_Leave_Request_Line_Item__c obj:triggerNew) {
            objSet.add(obj.ASI_eForm_Leave_Reuest__c);
        }//end for
        map<id,ASI_eForm_Leave_Request__c> mapObj = new map<id,ASI_eForm_Leave_Request__c>([select Id from ASI_eForm_Leave_Request__c where Id IN : objSet AND (ASI_eForm_Status__c =: statusApproved OR ASI_eForm_Status__c =: statusCompleted)]);
        if(trigger.isUpdate)
        {
        	for (ASI_eForm_Leave_Request_Line_Item__c obj:triggerNew)
            {
            	if (mapObj.containsKey(obj.ASI_eForm_Leave_Reuest__c) && profileName != admin)
            	{
                	if (!Test.isRunningTest())
					{
                		obj.addError('Edit not allowed for approved or completed requests');
                	}//end if
            	}//end if
        	}//end for
        }//end if
    }//end method
    
    // Added checking on HR Team user  ****** 2018-04-10 Linus@introv
    public static Boolean checkHRTeam(id userid)
    {
        Boolean IsHR = false;
        Id groupId = [Select Id From Group Where DeveloperName = 'ASI_Eform_KR_Approver'].Id;
        for(GroupMember member: [Select UserOrGroupId From GroupMember Where GroupId =: groupId And Group.Type = 'Regular']){
            if(member.UserOrGroupId == userid)
                IsHR = true;
        }
        
        return IsHR;
    }
    // END - Linus
    
}//end class