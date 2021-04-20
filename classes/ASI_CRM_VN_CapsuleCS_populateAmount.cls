/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCS_populateAmount
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ----------------------------------------
 * 23/11/2017       Kevin Choi             Created          
***********************************************************************************/
public class ASI_CRM_VN_CapsuleCS_populateAmount{
    public ASI_CRM_VN_CapsuleCS_populateAmount(){

    }
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        system.debug('Trigger ASI_CRM_VN_CapsuleCS_populateAmount Function');
        List<ASI_CRM_VN_Contract_Expenditure__c> expenditureList = (List<ASI_CRM_VN_Contract_Expenditure__c>) newList;
        Map<Id, ASI_CRM_VN_Contract_Expenditure__c> expenditureMap = (Map<Id, ASI_CRM_VN_Contract_Expenditure__c>) oldMap;

        for (ASI_CRM_VN_Contract_Expenditure__c expenditure : expenditureList){
            if(expenditureMap == null) {
            	expenditure.ASI_CRM_Commit_Amount__c = 0;
            	expenditure.ASI_CRM_Cal_Balance_Amount__c = (expenditure.ASI_CRM_VN_Sales_Target__c)*(expenditure.ASI_CRM_VN_Unit_Incentive__c);
            } else {
            	ASI_CRM_VN_Contract_Expenditure__c oldExpenditure = expenditureMap.get(expenditure.Id);
                if(expenditure.ASI_CRM_VN_Sales_Target__c != oldExpenditure.ASI_CRM_VN_Sales_Target__c || 
                   expenditure.ASI_CRM_VN_Unit_Incentive__c != oldExpenditure.ASI_CRM_VN_Unit_Incentive__c) {
                	expenditure.ASI_CRM_Cal_Balance_Amount__c = (expenditure.ASI_CRM_VN_Sales_Target__c)*(expenditure.ASI_CRM_VN_Unit_Incentive__c);
                }
            }
        }
    }
}