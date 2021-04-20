public  without sharing class ASI_CRM_CN_HeavyContract_TriggerClass {
    private static Boolean HasRunBeforeUpsert = false;
    
    
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        User u = ASI_CRM_CN_Function.getUser(curUserId);           
        if(u != null && u.BypassTriggers__c != null){
            if (u.BypassTriggers__c.contains('ASI_CRM_CN_Contract_TriggerClass') && !Test.isRunningTest()){
                isByPass = true;
            }
        }
        return isByPass;
    }
    
    
    
    public static string findSOAid(){
        string soaid = '';
        string AdminId='';
        for(User u : ASI_CRM_CN_Function.getUserList()){
            if(u.username.contains('prasia_soa@service.pernod-ricard.com')){
                soaid  = u.id; 
            }          
        }
        
        return soaid;
    }
    
    
    public static void routineAfterUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        
        
    }
    
    
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        //Decimal SingleContractAmount = 0;
        if(!isBypassByCurrentUser()){
            
            Set<ID> payID = new Set<ID>();
            Map<String, String> mapRejectedComment = new Map<String, String>();
            
            
            for(ASI_TH_CRM_Contract__c obj : trigger_new){
                //SingleContractAmount=ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(obj);
                if(trigger_oldMap.get(obj.id).ASI_CRM_CN_Status__c == 'Submitted' && obj.ASI_CRM_CN_Status__c == 'Draft'){
                    payID.add(obj.id);
                }
                
                //For national Contract if change from  Submitted to  Approved then change status to Final  
                if(trigger_oldMap.get(obj.id).ASI_CRM_CN_Status__c == 'Submitted' && obj.ASI_CRM_CN_Status__c == 'Approved' && obj.ASI_CRM_CN_National_Group_Contract__c ){
                    obj.ASI_CRM_CN_Status__c= 'Final';
                }
                //For Local Group Contract if the status change from  Submitted to  Approved then sending email to Local Group Contract Owner  
                if(trigger_oldMap.get(obj.id).ASI_CRM_CN_Status__c == 'Submitted' && obj.ASI_CRM_CN_Status__c == 'Approved' && obj.ASI_CRM_CN_Local_Group_Contract__c ){
                    if(obj.ASI_CRM_CN_Group_Contract__c!=null){
                        ASI_CRM_CN_HeavyContracFunctionClass.SendingEmailToContractOwner(obj.Id,obj.ASI_CRM_CN_Group_Contract__c,'ASI_CRM_CN_Heavy_Contract_ApprovedEmail');
                    }
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
                        if(mapRejectedComment.containsKey(obj.id) ){ //&& obj.ASI_CRM_CN_Approval_Status__c == 'Rejected' && trigger_oldMap.get(obj.id).ASI_CRM_CN_Approval_Status__c == 'Submitted'
                            obj.ASI_CRM_CN_Return_Comments__c = ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Returned-': 'Rejected-')  + mapRejectedComment.get(obj.id);
                            obj.ASI_CRM_Reject_Return_Comments__c = (obj.ASI_CRM_Reject_Return_Comments__c == NULL || obj.ASI_CRM_Reject_Return_Comments__c == '') ? ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ') + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id) :  ( (obj.ASI_CRM_Branch__c == 'returned') ? 'Return Comment / ': 'Reject Comment / ')  + UserInfo.getName() + ' / ' + Datetime.now().format('YYYY-MM-dd') + ':' + '\n' + mapRejectedComment.get(obj.id)+ '\n' + obj.ASI_CRM_Reject_Return_Comments__c;
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
            List<ASI_CRM_SpecialPromotionTypeSetting__c> LPromotionalType = [Select id, ASI_CRM_Promotion_Type__c, ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c
                                                                             From ASI_CRM_SpecialPromotionTypeSetting__c]; 
            for(ASI_CRM_SpecialPromotionTypeSetting__c p : LPromotionalType){
                MPromotionType.put(p.ASI_CRM_Promotion_Type__c, p.ASI_CRM_Add_RBA_As_Final_Approver_V0_0__c);                    
            }
            
            //  limit set approver when status is draft
            Boolean needSetApprover = false;
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                if(contract.ASI_CRM_CN_Status__c == 'Draft'){
                    SContractID.add(contract.id);
                    needSetApprover = true;
                    break;
                }
            }
            // find the manager from hierarchy if it is not included in dynamic route
            if(needSetApprover){
                List<ASI_CRM_Dynamic_Approval_Route__c> LApp = [Select id, ASI_CRM_Approval_Limit__c, ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c
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
                
                
                //  checking IHBR flag and National Group Contract Flag
                List<ASI_TH_CRM_Contract__c> LFlag = [Select id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_Return_Flag__c  from ASI_TH_CRM_Contract__c where id IN:SContractID];
                
                List<ASI_CRM_Fix_Approval_Route__c> LFApp;       
                
                
                string ApprovalRouteType='Heavy Contract On';
                if(trigger_new[0].ASI_CRM_CN_Local_Group_Contract__c && trigger_new[0].ASI_CRM_CN_PO_Version__c=='0.0'){
                    ApprovalRouteType='Local Group Contract';
                }
                if(trigger_new[0].ASI_CRM_CN_National_Group_Contract__c){
                    ApprovalRouteType='Group Contract' ;
                }
                LFApp = [Select Id,ASI_CRM_RVP__c,ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_Max_Amount__c, ASI_CRM_CN_Entry_Limit__c,ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,
                         ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c, ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approver_7__c,ASI_CRM_CN_Approver_8__c,ASI_CRM_CN_Approver_9__c,ASI_CRM_CN_Approver_10__c,ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                         ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c,ASI_CRM_CN_Approval_Limit_7__c,ASI_CRM_CN_Approval_Limit_8__c,ASI_CRM_CN_Approval_Limit_9__c,ASI_CRM_CN_Approval_Limit_10__c,ASI_CRM_CN_Approval_Limit_11__c,
                         ASI_CRM_CN_Type__c, ASI_CRM_CN_Regional_BA__c, ASI_CRM_Sales_Team__c , ASI_CRM_Commercial_Team__c
                         from ASI_CRM_Fix_Approval_Route__c where ASI_CRM_CN_Type__c = : ApprovalRouteType ]; 
                
                
                for(ASI_CRM_Fix_Approval_Route__c a : LFApp){
                    // Boolean AllowPush= false;
                    String commercialTeam = a.ASI_CRM_Commercial_Team__c != Null && a.ASI_CRM_Commercial_Team__c != '' ? a.ASI_CRM_Commercial_Team__c : ''; // if(AllowPush){
                    MAppLastRouteFix.put(a.ASI_CRM_Sales_Team__c + commercialTeam, a);
                }
                
                LFApp = null;
            }
            
            
            Set<String> SPONoClone = new Set<String>();
            Set<String> SUpdatingRecID = new Set<String>();
            
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                // limit set approver when status is draft
                if(contract.ASI_CRM_CN_Status__c == 'Draft' ){
                    setApproverToNull(contract);
                    
                    setApprovers(contract, MAppRouteFix, MAppRoute, MAppLastRouteFix, checkPromotionTypeRBA(contract), MUser, MPromotionType);
                }
                if(contract.ASI_CRM_CN_PO_Modification__c && !trigger_oldMap.get(contract.id).ASI_CRM_CN_PO_Modification__c){
                    //LContractNeedClone.add(contract);
                    Last_version.put(contract.ASI_CRM_CN_PO_No__c,contract.ASI_CRM_CN_PO_Version__c);
                    SPONoClone.add(contract.ASI_CRM_CN_PO_No__c);
                    SUpdatingRecID.add(contract.id);
                }
            }
            
            
            List<ASI_TH_CRM_Contract__c> clonedContracts = new List<ASI_TH_CRM_Contract__c>();
            
            
            List<ASI_CRM_Approval_Comment__c> LPOContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>(); //Twinkle 11/26/2014            
            
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                contract.Name=update_contractNo(contract);
                If((trigger_oldMap.get(contract.id).ASI_CRM_CN_Status__c != 'Final' && contract.ASI_CRM_CN_Status__c == 'Final') && contract.ASI_CRM_CN_BA_Final_Approver__c == true){
                    contract.ASI_CRM_CN_Contract_Upload__c = true;
                } 
            }
        }
        
    }
    
    
    
    
    public static string update_contractNo(ASI_TH_CRM_Contract__c c){
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
    
    
    public static void routineBeforeUpsert(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            c.ASI_TH_CRM_Contract_Status__c = c.ASI_CRM_CN_Status__c;
            if(c.ASI_CRM_CN_Status__c == 'Archived'){
                c.ASI_CRM_CN_IsClone__c = true;
            }
        }
        
        
        if(!ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_checkOverlapBypass')){ // select id,Name,BypassTriggers__c from user where id='005M0000006Ghih'
            checkOverlap(trigger_new,trigger_oldMap);
        }
        
        
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
        List<ASI_TH_CRM_Contract__c> contracts = [SELECT Id,Name, ASI_TH_CRM_Contract_External_ID__c ,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Return_Flag__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c IN :crmCodeMap.keySet() AND Name like :sameDate AND ASI_CRM_CN_Status__c <> 'Archived' AND (NOT ASI_CRM_CN_Status__c LIKE 'FY landing Archive') ORDER BY CreatedDate DESC];
        
        for(ASI_TH_CRM_Contract__c contract:contracts){
            if(!contractNoMap.keySet().contains(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c)){
                contractNoMap.put(contract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c,contract.Name);
            }  
        }
        
        for (ASI_TH_CRM_Contract__c contract:trigger_new) {
            if (contract.CreatedDate == null || (Test.isRunningTest() && contract.ASI_CRM_System_Debug__c)){
                String crmCode = outletIdCrmCodeMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
                Integer no = crmCodeNoMap.get(crmCode);
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
                Integer poVersionNo = 0;
                if(contract.ASI_CRM_CN_PO_Version__c != null){
                    String[] poVersion = contract.ASI_CRM_CN_PO_Version__c.split('\\.',0);
                    poVersionNo = Integer.valueOf(poVersion[1]);
                } 
                if(contract.Name == 'Automated, Do not Change')
                    contract.Name = crmCode + '.' + no + '.' + Datetime.now().format('yyyyMMdd') + '.' + poVersionNo;
            }
        }
        
        
        
    }
    
    
    
    public static void routineAfterInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!isBypassByCurrentUser()){
            Id BRSFLineRtId =Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CRM_CN_Contract_Heavy_BRSF');
            List<ASI_CRM_Contract_Cost__c> LContractCost_Insert = new List<ASI_CRM_Contract_Cost__c>();
            //List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFLineInsert= new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
            List<ASI_CRM_Approval_Comment__c> LNewContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
            // List<ASI_CRM_Module__c> ModuleList=new List<ASI_CRM_Module__c>();
            
            //----- get Contract Cost Setting List -----////ASI_CRM_CN_Activity_Code__c
            List<ASI_CRM_Contract_Cost_Setting__c> LContractCostSettingList = [SELECT id, Name, ASI_CRM_CN_Activity_Code__c,ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Fixed_Cost_Contract__c, ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Variable_Cost_Contract__c,   ASI_CRM_CN_Other_Cost_Payment_Request__c  FROM ASI_CRM_Contract_Cost_Setting__c];
            
            
            Set<String>  OutletWSSet= new Set<String>();
            for(ASI_TH_CRM_Contract__c Contract: trigger_new){
                OutletWSSet.add(Contract.ASI_CRM_CN_Outlet_WS__c);
            }
            
            //Get this contract's outlet
            
            Map<String,ASI_CRM_AccountsAdditionalField__c> OutletMap= new Map<String,ASI_CRM_AccountsAdditionalField__c>();
            for(ASI_CRM_AccountsAdditionalField__c Outlet : [select Id,ASI_CRM_CN_New_Image__c,ASI_CRM_CN_NewChannel__c,ASI_CRM_CN_Region__c,ASI_CRM_CN_Commercial_Team__c from ASI_CRM_AccountsAdditionalField__c where Id in :OutletWSSet and ASI_CRM_CN_New_Image__c!=null and ASI_CRM_CN_NewChannel__c !=null]){
                OutletMap.put(Outlet.Id, Outlet);//Outlet.ASI_CRM_CN_New_Image__c+Outlet.ASI_CRM_CN_NewChannel__c
            }
            
            //integer CounNum=0;
            String BRSFActivityCodeId='';
            for (ASI_TH_CRM_Contract__c contract:trigger_new) {
                if(LContractCostSettingList.size() > 0) {
                    if(contract.ASI_CRM_CN_IsClone__c == null || contract.ASI_CRM_CN_IsClone__c == false){  // check "contract" with "contract cost setting" 
                        for (ASI_CRM_Contract_Cost_Setting__c ccs:LContractCostSettingList) {
                            if(contract.ASI_TH_CRM_Promotion_Type__c == ccs.ASI_CRM_CN_Promotion_Type__c){
                                if((ccs.ASI_CRM_CN_Fixed_Cost_Contract__c != null && ccs.ASI_CRM_CN_Fixed_Cost_Contract__c == true) || (ccs.ASI_CRM_CN_Variable_Cost_Contract__c != null && ccs.ASI_CRM_CN_Variable_Cost_Contract__c == true)) {// create a "Contract Cost" object for the "Contract" 
                                    ASI_CRM_Contract_Cost__c newCS = CreateContractCostObjByContract(contract, ccs); // Added by Laputa : for Heavy Contract On only add fixed Contract Cost
                                    if(ccs.ASI_CRM_CN_Fixed_Cost_Contract__c){
                                        LContractCost_Insert.add(newCS);
                                    }
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
            
            //####### Contract Cost (end) #######
        }
        
        
    }
    
    //********************function********************************************************************************************************************************
    public static ASI_CRM_Contract_Cost__c CreateContractCostObjByContract (ASI_TH_CRM_Contract__c contract, ASI_CRM_Contract_Cost_Setting__c ccs) {
        ASI_CRM_Contract_Cost__c cs = new ASI_CRM_Contract_Cost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost'));
        cs.ASI_CRM_CN_Contract__c = contract.id;
        cs.Name = ccs.Name;
        cs.ASI_CRM_CN_Activity_Code__c = ccs.ASI_CRM_CN_Activity_Code__c;
        if(ccs.ASI_CRM_CN_Fixed_Cost_Contract__c != null && ccs.ASI_CRM_CN_Fixed_Cost_Contract__c == true){
            cs.ASI_CRM_CN_Cost_Type__c = 'Fixed';
        }
        cs.ASI_CRM_CN_Chinese_Description__c = ccs.ASI_CRM_CN_Chinese_Description__c;
        cs.ASI_CRM_CN_Sequence__c = ccs.ASI_CRM_CN_Sequence__c;
        cs.ASI_CRM_CN_Other_Cost_Payment_Request__c = ccs.ASI_CRM_CN_Other_Cost_Payment_Request__c;
        return cs;
    }
    
    
    
    
    
    
    
    public static void checkOverlap(list <ASI_TH_CRM_Contract__c > trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        string SOAid = findSOAid();
        Set<id> SOutletID = new Set<id>();
        Set<String> SPromotionType = new Set<String>();     
        Set<id> SCurrentContractID = new Set<id>();
        
        List<ASI_CRM_Special_Promotion_Type_Mapping__c> promtionTypeMappingList = new List<ASI_CRM_Special_Promotion_Type_Mapping__c>([SELECT id , ASI_CRM_Mapping_of_New_Promotion_Type__c  , ASI_CRM_Mapping_of_Old_Promotion_Type__c , ASI_CRM_Mapping_of_New_Promotion_Type__r.ASI_CRM_Promotion_Type__c , ASI_CRM_Mapping_of_Old_Promotion_Type__r.ASI_CRM_Promotion_Type__c FROM ASI_CRM_Special_Promotion_Type_Mapping__c  WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Special_Promotion_Type_Mapping']);
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
        
        
        for(ASI_TH_CRM_Contract__c c : trigger_new){
            if((c.ownerid != null && c.ownerid != SOAid) || (c.ownerid == null && Userinfo.getUserId() != SOAid)){
                if(c.ASI_CRM_CN_Status__c == 'Draft' && !c.ASI_CRM_CN_IsClone__c){
                    SOutletID.add(c.ASI_CRM_CN_Outlet_WS__c);
                    SPromotionType.add(c.ASI_TH_CRM_Promotion_Type__c);
                    SCurrentContractID.add(c.id);
                    if(mapOldPromotionType.containsKey(c.ASI_TH_CRM_Promotion_Type__c)){
                        SPromotionType.addAll(mapOldPromotionType.get(c.ASI_TH_CRM_Promotion_Type__c));
                    }
                }
            }
        }
        
        
        if(SOutletID.size()>0){
            List<ASI_TH_CRM_Contract__c> LContractExisting = [Select id, name, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Return_Flag__c  
                                                              from ASI_TH_CRM_Contract__c where RecordType.DeveloperName like 'ASI_CRM_CN%' and ASI_CRM_CN_Outlet_WS__c IN :SOutletID and 
                                                              ASI_TH_CRM_Promotion_Type__c IN :SPromotionType and ASI_CRM_CN_Status__c <> 'Archived'  and id not in :SCurrentContractID
                                                              AND (NOT ASI_CRM_CN_Status__c LIKE 'FY Landing Archive') order by ASI_CRM_CN_PO_Start_Date__c desc];
            
            system.debug('**LContractExisting'+LContractExisting);
            if(LContractExisting.size()>0){
                for(ASI_TH_CRM_Contract__c c : trigger_new){
                    Boolean isOverlap = false;
                    if((c.ownerid != null && c.ownerid != SOAid) || (c.ownerid == null && Userinfo.getUserId() != SOAid)){
                        for(ASI_TH_CRM_Contract__c contractOld : LContractExisting){
                            if(contractOld.ASI_CRM_CN_Outlet_WS__c == c.ASI_CRM_CN_Outlet_WS__c && 
                               (contractOld.ASI_TH_CRM_Promotion_Type__c == c.ASI_TH_CRM_Promotion_Type__c 
                                || (mapOldPromotionType.containsKey(c.ASI_TH_CRM_Promotion_Type__c) && mapOldPromotionType.get(c.ASI_TH_CRM_Promotion_Type__c).contains(contractOld.ASI_TH_CRM_Promotion_Type__c)) ) && contractOld.id != c.id){
                                    if(isOverlap(contractOld.ASI_CRM_CN_PO_Start_Date__c, contractOld.ASI_CRM_CN_PO_End_Date__c, c.ASI_CRM_CN_PO_Start_Date__c, c.ASI_CRM_CN_PO_End_Date__c)){
                                        isOverlap = true;
                                        break;
                                    }
                                }
                        }
                    }
                    if(isOverlap ){
                        c.addError(Label.ASI_CRM_CN_Contract_Date_Overlap);
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
    
    private static boolean checkPromotionTypeRBA(ASI_TH_CRM_Contract__c tmpContract) {
        boolean isAddRBAApprover = ASI_CRM_SpecialPromotionTypeSettingCache.getPromotionTypeRBA(tmpContract.ASI_TH_CRM_Promotion_Type__c, Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        
        return isAddRBAApprover;
    }
    
    
    
    public static void setApprovers(ASI_TH_CRM_Contract__c p, Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix,
                                    Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, 
                                    Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix,  boolean isAddRBAApprover,
                                    Map<id, User> MUser, Map<String, boolean> MPromotionType)
    {
        
        Decimal TotalAmount =ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(p);
        p.ASI_CRM_SG_Total_Contract_Margin__c = TotalAmount; //Save the total Amount
        
        Integer approver_count = 0;
        Integer return_approver_count = 0;
        
        //retrieve max contract amount
        Decimal maxContractAmount = -99999999;  //INC0084970 Fix: Michael Yip (Laputa) add ASI_TH_CRM_Promotion_Type__c field into contract SOQL
        for(ASI_TH_CRM_Contract__c ContractTemp :[Select Id,ASI_CRM_Est_Total_Dummy__c,ASI_CRM_CN_PO_Version__c,
                                                  ASI_CRM_CN_Total_Contract_Amount__c,ASI_CRM_CN_Contract_Fixed_Cost_Total__c, ASI_TH_CRM_Promotion_Type__c From ASI_TH_CRM_Contract__c 
                                                  where ASI_CRM_CN_PO_No__c = :p.ASI_CRM_CN_PO_No__c and ASI_CRM_CN_Status__c = 'Archived'])
        {
            Decimal contractAmount =ASI_CRM_CN_HeavyContractUtilitiesClass.CalTotalContractAmount(ContractTemp);
            if(maxContractAmount == -99999999){
                maxContractAmount =contractAmount;
            }
            if(maxContractAmount != -99999999 && contractAmount>maxContractAmount){
                maxContractAmount =contractAmount;
            }
            
        }
        maxContractAmount = maxContractAmount + 1;
        boolean onlyFix2Route1 = false;
        if(TotalAmount<= maxContractAmount){ 
            onlyFix2Route1 = true;
        }
        
        List<ASI_TH_CRM_Contract__c> LContract = [Select id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Return_Flag__c, OwnerId
                                                  from ASI_TH_CRM_Contract__c  where id =:p.id];
        
        // First Fix Route
        
        boolean proceed = true;
        id currentUserid = p.ASI_CRM_CN_Owner_Manager_ID__c;
        
        ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
        User currentApproverU = null;
        
        //**************************************Dynamic Route**************************************
        while(proceed && !onlyFix2Route1){
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
                    setApproverByCount(p, approver_count, currentApprover.ASI_CRM_User__c);
                }else if(currentApprover == null && currentApproverU != null){
                    setApproverByCount(p, approver_count, currentApproverU.id);
                }
                
                approver_count++;
                if(currentApprover != null){
                    if( currentApprover.ASI_CRM_End_of_Dynamic_Route__c || currentApprover.ASI_CRM_Approval_Limit__c >= TotalAmount){
                        proceed = false;
                    }
                }                                               
                currentApprover = null;
                currentApproverU = null;
            }else{
                proceed = false;
            }
        }
        
        //************************************second fix  Route************************************
        ASI_CRM_Fix_Approval_Route__c fixApprover2;
        for(ASI_TH_CRM_Contract__c c: LContract ){
            if(MUser.containsKey(p.OwnerId) && MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c != null){
                fixApprover2 = MAppLastRouteFix.containsKey(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) ? MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c + p.ASI_CRM_Commercial_Team__c) : MAppLastRouteFix.get(MUser.get(p.OwnerId).ASI_CRM_Sales_Team__c);
            }
        }
        
        if(fixApprover2 != null){
            if(fixApprover2.ASI_CRM_CN_Regional_BA__c!=null){
                p.ASI_CRM_Last_RBA_Approver__c=fixApprover2.ASI_CRM_CN_Regional_BA__c;
            }
            p.ASI_CRM_Approval_Route_Id__c = fixApprover2.Id ; 
        }
        
        Boolean GroupSpecialCOAApproval=false;
        if(p.ASI_CRM_CN_Group_Contract__c!=null && p.ASI_CRM_RVP_Approval__c){
            GroupSpecialCOAApproval=true;
        }
        
        if(fixApprover2 != null && fixApprover2.ASI_CRM_CN_Entry_Limit__c < TotalAmount  && !GroupSpecialCOAApproval){
            
            
            //set Return Approvers
            if(fixApprover2 .ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                    return_approver_count++;
                }
            }
            
            if(!onlyFix2Route1){
                
                if(p.ASI_CRM_RVP_Approval__c && fixApprover2.ASI_CRM_RVP__c!=NULL){
                    Boolean FoundRVP=False;//ASI_CRM_RVP__c
                    Boolean AllowPut=False;
                    
                    //Approver_2
                    if(fixApprover2 .ASI_CRM_CN_Approver_2__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_2__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_1__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                            return_approver_count++;
                        }
                    }
                    
                    
                    //Approver_3
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_3__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_3__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_2__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_3__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                            return_approver_count++;
                        }
                    }
                    
                    
                    
                    //Approver_4
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_4__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_4__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_3__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_4__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                            return_approver_count++;
                        }
                    }
                    
                    
                    //Approver_5
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_5__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_5__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_4__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_5__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                            return_approver_count++;
                        }
                    }
                    
                    //Approver_6
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_6__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_6__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_5__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                            return_approver_count++;
                        }
                    }//Ending*************
                    
                    
                    
                    //Approver_7
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_7__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_7__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_6__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                            return_approver_count++;
                        }
                    }//Ending*************
                    
                    
                    //Approver_8
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_8__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_8__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_7__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                            return_approver_count++;
                        }
                    }//Ending*************
                    
                    
                    
                    //Approver_9
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_9__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_9__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_8__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                            return_approver_count++;
                        }
                    }//Ending*************
                    
                    
                    //Approver_10
                    AllowPut=False;
                    if(fixApprover2 .ASI_CRM_CN_Approver_10__c != null){
                        if(!FoundRVP){ //Have not found RVP
                            if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_10__c){
                                FoundRVP=true;
                            } 
                            AllowPut=true;
                        }else{
                            if(fixApprover2 .ASI_CRM_CN_Approval_Limit_9__c < TotalAmount ){
                                AllowPut=true;
                            }
                        }
                    }
                    
                    if(AllowPut){
                        setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                        approver_count++;
                        if(p.ASI_CRM_CN_Return_Flag__c){
                            setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                            return_approver_count++;
                        }
                    }//Ending*************
                    
                    
                    
                    
                    
                }else{
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_1__c < TotalAmount ){
                        if(fixApprover2 .ASI_CRM_CN_Approver_2__c != null){
                            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                            approver_count++;
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_2__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_3__c != null){
                            setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_3__c);
                            approver_count++;
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_3__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_4__c != null){
                            setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_4__c);
                            approver_count++;
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_4__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_5__c != null){
                            setApproverByCount(p, approver_count, fixApprover2 .ASI_CRM_CN_Approver_5__c);
                            approver_count++;
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_5__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_6__c != null){
                            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                            approver_count++;
                            
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_6__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_7__c != null){
                            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                            approver_count++;
                            
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_7__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_8__c != null){
                            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                            approver_count++;
                            
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_8__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_9__c != null){
                            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                            approver_count++;
                            
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                                return_approver_count++;
                            }
                        }
                    }
                    
                    if(fixApprover2 .ASI_CRM_CN_Approval_Limit_9__c < TotalAmount){
                        if(fixApprover2 .ASI_CRM_CN_Approver_10__c != null){
                            setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                            approver_count++;
                            
                            if(p.ASI_CRM_CN_Return_Flag__c){
                                setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                                return_approver_count++;
                            }
                        }
                    }
                    //Ending*************
                }
                
                
            }
        }
        
        if(Test.isRunningTest())
            GroupSpecialCOAApproval =true;
        
        //Group Contract if check RVP Approver
        //system.debug('927 =====>fixApprover2 != null'+fixApprover2.ASI_CRM_CN_Entry_Limit__c );
        //system.debug('927 =====>TotalAmount'+TotalAmount );
        //system.debug('929 =====>GroupSpecialCOAApproval'+GroupSpecialCOAApproval);
        //system.debug('930 =====>fixApprover2 != null'+fixApprover2 != null);
        if((fixApprover2 != null && fixApprover2.ASI_CRM_CN_Entry_Limit__c < TotalAmount  && GroupSpecialCOAApproval )){
            if(fixApprover2 .ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_1__c);
                    return_approver_count++;
                }
            }
            
            Boolean FoundRVP=False;
            if(fixApprover2.ASI_CRM_CN_Approver_2__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_2__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_2__c);
                    return_approver_count++;
                }
                
            }	  
            if(fixApprover2.ASI_CRM_CN_Approver_3__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_3__c){
                    FoundRVP=true;
                }
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_3__c);
                    return_approver_count++;
                }
                
            }	  
            
            if(fixApprover2.ASI_CRM_CN_Approver_4__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_4__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_4__c);
                    return_approver_count++;
                }
                
            }	  
            
            
            if(fixApprover2.ASI_CRM_CN_Approver_5__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_5__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_5__c);
                    return_approver_count++;
                }
                
            }	  
            
            if(fixApprover2.ASI_CRM_CN_Approver_6__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_6__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_6__c);
                    return_approver_count++;
                }
                
            }
            
            
            if(fixApprover2.ASI_CRM_CN_Approver_7__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_7__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_7__c);
                    return_approver_count++;
                }
                
            }
            
            if(fixApprover2.ASI_CRM_CN_Approver_8__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_8__c){
                    FoundRVP=true;
                }
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_8__c);
                    return_approver_count++;
                }
                 
            }
            
            
            if(fixApprover2.ASI_CRM_CN_Approver_9__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_9__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_9__c);
                    return_approver_count++;
                }
                
            }
            
            
            if(fixApprover2.ASI_CRM_CN_Approver_10__c != null && fixApprover2.ASI_CRM_RVP__c!=NULL && !FoundRVP){
                if(fixApprover2.ASI_CRM_RVP__c==fixApprover2.ASI_CRM_CN_Approver_10__c){
                    FoundRVP=true;
                } 
                setApproverByCount(p, approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                approver_count++;
                if(p.ASI_CRM_CN_Return_Flag__c){
                    setReturnApproverByCount(p, return_approver_count, fixApprover2.ASI_CRM_CN_Approver_10__c);
                    return_approver_count++;
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
}