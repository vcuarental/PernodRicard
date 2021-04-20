/*********************************************************************************
 * Name:        ASI_CRM_MO_ContractCost_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-05-08       Introv: Axel LEUNG      Created
*********************************************************************************/
public class ASI_CRM_MO_ContractCost_TriggerCls {
    
    public static String TRIGGER_NAME = 'ASI_CRM_MO_ContractTrigger';

    public static void routineBeforeInsert(list<ASI_CRM_Contract_Cost__c> trigger_new) {
    }
    
    public static void routineBeforeUpsert(list<ASI_CRM_Contract_Cost__c> trigger_new) {
        // Declaration
        set<id> setCost = new set<id>();
        map<id, String> mapCost = new map<id, String>();
        map<id, String> mapCostName = new map<id, String>();
        // Declaration

        if (!ASI_CRM_MO_Function.IsBypassTrigger(TRIGGER_NAME)) {
            for (ASI_CRM_Contract_Cost__c obj : trigger_new) {
                if (obj.ASI_CRM_Investment_Payment__c != null)
	                setCost.add(obj.ASI_CRM_Investment_Payment__c);
            }
            for (ASI_CRM_Investment_Payment__c obj : [SELECT ID, Name, ASI_CRM_Payment_Type__c FROM ASI_CRM_Investment_Payment__c WHERE ID IN :setCost ]) {
                mapCost.put(obj.id, obj.ASI_CRM_Payment_Type__c);
                mapCostName.put(obj.id, obj.Name);
            }
            
            for (ASI_CRM_Contract_Cost__c obj : trigger_new) {
                obj.ASI_CRM_Investment_Value_Base__c = obj.ASI_CRM_Investment_Value__c * (obj.ASI_CRM_Exchange_Rate__c == null ? 0 : obj.ASI_CRM_Exchange_Rate__c);
                obj.ASI_CRM_CN_Cost_Type__c = mapCost.get(obj.ASI_CRM_Investment_Payment__c) == null ? '' : mapCost.get(obj.ASI_CRM_Investment_Payment__c);
                obj.Name = mapCostName.get(obj.ASI_CRM_Investment_Payment__c) == null ? '' : mapCostName.get(obj.ASI_CRM_Investment_Payment__c);
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_TH_CRM_Contract__c> trigger_old) {
        if(!ASI_CRM_MY_Function.IsBypassTrigger(TRIGGER_NAME)){
            for(ASI_TH_CRM_Contract__c objContract : trigger_old) {
                if(objContract.ASI_TH_CRM_Contract_Status__c != 'Draft'){
                    objContract.addError('Only Draft Contract can be deleted.');
                }
            }
        }
    }
}