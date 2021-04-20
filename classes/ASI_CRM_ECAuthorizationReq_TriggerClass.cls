/***************************************************************************************************************************
 * Name:        ASI_CRM_ECAuthorizationReq_TriggerClass
 * Description: Apex class for ASI_CRM_ECAuthorizationReq_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-05-09       Rutuja Bardapurkar          Created
 ****************************************************************************************************************************/


public class ASI_CRM_ECAuthorizationReq_TriggerClass {
   
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        User u = ASI_CRM_CN_Function.getUser(curUserId);
        if(u != null && u.BypassTriggers__c != null){
            if (u.BypassTriggers__c.contains('ASI_CRM_ECAuthorizationReq_TriggerClass') && !Test.isRunningTest()){
                isByPass = true;
            }
        }
        return isByPass;
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_EC_AUTHORIZATION_REQUEST__c> trigger_new, map<id, ASI_CRM_EC_AUTHORIZATION_REQUEST__c> trigger_oldMap, boolean isInsert) {
        System.debug('ASI_CRM_ECAuthorizationReq_TriggerClass.routineBeforeUpdate!');
        System.debug(isBypassByCurrentUser());
        //Decimal SingleContractAmount = 0;
        boolean isUpdate = False;
        if(!isBypassByCurrentUser()){
            
            Set<ID> payID = new Set<ID>();
            Map<String, String> mapRejectedComment = new Map<String, String>();
            
            
            for(ASI_CRM_EC_AUTHORIZATION_REQUEST__c obj : trigger_new){
                //SingleContractAmount=ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(obj);
                if(!isInsert){
                if(trigger_oldMap.get(obj.id).ASI_CRM_Status__c == 'Submitted' && obj.ASI_CRM_Status__c == 'Draft'){
                    System.debug('31 '+obj.ASI_CRM_Status__c );
                    payID.add(obj.id);
                }
                    if(trigger_oldMap.get(obj.id).ASI_CRM_Status__c == 'Draft' && (obj.ASI_CRM_Status__c == 'Submitted' || obj.ASI_CRM_Status__c == 'Approved') || ( trigger_oldMap.get(obj.id).ASI_CRM_Status__c == 'Approved' && obj.ASI_CRM_Status__c == 'Submitted') || ( trigger_oldMap.get(obj.id).ASI_CRM_Status__c == 'Submitted' && obj.ASI_CRM_Status__c == 'Approved')){
               			isUpdate = True;
                    }
                }
                    else{
                        if( obj.ASI_CRM_Status__c == 'Draft'){
                            System.debug('35 '+obj.ASI_CRM_Status__c );
                            payID.add(obj.id);
                        }
                    }
            
            }
            system.debug('payId43 ' + payID);
            if(payID.size() > 0){
                List<ProcessInstance> processIn = new List<ProcessInstance>([SELECT Id, TargetObjectId, Status, (SELECT Comments FROM Steps WHERE StepStatus = 'Rejected') FROM ProcessInstance WHERE TargetObjectId IN : payID AND Status = 'Rejected' ORDER BY CompletedDate DESC]);
                if(processIn.size() > 0){
                    for(ProcessInstance obj : processIn){
                        for(ProcessInstanceStep obj2 : obj.Steps){
                            if(!mapRejectedComment.containsKey(obj.TargetObjectId)){
                                if(obj2.Comments != null && obj2.Comments != '')
                                    mapRejectedComment.put(obj.TargetObjectId, obj2.Comments);
                            }
                        }
                    }
                    
                }
            }
            
            // Assign Approver
            Map<String, String> Last_version= new Map<String, String>();
            Map<id, User> MUser = new Map<id, User>();
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            
            Set<id> SContractID = new Set<id>();
            Set<id> SIHBR = new Set<id>();
            Set<id> SNational = new Set<id>();
            
            Map<string, boolean> MPromotionType = new Map<string, boolean>();
            List<ASI_CRM_SpecialPromotionTypeSetting__c> LPromotionalType = [SELECT id, ASI_CRM_Promotion_Type__c, ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c
                                                                             FROM ASI_CRM_SpecialPromotionTypeSetting__c];
            for(ASI_CRM_SpecialPromotionTypeSetting__c p : LPromotionalType){
                MPromotionType.put(p.ASI_CRM_Promotion_Type__c, p.ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c);
            }
            
            //  limit set approver when status is draft
            Boolean needSetApprover = false;
            /*for(ASI_CRM_EC_AUTHORIZATION_REQUEST__c contract : trigger_new){
                if(contract.ASI_CRM_Status__c == 'Draft'){
                    SContractID.add(contract.id);
                    needSetApprover = true;
                    break;
                }
            }*/
            // find the manager from hierarchy if it is not included in dynamic route
            
                List<ASI_CRM_Dynamic_Approval_Route__c> LApp = [SELECT id, ASI_CRM_Approval_Limit__c, ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c
                                                                FROM ASI_CRM_Dynamic_Approval_Route__c
                                                                WHERE ASI_CRM_Type__c = 'EC Authorization Request'];
                
                List<User> LUser = [SELECT id, ManagerID, ASI_CRM_Sales_Team__c FROM User WHERE IsActive = true /*WHERE CompanyName = 'Pernod Ricard China'*/];
                for(User u : LUser){
                    MUser.put(u.id, u);
                }
                
                for(ASI_CRM_Dynamic_Approval_Route__c a : LApp){
                    MAppRoute.put(a.ASI_CRM_User__c, a);
                }
                LApp = null;
                
                
                //  checking IHBR flag and National Group Contract Flag
                //List<ASI_CRM_EC_AUTHORIZATION_REQUEST__c> LFlag = [SELECT id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_Return_Flag__c  FROM ASI_CRM_EC_AUTHORIZATION_REQUEST__c WHERE id IN:SContractID];
                
                List<ASI_CRM_Fix_Approval_Route__c> LFApp;
                
                
                String ApprovalRouteType = 'EC Authorization Request';
                /* if (trigger_new[0].ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO') {
ApprovalRouteType = 'TOT/MOT Group Contract' ;
}*/
                
                LFApp = [SELECT Id,ASI_CRM_RVP__c,ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_Max_Amount__c, ASI_CRM_CN_Entry_Limit__c,ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,
                         ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c, ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approver_7__c,ASI_CRM_CN_Approver_8__c,ASI_CRM_CN_Approver_9__c,ASI_CRM_CN_Approver_10__c,ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                         ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c,ASI_CRM_CN_Approval_Limit_7__c,ASI_CRM_CN_Approval_Limit_8__c,ASI_CRM_CN_Approval_Limit_9__c,ASI_CRM_CN_Approval_Limit_10__c,ASI_CRM_CN_Approval_Limit_11__c,
                         ASI_CRM_CN_Type__c, ASI_CRM_CN_Regional_BA__c, ASI_CRM_Sales_Team__c , ASI_CRM_Commercial_Team__c
                         FROM ASI_CRM_Fix_Approval_Route__c WHERE ASI_CRM_CN_Type__c = : ApprovalRouteType ];
                
                
                for(ASI_CRM_Fix_Approval_Route__c a : LFApp){
                    // Boolean AllowPush= false;
                    String commercialTeam = a.ASI_CRM_Commercial_Team__c != null && a.ASI_CRM_Commercial_Team__c != '' ? a.ASI_CRM_Commercial_Team__c : ''; // if(AllowPush){
                    MAppLastRouteFix.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                    system.debug('MAppLastRouteFix' + MAppLastRouteFix);
                }
                
                LFApp = null;
            
            
            
            Set<String> SPONoClone = new Set<String>();
            Set<String> SUpdatingRecID = new Set<String>();
            
            for(ASI_CRM_EC_AUTHORIZATION_REQUEST__c EAR : trigger_new){
                // limit set approver when status is draft
                    setApproverToNull(EAR);
                    
                    setApprovers(EAR, MAppRouteFix, MAppRoute,MAppLastRouteFix, MUser, MPromotionType, isInsert, isUpdate);
                
            }
            
            
            List<ASI_CRM_EC_AUTHORIZATION_REQUEST__c> clonedContracts = new List<ASI_CRM_EC_AUTHORIZATION_REQUEST__c>();
            
            
            List<ASI_CRM_Approval_Comment__c> LPOContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>(); //Twinkle 11/26/2014
            
            
        }
        
    }
    
   

public static void setApprovers(ASI_CRM_EC_AUTHORIZATION_REQUEST__c p, Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix,
                                Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute,
                                Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix,
                                Map<id, User> MUser, Map<String, boolean> MPromotionType, boolean isInsert, boolean isUpdate)
{
    
   
    Integer approver_count = 0;
    Integer return_approver_count = 0;
    
    List<ASI_CRM_EC_AUTHORIZATION_REQUEST__c> LContract = [SELECT id, ASI_CRM_Customer_Name__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_Customer_Name__r.ASI_CRM_CN_CRM_Code__c, OwnerId
                                                           FROM ASI_CRM_EC_AUTHORIZATION_REQUEST__c  WHERE id =:p.id];
    
    system.debug('LContract' + LContract.size() + LContract);
    
    // First Fix Route
    id ownerId = p.ownerID;
    User userRecords = [SELECT id, Managerid, name FROM User WHERE id=: ownerId];
    boolean proceed = true;
    id currentUserid = userRecords.ManagerId;
    
    ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
    User currentApproverU = null;
    
    //**************************************Dynamic Route**************************************
   
    while(proceed){
       
        if(currentUserid != null && (MAppRoute.containsKey(currentUserid) || MUser.containsKey(currentUserid))){
            if(MAppRoute.get(currentUserid) != null){
                currentApprover = MAppRoute.get(currentUserid);
                currentUserid = currentApprover.ASI_CRM_Manager_ID__c;
            }else{
                if(MUser.get(currentUserid) != null){
                    
                    currentApproverU = MUser.get(currentUserid);
                    currentUserid = currentApproverU.ManagerID;
                }
            }
            
            if(currentApprover != null && currentApproverU == null){
                    system.debug('currentApprover.ASI_CRM_User__c ' + currentApprover.ASI_CRM_User__c);
                setApproverByCount(p, approver_count, currentApprover.ASI_CRM_User__c);
            }else if(currentApprover == null && currentApproverU != null){
                    system.debug('currentApproverU.id ' + currentApproverU.id);
                setApproverByCount(p, approver_count, currentApproverU.id);
            }
            
            approver_count++;
            if(currentApprover != null){
                if( currentApprover.ASI_CRM_End_of_Dynamic_Route__c){
                    proceed = false;
                }
            }
            currentApprover = null;
            currentApproverU = null;
        }else{
            proceed = false;
        }
    }
System.debug('263 MAppLastRouteFix'+MAppLastRouteFix);    
    //************************************second fix  Route************************************
    ASI_CRM_Fix_Approval_Route__c fixApprover2;
    ID curUserId = UserInfo.getUserId();
  //for(ASI_CRM_EC_AUTHORIZATION_REQUEST__c c: LContract ){
  if(isInsert){
        if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
            fixApprover2 =MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);
        }
  }
    else if (isUpdate) {
        if(MUser.containsKey(curUserId) && MUser.get(curUserId).ASI_CRM_Sales_Team__c != null){
            
            fixApprover2 =MAppLastRouteFix.get(MUser.get(curUserId).ASI_CRM_Sales_Team__c);
        }
    }
 //   }
    System.debug('273 MUser'+MUser);    

      
    system.debug('p.ownerID' + p.ownerID);
    system.debug('fixApprover2'  +fixApprover2);
    
    if(fixApprover2 != null ){
        //set Return Approvers
        if(fixApprover2 .ASI_CRM_CN_Approver_1__c != null){
            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
            approver_count++;
        }
        system.debug('fixApprover2.ASI_CRM_RVP__c' + fixApprover2.ASI_CRM_RVP__c);
        if(/*p.ASI_CRM_RVP_Approval__c && */ fixApprover2.ASI_CRM_RVP__c!=null){
            Boolean FoundRVP=false;//ASI_CRM_RVP__c
            Boolean AllowPut=false;
                    system.debug('inside iff ASI_CRM_RVP__c ');
                        system.debug('FoundRVP' + FoundRVP);
                        system.debug('approver_count' + approver_count);
            
            //Approver_2
            if(fixApprover2 .ASI_CRM_CN_Approver_2__c != null){
                    if(!FoundRVP){ //Have not found RVP
                        if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_2__c){
                            FoundRVP=true;
                        }
                        AllowPut=true;
                    }
                }
                if(AllowPut){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                    approver_count++;
                    
                }
                        system.debug('FoundRVP' + FoundRVP);

                //Approver_3
                AllowPut=false;
                if(fixApprover2 .ASI_CRM_CN_Approver_3__c != null){
                    if(!FoundRVP){ //Have not found RVP
                        if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_3__c){
                            FoundRVP=true;
                        }
                        AllowPut=true;
                    }
                }
                if(AllowPut){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                    approver_count++;
                   
                }
                        system.debug('FoundRVP' + FoundRVP);

                //Approver_4
                AllowPut=false;
                if(fixApprover2 .ASI_CRM_CN_Approver_4__c != null){
                    if(!FoundRVP){ //Have not found RVP
                        if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_4__c){
                            FoundRVP=true;
                        }
                        AllowPut=true;
                    }
                }
                if(AllowPut){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                    approver_count++;
                    
                }
		//Approver_5
                AllowPut=false;
            system.debug('FoundRVP' + FoundRVP);
                if(fixApprover2 .ASI_CRM_CN_Approver_5__c != null){
                    if(!FoundRVP){ //Have not found RVP
                        if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_5__c){
                            FoundRVP=true;
                        }
                        AllowPut=true;
                    }
                }
                if(AllowPut){
                    setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                    approver_count++;
                }
            } 
          
    }
     
}

public static void setApproverToNull(ASI_CRM_EC_AUTHORIZATION_REQUEST__c p){
    p.ASI_CRM_Approver_1__c = null;
    p.ASI_CRM_Approver_2__c = null;
    p.ASI_CRM_Approver_3__c = null;
    p.ASI_CRM_Approver_4__c = null;
    p.ASI_CRM_Approver_5__c = null;
    p.ASI_CRM_Approver_6__c = null;
    
}

public static void setApproverByCount(ASI_CRM_EC_AUTHORIZATION_REQUEST__c p, integer approver_count, Id userId)
{
    system.debug('userId ' + userId);
    if(approver_count == 0){
        p.ASI_CRM_Approver_1__c = userId;
    	system.debug('p.ASI_CRM_Approver_1__c ' + p.ASI_CRM_Approver_1__c);
    }
    else if(approver_count == 1){
        system.debug('Here 2');
        p.ASI_CRM_Approver_2__c = userId;
    
    }
    else if(approver_count == 2){
        p.ASI_CRM_Approver_3__c = userId;
               system.debug('Here 3');

    }
    else if(approver_count == 3){
               system.debug('Here 4');
        p.ASI_CRM_Approver_4__c = userId;
        
    }
    else if(approver_count == 4){
        p.ASI_CRM_Approver_5__c = userId;
        
    }
    else if(approver_count == 5){
        p.ASI_CRM_Approver_6__c = userId;
       
    }
    
    
}

}