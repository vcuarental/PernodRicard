public with sharing class ASI_CRM_MY_Contract_TriggerClass {
    public static String className = 'ASI_CRM_MY_ContractTrigger';
    
    public static void routineBeforeInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            // Declaration
            set<id> setOutletWS = new set<id>();
            map<id, String> mapOutletResp = new map<id, String>();
            map<id, boolean> mapOutletIsParent = new map<id, boolean>();
            map<id, String> mapOutletCatCode = new map<id, String>();
            // Declaration - End
            
            // Snap the commission rate from custom setting to contract
            List<ASI_CRM_MY_Settings__c> LstMYSetting = [SELECT ASI_CRM_MY_Salesman_Commission__c FROM ASI_CRM_MY_Settings__c LIMIT 1];
            
            for (ASI_TH_CRM_Contract__c objContract : trigger_new) {
                setOutletWS.add(objContract.ASI_CRM_CN_Outlet_WS__c);
                
                ASI_CRM_MY_RunningNumber_TriggerClass clsRunningNum = new ASI_CRM_MY_RunningNumber_TriggerClass('Contract');
                // To generate the new id if the contract is not deepClone as a history
                if (objContract.ASI_CRM_Is_Processing__c != TRUE || objContract.ASI_TH_CRM_Contract_Status__c != 'Final') {
                    System.debug('routineBeforeInsert: New Running Number');
                    objContract.ASI_CRM_Version__c = '1';
                    objContract.Name = clsRunningNum.nextAutoNumStr() + '.' + objContract.ASI_CRM_Version__c;
                    clsRunningNum.writeToDB();
                } else {
                    System.debug('routineBeforeInsert: NOT Getting New Running Number');
                }
                if(LstMYSetting[0].ASI_CRM_MY_Salesman_Commission__c != NULL){
                    objContract.ASI_CRM_Commission_Rate__c = LstMYSetting[0].ASI_CRM_MY_Salesman_Commission__c;
                }
             }
            
            // Get the Market Responsibilty of the Contract Outlet
            list<ASI_CRM_AccountsAdditionalField__c> lstOutletWS = [SELECT id, ASI_CRM_Market_Responsibility__c, ASI_CRM_IsParentAccount__c, ASI_CRM_Customer_Category_Code_2__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id IN :setOutletWS];
            for (ASI_CRM_AccountsAdditionalField__c obj : lstOutletWS) {
                mapOutletResp.put(obj.id, String.valueOf(obj.ASI_CRM_Market_Responsibility__c));
                mapOutletIsParent.put(obj.id, obj.ASI_CRM_IsParentAccount__c);
                mapOutletCatCode.put(obj.id, obj.ASI_CRM_Customer_Category_Code_2__c);
            }
            // Snap the Market Responsibility to Contract for DBC calculation
            List<User> lstUser = [SELECT Id, Name, ASI_CRM_MY_Customer_Category_Code_2__c FROM User WHERE id = :UserInfo.getUserId()];
            
            for (ASI_TH_CRM_Contract__c objContract : trigger_new) {
                String strMktResp = mapOutletResp.get(objContract.ASI_CRM_CN_Outlet_WS__c) == null ? '' : mapOutletResp.get(objContract.ASI_CRM_CN_Outlet_WS__c);
                String strCatCode = '';
                if(mapOutletCatCode.get(objContract.ASI_CRM_CN_Outlet_WS__c) != NULL){
                    strCatCode = mapOutletCatCode.get(objContract.ASI_CRM_CN_Outlet_WS__c);
                }else if(lstUser[0].ASI_CRM_MY_Customer_Category_Code_2__c != NULL){
                    strCatCode = lstUser[0].ASI_CRM_MY_Customer_Category_Code_2__c;
                }
                boolean blnIsParent = false;
                if (mapOutletIsParent.get(objContract.ASI_CRM_CN_Outlet_WS__c) != null && mapOutletIsParent.get(objContract.ASI_CRM_CN_Outlet_WS__c) == true)
                    blnisParent = true;
                
                objContract.ASI_CRM_Market_Responsibility__c = strMktResp;
                objContract.ASI_CRM_IsParentContract__c = blnIsParent;
                objContract.ASI_CRM_Customer_Category_Code_2__c = strCatCode;
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            // Declaration
            ASI_CRM_MY_ContractCommon clsContract = new ASI_CRM_MY_ContractCommon();
            list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract that just updating and no version revise is needed
            list<ASI_TH_CRM_Contract__c> lstContractRevise = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract need to revise
            list<ASI_TH_CRM_Contract__c> lstContractRevise_OLD = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract need to revise
            
            list<ASI_TH_CRM_Contract__c> lstContractFinal = new list<ASI_TH_CRM_Contract__c>(); // List to store the contract need to finalize
            map<id, String> mapRevision = new map<id, String>{};
            integer intCounter = 0;
            String strErrMsg = '';
            // Declaration - End
            
            // Prepare for revise/update/final
            for (ASI_TH_CRM_Contract__c objContract : trigger_new) {
            
                system.debug('ASI_CRM_MY_Contract_TriggerClass: Contract Old Map: ' + (trigger_oldMap.get(objContract.id)).Name);
                if (clsContract.checkNeedRevise(trigger_oldMap.get(objContract.id), objContract)) {
                    lstContractRevise.add(objContract);
                    lstContractRevise_OLD.add(trigger_oldMap.get(objContract.id));
                    system.debug('ASI_CRM_MY_Contract_TriggerClass: Revise: ' + string.valueof(objContract.Name) + ' ' + string.valueof(objContract.id));
                } else {
                    if (clsContract.checkGoFinal(trigger_oldMap.get(objContract.id), objContract)) {
                        lstContractFinal.add(objContract);
                        system.debug('ASI_CRM_MY_Contract_TriggerClass: Final: ' + string.valueof(objContract.Name) + ' ' + string.valueof(objContract.id));
                    } else {
                        lstContract.add(objContract);
                        system.debug('ASI_CRM_MY_Contract_TriggerClass: Update: ' + string.valueof(objContract.Name) + ' ' + string.valueof(objContract.id));
                    }
                }
                intCounter++;
            }
            
            system.debug('----------lstContract----------' + lstContract);
            system.debug('----------lstContractRevise----------' + lstContractRevise);
            system.debug('----------lstContractFinal----------' + lstContractFinal);
            
            Savepoint sp = Database.setSavepoint();
            try {
                system.debug('---------------------------------ASI_CRM_MY_Contract_TriggerClass.TRY BEFORE clsContract.reviseContracts');
                clsContract.reviseContracts(lstContractRevise, lstContractRevise_OLD); // Revise include: revising contract version and clone the whole set as copy
                system.debug('---------------------------------ASI_CRM_MY_Contract_TriggerClass.TRY AFTER clsContract.reviseContracts');
                lstContractRevise = lstContractRevise; // Just update and no further action needed
                system.debug(' strErrMsg 1 : '+strErrMsg);
                strErrMsg += clsContract.updateValidation(lstContract, trigger_oldMap);
                //strErrMsg += clsContract.finalValidation(lstContractFinal);
                System.debug('ASI_CRM_MY_Contract_TriggerClass: after updateValidation() ' + strErrMsg);
                if (strErrMsg != '') {
                    //throw new ContractException(strErrMsg);
                    trigger_new[0].addError(strErrMsg);
                    system.debug('ASI_CRM_MY_Contract_TriggerClass: updateValidation(): HAVE strError: ' + strErrMsg);
                } else {
                    clsContract.finalContracts(lstContractFinal); // To finalize contracts
                    system.debug('ASI_CRM_MY_Contract_TriggerClass: updateValidation(): NO Error');
                }
                system.debug('ASI_CRM_MY_Contract_TriggerClass: updateValidation(): strErrMsg: ' + strErrMsg);
            }catch (Exception e) {
                system.debug('ASI_CRM_MY_Contract_TriggerClass: updateValidation(): Exception: ' + e);
                Database.rollback(sp);
            } finally {
                if (strErrMsg != '') {
                    Database.rollback(sp);
                    system.debug('ASI_CRM_MY_Contract_TriggerClass: updateValidation(): finally');
                    trigger_new[0].addError(strErrMsg);
                }
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_TH_CRM_Contract__c> trigger_old) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            for(ASI_TH_CRM_Contract__c objContract : trigger_old) {
                if(objContract.ASI_TH_CRM_Contract_Status__c != 'Draft'){
                    objContract.addError('Only Draft Contract can be deleted.');
                }
            }
        }
    }
    /*
    public static void routineAfterInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
        }
    }
    
    public static void routineAfterAll(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
        }
    }*/
    
    public class ContractException extends Exception {}
}