public with sharing class ASI_CRM_WS_Evaluation_TriggerClass {
//lokman 4/5/2014 
    public static void routineBeforeInsert(list<ASI_CRM_WS_Evaluation__c> trigger_new){
        
        Set<id> SAccountID = new Set<id>();
        Set<String> Region = new Set<String>();
        
        //20160223 Ben @ Elufa
        Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, ManagerID FROM User WHERE CompanyName = 'Pernod Ricard China']);
        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicApprover = new List<ASI_CRM_Dynamic_Approval_Route__c>([SELECT id, ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Type__c, ASI_CRM_User__c
                                                                                                               FROM ASI_CRM_Dynamic_Approval_Route__c
                                                                                                               WHERE recordType.developerName = 'ASI_CRM_CN_Dynamic_Approval_Route'
                                                                                                               AND ASI_CRM_Type__c = 'WS Evaluation'
                                                                                                              ]);
        Map<ID, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicApprover = new Map<ID,ASI_CRM_Dynamic_Approval_Route__c>();
        
        for(ASI_CRM_Dynamic_Approval_Route__c obj : dynamicApprover){
            mapDynamicApprover.put(obj.ASI_CRM_User__c, obj);
        }
        
        //20160203 End
        
        // Get involved outlet account additional field records
        for(ASI_CRM_WS_Evaluation__c r : trigger_new){
            //20160324 Ben @ Elufa
            if(r.ASI_CRM_Status__c == 'Draft'){
                setApproverToNull(r);
            }
            //20160324 End
            SAccountID.add(r.ASI_CRM_T1_WS_Addition__c);
        }
        // Query Account additional Field for sub-channel, region
        Map<id, ASI_CRM_AccountsAdditionalField__c> MAccount = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c a :[Select id, ASI_CRM_CN_Region__c
            from ASI_CRM_AccountsAdditionalField__c where id IN :SAccountID]){

                if(a.ASI_CRM_CN_Region__c != null && a.ASI_CRM_CN_Region__c != ''){
                    Region.add(a.ASI_CRM_CN_Region__c);
                    if(!MAccount.containsKey(a.id))
                        MAccount.put(a.id,a);
                }
            }
        
        // Query Fix approval route based on sub-channel, region -- 
        Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c r : [Select id, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Type__c,
            ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c ,ASI_CRM_CN_Approver_3__c ,ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c
            from ASI_CRM_Fix_Approval_Route__c where ASI_CRM_CN_Type__c = 'WS Evaluation' and ASI_CRM_CN_Region_Area_Channel__c IN :Region ]){
                MApprover.put(r.ASI_CRM_CN_Region_Area_Channel__c,r);
            }
            
        
        // Assign Approver
        for(ASI_CRM_WS_Evaluation__c r : trigger_new){
            
            //20160223 Ben @ Elufa
            if(r.ASI_CRM_Status__c == 'Draft'){
                Id approverId; 
                Integer i = 1;
                if(mapUser.containsKey(r.ownerId) && ( mapDynamicApprover.containsKey(r.ownerId) && !mapDynamicApprover.get(r.ownerId).ASI_CRM_End_of_Dynamic_Route__c || !mapDynamicApprover.containsKey(r.ownerId))){
                    approverId = mapUser.get(r.ownerId).managerId;
                    dynamicRoute(r, mapUser, mapDynamicApprover, approverId, i);
                }
                
                //20160223 End
                setApprovers(r, MAccount, MApprover);
            }
        }
    }
    
    //20160223 Ben @ Elufa

    Public Static void dynamicRoute(ASI_CRM_WS_Evaluation__c wsEvaluation, Map<Id, USer> mapUser, Map<Id, ASI_CRM_Dynamic_Approval_Route__c> mapDynamicApprover, Id approverId, Integer i){
        
        String sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';
        
        if((approverId != NULL && !mapUser.containsKey(approverId)) || i > 8){
            
            setApproverToNull(wsEvaluation);
        }else if( approverId != NULL && mapUser.containsKey(approverId) && ( mapDynamicApprover.containsKey(approverId) && !mapDynamicApprover.get(approverId).ASI_CRM_End_of_Dynamic_Route__c || !mapDynamicApprover.containsKey(approverId))){
            
            wsEvaluation.put(sysApprover, approverId);
            approverId = mapUser.get(approverId).managerId;
            i++;
            dynamicRoute(wsEvaluation, mapUser, mapDynamicApprover, approverId, i);
            
        }else if(approverId != NULL && mapUser.containsKey(approverId) && ( mapDynamicApprover.containsKey(approverId) && mapDynamicApprover.get(approverId).ASI_CRM_End_of_Dynamic_Route__c)){
            
            wsEvaluation.put(sysApprover, approverId);
            
        }
    }
    
    //20160223 End
    
    public static void setApprovers(ASI_CRM_WS_Evaluation__c request, Map<id, ASI_CRM_AccountsAdditionalField__c> MAccount, Map<string, ASI_CRM_Fix_Approval_Route__c> MApprover){
        if(request != null && MAccount != null && MApprover != null){
            if(request.ASI_CRM_T1_WS_Addition__c!= null  & MAccount.containsKey(request.ASI_CRM_T1_WS_Addition__c)){
                ASI_CRM_AccountsAdditionalField__c accountAddField = MAccount.get(request.ASI_CRM_T1_WS_Addition__c);
                
                //20160223 Ben @ Elufa
                List<String> sysApproverList = new List<String>();
                for(integer i = 1 ; i <= 8 ; i++){
                    
                    String sysApprover = 'ASI_CRM_Sys_Approver_' + i + '__c';
                    if(request.get(sysApprover) == NULL){
                        sysApproverList.add(sysApprover);
                    }
                }
                //20160223 End
                
                // Assign approver 1 (region)
                if(accountAddField.ASI_CRM_CN_Region__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Region__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Region__c);
                    if(approver != null){
                        //request.ASI_CRM_Sys_Approver_3__c = approver.ASI_CRM_CN_Approver_1__c; //20160223 Ben @ Elufa
                        for(Integer i = 0 ; i < sysApproverList.size() ; i++){
                            if(i < 6){
                                String fixApprover = 'ASI_CRM_CN_Approver_' + (i + 1) + '__c';
                                request.put(sysApproverList[i], approver.get(fixApprover));
                            }else{
                                break;
                            }
                        }
                        //20160223 Ben @ Elufa
                    }
                }
                
                /*// Assign approver 2 (region)
                if(accountAddField.ASI_CRM_CN_Region__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Region__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Region__c);
                    if(approver != null){
                        request.ASI_CRM_Sys_Approver_4__c = approver.ASI_CRM_CN_Approver_2__c;
                    }
                }
                // Assign approver 3 (region)
                if(accountAddField.ASI_CRM_CN_Region__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Region__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Region__c);
                    if(approver != null){
                        request.ASI_CRM_Sys_Approver_5__c = approver.ASI_CRM_CN_Approver_3__c;
                    }
                }
                // Assign approver 4 (region)
                if(accountAddField.ASI_CRM_CN_Region__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Region__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Region__c);
                    if(approver != null){
                        request.ASI_CRM_Sys_Approver_6__c= approver.ASI_CRM_CN_Approver_4__c;
                    }
                }
                //20160201 Ben @ Elufa
                if(accountAddField.ASI_CRM_CN_Region__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Region__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Region__c);
                    if(approver != null){
                        request.ASI_CRM_Sys_Approver_7__c= approver.ASI_CRM_CN_Approver_5__c;
                    }
                }
                if(accountAddField.ASI_CRM_CN_Region__c != null && MApprover.containsKey(accountAddField.ASI_CRM_CN_Region__c)){
                    ASI_CRM_Fix_Approval_Route__c approver = MApprover.get(accountAddField.ASI_CRM_CN_Region__c);
                    if(approver != null){
                        request.ASI_CRM_Sys_Approver_8__c= approver.ASI_CRM_CN_Approver_6__c;
                    }
                }*/
                //20160201 End
            }
        }
    }
    
    /*
    public static void setApproverByCount(ASI_CRM_Image_Outlet_Request__c p, integer approver_count, Id userId)
    {
        if(approver_count == 0){
            p.ASI_CRM_Sys_Approver_Region__c = userId;
        }
        else if(approver_count == 1){
            p.ASI_CRM_Sys_Approver_Channel__c = userId;
        }        
    }
    */
    
    public static void setApproverToNull(ASI_CRM_WS_Evaluation__c p){
        //20160201 Ben @ Elufa
        p.ASI_CRM_Sys_Approver_8__c= null;
        p.ASI_CRM_Sys_Approver_7__c= null;
        p.ASI_CRM_Sys_Approver_6__c= null;
        p.ASI_CRM_Sys_Approver_5__c= null;
        //20160201 End
        p.ASI_CRM_Sys_Approver_4__c= null;
        p.ASI_CRM_Sys_Approver_3__c= null;
        p.ASI_CRM_Sys_Approver_2__c= null;
        p.ASI_CRM_Sys_Approver_1__c= null; 
    }
}