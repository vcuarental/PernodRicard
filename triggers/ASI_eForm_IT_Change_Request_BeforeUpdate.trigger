trigger ASI_eForm_IT_Change_Request_BeforeUpdate on ASI_eForm_IT_Change_Request__c (before update) {

    Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new);
                                            
    for (ASI_eForm_IT_Change_Request__c i : trigger.new)
    {
    	if (i.ownerid != trigger.oldMap.get(i.id).ownerid)
    	i = (ASI_eForm_IT_Change_Request__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
    }

  /*  map<string, id> rt_map1 = getRecordTypeId('ASI_eForm_IT_Change_Request__c');
    List<ASI_eForm_Route_Type__c> routeTypes = [SELECT ID, Name, ASI_eForm_Form_Type__c, 
                                                    (SELECT ID, Name, ASI_eForm_Approver__c, ASI_eForm_Note__c 
                                                    FROM ASI_eForm_Route_Rule_Details__r
                                                    WHERE ASI_eForm_Note__c = : ASI_eForm_PreFillApproversHandler.CIO)
                                                FROM ASI_eForm_Route_Type__c
                                                WHERE (Name = : 'ITCRF-PRHK-Finance' OR Name = : 'ITCRF-PRCN-Finance')
                                                AND ASI_eForm_Form_Type__c = : 'IT Change Request'];
                                                
    Map<String, ASI_eForm_Route_Type__c> routeTypesMap = new Map<String, ASI_eForm_Route_Type__c>();
    Map<ID, ASI_eForm_IT_Change_Request__c> oldChangeRequest = trigger.oldMap;
    
    for (ASI_eForm_Route_Type__c routeType : routeTypes)
    {
        routeTypesMap.put(routeType.name, routeType);
    }
    
    for (ASI_eForm_IT_Change_Request__c changeRequest : trigger.new)
    {
        if (rt_map1.get('ASI_eForm_HK_IT_Change_Request_Submitted') == changeRequest.recordTypeID || rt_map1.get('ASI_eForm_CN_IT_Change_Request_Submitted') == changeRequest.recordTypeID )
        {
            if (oldChangeRequest.get(changeRequest.id).ASI_eForm_FCost_absorbed_by_IT__c != changeRequest.ASI_eForm_FCost_absorbed_by_IT__c && changeRequest.ASI_eForm_FCost_absorbed_by_IT__c)
            {
                if (rt_map1.get('ASI_eForm_CN_IT_Change_Request_Submitted') == changeRequest.recordTypeID )
                {
                    ASI_eForm_Route_Type__c route = routeTypesMap.get('ITCRF-PRCN-Finance'); 
                    ID routeUser = route != null ?  (route.ASI_eForm_Route_Rule_Details__r.size() != 0 ?
                                                    (route.ASI_eForm_Route_Rule_Details__r.get(0).ASI_eForm_Approver__c)
                                                    :
                                                    (null))
                                                    :null;
                    changeRequest.ASI_eForm_CIO_Approver__c = routeUser;
                }
                else if (rt_map1.get('ASI_eForm_HK_IT_Change_Request_Submitted') == changeRequest.recordTypeID)
                {
                    ASI_eForm_Route_Type__c route = routeTypesMap.get('ITCRF-PRHK-Finance'); 
                    ID routeUser = route != null ?  (route.ASI_eForm_Route_Rule_Details__r.size() != 0 ?
                                                    (route.ASI_eForm_Route_Rule_Details__r.get(0).ASI_eForm_Approver__c)
                                                    :
                                                    (null))
                                                    :null;
                    changeRequest.ASI_eForm_CIO_Approver__c = routeUser;
                }
            }
            else if (oldChangeRequest.get(changeRequest.id).ASI_eForm_FCost_absorbed_by_IT__c != changeRequest.ASI_eForm_FCost_absorbed_by_IT__c && !changeRequest.ASI_eForm_FCost_absorbed_by_IT__c)
            {
                changeRequest.ASI_eForm_CIO_Approver__c = null;
            }
        }
        if (changeRequest.ASI_eForm_FCost_absorbed_by_IT__c && changeRequest.ASI_eForm_CIO_Approver__c == null)
        {
            changeRequest.ASI_eForm_CIO_Approver__c.addError('Cost absorbed by Local/Regional IT is checked but there is no CIO Approver. Please review data.');
        }
    }

    public map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }*/

}