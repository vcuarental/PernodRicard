/*Filename:    ASI_CRM_KH_Contract_TriggerClass.cls
* 
*
*
* History
* -----------------------------------------------------------------------------
* 2020-10-02        Wilken Lee        [WL 1.0] Add checking by market
*/
public with sharing class ASI_CRM_KH_Contract_TriggerClass {
    public static String className = 'ASI_CRM_KH_ContractTrigger';
    
    public static void routineBeforeInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)){
            // Declaration
            set<id> setOutletWS = new set<id>();
            map<id, String> mapOutletResp = new map<id, String>();
            map<id, boolean> mapOutletIsParent = new map<id, boolean>();
            map<id, String> mapOutletCatCode = new map<id, String>();
            // Declaration - End
            
            // Snap the commission rate from custom setting to contract
           // List<ASI_CRM_MY_Settings__c> LstMYSetting = [SELECT ASI_CRM_MY_Salesman_Commission__c FROM ASI_CRM_MY_Settings__c LIMIT 1];
            
            for (ASI_TH_CRM_Contract__c objContract : trigger_new) {
                setOutletWS.add(objContract.ASI_CRM_CN_Outlet_WS__c);
                
                //ASI_CRM_KH_AutoNumberAssignment_Generic clsRunningNum = new ASI_CRM_KH_AutoNumberAssignment_Generic('Contract');  //WL 1.0
                ASI_CRM_KH_AutoNumberAssignment_Generic clsRunningNum = new ASI_CRM_KH_AutoNumberAssignment_Generic('ASI_CRM_KH_Contract');     //WL 1.0
                // To generate the new id if the contract is not deepClone as a history
                if (objContract.ASI_CRM_Is_Processing__c != TRUE || objContract.ASI_TH_CRM_Contract_Status__c != 'Final') {
                    System.debug('routineBeforeInsert: New Running Number');
                    objContract.ASI_CRM_Version__c = '1';
                    objContract.Name = clsRunningNum.nextAutoNumStr() + '.' + objContract.ASI_CRM_Version__c;
                    clsRunningNum.writeToDB();
                    System.debug('ccc + ' + clsRunningNum);
                } else {
                    System.debug('routineBeforeInsert: NOT Getting New Running Number');
                }
                /*
                if(LstMYSetting[0].ASI_CRM_MY_Salesman_Commission__c != NULL){
                    objContract.ASI_CRM_Commission_Rate__c = LstMYSetting[0].ASI_CRM_MY_Salesman_Commission__c;
                }
                */
             }
            /*
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
            */
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
    
    public class ContractException extends Exception {}
}