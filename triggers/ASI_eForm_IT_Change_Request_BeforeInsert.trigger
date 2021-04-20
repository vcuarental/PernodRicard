trigger ASI_eForm_IT_Change_Request_BeforeInsert on ASI_eForm_IT_Change_Request__c (before insert) {

    map<string, id> rt_map1 = getRecordTypeId('ASI_eForm_IT_Change_Request__c');
    ASI_eForm_AutoNumberAssignment autoNumAssignHK = null;
    ASI_eForm_AutoNumberAssignment autoNumAssignCN = null;
    
    Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new);
    
    for (ASI_eForm_IT_Change_Request__c i : trigger.new)
    {

        if (rt_map1.get('ASI_eForm_HK_IT_Change_Request') == i.recordTypeID || rt_map1.get('ASI_eForm_HK_IT_Change_Request_Final') == i.recordTypeID)
        {
            if (autoNumAssignHK == null)
            {
                autoNumAssignHK = new ASI_eForm_AutoNumberAssignment('ASI_eForm_IT_Change_Request_HK');
            }
            i.ASI_eForm_Change_Request_No__c = autoNumAssignHK.nextAutoNumStr();
        }
        else if (rt_map1.get('ASI_eForm_CN_IT_Change_Request') == i.recordTypeID || rt_map1.get('ASI_eForm_CN_IT_Change_Request_Final') == i.recordTypeID)
        {
            if (autoNumAssignCN == null)
            {
                autoNumAssignCN  = new ASI_eForm_AutoNumberAssignment('ASI_eForm_IT_Change_Request_CN');
            }
            i.ASI_eForm_Change_Request_No__c = autoNumAssignCN.nextAutoNumStr();
        }
        
		i = (ASI_eForm_IT_Change_Request__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
        
    }
    
    if (autoNumAssignHK != null)
        autoNumAssignHK.writeToDB();
    
    if (autoNumAssignCN != null)
        autoNumAssignCN.writeToDB();

    public map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }

}