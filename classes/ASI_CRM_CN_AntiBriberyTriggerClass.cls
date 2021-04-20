public without sharing class ASI_CRM_CN_AntiBriberyTriggerClass {
    
    public static void entryCriteriaCheck(List<ASI_CRM_Anti_Bribery__c> triggerNew, Map<Id, ASI_CRM_Anti_Bribery__c> triggerOldMap){
        
        Map<id, RecordType> mapRT = new map<id, RecordType>([SELECT id,DeveloperName,Name FROM recordType WHERE sObjectType = 'ASI_CRM_Anti_Bribery__c']);
        Map<String, Double> mapParameters = new Map<String, Double>();
        Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, ManagerID FROM User WHERE CompanyName = 'Pernod Ricard China']); 
        Map<String, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
        Set<id> VIP_userID = new Set<id>();
        boolean a;
        
        list<ASI_CRM_Application_Parameter__c> parameters = new List<ASI_CRM_Application_Parameter__c>([SELECT id,
                                                                                                      ASI_CRM_Parameter_Key__c, ASI_CRM_Threshhold__c FROM ASI_CRM_Application_Parameter__c
                                                                                                      WHERE ASI_CRM_Module__c= 'AB']);
        
        List<ASI_CRM_Dynamic_Approval_Route__c> LApp = [Select id,ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Type__c,
                                                        ASI_CRM_User__c
                                                        , ASI_CRM_Approval_Limit__c
                                                        from ASI_CRM_Dynamic_Approval_Route__c 
                                                        where ASI_CRM_Type__c = 'AB General'];
        
        List<ASI_CRM_Fix_Approval_Route__c> fixApproverList = new List<ASI_CRM_Fix_Approval_Route__c>([SELECT id,ASI_CRM_CN_Approver_1__c,
                                                                                                       ASI_CRM_CN_Approver_2__c,ASI_CRM_CN_Approver_3__c,
                                                                                                       ASI_CRM_CN_Approver_4__c,ASI_CRM_CN_Approver_5__c,
                                                                                                       ASI_CRM_CN_Approver_6__c,ASI_CRM_CN_Type__c,ASI_CRM_CN_Alternative_Approver__c
                                                                                                       FROM ASI_CRM_Fix_Approval_Route__c 
                                                                                                       WHERE ASI_CRM_CN_Type__c Like 'Offering Non-PO'
                                                                                                       //OR ASI_CRM_CN_Type__c = 'Offering H- Contract Outlet(Non-PO)'
                                                                                                       OR ASI_CRM_CN_Type__c Like 'Offering PO(Non-Facilitation Fees)'
                                                                                                       OR ASI_CRM_CN_Type__c Like 'Receiving Cash-Notification'
                                                                                                       OR ASI_CRM_CN_Type__c Like 'Receiving G(non cash)&H-Non-Trip'
                                                                                                       OR ASI_CRM_CN_Type__c Like 'Receiving G(non cash)&H-Trip'
                                                                                                       OR ASI_CRM_CN_Type__c Like 'AB Policy VIP'
                                                                                                      ]);
        // 20171109 Ryan@introv
        
        list<GroupMember> GM = new list<GroupMember>([SELECT UserorGroupId
                                                      FROM GroupMember where 
                                                      group.developerName = 'ASI_CRM_CN_Anti_Bribery_VIP_Group'
                                                     ]);
        
        for(GroupMember obj : GM)
        {
            VIP_userID.add(obj.UserorGroupId);
        }
        // 20171109 Ryan@introv
        for(ASI_CRM_Application_Parameter__c parameter : parameters){
            mapParameters.put(parameter.ASI_CRM_Parameter_Key__c,parameter.ASI_CRM_Threshhold__c);
        }
        
        //20190823:AM@Introv - ignore user company
        Set<Id> setDRouteUser = new Set<Id>();
        for(ASI_CRM_Dynamic_Approval_Route__c obj : LApp){
            MAppRoute.put(obj.ASI_CRM_User__c,obj);
            setDRouteUser.add(obj.ASI_CRM_User__c);		//20190823:AM@Introv - ignore user company
        }
        
        //20190823:AM@Introv - ignore user company - start
        for(ASI_CRM_Anti_Bribery__c oAB : triggerNew){
            if(mapUser.get(oAB.OwnerId) != NULL){
                setDRouteUser.add(oAB.OwnerId);
            }
        }
        Map<ID, User> mapDRouteUser = new Map<ID,User>([SELECT ID, ManagerID FROM User WHERE ID IN :setDRouteUser]);
        //20190823:AM@Introv - ignore user company - end
        
        for(ASI_CRM_Fix_Approval_Route__c obj : fixApproverList){
            MAppRouteFix.put(obj.ASI_CRM_CN_Type__c,obj);
        }
        
        for(ASI_CRM_Anti_Bribery__c antiBriberyObj : triggerNew){
            
            Boolean isVIP = false; // 20171110 Introv
            
            if(mapUser.get(antiBriberyObj.OwnerId)==null){
                antiBriberyObj.addError('For Pernod Ricard China staff only.');
                break;
            }
            
            //20161118 Elufa // 20180208 Introv added this logic to insert case
            if(USerInfo.getLanguage()=='zh_CN' 
               && ( (triggerOldMap != Null && ( triggerOldMap.get(antiBriberyObj.id).ASI_CRM_Status__c == 'Draft' && ( antiBriberyObj.ASI_CRM_Status__c == 'Submitted' || antiBriberyObj.ASI_CRM_Status__c == 'Archived' ))) 
                   || (trigger.isInsert))
               && ( antiBriberyObj.ASI_CRM_Proposed_Date_of_Offering__c < date.today() || antiBriberyObj.ASI_CRM_Proposed_Date_of_Received__c < date.today() ) 
               && ( antiBriberyObj.ASI_CRM_Special_Reason__c == Null || antiBriberyObj.ASI_CRM_Special_Reason__c == '')){
                
                antiBriberyObj.addError('(拟定)给与日期 /（拟定）接受日期早于系统提交日期，请填写特殊原因');
                break;
            }else if(( (triggerOldMap != Null && ( triggerOldMap.get(antiBriberyObj.id).ASI_CRM_Status__c == 'Draft' && ( antiBriberyObj.ASI_CRM_Status__c == 'Submitted' || antiBriberyObj.ASI_CRM_Status__c == 'Archived' ))) 
                   || (trigger.isInsert))
               && ( antiBriberyObj.ASI_CRM_Proposed_Date_of_Offering__c < date.today() || antiBriberyObj.ASI_CRM_Proposed_Date_of_Received__c < date.today() ) 
               && ( antiBriberyObj.ASI_CRM_Special_Reason__c == Null || antiBriberyObj.ASI_CRM_Special_Reason__c == '')){
                
                antiBriberyObj.addError('Please provide the Reason of (Proposed) Date of Offering/Received earlier than Today in the Special Reason Text Box before submission');
                break;
            }
            //20161118
            
            //20180206 Introv
            if(trigger.isInsert || antiBriberyObj.ASI_CRM_Status__c == 'Draft'){
                antiBriberyObj.ASI_CRM_FixApproval__c = false;
                antiBriberyObj.ASI_CRM_DynamicApproval__c = false;
            }
            
            if(antiBriberyObj.ASI_CRM_Status__c=='Draft'){
                setApproverToNull(antiBriberyObj);
                
                // 20171109 Ryan@introv
                
                if(VIP_userID.Contains(antiBriberyObj.OwnerId))
                {
                    antiBriberyObj.ASI_CRM_FixApproval__c = true;
                    
                }else if(mapRT.get(antiBriberyObj.recordTypeID).DeveloperName=='ASI_CRM_CN_Offering_Non_PO'){
                    if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Gift'){
                        if((antiBriberyObj.ASI_CRM_AccumValueOfGiftsPerRecipient__c + antiBriberyObj.ASI_CRM_Value_Per_Recipient__c) > mapParameters.get('case1') && antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case2')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }else if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case3')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Hospitality'){
                        if((antiBriberyObj.ASI_CRM_AccumValueHospiPerRecipient__c + antiBriberyObj.ASI_CRM_Value_Per_Recipient__c) > mapParameters.get('case4') && antiBriberyObj.ASI_CRM_Value_Per_Recipient__c > mapParameters.get('case5')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }else if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case6')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Trips (Travelling Together)'){
                        if((antiBriberyObj.ASI_CRM_AccumValueHospiPerRecipient__c + antiBriberyObj.ASI_CRM_Value_Per_Recipient__c) > mapParameters.get('case7') && antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case8')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }else if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case9')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Trips (Not Travelling Together)'){
                        if((antiBriberyObj.ASI_CRM_AccumValueOfGiftsPerRecipient__c + antiBriberyObj.ASI_CRM_Value_Per_Recipient__c) > mapParameters.get('case10')&&antiBriberyObj.ASI_CRM_Value_Per_Recipient__c > mapParameters.get('case11')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }else if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case12')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Charitable Donation'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case13')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Sponsorship/Community Project'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case14')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Engagement of Lobbyists'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case15')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }
                    if(antiBriberyObj.ASI_CRM_Within_3_Month__c != 'No'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case16')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }
                }else if(mapRT.get(antiBriberyObj.recordTypeID).DeveloperName == 'ASI_CRM_CN_Offering_PO_excl_FP'){
                    if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Gift'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case17')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Hospitality'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case18')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Charitable Donation'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case19')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Sponsorship/Community Project'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case20')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Political Donation'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case21')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Engagement of Lobbyists'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case22')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Trips (Not Travelling Together)'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case23')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Trips (Travelling Together)'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case24')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }
                    /*}else if(mapRT.get(antiBriberyObj.recordTypeID).DeveloperName == 'ASI_CRM_CN_Offering_H_Contract_OutletNPO'){
if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Hospitality'){
if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case25')){
antiBriberyObj.ASI_CRM_DynamicApproval__c = true;
}
}else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Trips (Travelling Together)'){
if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case26')){
antiBriberyObj.ASI_CRM_DynamicApproval__c = true;
}
}*/
                }else if(mapRT.get(antiBriberyObj.recordTypeID).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'){
                    if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Hospitality'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case27')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }else if(antiBriberyObj.ASI_CRM_Within_3_Month__c != 'No'){
                            if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case28')){
                                antiBriberyObj.ASI_CRM_FixApproval__c = true;
                                antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                            }
                        }else if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c + antiBriberyObj.ASI_CRM_Accum_Value_per_Recipient__c > mapParameters.get('case30')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Trip'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case29')){
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true;
                            antiBriberyObj.ASI_CRM_FixApproval__c = true; //20170210, elufa
                        }
                    }else if(antiBriberyObj.ASI_CRM_Reporting_Item__c == 'Gift'){
                        if(antiBriberyObj.ASI_CRM_Value_Per_Recipient__c>mapParameters.get('case31')){
                            antiBriberyObj.ASI_CRM_FixApproval__c = true;
                            antiBriberyObj.ASI_CRM_DynamicApproval__c = true; //20170210, elufa
                        }
                    }
                }else if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                    antiBriberyObj.ASI_CRM_FixApproval__c = true;
                    antiBriberyObj.ASI_CRM_DynamicApproval__c = true;
                }
                
                a = false;
                
                /*if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_H_Contract_OutletNPO'){
a = specialCase(antiBriberyObj, MAppRouteFix.get('Offering H- Contract Outlet(Non-PO)'));
}
else */
                if(VIP_userID.Contains(antiBriberyObj.OwnerId))// 20171109 Ryan@introv
                {
                    a = specialCase(antiBriberyObj, MAppRouteFix.get('AB Policy VIP'));
                    isVIP = true;
                }else if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_PO_excl_FP'){
                    a = specialCase(antiBriberyObj, MAppRouteFix.get('Offering PO(Non-Facilitation Fees)'));
                }
                else if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_Non_PO'){
                    a = specialCase(antiBriberyObj, MAppRouteFix.get('Offering Non-PO'));
                }
                else if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                    a = specialCase(antiBriberyObj, MAppRouteFix.get('Receiving Cash-Notification'));
                }
                else if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H' && antiBriberyObj.ASI_CRM_Reporting_Item__c!='Trip'){
                    a = specialCase(antiBriberyObj, MAppRouteFix.get('Receiving G(non cash)&H-Non-Trip'));
                }
                else if(mapRT.get(antiBriberyObj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'){
                    a = specialCase(antiBriberyObj, MAppRouteFix.get('Receiving G(non cash)&H-Trip'));
                }
                
                if(a)
                { //20170210, elufa
                    //20190823:AM@Introv - ignore user company
                    //setDynamicApprover(antiBriberyObj, mapUser, mapRT, MAppRouteFix, MAppRoute, true); //20170210, elufa
                    setDynamicApprover(antiBriberyObj, mapDRouteUser, mapRT, MAppRouteFix, MAppRoute, true); //20170210, elufa
                    setFixedApprover(antiBriberyObj, MAppRouteFix, mapRT, isVIP);
                } //20170210, elufa
                else {
                    //20190823:AM@Introv - ignore user company - start
                    //setApprover(antiBriberyObj, mapRT, LApp, fixApproverList, MAppRouteFix, MAppRoute, mapUser, isVIP);
                    setApprover(antiBriberyObj, mapRT, LApp, fixApproverList, MAppRouteFix, MAppRoute, mapDRouteUser, isVIP);
                }
                
                handleSelfApproval(antiBriberyObj, MAppRouteFix, mapRT, isVIP);
                userNotification(antiBriberyObj, MAppRouteFix, mapRT);
                
                //20190726:AM@Introv - remove duplicate approvers
                removeDuplicateApprovers(antiBriberyObj);
            }
        }//for
    }//method
    
    Public static void removeDuplicateApprovers(ASI_CRM_Anti_Bribery__c obj) {
		Set<Id> oApproverList = new Set<Id>();
        
        String sysApprover;
        for(integer i = 1 ; i <=8 ; i++){
            sysApprover = 'ASI_CRM_Sys_Approver_'+i+'__c';
            if (obj.get(sysApprover) != NULL) {
                oApproverList.add((Id)obj.get(sysApprover));
            }
        }
        
        if (oApproverList.size() > 0) {
            setApproverToNull(obj);
            
            integer iCount = 1;
            for (Id idTmpApprover : oApproverList) {
                sysApprover = 'ASI_CRM_Sys_Approver_'+iCount+'__c';
                obj.put(sysApprover, idTmpApprover);
                
                iCount++;
            }
        }
    }
    
    Public static void setApprover(ASI_CRM_Anti_Bribery__c obj,Map<id, RecordType> mapRT, List<ASI_CRM_Dynamic_Approval_Route__c> LApp, List<ASI_CRM_Fix_Approval_Route__c> fixApproverList, Map<String, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix, Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, Map<ID, User> mapUser, Boolean isVIP){
        
        
        if(obj.ASI_CRM_DynamicApproval__c){
            //setDynamicApprover(obj, mapUser, mapRT, MAppRouteFix, MAppRoute, false); //20170210, elufa
            setDynamicApprover(obj, mapUser, mapRT, MAppRouteFix, MAppRoute, true); //20170210, elufa
        }
        
        if(obj.ASI_CRM_FixApproval__c){
            /*if(mapRT.get(obj.recordTypeId).DeveloperName != 'ASI_CRM_CN_Receiving_Cash')
                setDynamicApprover(obj, mapUser, mapRT, MAppRouteFix, MAppRoute, true);
            else
                //setDynamicApprover(obj, mapUser, mapRT, MAppRouteFix, MAppRoute, false); //20170210, elufa
                setDynamicApprover(obj, mapUser, mapRT, MAppRouteFix, MAppRoute, true); //20170210, elufa*/			//20171110 Introv commented
            
            //20171110 Introv
            if(!isVIP)
                setDynamicApprover(obj, mapUser, mapRT, MAppRouteFix, MAppRoute, true);
            setFixedApprover(obj, MAppRouteFix, mapRT, isVIP);
        }
    }
    
    public static void setApproverToNull(ASI_CRM_Anti_Bribery__c obj){
        
        String sysApprover;
        
        for(integer i = 1 ; i <=8 ; i++){
            sysApprover = 'ASI_CRM_Sys_Approver_'+i+'__c';
            obj.put(sysApprover,null);
        }
    }
    
    public static void handleSelfApproval(ASI_CRM_Anti_Bribery__c obj,Map<String, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix,Map<id, RecordType> mapRT, Boolean isVIP){
        
        String sysApprover;
        
        for(integer i = 1 ; i <=8 ; i++){
            sysApprover = 'ASI_CRM_Sys_Approver_'+i+'__c';
            if(obj.OwnerID == obj.get(sysApprover)){
                /*if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_H_Contract_OutletNPO'){
                    obj.put(sysApprover,MAppRouteFix.get('Offering H- Contract Outlet(Non-PO)').get('ASI_CRM_CN_Alternative_Approver__c'));
                }
                else */
                
                //20171113 Introv
                if(isVIP){
                    obj.put(sysApprover,MAppRouteFix.get('AB Policy VIP').get('ASI_CRM_CN_Alternative_Approver__c'));
                //20171113 End
                }else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'&&obj.ASI_CRM_Reporting_Item__c!='Trip'){
                    obj.put(sysApprover,MAppRouteFix.get('Receiving G(non cash)&H-Non-Trip').get('ASI_CRM_CN_Alternative_Approver__c'));
                }
                else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'){
                    obj.put(sysApprover,MAppRouteFix.get('Receiving G(non cash)&H-Trip').get('ASI_CRM_CN_Alternative_Approver__c'));
                }
                else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_PO_excl_FP'){
                    obj.put(sysApprover,MAppRouteFix.get('Offering PO(Non-Facilitation Fees)').get('ASI_CRM_CN_Alternative_Approver__c'));
                }
                else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_Non_PO'){
                    obj.put(sysApprover,MAppRouteFix.get('Offering Non-PO').get('ASI_CRM_CN_Alternative_Approver__c'));
                }
                else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                    obj.put(sysApprover,MAppRouteFix.get('Receiving Cash-Notification').get('ASI_CRM_CN_Alternative_Approver__c'));
                }
            }
        }
    }//method
    public static boolean specialCase(ASI_CRM_Anti_Bribery__c obj,ASI_CRM_Fix_Approval_Route__c fixApprover){
        boolean a = false;
        
        if(obj.ownerID == fixapprover.ASI_CRM_CN_Approver_1__c ||
           obj.OwnerID == fixapprover.ASI_CRM_CN_Approver_2__c ||
           obj.ownerID == fixapprover.ASI_CRM_CN_Approver_3__c ||
           obj.ownerID == fixapprover.ASI_CRM_CN_Approver_4__c ||
           obj.ownerID == fixapprover.ASI_CRM_CN_Approver_5__c ||
           obj.ownerID == fixapprover.ASI_CRM_CN_Approver_6__c){
               a = true;
           }
        return a;
    }
    public static void setFixedApprover(ASI_CRM_Anti_Bribery__c obj, Map<String, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix, Map<id, RecordType> mapRT, Boolean isVIP){
        
        String sysApprover;
        String fApprover;
        List<String> sysApproverList = new List<String>();
        integer k = 1;
        integer x = 0;
        
        for(integer i = 1 ; i <= 8 ; i++){
            
            sysApprover = 'ASI_CRM_Sys_Approver_'+ i +'__c';
            
            if(obj.get(sysApprover) == null){
                sysApproverList.add(sysApprover);
            }
        }
        
        while(k <= 6){
            
            fApprover = 'ASI_CRM_CN_Approver_'+ k +'__c';
            
            //20171110 Introv
            if(isVIP){
                
                if(MAppRouteFix.get('AB Policy VIP').get(fApprover) != Null){
                    obj.put(sysApproverList[x], MAppRouteFix.get('AB Policy VIP').get(fApprover));
                    x++;
                }
                
            //20171110 End
            }else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H' && obj.ASI_CRM_Reporting_Item__c!='Trip'){
                
                if(MAppRouteFix.get('Receiving G(non cash)&H-Non-Trip').get(fApprover) != Null){
                    obj.put(sysApproverList[x], MAppRouteFix.get('Receiving G(non cash)&H-Non-Trip').get(fApprover));
                    x++;
                }
            }else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'){
                
                if(MAppRouteFix.get('Receiving G(non cash)&H-Trip').get(fApprover) != Null){
                    obj.put(sysApproverList[x], MAppRouteFix.get('Receiving G(non cash)&H-Trip').get(fApprover));
                    x++;
                }
            }else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_PO_excl_FP'){
                
                if(MAppRouteFix.get('Offering PO(Non-Facilitation Fees)').get(fApprover) != Null){
                    obj.put(sysApproverList[x], MAppRouteFix.get('Offering PO(Non-Facilitation Fees)').get(fApprover));
                    x++;
                }
            }else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_Non_PO'){
                
                if(MAppRouteFix.get('Offering Non-PO').get(fApprover) != Null){
                    obj.put(sysApproverList[x], MAppRouteFix.get('Offering Non-PO').get(fApprover));
                    x++;
                }
            }else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                
                if(MAppRouteFix.get('Receiving Cash-Notification').get(fApprover) != Null){
                    obj.put(sysApproverList[x], MAppRouteFix.get('Receiving Cash-Notification').get(fApprover));
                    x++;
                }
            }
            
            if(x >= sysApproverList.size())
                break;
            
            k++;
        }
    }//method
    
    public static void userNotification(ASI_CRM_Anti_Bribery__c obj, Map<String, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix, Map<id, RecordType> mapRT){
        
        if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'&&obj.ASI_CRM_Reporting_Item__c!='Trip'){
                obj.put('ASI_CRM_Notification_User__c',MAppRouteFix.get('Receiving G(non cash)&H-Non-Trip').get('ASI_CRM_CN_Approver_1__c'));
            }
            else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'){
                obj.put('ASI_CRM_Notification_User__c',MAppRouteFix.get('Receiving G(non cash)&H-Trip').get('ASI_CRM_CN_Approver_1__c'));
            }
            else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_PO_excl_FP'){
                obj.put('ASI_CRM_Notification_User__c',MAppRouteFix.get('Offering PO(Non-Facilitation Fees)').get('ASI_CRM_CN_Approver_1__c'));
            }
            else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_Non_PO'){
                obj.put('ASI_CRM_Notification_User__c',MAppRouteFix.get('Offering Non-PO').get('ASI_CRM_CN_Approver_1__c'));
            }
            /*else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_H_Contract_OutletNPO'){
                obj.put('ASI_CRM_Notification_User__c',MAppRouteFix.get('Offering H- Contract Outlet(Non-PO)').get('ASI_CRM_CN_Approver_1__c'));
            }*/
    }
    
    public static void setDynamicApprover(ASI_CRM_Anti_Bribery__c obj, Map<ID, User> mapUser, Map<id, RecordType> mapRT, Map<String, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix, Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, Boolean VP){
        
        ID approverID;
        
        if(mapUser.containsKey(obj.OwnerID) && mapUser.get(obj.OwnerID).ManagerID != null)
            approverID = mapUser.get(obj.OwnerID).ManagerID;
        
        //boolean endLoop = false; //20170210, elufa
        Integer approverCount = 1;
        for(integer i = 1 ; i <= 50 ; i++){
            
            /*if(MAppRoute.containsKey(approverID) && MAppRoute.get(approverID).ASI_CRM_End_of_Dynamic_Route__c && ((VP && MAppRoute.get(approverID).ASI_CRM_Approval_Limit__c != Null && MAppRoute.get(approverID).ASI_CRM_Approval_Limit__c > 0) || (!VP))){
                if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                    obj.put('ASI_CRM_Sys_Approver_1__c',mapUser.get(obj.OwnerID).ManagerID);
                    obj.put('ASI_CRM_Sys_Approver_2__c',approverID);
                    
                }else
                    obj.put('ASI_CRM_Sys_Approver_1__c',approverID);
                
                break;
                
            }else if(endLoop){
                if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                    obj.put('ASI_CRM_Sys_Approver_2__c',approverID);
                    if(mapUser.containsKey(mapUser.get(obj.OwnerID).ManagerID))
                        obj.put('ASI_CRM_Sys_Approver_1__c',mapUser.get(mapUser.get(obj.OwnerID).ManagerID).id);
                }else
                    obj.put('ASI_CRM_Sys_Approver_1__c',approverID);
                
                break;
            }
            
            if(approverID != Null && mapUser.containsKey(approverID) && mapUser.containsKey(mapUser.get(approverID).ManagerID))
                approverID = mapUser.get(approverID).ManagerID;
            
            else{
                endLoop = true;
                if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_G_non_cash_H'){
                    approverID = MAppRouteFix.get('Receiving G(non cash)&H-Trip').ASI_CRM_CN_Approver_1__c;
                /*}else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Offering_H_Contract_OutletNPO'){
                    approverID = MAppRouteFix.get('Offering H- Contract Outlet(Non-PO)').ASI_CRM_CN_Approver_1__c;
                *//*}else if(mapRT.get(obj.RecordTypeId).DeveloperName == 'ASI_CRM_CN_Receiving_Cash'){
                    approverID = MAppRouteFix.get('Receiving Cash-Notification').ASI_CRM_CN_Approver_1__c;
                }else{
                    approverID = Null;
                }
            }*/ //20170210, elufa
            
            //20170210, elufa
            if(MAppRoute.containsKey(approverID))
            {
                if(!MAppRoute.get(approverID).ASI_CRM_End_of_Dynamic_Route__c)
                {
                    obj.put('ASI_CRM_Sys_Approver_'+approverCount+'__c',approverID);
                    approverCount++;
                    if(approverID != Null && mapUser.containsKey(approverID) && mapUser.containsKey(mapUser.get(approverID).ManagerID))
                    {
                        approverID = mapUser.get(approverID).ManagerID;
                    }
                    else
                    {
                        break;
                    }
                }
                else
                {
                    obj.put('ASI_CRM_Sys_Approver_'+approverCount+'__c',approverID);
                    break;
                }
            }
            else if(approverID != Null && mapUser.containsKey(approverID) && mapUser.containsKey(mapUser.get(approverID).ManagerID))
            {
                approverID = mapUser.get(approverID).ManagerID;
            }
            else
            {
                break;
            }
            //20170210, elufa
        }
    }
    
    //20161219, Leo@Elufa
  
    public static void routineBeforeDelete(List<ASI_CRM_Anti_Bribery__c> triggerOld)
    { 
        User curUser = [Select Id,Profile.Name FROM User WHERE Id =: userinfo.getUserId()];
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'ASI_CRM_CN_Anti_Bribery_Officer'].Id;
        List<GroupMember> gMembers 
            = new List<GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: groupId]);
        Set<Id> memberSet = new Set<Id>();
        for(GroupMember member: gMembers)
        {
            memberSet.add(member.UserOrGroupId);
        }
        for(ASI_CRM_Anti_Bribery__c obj : triggerOld)
        {
            if(!curUser.Profile.Name.contains('System Administrator')&&!memberSet.contains(curUser.Id))
            {
                if(!Test.isRunningTest())
                    obj.addError('Delete function was only allowed to AB Admin');
            }//end if
        }//end for
    }
    
    //20161219, Leo@Elufa
    
    //20171107, Ryan@introv
    public static void AfterInsertMethod(List<ASI_CRM_Anti_Bribery__c> triggerNew)
    {
        AutoSubmission(triggerNew); 
    }
    
    public static void AutoSubmission(List<ASI_CRM_Anti_Bribery__c> triggerNew)
    {
        list<ASI_CRM_Anti_Bribery__c> SubmitList = new list<ASI_CRM_Anti_Bribery__c>();
        Map<id,recordType> mapRT = new Map<id,recordType>([SELECT id,DeveloperName FROM RecordType WHERE sObjectType='ASI_CRM_Anti_Bribery__c']); 
        set<id> triggerNewID = new set<id>();
        Map<id,String> ErrorMsg = new Map<id,String>();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        
        for(ASI_CRM_Anti_Bribery__c obj : triggerNew)
        {
            triggerNewID.add(obj.id);
        }
        
        SubmitList = [select id, ASI_CRM_Auto_Submission_Flag__c, RecordTypeId,ASI_CRM_DynamicApproval__c,ASI_CRM_FixApproval__c 
                      from ASI_CRM_Anti_Bribery__c
                      where id in :triggerNewID
                      AND ASI_CRM_Auto_Submission_Flag__c = false
                     ]; 
        
        for(ASI_CRM_Anti_Bribery__c obj: SubmitList)
        {
            //if(obj.ASI_CRM_Auto_Submission_Flag__c == false)
            //{
                if(mapRT.get(obj.RecordTypeId).DeveloperName!='ASI_CRM_CN_Receiving_Cash' && (obj.ASI_CRM_DynamicApproval__c==true || obj.ASI_CRM_FixApproval__c==true)){
                    obj.ASI_CRM_Approval_Checkbox__c = true;
                }else{
                    obj.ASI_CRM_Status__c = 'Archived';
                }
            //}
        }
        
        update SubmitList;
        
        for(ASI_CRM_Anti_Bribery__c obj: SubmitList)
        {
            if(obj.ASI_CRM_Approval_Checkbox__c == true && obj.ASI_CRM_Status__c!= 'Archived')
            {
                if(obj.id!=null)
                {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(obj.id);
                    req1.setSubmitterId(UserInfo.getUserId());
                    requests.add(req1);
                }
            }
        }
        Approval.ProcessResult[] processResults = null;
        
        try {
            processResults = Approval.process(requests);
        }catch (System.DmlException e) {
            //triggerNew[0].adderror('Exception Is ' + e.getMessage());
        }
        
        if(processResults != Null){
            
            for(Approval.ProcessResult result :processResults)
            {
                if(!result.isSuccess())
                {               
                    ErrorMsg.put(result.getEntityId(),'Error: Record failed to submit for approval.');
                }
            }
        }
        
        for(ASI_CRM_Anti_Bribery__c obj : triggerNew)
        {
            if(ErrorMsg.containsKey(obj.id))
            {
                obj.adderror(ErrorMsg.get(obj.id));
            }
        }
    }
    //20171107, Ryan@introv
}