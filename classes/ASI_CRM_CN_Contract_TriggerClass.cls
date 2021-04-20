/* Filename:    ASI_CRM_CN_Contract_TriggerClass.cls
* Author:      Michael Yip (Introv Limited)
* Purpose:     CRM CN Contract Trigger Class
*
*
* History
* -----------------------------------------------------------------------------
* 2012-04-27   michael.yip@introv.com      Created
* 2014-06-23   michael.yip@introv.com      Added checking for overlapping contract start/end date date for ON/Off except RTD or soa prasis owned historical record
* 2014-08-28   michael.yip@introv.com      Limit set approver to draft status contract
* 2014-09-19   michael.yio@introv.com      Fix Contract No Generation for PO Modification
* 2014-09-26   twinkle.li@introv.com       National Group Contract and IHBR Approval process, additional Regional BA for approval process
* 2014-10-20   twinkle.li@introv.com       Put the managers even that are not included in Dynamic Route into the approval process
* 2014-10-31   twinkle.li@introv.com       Asign Regional BA into the approval process if Add "RBA as Final Approver (V0.0)" is checked
* 2014-11-24   twinkle.li@introv.com       Insert an Approval comment with "CN New Contract Comment" record type when new a Contract
*/

public without sharing class ASI_CRM_CN_Contract_TriggerClass{
    
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        
        
        //Edited by Michael Yip (Introv) 04Jul2014 moving the query user to 'ASI_CRM_CN_Function' for reducting soql
        User u = ASI_CRM_CN_Function.getUser(curUserId);           
        if(u != null && u.BypassTriggers__c != null){
            if (u.BypassTriggers__c.contains('ASI_CRM_CN_Contract_TriggerClass') && !Test.isRunningTest()){
                isByPass = true;
            }
        }
        
        
        return isByPass;
    }
    
    public static void routineBeforeUpsert(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        if(!isBypassByCurrentUser()){
            // Added by Michael Yip (Introv) 21Jun2014 for update contract status (th) with cn
            copyContractStatus(trigger_new);
            
            // Added by Michael Yip (Introv) 14Jun2014 update exchange rate
            UpdateExRate(trigger_new,trigger_oldMap);
            
            // Added by Michael Yip (Introv) 23Jun2014 check overlap
            checkOverlap(trigger_new,trigger_oldMap);
            
            //Added by Kendy.Tam (Introv) 2014-06-27 generate Contract No.
            //if(!isBypassByCurrentUser()){
            generateContractNo(trigger_new);
        }
    }
    
    private static void generateContractNo(List<ASI_TH_CRM_Contract__c> trigger_new){
        Map<String,String> outletIdMap = new Map<String,String>();
        Map<String,String> crmCodeMap = new Map<String,String>();
        Map<String,String> contractNoMap = new Map<String,String>();
        Map<String,String> outletIdCrmCodeMap = new Map<String,String>();
        Map<String,Integer> crmCodeNoMap = new Map<String,Integer>();
        
        for (ASI_TH_CRM_Contract__c contract:trigger_new) {
            outletIdMap.put(contract.ASI_CRM_CN_Outlet_WS__c,contract.ASI_CRM_CN_Outlet_WS__c);         
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Id,ASI_CRM_CN_CRM_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id IN :outletIdMap.keySet()];
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customers){
            crmCodeMap.put(customer.ASI_CRM_CN_CRM_Code__c,customer.ASI_CRM_CN_CRM_Code__c);
            outletIdCrmCodeMap.put(customer.Id,customer.ASI_CRM_CN_CRM_Code__c);
        }
        String sameDate = '%' + Datetime.now().format('yyyyMMdd') +'%';
        //List<ASI_TH_CRM_Contract__c> contracts = [SELECT Id,Name, ASI_TH_CRM_Contract_External_ID__c ,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Return_Flag__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c IN :crmCodeMap.keySet() AND CreatedDate = TODAY AND ASI_CRM_CN_Status__c <> 'Archived' ORDER BY CreatedDate DESC];
        List<ASI_TH_CRM_Contract__c> contracts = [SELECT Id,Name, ASI_TH_CRM_Contract_External_ID__c ,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Return_Flag__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c IN :crmCodeMap.keySet() AND Name like :sameDate AND ASI_CRM_CN_Status__c <> 'Archived' AND (NOT ASI_CRM_CN_Status__c LIKE 'FY landing Archive') ORDER BY CreatedDate DESC];
        //20170210 Elufa added 'FY landing Archive'
        System.debug(contracts);
        
        for(ASI_TH_CRM_Contract__c contract:contracts){
            if(!contractNoMap.keySet().contains(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c)){
                contractNoMap.put(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c,contract.Name);
            }  
        }
        
        System.debug(contractNoMap);
        for (ASI_TH_CRM_Contract__c contract:trigger_new) {
            System.debug(contract);
            if (contract.CreatedDate == null){
                String crmCode = outletIdCrmCodeMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
                System.debug(crmCode);
                Integer no = crmCodeNoMap.get(crmCode);
                System.debug(no);
                if(no == null){
                    no = 0;
                    if(contractNoMap.keySet().contains(crmCode)){
                        String contractNo = contractNoMap.get(crmCode);
                        String[] contractNoDiv = contractNo.split('\\.',0);
                        System.debug(contractNoDiv);
                        if(contractNoDiv.size()>1)
                            no = Integer.valueOf(contractNoDiv[1]) + 1; 
                    }               
                }else{
                    no = no + 1;
                }
                crmCodeNoMap.put(crmCode,no);
                System.debug(no);    
                Integer poVersionNo = 0;
                if(contract.ASI_CRM_CN_PO_Version__c != null){
                    String[] poVersion = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
                    poVersionNo = Integer.valueOf(poVersion[1]);
                } 
                //2014-11-27 Added by wilson to fix the PO modification number generation error issue
                if(contract.Name == 'Automated, Do not Change')
                    contract.Name = crmCode + '.' + no + '.' + Datetime.now().format('yyyyMMdd') + '.' + poVersionNo;
                System.debug(contract.name);
            }
        }
        
    }
    
    //Updated by Twinkle 11/24/2014 - insert a new Approval Comment
    public static void routineAfterInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!isBypassByCurrentUser()){
            //####### Contract Cost (start) #######                
            List<ASI_CRM_Contract_Cost__c> LContractCost_Insert = new List<ASI_CRM_Contract_Cost__c>();            
            List<ASI_CRM_Approval_Comment__c> LNewContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
            
            //----- get Contract Cost Setting List -----//
            //ASI_CRM_CN_Activity_Code__c
            List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList = [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c,
                                                                               ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c, 
                                                                               ASI_CRM_CN_Other_Cost_Payment_Request__c 
                                                                               FROM ASI_CRM_Contract_Cost_Setting__c];
            
            if(LContractCostSettingList.size() > 0 && trigger_new[0].ASI_CRM_CN_PO_Version__c=='0.0') {
                
                for (ASI_TH_CRM_Contract__c contract:trigger_new) {
                    if(contract.ASI_CRM_CN_IsClone__c == null || contract.ASI_CRM_CN_IsClone__c == false)
                    {
                        //----- check "contract" with "contract cost setting" -----
                        for (ASI_CRM_Contract_Cost_Setting__c ccs:LContractCostSettingList) {
                            if(contract.ASI_TH_CRM_Promotion_Type__c == ccs.ASI_CRM_CN_Promotion_Type__c)
                            {
                                if((ccs.ASI_CRM_CN_Fixed_Cost_Contract__c != null && ccs.ASI_CRM_CN_Fixed_Cost_Contract__c == true) || (ccs.ASI_CRM_CN_Variable_Cost_Contract__c != null && ccs.ASI_CRM_CN_Variable_Cost_Contract__c == true)) {
                                    //----- create a "Contract Cost" object for the "Contract" -----
                                    ASI_CRM_Contract_Cost__c newCS = CreateContractCostObjByContract(contract, ccs);
                                    // Added by Laputa : for Heavy Contract On only add fixed Contract Cost
                                    if(contract.ASI_TH_CRM_Promotion_Type__c== 'Heavy Contract On' && ccs.ASI_CRM_CN_Fixed_Cost_Contract__c){
                                        LContractCost_Insert.add(newCS);
                                    }else{
                                        LContractCost_Insert.add(newCS);
                                    }
                                    
                                }                   
                            }
                        }
                    }
                    if(Global_RecordTypeCache.getRt(contract.recordTypeId) != null && Global_RecordTypeCache.getRt(contract.recordTypeId).developerName.contains('ASI_CRM_CN_Contract') && contract.ASI_CRM_CN_Status__c == 'Draft' && contract.ASI_CRM_CN_PO_Version__c == '0.0'){
                        LNewContractComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c = contract.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')));
                    }
                }
                
                if(LContractCost_Insert !=null && LContractCost_Insert.size() > 0) 
                    insert LContractCost_Insert;
                
                if(LNewContractComment_Insert !=null && LNewContractComment_Insert.size() > 0) 
                    insert LNewContractComment_Insert;
                
            }
            //####### Contract Cost (end) #######
        }
        
        
    }
    
    public static void routineBeforeInsert(list<ASI_TH_CRM_Contract__c> trigger_new){
        // Added by Michael Yip (Introv) 14Jun2014 update exchange rate
        // UpdateExRate(trigger_new,null);        
        
    }   
    
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        
        if(!isBypassByCurrentUser()){
            
            //20151210 Ben @ Elufa System
            Set<ID> payID = new Set<ID>();
            Map<String, String> mapRejectedComment = new Map<String, String>();
            
            for(ASI_TH_CRM_Contract__c obj : trigger_new){
                if(trigger_oldMap.get(obj.id).ASI_CRM_CN_Status__c == 'Submitted' && obj.ASI_CRM_CN_Status__c == 'Draft'){
                    payID.add(obj.id);
                }
            }
            
            if(payID.size() > 0){
                List<ProcessInstance> processIn = new List<ProcessInstance>([SELECT Id, TargetObjectId, Status, (SELECT Comments FROM Steps WHERE StepStatus = 'Rejected') FROM ProcessInstance where TargetObjectId IN : payID AND Status = 'Rejected' ORDER BY CompletedDate DESC]);
                if(processIn.size() > 0){
                    for(ProcessInstance obj : processIn){
                        for(ProcessInstanceStep obj2 : obj.Steps){
                            if(!mapRejectedComment.containsKey(obj.TargetObjectId)){
                                if(obj2.Comments != NULL && obj2.Comments != '')
                                    mapRejectedComment.put(obj.TargetObjectId, obj2.Comments);
                            }
                        }
                    }
                    for(ASI_TH_CRM_Contract__c obj : trigger_new){
                        if(mapRejectedComment.containsKey(obj.id) && obj.ASI_CRM_CN_Approval_Status__c == 'Rejected' && trigger_oldMap.get(obj.id).ASI_CRM_CN_Approval_Status__c == 'Submitted'){
                            obj.ASI_CRM_CN_Return_Comments__c = ( (/*trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c*/obj.ASI_CRM_Branch__c == 'returned') ? 'Returned-': 'Rejected-')  + mapRejectedComment.get(obj.id);
                            /*obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment : ' : 'Reject Comment : ') + mapRejectedComment.get(obj.id) : obj.ASI_CRM_Reject_Return_Comments__c + '\n' + ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment : ' : 'Reject Comment : ' ) + mapRejectedComment.get(obj.id);*/
                            //obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment / ': 'Reject Comment / ') + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id) :  ( (trigger_oldMap.get(obj.id).ASI_CRM_CN_Return_Flag__c && !obj.ASI_CRM_CN_Return_Flag__c) ? 'Return Comment / ': 'Reject Comment / ')  + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id)+ '\n' + obj.ASI_CRM_Reject_Return_Comments__c;
                            //20160929, edited by Leo
                            obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ') + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id) :  ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ')  + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id)+ '\n' + obj.ASI_CRM_Reject_Return_Comments__c;
                        }
                    }
                }
            }
            //20151210 End
            
            // Added by Michael Yip (Introv) 3May2014 Assign Approver       
            Map<String, String> Last_version= new Map<String, String>();//lokman 22/5/2014
            Map<id, User> MUser = new Map<id, User>(); //Twinkle 20/10/2014
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            
            //Twinkle 26/9/2014
            Set<id> SContractID = new Set<id>(); 
            Set<id> SIHBR = new Set<id>(); 
            Set<id> SNational = new Set<id>(); 
            
            //Added by Twinkle 31/10/2014
            Map<string, boolean> MPromotionType = new Map<string, boolean>();      
            List<ASI_CRM_SpecialPromotionTypeSetting__c> LPromotionalType = [Select id, ASI_CRM_Promotion_Type__c, ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c
                                                                             From ASI_CRM_SpecialPromotionTypeSetting__c]; 
            for(ASI_CRM_SpecialPromotionTypeSetting__c p : LPromotionalType){
                MPromotionType.put(p.ASI_CRM_Promotion_Type__c, p.ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c);                    
            }
            //End by Twinkle 31/10/2014
            
            // Updated by Michael Yip (Introv) 28Aug2014 to limit set approver when status is draft
            Boolean needSetApprover = false;
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                if(contract.ASI_CRM_CN_Status__c == 'Draft'){
                    SContractID.add(contract.id);
                    needSetApprover = true;
                    break;
                }
            }
            // Updated by Twinkle Li (Introv) 20Oct2014 to find the manager from hierarchy if it is not included in dynamic route
            if(needSetApprover){
                List<ASI_CRM_Dynamic_Approval_Route__c> LApp = [Select id, ASI_CRM_Approval_Limit__c,
                                                                ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c
                                                                from ASI_CRM_Dynamic_Approval_Route__c 
                                                                where ASI_CRM_Type__c = 'Contract'];
                
                List<User> LUser = [Select id, ManagerID, ASI_CRM_Sales_Team__c from User Where CompanyName = 'Pernod Ricard China'];
                for(User u : LUser){
                    MUser.put(u.id, u);
                }            
                
                for(ASI_CRM_Dynamic_Approval_Route__c a : LApp){
                    MAppRoute.put(a.ASI_CRM_User__c, a);
                }
                LApp = null;
                System.debug(MAppRoute);
                
                // Added by Twinkle Li (Introv) 26Sept2014 for checking IHBR flag and National Group Contract Flag
                List<ASI_TH_CRM_Contract__c> LFlag = [Select id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_Return_Flag__c
                                                      from ASI_TH_CRM_Contract__c
                                                      where id IN:SContractID];
                
                List<ASI_CRM_Fix_Approval_Route__c> LFApp;                          
                LFApp = [Select ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Entry_Limit__c,
                         ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,
                         ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,  ASI_CRM_CN_Approver_7__c, ASI_CRM_CN_Approver_8__c, ASI_CRM_CN_Approver_9__c, ASI_CRM_CN_Approver_10__c, 
                         ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                         ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c,ASI_CRM_CN_Approval_Limit_7__c,ASI_CRM_CN_Approval_Limit_8__c,ASI_CRM_CN_Approval_Limit_9__c,ASI_CRM_CN_Approval_Limit_10__c,
                         ASI_CRM_CN_Type__c, ASI_CRM_CN_Regional_BA__c
                         , ASI_CRM_Sales_Team__c //20160819, added by Leo
                         , ASI_CRM_Commercial_Team__c //20161118 Elufa
                         from ASI_CRM_Fix_Approval_Route__c
                         where ASI_CRM_CN_Type__c = 'Contract 1st Part' or ASI_CRM_CN_Type__c = 'Contract 2nd Part' 
                         or ASI_CRM_CN_Type__c = 'National Group Contract 1st Part' or ASI_CRM_CN_Type__c = 'National Group Contract 2nd Part'
                         or ASI_CRM_CN_Type__c = 'Contract (IHBR) 1st' or ASI_CRM_CN_Type__c = 'Contract (IHBR) 2nd']; 
                
                for(ASI_CRM_Fix_Approval_Route__c a : LFApp){
                    
                    String commercialTeam = a.ASI_CRM_Commercial_Team__c != Null && a.ASI_CRM_Commercial_Team__c != '' ? a.ASI_CRM_Commercial_Team__c : '';//20161118 Elufa
                    

                    //20160819, added by Leo
                    if(a.ASI_CRM_CN_Type__c == 'National Group Contract 1st Part')
                        MAppRouteFix.put('National Group Contract 1st Part '+a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20161202 Elufa Added commercialTeam
                    else if(a.ASI_CRM_CN_Type__c == 'National Group Contract 2nd Part')
                        MAppLastRouteFix.put('National Group Contract 2nd Part '+a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20161202 Elufa Added commercialTeam
                    //20160819, added by Leo
                    
                    //20161118 Elufa add + commercialTeam for all fix route
                    else if(a.ASI_CRM_CN_Type__c == 'Contract (IHBR) 1st')
                        MAppRouteFix.put('Contract (IHBR) 1st' + a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20161202 Elufa Added commercialTeam
                    //MAppRouteFix.put('Contract (IHBR) 1st', a);
                    else if(a.ASI_CRM_CN_Type__c == 'Contract (IHBR) 2nd')
                        MAppLastRouteFix.put('Contract (IHBR) 2nd' + a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20161202 Elufa Added commercialTeam
                    //MAppLastRouteFix.put('Contract (IHBR) 2nd', a);
                    
            
                    //20160819, added by Leo
                    else if(a.ASI_CRM_CN_Type__c == 'Contract 1st Part')
                        MAppRouteFix.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20161202 Elufa Added commercialTeam
                    else if(a.ASI_CRM_CN_Type__c == 'Contract 2nd Part')
                        MAppLastRouteFix.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);//20161202 Elufa Added commercialTeam
                    //20160819, added by Leo
                }
                
                LFApp = null;
                System.debug(MAppRouteFix);
                System.debug(MAppLastRouteFix);
            }
            
            // Edited by MIchael Yip (Introv) to reduce SOQL
          
            System.debug(MAppLastRouteFix);
            // Added by Michael Yip (Introv) 6May2014 for Clone PO
            List<ASI_TH_CRM_Contract__c> LContractNeedClone = new List<ASI_TH_CRM_Contract__c>();
            Set<String> SPONoClone = new Set<String>();
            Set<String> SUpdatingRecID = new Set<String>();
            
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                // Updated by Michael Yip (Introv) 28Aug2014 to limit set approver when status is draft
                if(contract.ASI_CRM_CN_Status__c == 'Draft' ){
                    setApproverToNull(contract);                 
                    setApprovers(contract, MAppRouteFix, MAppRoute, MAppLastRouteFix, checkPromotionTypeRBA(contract), MUser, MPromotionType);
                }
                if(contract.ASI_CRM_CN_PO_Modification__c && !trigger_oldMap.get(contract.id).ASI_CRM_CN_PO_Modification__c){
                    //LContractNeedClone.add(trigger_oldMap.get(contract.id));
                    LContractNeedClone.add(contract);
                    Last_version.put(contract.ASI_CRM_CN_PO_No__c,contract.ASI_CRM_CN_PO_Version__c);//lokman 22/5/2014
                    System.debug(contract.ASI_CRM_CN_PO_Version__c);
                    SPONoClone.add(contract.ASI_CRM_CN_PO_No__c);
                    SUpdatingRecID.add(contract.id);
                }
            }
            
            //Modified by William Yang (Introv) 20141022 to fix PO Version
            List<ASI_TH_CRM_Contract__c> clonedContracts = new List<ASI_TH_CRM_Contract__c>();
            
            if(LContractNeedClone.size()>0){
                system.debug('Contract Start Clone'+ LContractNeedClone);
                clonedContracts = CloneContract(LContractNeedClone);
       
            }
           
            
            List<ASI_CRM_Approval_Comment__c> LPOContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>(); //Twinkle 11/26/2014            
            
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                if(clonedContracts != null && clonedContracts.size() >0 )
                    for(ASI_TH_CRM_Contract__c get_version: clonedContracts ){
                        if(get_version.ASI_CRM_CN_PO_Version__c==Last_version.get(contract.ASI_CRM_CN_PO_No__c)&&get_version.ASI_CRM_CN_PO_No__c==contract.ASI_CRM_CN_PO_No__c){
                            contract.ASI_CRM_CN_Last_PO_version__c=get_version.id;}
                        if(get_version.ASI_CRM_CN_PO_Version__c=='0.0'&&get_version.ASI_CRM_CN_PO_No__c==contract .ASI_CRM_CN_PO_No__c){
                            contract.ASI_CRM_CN_V0_0_PO_version__c=get_version.id;}
                    }
                if(contract.ASI_CRM_CN_PO_Modification__c && !trigger_oldMap.get(contract.id).ASI_CRM_CN_PO_Modification__c)
                {
                    //20151230 Ben @ Elufa System
                    //20151230 End
                    List<String> poVersionSplit = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
                    if(poVersionSplit != null && poVersionSplit.size() ==2)
                    {
                        contract.ASI_CRM_CN_PO_Version__c = poVersionSplit[0] + '.' + String.valueOf(Integer.valueOf(poVersionSplit[1])+1);
                    }
                    LPOContractComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c = contract.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')));            
                    contract.ASI_TH_CRM_Start_Date__c = null;
                    contract.ASI_TH_CRM_End_Date__c = null;
                    contract.ASI_CRM_Reject_Return_Comments__c = '';//20160229 Ben @ Elufa
                    contract.ASI_CRM_CN_Return_Comments__c = '';
                    //20160308 Ben @ Elufa
                    contract.ASI_CRM_CN_Last_Approved_By__c = NULL;
                    contract.ASI_CRM_CN_Last_Approved_Date__c = NULL;
                    contract.ASI_CRM_CN_Last_Recall_By__c = NULL;
                    contract.ASI_CRM_CN_Last_Recall_Date__c = NULL;
                    contract.ASI_CRM_CN_Last_Rejected_By__c = NULL;
                    contract.ASI_CRM_CN_Last_Rejected_Date__c = NULL;
                    contract.ASI_CRM_CN_Last_Submitted_By__c = NULL;
                    contract.ASI_CRM_CN_Last_Submitted_Date__c = NULL;
                    //20160308 End
                }
                
                contract.Name=update_contractNo(contract);
                
                
        
                
                //Added by Twinkle Li 20141110
                If((trigger_oldMap.get(contract.id).ASI_CRM_CN_Status__c != 'Final' && contract.ASI_CRM_CN_Status__c == 'Final') && contract.ASI_CRM_CN_BA_Final_Approver__c == true){
                    contract.ASI_CRM_CN_Contract_Upload__c = true;
                }
                //End Twinkle Li 20141110    
            }
            /*lokman 21/5/2014 end */
            //William Yang 20141022 End
            insert LPOContractComment_Insert;
        }
        //
    }
    
    //***** added by leo @2014/06/22 (start) *****
    public static void routineBeforeDelete(list<ASI_TH_CRM_Contract__c> trigger_old) {
        for (ASI_TH_CRM_Contract__c contract :trigger_old) { 
            if(!isByPassByCurrentUser()){ 
                if (Global_RecordTypeCache.getRt(contract.recordTypeId).developerName.contains('ASI_CRM_CN_Contract'))
                {
                    if (contract.ASI_CRM_CN_Status__c != 'Draft' || contract.ASI_CRM_CN_PO_Version__c != '0.0')//&& contract.ASI_CRM_CN_Status__c != 'Archived')
                        contract.addError('Not allowed to delete because the Contract is NOT in \'Draft\' status');
                }
                
                //***** added by Twinkle @2014/08/29 (start) *****
                
                String errMsg = Label.ASI_CRM_CN_ContractPOVersionCheckErrMsg;
                if (contract.ASI_CRM_CN_PO_Version__c != '0.0' && !contract.ASI_CRM_CN_IsClone__c )
                    contract.addError(errMsg);               
            }
            //***** added by Twinkle @2014/08/29 (end) *****
        }        
        
        for (ASI_TH_CRM_Contract__c contract :trigger_old) { 
            
        }
        //***** added by Twinkle @2014/08/29 (end) *****
    }
    //***** added by leo @2014/06/22 (end) *****
    
    //***** added by leo @2014/07/03 (start) *****
    public static void routineAfterAll(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        if(!isBypassByCurrentUser()){
            calcLatestVol(trigger_new,trigger_oldMap);
        }
    }
    
    public static void routineAfterDelete(list<ASI_TH_CRM_Contract__c> trigger_old){
        calcLatestVol(trigger_old,null);
    }
    //***** added by leo @2014/07/03 (end) *****
    
    
    // Added by Michael Yip (Introv) 23Jun2014 check overlap of contract for ON/OFF except RTD
    public static void checkOverlap(list <ASI_TH_CRM_Contract__c > trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        string SOAid = findSOAid();
        Set<id> SOutletID = new Set<id>();
        Set<String> SPromotionType = new Set<String>();     
        Set<id> SCurrentContractID = new Set<id>();
        
        //20160608 Ben @ Elufa
        List<ASI_CRM_Special_Promotion_Type_Mapping__c> promtionTypeMappingList = new List<ASI_CRM_Special_Promotion_Type_Mapping__c>([SELECT id
                                                                                                                                       , ASI_CRM_Mapping_of_New_Promotion_Type__c
                                                                                                                                       , ASI_CRM_Mapping_of_Old_Promotion_Type__c
                                                                                                                                       , ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c
                                                                                                                                       , ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c
                                                                                                                                       FROM ASI_CRM_Special_Promotion_Type_Mapping__c
                                                                                                                                       WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Special_Promotion_Type_Mapping'
                                                                                                                                      ]);
        Map<String, Set<String>> mapOldPromotionType = new Map<String, Set<String>>();
        
        if(promtionTypeMappingList.size() > 0){
            for(ASI_CRM_Special_Promotion_Type_Mapping__c obj : promtionTypeMappingList){
                
                Set<String> tmpType = new Set<String>();
                
                if(mapOldPromotionType.containsKey(obj.ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c)){
                    
                    tmpType = mapOldPromotionType.get(obj.ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
                    tmpType.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
                    mapOldPromotionType.put(obj.ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c, tmpType);
                }else{
                    
                    tmpType.add(obj.ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c);
                    mapOldPromotionType.put(obj.ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c, tmpType);
                }
            }
        }
        //20160608 End
        
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            System.debug(c.ownerid);
            System.debug(SOAid);
            if((c.ownerid != null && c.ownerid != SOAid) || (c.ownerid == null && Userinfo.getUserId() != SOAid)){
                if(c.ASI_CRM_CN_Status__c == 'Draft' && !c.ASI_CRM_CN_IsClone__c){
                    //Updated by William Yang(Introv)2014-12-1 for #181
                    if(c.ASI_TH_CRM_Promotion_Type__c == 'New Contract ON' || c.ASI_TH_CRM_Promotion_Type__c == 'New Contract OFF' || c.ASI_TH_CRM_Promotion_Type__c == 'New Contract E-Commerce' 
                       || c.ASI_TH_CRM_Promotion_Type__c == 'RTD ON' || c.ASI_TH_CRM_Promotion_Type__c == 'RTD OFF'
                       || c.ASI_TH_CRM_Promotion_Type__c == 'Contract ON' || c.ASI_TH_CRM_Promotion_Type__c == 'Contract OFF' || c.ASI_TH_CRM_Promotion_Type__c == 'Contract E-Commerce'){//20160607 Ben @ Elufa
                           SOutletID.add(c.ASI_CRM_CN_Outlet_WS__c);
                           SPromotionType.add(c.ASI_TH_CRM_Promotion_Type__c);
                           SCurrentContractID.add(c.id);
                           if(mapOldPromotionType.containsKey(c.ASI_TH_CRM_Promotion_Type__c)){
                               SPromotionType.addAll(mapOldPromotionType.get(c.ASI_TH_CRM_Promotion_Type__c));
                           }
                           System.debug(c);
                       }
                }
            }
        }
        
        System.debug(SCurrentContractID);
        if(SOutletID.size()>0){
            List<ASI_TH_CRM_Contract__c> LContractExisting = [Select id, name, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c, 
                                                              ASI_CRM_CN_Status__c, ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Return_Flag__c  
                                                              from ASI_TH_CRM_Contract__c 
                                                              where RecordType.DeveloperName= 'ASI_CRM_CN_Contract' and ASI_CRM_CN_Outlet_WS__c IN :SOutletID and ASI_TH_CRM_Promotion_Type__c IN :SPromotionType and ASI_CRM_CN_Status__c <> 'Archived'//Updated by William Yang(Introv)2014-12-1 for #181
                                                              and id not in :SCurrentContractID AND (NOT ASI_CRM_CN_Status__c LIKE 'FY Landing Archive') order by ASI_CRM_CN_PO_Start_Date__c desc];
            if(LContractExisting.size()>0){
                //compareDate(trigger_new, LContractExisting);
                for(ASI_TH_CRM_Contract__c c : trigger_new){
                    System.debug(c.ownerid);
                    System.debug(SOAid);
                    Boolean isOverlap = false;
                    System.debug(c);
                    if((c.ownerid != null && c.ownerid != SOAid) || (c.ownerid == null && Userinfo.getUserId() != SOAid)){
                        if(c.ASI_TH_CRM_Promotion_Type__c == 'New Contract ON' || c.ASI_TH_CRM_Promotion_Type__c == 'New Contract OFF'|| c.ASI_TH_CRM_Promotion_Type__c == 'New Contract E-Commerce' 
                           || c.ASI_TH_CRM_Promotion_Type__c == 'RTD ON' || c.ASI_TH_CRM_Promotion_Type__c == 'RTD OFF'
                           || c.ASI_TH_CRM_Promotion_Type__c == 'Contract ON' || c.ASI_TH_CRM_Promotion_Type__c == 'Contract OFF' || c.ASI_TH_CRM_Promotion_Type__c == 'Contract E-Commerce'){//20160607 Ben @ Elufa
                               for(ASI_TH_CRM_Contract__c contractOld : LContractExisting){
                                   System.debug(contractOld);
                                   if(contractOld.ASI_CRM_CN_Outlet_WS__c == c.ASI_CRM_CN_Outlet_WS__c && 
                                      (contractOld.ASI_TH_CRM_Promotion_Type__c == c.ASI_TH_CRM_Promotion_Type__c 
                                       || (mapOldPromotionType.containsKey(c.ASI_TH_CRM_Promotion_Type__c) && mapOldPromotionType.get(c.ASI_TH_CRM_Promotion_Type__c).contains(contractOld.ASI_TH_CRM_Promotion_Type__c)) )//20160608 Ben @ Elufa //&& contractOld.ASI_CRM_CN_Status__c == 'Final' && contractOld.ASI_CRM_CN_Status__c == 'Submitted'
                                      && contractOld.id != c.id){
                                          if(isOverlap(contractOld.ASI_CRM_CN_PO_Start_Date__c, contractOld.ASI_CRM_CN_PO_End_Date__c, c.ASI_CRM_CN_PO_Start_Date__c, c.ASI_CRM_CN_PO_End_Date__c)){
                                              System.debug(contractold);
                                              System.debug(c);
                                              isOverlap = true;
                                              break;
                                          }
                                      }
                               }
                           }
                    }
                    if(isOverlap && Userinfo.getUserId()!='005M0000004uXMNIA2' && Userinfo.getUserId()!='005M0000006GhihIAC' && Userinfo.getUserId()!='005D0000002fnWOIAY' && 
                       Userinfo.getUserId()!='005M0000006GhihIAC' && Userinfo.getUserId()!='005M0000007HanWIAS'){
                        c.addError(Label.ASI_CRM_CN_Contract_Date_Overlap);
                        //c.addError('Contract Date overlap');
                    }
                }
            }
        }
    }
    
    public static boolean isOverlap(Date LastConStartDate, Date LastConEndDate, Date ThisConStartDate, Date ThisConEndDate){
        boolean overlap = false;
        LastConStartDate = LastConStartDate.toStartOfMonth();
        LastConEndDate = LastConEndDate.toStartOfMonth().addMonths(1).addDays(-1);
         
        if((ThisConStartDate < LastConStartDate && ThisConEndDate < LastConStartDate) || (ThisConStartDate > LastConEndDate && ThisConEndDate > LastConEndDate))
            overlap = false;
        else
            overlap = true;
        
        
        return overlap;
    }
    
    public static string findSOAid(){
        string soaid = '';
        
        //List<user> LUser = [select id, username, name from user where username like 'prasia_soa@service.pernod-ricard.com%'];
        //if(LUser.size()>0)
        //    soaid = LUser[0].id;
        for(User u : ASI_CRM_CN_Function.getUserList()){
            if(u.username.contains('prasia_soa@service.pernod-ricard.com'))
                soaid  = u.id;                
        }
        return soaid;
    }
    
    public static void UpdateExRate(list <ASI_TH_CRM_Contract__c > trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        
        Decimal strExRate;
        string strCountry;
        string strCCurrency;
        string strBCurrency;
        string strExCCurrency;
        Date strEffDate;
        
        List <ASI_MFM_Exchange_Rate__c> ExRateList = [SELECT id, ASI_MFM_Application__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Effective_Date__c, ASI_MFM_Country__c, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c FROM ASI_MFM_Exchange_Rate__c where asi_mfm_country__c = 'CN' and asi_mfm_application__c = 'CRM' order by ASI_MFM_Effective_Date__c desc ];
        for (ASI_TH_CRM_Contract__c a : trigger_new){
            strCCurrency = a.ASI_CRM_CN_Currency__c;
            strBCurrency = a.ASI_CRM_CN_Sys_Local_Currency__c;
            strEffDate = a.ASI_CRM_CN_PO_Start_Date__c;
            
            //If Currency is changed
            if (trigger_oldMap == null || strCCurrency != trigger_oldMap.get(a.id).ASI_CRM_CN_Currency__c || a.ASI_CRM_CN_PO_Start_Date__c != trigger_oldMap.get(a.id).ASI_CRM_CN_PO_Start_Date__c){
                system.debug('Do Exchange!');
                if (strCCurrency != strBCurrency && strCCurrency != null ){
                    system.debug('Different currency');
                    
                    strCountry = 'CN';
                    
                    for (ASI_MFM_Exchange_Rate__c c : ExRateList){
                        if (c.ASI_MFM_Application__c == 'CRM' && c.ASI_MFM_Country__c ==strCountry && c.ASI_MFM_Base_Currency__c == strBCurrency && c.ASI_MFM_Counter_Currency__c == strCCurrency && c.ASI_MFM_Effective_Date__c <= strEffDate){
                            strExRate = c.ASI_MFM_Exchange_Rate__c;
                            break;
                        }
                    }
                    if (ExRateList.size() >0){
                        a.ASI_CRM_CN_Exchange_Rate__c = strExRate;
                    }else{
                        a.ASI_CRM_CN_Exchange_Rate__c = null;
                        system.debug('Exchange Rate reference not found.');
                    }
                }else{ 
                    a.ASI_CRM_CN_Exchange_Rate__c = 1;
                }
                
                
            }//End DoExchange
        }
    }
    
    // Added by Michael Yip (Introv) 21Jun2014 for update contract status (th) with cn
    private static void copyContractStatus(list<ASI_TH_CRM_Contract__c> trigger_new){
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            c.ASI_TH_CRM_Contract_Status__c = c.ASI_CRM_CN_Status__c;
            if(c.ASI_CRM_CN_Status__c == 'Archived')
                c.ASI_CRM_CN_IsClone__c = true;
        }
    }
    
    public static string update_contractNo(ASI_TH_CRM_Contract__c c){
        // Edited by Michael Yip (Introv) 19Sep2014 to fix contract no generation for PO Modification
        String contract_no;
        String[] temp_contract_no;
        String[] temp_po_version;
        Decimal poVersion;
        
        if(c != null){
            contract_no=c.Name;
            if(contract_no != null)
                temp_contract_no=contract_no.split('\\.',0);
            if(c.ASI_CRM_CN_PO_Version__c != null)
                temp_po_version=c.ASI_CRM_CN_PO_Version__c.split('\\.',0);
            poVersion = Decimal.valueOf(c.ASI_CRM_CN_PO_Version__c);
        }
        if(temp_contract_no != null && temp_contract_no.size() == 4 && temp_po_version != null && temp_po_version.size() ==2)
        {
            if(poVersion < 1.0)
                contract_no=temp_contract_no[0]+'.'+temp_contract_no[1]+'.'+temp_contract_no[2]+'.'+temp_po_version[1];
            else 
                contract_no=temp_contract_no[0]+'.'+temp_contract_no[1]+'.'+temp_contract_no[2]+'.'+String.valueof(Decimal.valueOf(temp_po_version[0]) * 10 + Decimal.valueOf(temp_po_version[1]));
        }
        return contract_no;
    }
    
    public static string raisePOVersion(ASI_TH_CRM_Contract__c c){
        
        //return '0.1';
        return String.valueOf(Decimal.valueOf(c.ASI_CRM_CN_PO_Version__c)+0.1);
    }
    
    //Updated by Twinkle Li (Introv) 20Oct2014
    public static void setApprovers(ASI_TH_CRM_Contract__c p, Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix,
                                    Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, 
                                    Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix, 
                                    boolean isAddRBAApprover, Map<id, User> MUser,
                                    Map<String, boolean> MPromotionType)
    {
        
        Integer approver_count = 0;
        Integer return_approver_count = 0;
        
        //retrieve max contract amount
        AggregateResult result = [Select Max(ASI_CRM_CN_Total_Contract_Amount__c) MaxContractAmount From ASI_TH_CRM_Contract__c where ASI_CRM_CN_PO_No__c = :p.ASI_CRM_CN_PO_No__c and ASI_CRM_CN_Status__c = 'Archived'];
        Decimal maxContractAmount = -99999999;
        if(result.get('MaxContractAmount') != null){
            maxContractAmount = Decimal.valueOf(String.valueOf(result.get('MaxContractAmount')));
        }
        //Add 0.1 buffer for maximum contract amount check 29/9
        //maxContractAmount = maxContractAmount + 0.1;
        //20160530 change 0.1 buffer for maximum contract amount check to 1.0
        maxContractAmount = maxContractAmount + 1;
        boolean onlyFix2Route1 = false;
        if(p.ASI_CRM_CN_Total_Contract_Amount__c <= maxContractAmount){
            onlyFix2Route1 = true;
        }
        System.debug('ASI_CRM_CN_Total_Contract_Amount__c :' + p.ASI_CRM_CN_Total_Contract_Amount__c );
        System.debug('maxContractAmount :' + maxContractAmount);
        System.debug(onlyFix2Route1);
        
        List<ASI_TH_CRM_Contract__c> LContract = [Select id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Return_Flag__c, OwnerId
                                                  from ASI_TH_CRM_Contract__c
                                                  where id =:p.id];
        
        // First Fix Route
        ASI_CRM_Fix_Approval_Route__c fixApprover;
        for(ASI_TH_CRM_Contract__c c: LContract ){
            //20160921 Ben @ Elufa
            if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
                if(p.ASI_CRM_National_Group__c != Null){//20170309 Elufa Commented if(p.ASI_CRM_CN_National_Group_Contract__c == true){
                    fixApprover = MAppRouteFix.containsKey('National Group Contract 1st Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppRouteFix.get('National Group Contract 1st Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppRouteFix.get('National Group Contract 1st Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);//20161202 Elufa Added Commercial Team
             
                }
                //20160922 Ben @ Elufa Commented
                
                else{
                    //fixApprover = MAppRouteFix.get(p.ASI_CRM_CN_Division__c); //20160819,edited by Leo
                    //if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null) //20160819,edited by Leo
                    fixApprover = MAppRouteFix.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);//20161202 Elufa added Commercial Team
                    system.debug(fixApprover);
                }
            }
        }
        
        if(fixApprover != null && fixApprover.ASI_CRM_CN_Entry_Limit__c < p.ASI_CRM_CN_Total_Contract_Amount__c && !onlyFix2Route1){
            if(fixApprover.ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_1__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_2__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_2__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_3__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_3__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_4__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_4__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_5__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_5__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_6__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_6__c);
                approver_count++;
            }
            
            
             if(fixApprover.ASI_CRM_CN_Approval_Limit_6__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_7__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_7__c);
                approver_count++;
            }
            
             if(fixApprover.ASI_CRM_CN_Approval_Limit_7__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_8__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_8__c);
                approver_count++;
            }
            
            
                 
             if(fixApprover.ASI_CRM_CN_Approval_Limit_8__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_9__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_9__c);
                approver_count++;
            }
            
             if(fixApprover.ASI_CRM_CN_Approval_Limit_9__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                if(fixApprover.ASI_CRM_CN_Approver_10__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_10__c);
                approver_count++;
            }
            
            
        }
        boolean proceed = true;
        id currentUserid = p.ASI_CRM_CN_Owner_Manager_ID__c;
        system.debug(currentUserid);
        
        ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
        User currentApproverU = null;
        
        //Dynamic Route
        while(proceed && !onlyFix2Route1){
            if(currentUserid != null && (MAppRoute.containsKey(currentUserid) || MUser.containsKey(currentUserid))){
                if(MAppRoute.get(currentUserid) != null){
                    currentApprover = MAppRoute.get(currentUserid);
                    currentUserid = currentApprover.ASI_CRM_Manager_ID__c;
                }
                else{
                    if(MUser.get(currentUserid) != null){
                        currentApproverU = MUser.get(currentUserid);
                        currentUserid = currentApproverU.ManagerID;
                    }
                }
                
                if(currentApprover != null && currentApproverU == null){                            
                    setApproverByCount(p, approver_count, currentApprover.ASI_CRM_User__c);
                }
                else if(currentApprover == null && currentApproverU != null){
                    setApproverByCount(p, approver_count, currentApproverU.id);
                }
                
                approver_count++;
                if(currentApprover != null){
                    if( currentApprover.ASI_CRM_End_of_Dynamic_Route__c || currentApprover.ASI_CRM_Approval_Limit__c >= p.ASI_CRM_CN_Total_Contract_Amount__c){
                        proceed = false;
                    }
                }                                               
                currentApprover = null;
                currentApproverU = null;
            }
            else{
                proceed = false;
            }
        }
        
        //second fix
        ASI_CRM_Fix_Approval_Route__c fixApprover2;
        for(ASI_TH_CRM_Contract__c c: LContract ){
            if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
                if(p.ASI_CRM_CN_National_Group_Contract__c){//20170309 Elufa Commented if(p.ASI_CRM_CN_National_Group_Contract__c == true){ //20170524 Changed back to p.ASI_CRM_CN_National_Group_Contract__c //fixApprover2 = MAppLastRouteFix.get('National Group Contract 2nd Part '+p.ASI_CRM_CN_Division__c); //20160819,edited by Leo //if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null) //20160819,edited by Leo
                    fixApprover2 = MAppLastRouteFix.containsKey('National Group Contract 2nd Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppLastRouteFix.get('National Group Contract 2nd Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppLastRouteFix.get('National Group Contract 2nd Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); //20161202 Elufa Added Commercial
                    system.debug(fixApprover2);
                }
                //20160922 Ben @ Elufa commented

                //20160922 End
                else{
                    
                    fixApprover2 = MAppLastRouteFix.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); //20161202 Elufa Added Commercial
                    system.debug(fixApprover2);
                }
            }
        }
        
        if(fixApprover2 != null && fixApprover2.ASI_CRM_CN_Entry_Limit__c < p.ASI_CRM_CN_Total_Contract_Amount__c){
            
            //Modified by William Yang(Introv) 20140929 to set Return Approvers
            
            if(fixApprover2 .ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                approver_count++;
                
                if(p.ASI_CRM_CN_Return_Flag__c)
                {
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                    return_approver_count++;
                }
            }
            if(!onlyFix2Route1){
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_2__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_2__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                        return_approver_count++;
                    }
                }
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_3__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_3__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                        return_approver_count++;
                    }
                }
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_4__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_4__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                        return_approver_count++;
                    }
                }
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_5__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_5__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                        return_approver_count++;
                    }
                }
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_6__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_6__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                        return_approver_count++;
                    }
                }
                
                
                
                
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_6__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_7__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_7__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                        return_approver_count++;
                    }
                }
                
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_7__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_8__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_8__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                        return_approver_count++;
                    }
                }
                
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_8__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_9__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_9__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                        return_approver_count++;
                    }
                }
                
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_9__c < p.ASI_CRM_CN_Total_Contract_Amount__c)
                    if(fixApprover2 .ASI_CRM_CN_Approver_10__c != null)
                {
                    setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_10__c);
                    approver_count++;
                    
                    if(p.ASI_CRM_CN_Return_Flag__c)
                    {
                        setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                        return_approver_count++;
                    }
                }
                
                
                
            }
        }
        
        //Updated by Twinkle Li (Introv) 24Sept2014 to add last approval as Regional BA if Contract version is 0.0 and approval type is Contract 2nd part or National Group Contract 2nd part or Contract (IHBR) 2nd part
        //Regional BA
        if(isAddRBAApprover)
        {
            ASI_CRM_Fix_Approval_Route__c fixApprover3;
            
            //Updated by William Yang (Introv) 20141118 for UAT II #22
            for(ASI_TH_CRM_Contract__c c: LContract ){
                if(p.ASI_CRM_CN_National_Group_Contract__c)//20170309 Elufa Commented if(p.ASI_CRM_CN_National_Group_Contract__c == true){ //20170524 change back to p.ASI_CRM_CN_National_Group_Contract__c
                {
                    //fixApprover3 = MAppLastRouteFix.get('National Group Contract 2nd Part '+p.ASI_CRM_CN_Division__c); //20160819,edited by Leo
                    if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null) //20160819,edited by Leo
                        fixApprover3 = MAppLastRouteFix.containsKey('National Group Contract 2nd Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppLastRouteFix.get('National Group Contract 2nd Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppLastRouteFix.get('National Group Contract 2nd Part '+MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); //20161202 Elufa Added Commercial
                }
                //20161118 Elufa IHBR goes normal Approval Route IM64282
                
                else
                {
                    //fixApprover3 = MAppLastRouteFix.get(p.ASI_CRM_CN_Division__c); //20160819,edited by Leo
                    if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null) //20160819,edited by Leo
                        fixApprover3 = MAppLastRouteFix.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c); //20161202 Elufa Added Commercial
                }
            }
            
            if((MPromotionType.containsKey(p.ASI_TH_CRM_Promotion_Type__c)) && MPromotionType.get(p.ASI_TH_CRM_Promotion_Type__c) != null){
                if(p.ASI_CRM_CN_PO_Version__c == '0.0' && MPromotionType.get(p.ASI_TH_CRM_Promotion_Type__c)){    
                   
                    if(fixApprover3 != null){                 
                        p.ASI_CRM_CN_BA_Final_Approver__c = true;                          
                        setApproverByCount(p, approver_count, fixApprover3.ASI_CRM_CN_Regional_BA__c);
                        approver_count++;
                        
                        if(p.ASI_CRM_CN_Return_Flag__c)
                        {
                            setReturnApproverByCount(p, return_approver_count, fixApprover3.ASI_CRM_CN_Regional_BA__c);
                            return_approver_count++;
                        }
                    }
                }
            }
        }
    }
    
    public static void setApproverByCount(ASI_TH_CRM_Contract__c p, integer approver_count, Id userId)
    {
        if(approver_count == 0)
            p.ASI_CRM_CN_Sys_Approver_1__c = userId;
        
        else if(approver_count == 1)
            p.ASI_CRM_CN_Sys_Approver_2__c = userId;
        
        else if(approver_count == 2)
            p.ASI_CRM_CN_Sys_Approver_3__c = userId;
        
        else if(approver_count == 3)
            p.ASI_CRM_CN_Sys_Approver_4__c = userId;
        
        else if(approver_count == 4)
            p.ASI_CRM_CN_Sys_Approver_5__c = userId;
        
        else if(approver_count == 5)
            p.ASI_CRM_CN_Sys_Approver_6__c = userId;
        
        else if(approver_count == 6)
            p.ASI_CRM_CN_Sys_Approver_7__c = userId;
        
        else if(approver_count == 7)
            p.ASI_CRM_CN_Sys_Approver_8__c = userId;
        
        else if(approver_count == 8)
            p.ASI_CRM_CN_Sys_Approver_9__c = userId;
        
        else if(approver_count == 9)
            p.ASI_CRM_CN_Sys_Approver_10__c = userId;
        
        else if(approver_count == 10)
            p.ASI_CRM_CN_Sys_Approver_11__c = userId;
        
    }
    
    public static void setReturnApproverByCount(ASI_TH_CRM_Contract__c p, integer approver_count, Id userId)
    {
        if(approver_count == 0)
            p.ASI_CRM_CN_Return_Approver_1__c = userId;
        
        else if(approver_count == 1)
            p.ASI_CRM_CN_Return_Approver_2__c = userId;
        
        else if(approver_count == 2)
            p.ASI_CRM_CN_Return_Approver_3__c = userId;
        
        else if(approver_count == 3)
            p.ASI_CRM_CN_Return_Approver_4__c = userId;
        
        else if(approver_count == 4)
            p.ASI_CRM_CN_Return_Approver_5__c = userId;
        
        else if(approver_count == 5)
            p.ASI_CRM_CN_Return_Approver_6__c = userId;
        
        else if(approver_count == 6)
            p.ASI_CRM_CN_Return_Approver_7__c = userId;
        
        else if(approver_count == 7)
            p.ASI_CRM_CN_Return_Approver_8__c = userId;
        
        else if(approver_count == 8)
            p.ASI_CRM_CN_Return_Approver_9__c = userId;
        
        else if(approver_count == 9)
            p.ASI_CRM_CN_Return_Approver_10__c = userId;
        
        else if(approver_count == 10)
            p.ASI_CRM_CN_Return_Approver_11__c = userId;
    }
    
    public static void setApproverToNull(ASI_TH_CRM_Contract__c p){
        p.ASI_CRM_CN_Sys_Approver_1__c = null;
        p.ASI_CRM_CN_Sys_Approver_2__c = null;
        p.ASI_CRM_CN_Sys_Approver_3__c = null;
        p.ASI_CRM_CN_Sys_Approver_4__c = null;
        p.ASI_CRM_CN_Sys_Approver_5__c = null;
        p.ASI_CRM_CN_Sys_Approver_6__c = null;
        p.ASI_CRM_CN_Sys_Approver_7__c = null;
        p.ASI_CRM_CN_Sys_Approver_8__c = null;
        p.ASI_CRM_CN_Sys_Approver_9__c = null;
        p.ASI_CRM_CN_Sys_Approver_10__c = null;
        p.ASI_CRM_CN_Sys_Approver_11__c = null;
        
        p.ASI_CRM_CN_Return_Approver_1__c = null;
        p.ASI_CRM_CN_Return_Approver_2__c = null;
        p.ASI_CRM_CN_Return_Approver_3__c = null;
        p.ASI_CRM_CN_Return_Approver_4__c = null;
        p.ASI_CRM_CN_Return_Approver_5__c = null;
        p.ASI_CRM_CN_Return_Approver_6__c = null;
        p.ASI_CRM_CN_Return_Approver_7__c = null;
        p.ASI_CRM_CN_Return_Approver_8__c = null;
        p.ASI_CRM_CN_Return_Approver_9__c = null;
        p.ASI_CRM_CN_Return_Approver_10__c = null;
        p.ASI_CRM_CN_Return_Approver_11__c = null; 
        
        p.ASI_CRM_CN_BA_Final_Approver__c = false; 
    }
    
    public static ASI_CRM_Contract_Cost__c CreateContractCostObjByContract (ASI_TH_CRM_Contract__c contract, ASI_CRM_Contract_Cost_Setting__c ccs) {
        ASI_CRM_Contract_Cost__c cs = new ASI_CRM_Contract_Cost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost'));
        
        cs.ASI_CRM_CN_Contract__c = contract.id;
        cs.Name = ccs.Name;
        cs.ASI_CRM_CN_Activity_Code__c = ccs.ASI_CRM_CN_Activity_Code__c;
        
        if(ccs.ASI_CRM_CN_Fixed_Cost_Contract__c != null && ccs.ASI_CRM_CN_Fixed_Cost_Contract__c == true)
        {
            cs.ASI_CRM_CN_Cost_Type__c = 'Fixed';
        }
        else if(ccs.ASI_CRM_CN_Variable_Cost_Contract__c != null && ccs.ASI_CRM_CN_Variable_Cost_Contract__c == true)
        {
            cs.ASI_CRM_CN_Cost_Type__c = 'Variable';
        }
        
        cs.ASI_CRM_CN_Chinese_Description__c = ccs.ASI_CRM_CN_Chinese_Description__c;
        cs.ASI_CRM_CN_Sequence__c = ccs.ASI_CRM_CN_Sequence__c;
        cs.ASI_CRM_CN_Other_Cost_Payment_Request__c = ccs.ASI_CRM_CN_Other_Cost_Payment_Request__c;
        
        return cs;
    }
    
    public static List<ASI_TH_CRM_Contract__c> CloneContract(List<ASI_TH_CRM_Contract__c> LContract) { 
        
        //---- List for mapping 'original contract id' and 'cloned contract pbject position' ----
        Map<id, integer> MapContract = new Map<id, integer>();
        
        //---- original child objects ----
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<Attachment> LAtth = new List<Attachment>();
        List<ASI_TH_CRM_Contract__Feed> LFeed = new List<ASI_TH_CRM_Contract__Feed>();
        
        string strListOfOriginalId = '';
        
        for(ASI_TH_CRM_Contract__c originalContract :LContract) {
            if(strListOfOriginalId == '')
                strListOfOriginalId = '\'' + originalContract.Id + '\'';
            else
                strListOfOriginalId += ', \'' + originalContract.Id + '\'';
        }        
        
        string whereClause = 'ASI_CRM_CN_Contract__c IN (' + strListOfOriginalId + ')';
        string whereClauseAtth = 'Parentid IN (' + strListOfOriginalId + ')';
        string whereClauseFeed = 'Type = \'ContentPost\' AND ParentId IN (' + strListOfOriginalId + ') AND Id != null ORDER BY ContentFileName';
        
        //---- get original BRSF line items ----
        string soqlBRSF = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Contract_BRSF_Line_Item__c', whereClause, '');
        LBRSF = DATABASE.Query(soqlBRSF);
        
        //---- get original Contract Cost items ----
        string soqlContractCost = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Contract_Cost__c', whereClause, '');
        LContractCost = DATABASE.Query(soqlContractCost);
        
        //---- get original Covered Outlet items ----
        string soqlCoveredOutlet = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Covered_Outlet__c', whereClause, '');
        LCoveredOutlet = DATABASE.Query(soqlCoveredOutlet);
        
   
        
        
        //---- cloned objects ----
        List<ASI_TH_CRM_Contract__c> LContract_Clone = new List<ASI_TH_CRM_Contract__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF_Clone = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_Contract_Cost__c> LContractCost_Clone = new List<ASI_CRM_Contract_Cost__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet_Clone = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<Attachment> LAtth_Clone = new List<Attachment>();
        List<FeedItem> LFeed_Clone = new List<FeedItem>();
        
        // (1) ------ Process Contract objects (start) ------
        integer contractListPos = 0;
        if(LContract != null && LContract.size() > 0)
        {
            for(ASI_TH_CRM_Contract__c originalContract :LContract) {
                ASI_TH_CRM_Contract__c cloneContract =originalContract.clone(false, true);
                cloneContract.ASI_CRM_CN_IsClone__c = true;         // set IsClone flag
                cloneContract.ASI_TH_CRM_Contract_External_ID__c=null;//lokman 4/7/2014 external id remove for clone record
                cloneContract.ASI_CRM_CN_PO_Modification__c = false;
                cloneContract.ASI_CRM_CN_Status__c = 'Archived';
                cloneContract.ASI_CRM_CN_PO_Version__c =originalContract.ASI_CRM_CN_PO_Version__c;
                cloneContract.id=null;
                LContract_Clone.add(cloneContract);
                
                MapContract.put(originalContract.Id, contractListPos);
                contractListPos++;
            }
        }
        System.debug('Cloning LContract_Clone:'+LContract_Clone);
        if(LContract_Clone != null && LContract_Clone.size() > 0) {
            upsert LContract_Clone;
        }
        
        //Added by Twinkle 11/26/2014 - Contract Approval Comment       
        List<ASI_CRM_Approval_Comment__c> LTransferContractComment_Insert = [SELECT id, ASI_CRM_Contract__c FROM ASI_CRM_Approval_Comment__c WHERE ASI_CRM_Contract__c =: LContract[0].id];
        system.debug(LContract_Clone);
        for(ASI_TH_CRM_Contract__c contractClone : LContract_Clone){
            for(ASI_CRM_Approval_Comment__c tcc : LTransferContractComment_Insert){
                tcc.ASI_CRM_Contract__c = contractClone.id;
            }
        }                        
        update LTransferContractComment_Insert;
        //Ended by Twinkle 11/26/2014
        
        
        // (2) ------ Process BRSF Line Items (start) ------
        if(LBRSF != null && LBRSF.size()>0)
        {
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c originalBRSF :LBRSF) {
                ASI_CRM_CN_Contract_BRSF_Line_Item__c cloneBRSF = originalBRSF.clone(false, true);
                cloneBRSF.ASI_CRM_CN_Contract__c = LContract_Clone[MapContract.get(originalBRSF.ASI_CRM_CN_Contract__c)].Id;
                cloneBRSF.ASI_CRM_CN_External_ID__c=null;//lokman 4/7/2014
                LBRSF_Clone.add(cloneBRSF);
            }
        }
        
        if(LBRSF_Clone != null && LBRSF_Clone.size() > 0) {
            insert LBRSF_Clone;
        }
        // (2) ------ Process BRSF Line Items (end) ------
        
        // (3) ------ Process Constract Cost Items (start) ------
        if(LContractCost != null && LContractCost.size()>0)
        {
            for(ASI_CRM_Contract_Cost__c originalCost :LContractCost) {
                ASI_CRM_Contract_Cost__c cloneCost = originalCost.clone(false, true);
                cloneCost.ASI_CRM_CN_Contract__c = LContract_Clone[MapContract.get(originalCost.ASI_CRM_CN_Contract__c)].Id;
                cloneCost.ASI_CRM_CN_External_ID__c=null;//lokman 4/7/2014
                LContractCost_Clone.add(cloneCost);
            }
        }
        
        if(LContractCost_Clone != null && LContractCost_Clone.size() > 0) {
            insert LContractCost_Clone;
        }
        // (3) ------ Process Constract Cost Items (end) ------
        
        
        // (4) ------ Process Covered Outlet Items (start) ------
        if(LCoveredOutlet != null && LCoveredOutlet.size()>0)
        {
            for(ASI_CRM_CN_Covered_Outlet__c originalCoveredOutlet :LCoveredOutlet) {
                ASI_CRM_CN_Covered_Outlet__c cloneCoveredOutlet = originalCoveredOutlet.clone(false, true);
                cloneCoveredOutlet.ASI_CRM_CN_Contract__c = LContract_Clone[MapContract.get(originalCoveredOutlet.ASI_CRM_CN_Contract__c)].Id;
                cloneCoveredOutlet.ASI_CRM_CN_External_ID__c=null;//lokman 4/7/2014
                LCoveredOutlet_Clone.add(cloneCoveredOutlet);
            }
        }
        
        if(LCoveredOutlet_Clone != null && LCoveredOutlet_Clone.size() > 0) {
            insert LCoveredOutlet_Clone;
        }
        // (4) ------ Process Covered Outlet Items (end) ------
        
        // (5) ------ Process Attachment (start) ------
        if(LAtth != null && LAtth.size()>0)
        {
            for(Attachment originalAtth :LAtth) {
                Attachment cloneAtth = originalAtth.clone(false, true);
                cloneAtth.ParentId = LContract_Clone[MapContract.get(originalAtth.ParentId)].Id;
                System.debug(cloneAtth.ParentID);
                cloneAtth.ownerid = UserInfo.getUserID();
                
                //LAtth_Clone.add(cloneAtth);
            }
        }
        
        if(LAtth_Clone != null && LAtth_Clone.size() > 0) {
            System.debug(LAtth_Clone);
            insert LAtth_Clone;
        }
        // (5) ------ Process Attachment (end) ------
        
      
        if(LFeed_Clone != null && LFeed_Clone.size() > 0) {
            insert LFeed_Clone;
        }        
        // (6) ------ Process Feed (end) ------
        
        // (1) ------ Process Contract objects (end) ------    
        
        
        return LContract_Clone;
    }
    
    //***** added by leo @2014/07/03 - functions (start) *****
    private static void calcLatestVol(List<ASI_TH_CRM_Contract__c> LCont, Map<id,ASI_TH_CRM_Contract__c> MCont){
        // Calculate latest contract estimate vol in Customer for reporting
        Set<id> SContractID = new Set<id>();
    
        for(ASI_TH_CRM_Contract__c contract : LCont){
            // Added by Michael YIp (Introv) 04Jul2014 limit number of time updating contract
            if(MCont != null){
                if((contract.ASI_TH_CRM_Contract_Status__c == 'Final' && MCont.get(contract.id).ASI_TH_CRM_Contract_Status__c != 'Final')
                   || (contract.ASI_TH_CRM_Contract_Status__c != 'Final' && MCont.get(contract.id).ASI_TH_CRM_Contract_Status__c == 'Final')){
                       SContractID.add(contract.id);
                   }
            }
            else    // for insert/delete
                SContractID.add(contract.id);
        }
        if(SContractID.size()>0){
            
            List<ASI_TH_CRM_Contract__c> LContract = [Select id, name, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_Return_Flag__c, 
                                                      ASI_CRM_CN_BRSF_Total_Est_Monthly_Qty__c, ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Contract_External_ID__c
                                                      from ASI_TH_CRM_Contract__c
                                                      where id IN :SContractID and 
                                                      (ASI_TH_CRM_Promotion_Type__c = 'New Contract ON' or ASI_TH_CRM_Promotion_Type__c = 'New Contract OFF'
                                                       or ASI_TH_CRM_Promotion_Type__c = 'New Contract - On' or ASI_TH_CRM_Promotion_Type__c = 'New Contract - Off')
                                                      and ASI_CRM_CN_Status__c = 'Final'
                                                      order by ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Start_Date__c desc ];
            System.debug(LContract);
            Set<id> SCustomerID = new Set<id>();
            for(ASI_TH_CRM_Contract__c c : LContract){
                SCustomerID.add(c.ASI_CRM_CN_Outlet_WS__c);
            }
            
            List<ASI_CRM_AccountsAdditionalField__c> LCustomer = [Select id, name, ASI_CRM_CN_Latest_Contract_Target_Volume__c 
                                                                  from ASI_CRM_AccountsAdditionalField__c
                                                                  where id IN :SCustomerID];
            System.debug(LCustomer);
            
            List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LContractBRSF = [SELECT ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_External_ID__c, id, ASI_CRM_CN_Est_Monthly_Qty__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =: SContractID];
            
            calcLatestVol(LCustomer, LContract, LContractBRSF);
        }
    }
    
    private static void calcLatestVol(List<ASI_CRM_AccountsAdditionalField__c> LCustomer, List<ASI_TH_CRM_Contract__c> LContract, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LContractBRSF){
        Map<id,ASI_CRM_AccountsAdditionalField__c> MCustomer = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c cus :LCustomer){
            MCustomer.put(cus.id, cus);
        }
        System.debug(MCustomer);
        List<ASI_CRM_AccountsAdditionalField__c> LCustomerUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
        Set<id> SCusUpdatedID = new Set<id>();
        for(ASI_TH_CRM_Contract__c con : LContract){
            if(!SCusUpdatedID.contains(con.ASI_CRM_CN_Outlet_WS__c) && MCustomer.containsKey(con.ASI_CRM_CN_Outlet_WS__c)){
                ASI_CRM_AccountsAdditionalField__c cus = MCustomer.get(con.ASI_CRM_CN_Outlet_WS__c);
                System.debug(cus);
                
                // get Est_Monthly_Qty from Contract BRSF Line items
                decimal sumEstMonthlyQty = 0;
                if(LContractBRSF != null && LContractBRSF.size()>0)
                {
                    for(ASI_CRM_CN_Contract_BRSF_Line_Item__c conBRSF : LContractBRSF){
                        if(conBRSF.ASI_CRM_CN_Contract__c == con.id)
                        {
                            if(conBRSF.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                            {
                                sumEstMonthlyQty += conBRSF.ASI_CRM_CN_Est_Monthly_Qty__c;
                            }
                        }
                    }                                   
                }
                
                cus.ASI_CRM_CN_Latest_Contract_Target_Volume__c  = sumEstMonthlyQty;
                SCusUpdatedID.add(con.ASI_CRM_CN_Outlet_WS__c);
                LCustomerUpdate.add(cus);
            }
        }
        System.debug(LCustomerUpdate);
        if(LCustomerUpdate != null && LCustomerUpdate.size()>0){
            update LCustomerUpdate;
        }
    }
    //***** added by leo @2014/07/03 - functions (end) *****
    
    private static boolean checkPromotionTypeRBA(ASI_TH_CRM_Contract__c tmpContract) {
        boolean isAddRBAApprover = ASI_CRM_SpecialPromotionTypeSettingCache.getPromotionTypeRBA(tmpContract.ASI_TH_CRM_Promotion_Type__c, Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        
        return isAddRBAApprover;
    }
}