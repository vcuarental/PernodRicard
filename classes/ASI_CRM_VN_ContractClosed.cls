/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ContractClosed
 * Description: Apex class for ASI_CRM_VN_ContractClosed, handle contract changed to close
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-23       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_VN_ContractClosed {
    public ASI_CRM_VN_ContractClosed() {

    }

    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        List<Id> closedContractIds = new List<Id>();

        for (ASI_CRM_VN_Contract__c contract : contractList) {
            ASI_CRM_VN_Contract__c oldContract = (ASI_CRM_VN_Contract__c) oldMap.get(contract.Id);
            if ((contract.ASI_CRM_Contract_Status__c == 'Closed' && oldContract.ASI_CRM_Contract_Status__c != 'Closed') || 
                (contract.ASI_CRM_Contract_Status__c == 'Closed(Terminated)' && oldContract.ASI_CRM_Contract_Status__c != 'Closed(Terminated)')) {
                closedContractIds.add(contract.Id);
            }
        }

//       When MCF/Capsule Contract Status -> 'Closed', All Request should be changed to 'Closed'
        List<ASI_GiftBox_Request_Header__c> requestHeaders = [SELECT Id 
                                                              FROM ASI_GiftBox_Request_Header__c
                                                              WHERE ASI_CRM_VN_Contract__c IN :closedContractIds
                                                              AND ASI_GiftBox_Status__c = 'Open'];

        for (ASI_GiftBox_Request_Header__c requestHeader : requestHeaders) {
            requestHeader.ASI_GiftBox_Status__c = 'Closed';
        }

        update requestHeaders;
    }

}