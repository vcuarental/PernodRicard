/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromotionReq_CheckContract
 * Description: Check contract has Contract Expenditure 'Promotion' and balance > 0
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-12-28       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_VN_PromotionReq_CheckContract {
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> requestList   = (List<ASI_GiftBox_Request_Header__c>) newList;

        // Get all contracts
        Set<Id> contractIds = ASI_CRM_VN_Util_Pluck.ids(requestList, ASI_GiftBox_Request_Header__c.ASI_CRM_VN_Contract__c);

        List<ASI_CRM_VN_Contract_Expenditure__c> expenditures = [
                SELECT id, ASI_CRM_Balance_Amount__c
                FROM ASI_CRM_VN_Contract_Expenditure__c
                WHERE ASI_CRM_VN_Contract__c IN :contractIds
                AND ASI_CRM_VN_Item__c = 'Promotion'
        ];

        if (expenditures.isEmpty()) {
            requestList[0].addError('Contract should have Expenditure Promotion.');
        }
        for (ASI_CRM_VN_Contract_Expenditure__c expenditure : expenditures) {
            if (expenditure.ASI_CRM_Balance_Amount__c <= 0) {
                requestList[0].addError('Promotion expenditure has no balance left.');
            }
        }
    }
}