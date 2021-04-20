/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromotionReqUpdateContract
 * Description: Roll up to contract expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-12       Jeffrey Cheung          Created
 * 2018-12-09       Calvin Chiu             Fixed Currency issue: use ASI_CRM_Currency__c instead of ASI_CRM_Currency__c
 ****************************************************************************************************************************/

public with sharing class ASI_CRM_VN_PromotionReqUpdateContract {
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        system.debug('Trigger ASI_CRM_VN_PromotionReqUpdateContract Function');

        List<ASI_GiftBox_Request_Header__c> csRequestList = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> csRequestOldMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        List<Id> contractIds = new List<Id>();
        List<ASI_CRM_VN_Contract_Expenditure__c> updatedContractExpenditures = new List<ASI_CRM_VN_Contract_Expenditure__c>();

        //        Get all contracts
        for (ASI_GiftBox_Request_Header__c csRequest : csRequestList) {
            if(csRequest.ASI_GiftBox_Status__c == 'Complete' && 
               csRequestOldMap.get(csRequest.Id).ASI_GiftBox_Status__c != 'Complete') {
                contractIds.add(csRequest.ASI_CRM_VN_Contract__c);
            }
        }
        List<ASI_CRM_VN_Contract__c> contracts = [SELECT
                ASI_CRM_To_VND_Exchange_Rate__c, ASI_CRM_Currency__c,
        (SELECT ASI_CRM_VN_Item__c, ASI_CRM_Commit_Amount__c FROM Contract_Expenditures__r WHERE ASI_CRM_VN_Item__c = 'Promotion'),
        (SELECT ASI_CRM_VN_Amount__c FROM Gift_Box_POSM_Requests__r WHERE RecordType.DeveloperName LIKE 'ASI_CRM_VN_Promotion_Request%' AND ASI_GiftBox_Status__c IN ('Complete', 'Approved'))
        FROM ASI_CRM_VN_Contract__c WHERE Id IN :contractIds];

        System.debug('contracts! ' + contracts);

        // for each contract, update its promotion expenditure committed amount
        for (ASI_CRM_VN_Contract__c contract : contracts) {
            Decimal sum = 0;
            for (ASI_GiftBox_Request_Header__c request : contract.Gift_Box_POSM_Requests__r) {
                sum += request.ASI_CRM_VN_Amount__c == null ? 0 : request.ASI_CRM_VN_Amount__c;
            }
            for (ASI_CRM_VN_Contract_Expenditure__c expenditure : contract.Contract_Expenditures__r) {
                expenditure.ASI_CRM_Commit_Amount__c = contract.ASI_CRM_Currency__c == 'USD' ? sum * contract.ASI_CRM_To_VND_Exchange_Rate__c: sum;
                updatedContractExpenditures.add(expenditure);
            }
        }

        update updatedContractExpenditures;
    }

}