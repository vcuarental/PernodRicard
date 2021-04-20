public with sharing class ASI_CRM_MO_Contract_TriggerClass {
    public static String TRIGGER_NAME = 'ASI_CRM_MO_ContractTrigger';
    
    public static void routineBeforeInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!ASI_CRM_MO_Function.IsBypassTrigger(TRIGGER_NAME)){
            // Declaration
            set<id> setOutletWS = new set<id>();
            map<id, String> mapOutletResp = new map<id, String>();
            map<id, boolean> mapOutletIsParent = new map<id, boolean>();
            map<id, String> mapOutletCatCode = new map<id, String>();
            ASI_CRM_MO_ContractCommon clsContract = new ASI_CRM_MO_ContractCommon();
            // Declaration - End
            
            for (ASI_TH_CRM_Contract__c objContract : trigger_new) {
                setOutletWS.add(objContract.ASI_TH_CRM_Outlet__c);
                
                ASI_CRM_MO_RunningNumber_TriggerCls clsRunningNum = new ASI_CRM_MO_RunningNumber_TriggerCls('Contract');
                // To generate the new id if the contract is not deepClone as a history
                if (objContract.ASI_CRM_Is_Processing__c != TRUE || objContract.ASI_TH_CRM_Contract_Status__c != 'Final') {
                    System.debug('routineBeforeInsert: New Running Number');
                    objContract.ASI_CRM_Version__c = '0';
                    objContract.Name = objContract.ASI_CRM_Customer_Code__c + '.' + clsContract.getFiscalYear(objContract.ASI_TH_CRM_Start_Date__c) + clsRunningNum.nextAutoNumStr() + '.' + objContract.ASI_CRM_Version__c;
                    clsRunningNum.writeToDB();
                    
                    // TODO, reduce number of calls
                    if (objContract.ASI_CRM_CN_Exchange_Rate__c == null || objContract.ASI_CRM_CN_Exchange_Rate__c == 0) {
                        objContract.ASI_CRM_CN_Exchange_Rate__c = clsContract.getExRate(objContract.ASI_CRM_CN_Currency__c, objContract.ASI_TH_CRM_Start_Date__c);
                    }
                } else {
                    System.debug('routineBeforeInsert: NOT Getting New Running Number');
                }
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        if(!ASI_CRM_MO_Function.IsBypassTrigger(TRIGGER_NAME)){
            // Declaration
            ASI_CRM_MO_ContractCommon clsContract = new ASI_CRM_MO_ContractCommon();
            list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract that just updating and no version revise is needed
            list<ASI_TH_CRM_Contract__c> lstContractRevise = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract need to revise
            list<ASI_TH_CRM_Contract__c> lstContractRevise_OLD = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract need to revise
            
            list<ASI_TH_CRM_Contract__c> lstContractFinal = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract need to finalize
            map<id, String> mapRevision = new map<id, String>{};
            integer intCounter = 0;
            String strErrMsg = '';
            
            Map<id, User> MUser = new Map<id, User>();
            Map<string, boolean> MPromotionType = new Map<string, boolean>();
            Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_CRM_Dynamic_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix = new Map<string, ASI_CRM_Fix_Approval_Route__c>();
            Map<id, boolean> mapMktApproval = new Map<id, boolean>();
            Set<id> setContractID = new Set<id>(); 
            set<id> setCostMktApproval = new set<id>();
            // Declaration - End
            
            // Approval - Start
            Boolean needSetApprover = false;
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                if(contract.ASI_TH_CRM_Contract_Status__c == 'Draft'){
                    setContractID.add(contract.id);
                    needSetApprover = true;
                    mapMktApproval.put(contract.id, false); // Initial
                    break;
                }
            }
            if (needSetApprover){
                id idRTInvPayment = Global_RecordTypeCache.getRTId('ASI_CRM_Investment_Payment__cASI_CRM_MO_Investment_Payment');
                for (ASI_CRM_Investment_Payment__c obj : [
                    SELECT ID, ASI_CRM_Marketing_Approval__c FROM ASI_CRM_Investment_Payment__c WHERE ASI_CRM_Marketing_Approval__c = true AND RecordTypeId = :idRTInvPayment
                ]) {
                    setCostMktApproval.add(obj.id);
                }
                if (setCostMktApproval.size() > 0) {
                    for (ASI_CRM_Contract_Cost__c obj : [
                        SELECT id, ASI_CRM_Investment_Payment__c, ASI_CRM_CN_Contract__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c IN :setContractID
                    ]) {
                        if (setCostMktApproval.contains(obj.ASI_CRM_Investment_Payment__c)) {
                            mapMktApproval.put(obj.ASI_CRM_CN_Contract__c, true);
                        }
                    }
                }   
                
                List<ASI_CRM_Dynamic_Approval_Route__c> LApp = new list<ASI_CRM_Dynamic_Approval_Route__c>();//;[
                //    Select id, ASI_CRM_Approval_Limit__c,
                //  ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Manager_ID__c, ASI_CRM_Type__c, ASI_CRM_User__c 
                //    from ASI_CRM_Dynamic_Approval_Route__c 
                //    where ASI_CRM_Type__c = 'Contract'
                //];
                
                for (User u : [Select id, ManagerID from User Where CompanyName = 'Pernod Ricard China']){
                    MUser.put(u.id, u);
                }
                LApp = null;
                
                List<ASI_TH_CRM_Contract__c> LFlag = [
                    Select id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_National_Group_Contract__c, ASI_CRM_CN_Return_Flag__c
                    FROM ASI_TH_CRM_Contract__c
                    WHERE id IN:setContractID
                ];
                
                List<ASI_CRM_Fix_Approval_Route__c> LFApp;                          
                LFApp = [
                    Select ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_CN_Entry_Limit__c,
                    ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c,
                    ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c,  
                    ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c,
                    ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c,
                    ASI_CRM_CN_Type__c, ASI_CRM_CN_Regional_BA__c, ASI_CRM_Marketing_Approver__c 
                    from ASI_CRM_Fix_Approval_Route__c
                    where ASI_CRM_CN_Type__c = 'Contract 1st Part' or ASI_CRM_CN_Type__c = 'Contract 2nd Part' 
                ];
                for (ASI_CRM_Fix_Approval_Route__c a : LFApp) {
                    if(a.ASI_CRM_CN_Type__c == 'Contract 1st Part')
                        MAppRouteFix.put(a.ASI_CRM_CN_Region_Area_Channel__c, a);
                    else if(a.ASI_CRM_CN_Type__c == 'Contract 2nd Part')
                        MAppLastRouteFix.put(a.ASI_CRM_CN_Region_Area_Channel__c, a);                           
                }
                LFApp = null;
                System.debug(MAppRouteFix);
                System.debug(MAppLastRouteFix);
            }
            for(ASI_TH_CRM_Contract__c contract : trigger_new){
                // To limit set approver when status is draft
                if (contract.ASI_TH_CRM_Contract_Status__c == 'Draft'){
                    setApproverToNull(contract);                 
                    setApprovers(contract, MAppRouteFix, MAppRoute, MAppLastRouteFix, false, MUser, MPromotionType, mapMktApproval);
                }
            }
            // Approval - End
            
            // Prepare for revise/update/final
            for (ASI_TH_CRM_Contract__c objContract : trigger_new) {
            
                system.debug('ASI_CRM_MO_Contract_TriggerClass: Contract Old Map: ' + (trigger_oldMap.get(objContract.id)).Name);
                if (clsContract.checkNeedRevise(trigger_oldMap.get(objContract.id), objContract)) {
                    lstContractRevise.add(objContract);
                    lstContractRevise_OLD.add(trigger_oldMap.get(objContract.id));
                    system.debug('ASI_CRM_MO_Contract_TriggerClass: Revise: ' + string.valueof(objContract.Name) + ' ' + string.valueof(objContract.id));
                } else {
                    if (clsContract.checkGoFinal(trigger_oldMap.get(objContract.id), objContract)) {
                        lstContractFinal.add(objContract);
                        system.debug('ASI_CRM_MO_Contract_TriggerClass: Final: ' + string.valueof(objContract.Name) + ' ' + string.valueof(objContract.id));
                    } else {
                        // TODO, reduce number of calls
                        if (objContract.ASI_CRM_CN_Exchange_Rate__c == null || objContract.ASI_CRM_CN_Exchange_Rate__c == 0) {
                            objContract.ASI_CRM_CN_Exchange_Rate__c = clsContract.getExRate(objContract.ASI_CRM_CN_Currency__c, objContract.ASI_TH_CRM_Start_Date__c);
                        }
                            
                        lstContract.add(objContract);
                        system.debug('ASI_CRM_MO_Contract_TriggerClass: Update: ' + string.valueof(objContract.Name) + ' ' + string.valueof(objContract.id));
                    }
                }
                intCounter++;
            }
            
            system.debug('----------lstContract----------' + lstContract);
            system.debug('----------lstContractRevise----------' + lstContractRevise);
            system.debug('----------lstContractFinal----------' + lstContractFinal);
            
            Savepoint sp = Database.setSavepoint();
            try {
                system.debug('---------------------------------ASI_CRM_MO_Contract_TriggerClass.TRY BEFORE clsContract.reviseContracts');
                clsContract.reviseContracts(lstContractRevise, lstContractRevise_OLD); // Revise include: revising contract version and clone the whole set as copy
                system.debug('---------------------------------ASI_CRM_MO_Contract_TriggerClass.TRY AFTER clsContract.reviseContracts');
                lstContractRevise = lstContractRevise; // Just update and no further action needed
                strErrMsg += clsContract.updateValidation(lstContract, trigger_oldMap);
                strErrMsg += clsContract.finalValidation(lstContractFinal);
                System.debug('ASI_CRM_MO_Contract_TriggerClass: after updateValidation() ' + strErrMsg);
                if (strErrMsg != '') {
                    //throw new ContractException(strErrMsg);
                    trigger_new[0].addError(strErrMsg);
                    system.debug('ASI_CRM_MO_Contract_TriggerClass: updateValidation(): HAVE strError: ' + strErrMsg);
                } else {
                    clsContract.finalContracts(lstContractFinal); // To finalize contracts
                    system.debug('ASI_CRM_MO_Contract_TriggerClass: updateValidation(): NO Error');
                }
                system.debug('ASI_CRM_MO_Contract_TriggerClass: updateValidation(): strErrMsg: ' + strErrMsg);
            }catch (Exception e) {
                system.debug('ASI_CRM_MO_Contract_TriggerClass: updateValidation(): Exception: ' + e);
                Database.rollback(sp);
            } finally {
                if (strErrMsg != '') {
                    Database.rollback(sp);
                    system.debug('ASI_CRM_MO_Contract_TriggerClass: updateValidation(): finally');
                    trigger_new[0].addError(strErrMsg);
                }
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_TH_CRM_Contract__c> trigger_old) {
        if(!ASI_CRM_MO_Function.IsBypassTrigger(TRIGGER_NAME)){
            for(ASI_TH_CRM_Contract__c objContract : trigger_old) {
                if(objContract.ASI_TH_CRM_Contract_Status__c != 'Draft'){
                    objContract.addError('Only Draft Contract can be deleted.');
                }
            }
        }
    }
    
    public static void routineAfterUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        if(!ASI_CRM_MO_Function.IsBypassTrigger(TRIGGER_NAME)){
            list<ASI_CRM_Audit_Trail__c> lstAT = new list<ASI_CRM_Audit_Trail__c>();
            id MOAuditTrailRT = Global_RecordTypeCache.getRTId('ASI_CRM_Audit_Trail__cASI_CRM_MO_Audit_Trail');
            set<id> setContract = new set<id>();
            set<id> setOwner = new set<id>();
            map<id, string> mapOwner = new map<id, string>();
            set<id> setContractUptExRate = new set<id>();
            
            for(ASI_TH_CRM_Contract__c objContract : trigger_new){
                if(objContract.Ownerid != trigger_oldMap.get(objContract.id).Ownerid){
                    setContract.add(objContract.id);
                    setOwner.add(objContract.Ownerid);
                    setOwner.add(trigger_oldMap.get(objContract.id).Ownerid);
                }
            }
            
            for(User u : [SELECT id, Name FROM User WHERE id IN : setOwner]){
                mapOwner.put(u.id, u.name);
            }
            
            for(ASI_TH_CRM_Contract__c objContract : trigger_new){
                if(objContract.ASI_TH_CRM_Start_Date__c != trigger_oldMap.get(objContract.id).ASI_TH_CRM_Start_Date__c){
                     lstAT.add(new ASI_CRM_Audit_Trail__c(ASI_CRM_Contract__c = objContract.id, ASI_CRM_Field_Name__c = 'Start Date', ASI_CRM_Original__c = String.valueOf(trigger_oldMap.get(objContract.id).ASI_TH_CRM_Start_Date__c), ASI_CRM_New__c = string.valueOf(objContract.ASI_TH_CRM_Start_Date__c), RecordTypeId = MOAuditTrailRT));
                }
                
                if(objContract.ASI_TH_CRM_End_Date__c != trigger_oldMap.get(objContract.id).ASI_TH_CRM_End_Date__c){
                     lstAT.add(new ASI_CRM_Audit_Trail__c(ASI_CRM_Contract__c = objContract.id, ASI_CRM_Field_Name__c = 'End Date', ASI_CRM_Original__c = String.valueOf(trigger_oldMap.get(objContract.id).ASI_TH_CRM_End_Date__c), ASI_CRM_New__c = string.valueOf(objContract.ASI_TH_CRM_End_Date__c), RecordTypeId = MOAuditTrailRT));
                }
                
                if(setContract.contains(objContract.id)){
                     lstAT.add(new ASI_CRM_Audit_Trail__c(ASI_CRM_Contract__c = objContract.id, ASI_CRM_Field_Name__c = 'Owner', ASI_CRM_Original__c = mapOwner.get(trigger_oldMap.get(objContract.id).Ownerid), ASI_CRM_New__c = mapOwner.get(objContract.Ownerid), RecordTypeId = MOAuditTrailRT));
                }
                
                if (objContract.ASI_CRM_CN_Exchange_Rate__c != null && objContract.ASI_CRM_CN_Exchange_Rate__c != trigger_oldMap.get(objContract.id).ASI_CRM_CN_Exchange_Rate__c){
                    setContractUptExRate.add(objContract.id);
                }
            }
            
            if(lstAT != NULL && lstAT.size() > 0) {
                insert lstAT;
            }
            if (setContractUptExRate.size() > 0) {
                list<ASI_CRM_Contract_Cost__c> lstCC = [SELECT id, ASI_CRM_Investment_Value__c, ASI_CRM_Investment_Value_Base__c FROM ASI_CRM_Contract_Cost__c WHERE ASI_CRM_CN_Contract__c IN :setContractUptExRate ];
                if (lstCC != null && lstCC.size() > 0) {
                    update lstCC;
                }
            }
        }
    }
    
    /*
    public static void routineAfterInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!ASI_CRM_MO_Function.IsBypassTrigger(className)){
        }
    }
    
    public static void routineAfterAll(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        if(!ASI_CRM_MO_Function.IsBypassTrigger(className)){
        }
    }*/
    
    public class ContractException extends Exception {}
    
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
    
    public static void setApprovers(ASI_TH_CRM_Contract__c p, Map<string, ASI_CRM_Fix_Approval_Route__c> MAppRouteFix,
        Map<id, ASI_CRM_Dynamic_Approval_Route__c> MAppRoute, 
        Map<string, ASI_CRM_Fix_Approval_Route__c> MAppLastRouteFix, 
        boolean isAddRBAApprover, Map<id, User> MUser,
        Map<String, boolean> MPromotionType, Map<id, boolean> mapMktApproval)
    {            
        Integer approver_count = 0;
        Integer return_approver_count = 0;
        
        //retrieve max contract amount
        //AggregateResult result = [Select Max(ASI_CRM_Total_Investment_Base__c ) MaxContractAmount From ASI_TH_CRM_Contract__c where ASI_CRM_CN_PO_No__c = :p.ASI_CRM_CN_PO_No__c and ASI_TH_CRM_Contract_Status__c = 'Archived'];
        //Decimal maxContractAmount = -99999999;
        //if(result.get('MaxContractAmount') != null){
        //    maxContractAmount = Decimal.valueOf(String.valueOf(result.get('MaxContractAmount')));
        //}
        boolean onlyFix2Route1 = false;
        //if(p.ASI_CRM_Total_Investment_Base__c  <= maxContractAmount){
        //    onlyFix2Route1 = true;
        //}
        //System.debug('ASI_CRM_Total_Investment_Base__c  :' + p.ASI_CRM_Total_Investment_Base__c  );
        //System.debug('maxContractAmount :' + maxContractAmount);
        //System.debug(onlyFix2Route1);
        boolean blnNeedMktApproval = false;
        if (mapMktApproval != null && mapMktApproval.get(p.id) != null && mapMktApproval.get(P.id) == true) {
            blnNeedMktApproval = true;
        }
        
        List<ASI_TH_CRM_Contract__c> LContract = [
            Select id, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_Return_Flag__c 
            from ASI_TH_CRM_Contract__c
            where id =:p.id
        ];
        
        // First Fix Route
        ASI_CRM_Fix_Approval_Route__c fixApprover;
        for (ASI_TH_CRM_Contract__c c: LContract ){
            //if(p.ASI_CRM_CN_National_Group_Contract__c == true){
            //    fixApprover = MAppRouteFix.get('National Group Contract 1st Part '+p.ASI_CRM_CN_Division__c);
            //    system.debug(fixApprover);
            //}
            //else if(c.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true){
            //    fixApprover = MAppRouteFix.get('Contract (IHBR) 1st');
            //    system.debug(fixApprover);
            //}
            //else{
            //    fixApprover = MAppRouteFix.get(p.ASI_CRM_CN_Division__c);
            //    system.debug(fixApprover);
            //}
            fixApprover = MAppRouteFix.get('Macau');
        }
        
        system.debug('---------------------- fixApprover.ASI_CRM_CN_Entry_Limit__c : ' + fixApprover.ASI_CRM_CN_Entry_Limit__c);
        system.debug('---------------------- ASI_CRM_Total_Investment_Base__c : ' + p.ASI_CRM_Total_Investment_Base__c);
        
        if(fixApprover != null && fixApprover.ASI_CRM_CN_Entry_Limit__c < p.ASI_CRM_Total_Investment_Base__c  && !onlyFix2Route1){
            if(fixApprover.ASI_CRM_CN_Approver_1__c != null){         
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_1__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_Total_Investment_Base__c )
                if(fixApprover.ASI_CRM_CN_Approver_2__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_2__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_Total_Investment_Base__c )
                if(fixApprover.ASI_CRM_CN_Approver_3__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_3__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_Total_Investment_Base__c )
                if(fixApprover.ASI_CRM_CN_Approver_4__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_4__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_Total_Investment_Base__c )
                if(fixApprover.ASI_CRM_CN_Approver_5__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_5__c);
                approver_count++;
            }
            if(fixApprover.ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_Total_Investment_Base__c )
                if(fixApprover.ASI_CRM_CN_Approver_6__c != null)
            {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_CN_Approver_6__c);
                approver_count++;
            }
            
        }
        boolean proceed = true;
        /*
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
                    if( currentApprover.ASI_CRM_End_of_Dynamic_Route__c || currentApprover.ASI_CRM_Approval_Limit__c >= p.ASI_CRM_Total_Investment_Base__c ){
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
        System.debug(p.ASI_CRM_CN_Region__c);
        */
        //second fix
        ASI_CRM_Fix_Approval_Route__c fixApprover2;
        for(ASI_TH_CRM_Contract__c c: LContract ) {
            //if(p.ASI_CRM_CN_National_Group_Contract__c == true){
            //    fixApprover2 = MAppLastRouteFix.get('National Group Contract 2nd Part '+p.ASI_CRM_CN_Division__c);
            //    system.debug(fixApprover2);
            //}
            //else if(c.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true){
            //    fixApprover2 = MAppLastRouteFix.get('Contract (IHBR) 2nd');
            //    system.debug(fixApprover2);
            //}
            //else{
            //    fixApprover2 = MAppLastRouteFix.get(p.ASI_CRM_CN_Division__c);
            //    system.debug(fixApprover2);
            //}
            fixAPprover2 = MAppLastRouteFix.get('Macau');

            system.debug(fixApprover2);
        }
        
        if(fixApprover2 != null && fixApprover2.ASI_CRM_CN_Entry_Limit__c < p.ASI_CRM_Total_Investment_Base__c ){
            
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
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_1__c < p.ASI_CRM_Total_Investment_Base__c )
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
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_2__c < p.ASI_CRM_Total_Investment_Base__c )
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
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_3__c < p.ASI_CRM_Total_Investment_Base__c )
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
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_4__c < p.ASI_CRM_Total_Investment_Base__c )
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
                if(fixApprover2 .ASI_CRM_CN_Approval_Limit_5__c < p.ASI_CRM_Total_Investment_Base__c )
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
            }
        }
        
        //Updated by Twinkle Li (Introv) 24Sept2014 to add last approval as Regional BA if Contract version is 0.0 and approval type is Contract 2nd part or National Group Contract 2nd part or Contract (IHBR) 2nd part
        //Regional BA
        if(isAddRBAApprover)
        {
            ASI_CRM_Fix_Approval_Route__c fixApprover3;
            
            //Updated by William Yang (Introv) 20141118 for UAT II #22
            for(ASI_TH_CRM_Contract__c c: LContract ){
                if(p.ASI_CRM_CN_National_Group_Contract__c == true)
                    fixApprover3 = MAppLastRouteFix.get('National Group Contract 2nd Part '+p.ASI_CRM_CN_Division__c);
                else if(c.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true)
                    fixApprover3 = MAppLastRouteFix.get('Contract (IHBR) 2nd');
                else
                    fixApprover3 = MAppLastRouteFix.get(p.ASI_CRM_CN_Division__c);
            }
            
            if((MPromotionType.containsKey(p.ASI_TH_CRM_Promotion_Type__c)) && MPromotionType.get(p.ASI_TH_CRM_Promotion_Type__c) != null){
                if(p.ASI_CRM_CN_PO_Version__c == '0.0' && MPromotionType.get(p.ASI_TH_CRM_Promotion_Type__c)){    
                    /* by William Yang (Introv) 20141118 for UAT II #22
                    if(p.ASI_CRM_CN_National_Group_Contract__c == true)
                    fixApprover3 = MAppLastRouteFix.get('National Group Contract 2nd Part '+p.ASI_CRM_CN_Division__c);
                    else if(p.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Is_IHBR_Outlet__c == true)
                    fixApprover3 = MAppLastRouteFix.get('Contract (IHBR) 2nd');
                    else
                    fixApprover3 = MAppLastRouteFix.get(p.ASI_CRM_CN_Division__c);
                    */
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
        
        if (blnNeedMktApproval && fixApprover.ASI_CRM_Marketing_Approver__c != null) {
            if (approver_count <= 2) {
                setApproverByCount(p, approver_count, fixApprover.ASI_CRM_Marketing_Approver__c);
                approver_count++;
            } else {
                p.ASI_CRM_CN_Sys_Approver_11__c = p.ASI_CRM_CN_Sys_Approver_10__c;
                p.ASI_CRM_CN_Sys_Approver_10__c = p.ASI_CRM_CN_Sys_Approver_9__c;
                p.ASI_CRM_CN_Sys_Approver_9__c = p.ASI_CRM_CN_Sys_Approver_8__c;
                p.ASI_CRM_CN_Sys_Approver_8__c = p.ASI_CRM_CN_Sys_Approver_7__c;
                p.ASI_CRM_CN_Sys_Approver_7__c = p.ASI_CRM_CN_Sys_Approver_6__c;
                p.ASI_CRM_CN_Sys_Approver_6__c = p.ASI_CRM_CN_Sys_Approver_5__c;
                p.ASI_CRM_CN_Sys_Approver_5__c = p.ASI_CRM_CN_Sys_Approver_4__c;
                p.ASI_CRM_CN_Sys_Approver_4__c = p.ASI_CRM_CN_Sys_Approver_3__c;
                p.ASI_CRM_CN_Sys_Approver_3__c = fixApprover.ASI_CRM_Marketing_Approver__c;
                approver_count++;
            }
        }
    }
    
    
}