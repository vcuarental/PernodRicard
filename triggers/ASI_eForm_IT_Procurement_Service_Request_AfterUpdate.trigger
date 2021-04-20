trigger ASI_eForm_IT_Procurement_Service_Request_AfterUpdate on ASI_eForm_IT_Procurement_Service_Request__c (after update) {

ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_IT_Procurement_Service_Request__Share', 
                                                            'ASI_eForm_IT_Procurement_Manager_Access__c', 
                                                            new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Approver__c', 'ASI_eForm_Finance_Director__c',
                                                                            'ASI_eForm_CIO__c'}, 
                                                            trigger.oldMap);
                                                            
                                                                                            
    map<string, id> rt_map1 = getRecordTypeId('ASI_eForm_IT_Procurement_Service_Request__c');
    Set<ID> itProcHardwareFinalIDs = new Set<ID>();
    List<ASI_eForm_IT_Procurement_Service_Request__c> itProcHardwareFinalList = new List<ASI_eForm_IT_Procurement_Service_Request__c>();
    
    for (ASI_eForm_IT_Procurement_Service_Request__c itProc : trigger.new )
    {
        if (rt_map1.get('ASI_eForm_HK_Hardware_Software_Request_Final') == itProc.recordtypeid && itProc.recordtypeid != trigger.oldMap.get(itProc.id).recordtypeid)
        {
            itProcHardwareFinalIDs.add(itProc.id);
            itProcHardwareFinalList.add(itProc);
        }
    }
    
    
    if (itProcHardwareFinalIDs.size() != 0 && itProcHardwareFinalList.size() != 0)
    {
        Map<ID, ASI_eForm_IT_Procurement_Service_Request__c> itProcHardwareFinalMap = new Map<ID, ASI_eForm_IT_Procurement_Service_Request__c>
                                                                                        ([SELECT id, name, (SELECT id, name, ASI_eForm_HASRF_Category__c
                                                                                                            FROM IT_Procurement_Service_Items__r)
                                                                                          FROM ASI_eForm_IT_Procurement_Service_Request__c
                                                                                          WHERE ID IN : itProcHardwareFinalIDs]);
        Set<ID> groupIds = new Set<ID>();
        List<group> AllGroupList = [SELECT ID, DeveloperName FROM group WHERE DeveloperName = : 'ASI_eForm_Infra_Group' OR DeveloperName = : 'ASI_eForm_General_Admin'];
        Map<ID, String> groupNameIdMap = new Map<ID, String>();
        Map<String, set<ID>> userGroupMap = new Map<String, set<ID>>();
        
        for (group i : AllGroupList)
        {
            groupIds.add(i.id);
            groupNameIdMap.put(i.id, i.DeveloperName);
        }
        
        List<groupMember> userGroupList = [SELECT ID, GroupId, UserOrGroupId FROM groupMember WHERE GroupId IN : groupIds];
        
        Set<ID> generalAdminUsers = new Set<ID>();
        Set<ID> infraGeneralUsers = new Set<ID>();
        Set<ID> allUsers = new Set<ID>();
        for (groupMember i : userGroupList)
        {
            if (groupNameIdMap.get(i.GroupId) == 'ASI_eForm_General_Admin')
                generalAdminUsers.add(i.UserOrGroupId);
            else if (groupNameIdMap.get(i.GroupId) == 'ASI_eForm_Infra_Group')
                infraGeneralUsers.add(i.UserOrGroupId);
            allUsers.add(i.UserOrGroupId);
        }
        userGroupMap.put('ASI_eForm_General_Admin', generalAdminUsers);
        userGroupMap.put('ASI_eForm_Infra_Group', infraGeneralUsers);
        
        if (allUsers.size() != 0)
        {
            List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
            Map<Id,User> selectedUsersMap = new Map<Id,User>([Select Id, Email from User where Id in : allUsers]);
            
            EmailTemplate emailTemplate =  [SELECT id,name, DeveloperName  FROM EmailTemplate WHERE 
                                            DeveloperName  in ('ASI_eForm_HK_HASRF_ApvdEmail_Template') LIMIT 1];
            
            OrgWideEmailAddress itServiceDesk = ASI_eForm_GenericTriggerClass.retrieveITServiceDesk();                   
            for (ASI_eForm_IT_Procurement_Service_Request__c itProcFinal : itProcHardwareFinalList)
            {
                Set<String> uniqueEmails = new Set<String>();
                List<ASI_eForm_IT_Procurement_Service_Item__c> itProcItemList = itProcHardwareFinalMap.get(itProcFinal.id).IT_Procurement_Service_Items__r;
            
                boolean isNonITRelated = false;
                boolean isOthers = false;
                
                if (itProcItemList.size() == 1)
                {
                    if (itProcItemList.get(0).ASI_eForm_HASRF_Category__c == 'Non IT Related Subscription Items') 
                        isNonITRelated = true;
                    else
                        isOthers = true;
                } 
                else if (itProcItemList.size() != 0)
                {
                    for (ASI_eForm_IT_Procurement_Service_Item__c itProcItem : itProcItemList)
                    {
                        if (itProcItem.ASI_eForm_HASRF_Category__c == 'Non IT Related Subscription Items')
                        {
                            isNonITRelated = true;
                        }
                        else
                            isOthers = true;
                        if (isNonITRelated && isOthers)
                            break;
                    }
                }
            
                if (isNonITRelated)
                {
                    Set<ID> nonItRelatedUsers = userGroupMap.get('ASI_eForm_General_Admin');
                    for (ID userId : nonItRelatedUsers)
                    {
                        String email = selectedUsersMap.get(userId).Email;
                        if (email != null)
                            uniqueEmails.add(email);
                    }
                }
            
                if (isOthers)
                {
                    Set<ID> otherUsers = userGroupMap.get('ASI_eForm_Infra_Group');
                    for (ID userId : otherUsers)
                    {
                        String email = selectedUsersMap.get(userId).Email;
                        if (email != null)
                            uniqueEmails.add(email);
                    }
                }
                
                if (uniqueEmails.size() != 0)
                {   
                    List<String> addresses = new List<String>();
                    addresses.addAll(uniqueEmails);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setSaveAsActivity(false);
                    email.setTargetObjectId(itProcFinal.ownerId);
                    
                    if (itServiceDesk != null)
                    {
                        email.setSenderDisplayName(itServiceDesk.DisplayName);
                        email.setReplyTo(itServiceDesk.Address);
                    }
                    
                    email.setToAddresses(addresses);
                    email.setWhatId(itProcFinal.Id);
                    email.setTemplateId(emailTemplate.Id); 
                    allMail.add(email);
                    system.debug('clk1 email ' + email);
                    //system.debug('clk2 itProcFinal ' + itProcFinal.Id);
                    //system.debug('clk3 OwnerID ' + itProcFinal.ownerId);
                }
            }
            
            if (allMail.size() != 0)
                Messaging.SendEmailResult [] r = Messaging.sendEmail(allMail); 
        }
    }
    

    public map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }                                                           

}