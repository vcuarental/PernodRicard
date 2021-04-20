/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCS_updateAmtToContract
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ----------------------------------------
 * 24/11/2017       Kevin Choi             Created          
***********************************************************************************/
public class ASI_CRM_VN_CapsuleCS_updateAmtToContract{

    private final static String RECORD_APPROVED = 'Approved';

    public ASI_CRM_VN_CapsuleCS_updateAmtToContract(){
    }

    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        system.debug('Trigger ASI_CRM_VN_CapsuleCS_updateAmtToContract Function');
        List<ASI_GiftBox_Request_Header__c> csRequestList = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id,ASI_GiftBox_Request_Header__c> csRequestOldMap = (Map<Id,ASI_GiftBox_Request_Header__c>) oldMap;
        List<ASI_GiftBox_Request_Header__c> csRequestApproved = new List<ASI_GiftBox_Request_Header__c> ();

        for (ASI_GiftBox_Request_Header__c csRequest : csRequestList){
            if (csRequest.ASI_GiftBox_Status__c == RECORD_APPROVED && 
                csRequestOldMap.get(csRequest.Id).ASI_GiftBox_Status__c != RECORD_APPROVED)
                csRequestApproved.add(csRequest);

        }

        if (csRequestApproved.size() > 0)
            updateContract(csRequestApproved);

    }

    private void updateContract(List<ASI_GiftBox_Request_Header__c> csRequestApproved){
        Set<Id> requestContractIdSet = new Set<Id>();
        Set<Id> csRequestIdSet = new Set<Id>();
        Map<Id,ASI_CRM_VN_Contract_Expenditure__c> subBrandExpenditureMap = new Map<Id,ASI_CRM_VN_Contract_Expenditure__c>();

        for (ASI_GiftBox_Request_Header__c csRequest : csRequestApproved){
            requestContractIdSet.add(csRequest.ASI_CRM_VN_Contract__c);
            csRequestIdSet.add(csRequest.Id);
        }

        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = [select Id, ASI_CRM_VN_Contract__c, ASI_CRM_Sub_Brand__c, ASI_CRM_VN_Total_Amount__c, 
                                                                            ASI_CRM_Commit_Amount__c, ASI_CRM_Balance_Amount__c, ASI_CRM_Cal_Balance_Amount__c 
                                                                            from ASI_CRM_VN_Contract_Expenditure__c where ASI_CRM_VN_Contract__c IN: requestContractIdSet];

        for (ASI_CRM_VN_Contract_Expenditure__c expenditure : contractExpenditureList){
            subBrandExpenditureMap.put(expenditure.ASI_CRM_Sub_Brand__c, expenditure);
        }

        List<ASI_GiftBox_Request_Item__c> requestItemList = [select Id, ASI_GiftBox_Request_Id__c, ASI_CRM_Subbrand__c, ASI_CRM_Amount__c 
                                                             from ASI_GiftBox_Request_Item__c where ASI_GiftBox_Request_Id__c IN: csRequestIdSet];

        for (ASI_GiftBox_Request_Item__c requestItem : requestItemList){
            if (subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c) != null){
                if(subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_Commit_Amount__c == null) 
                    subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_Commit_Amount__c = 0;
                
                if(subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_Cal_Balance_Amount__c == null)
                    subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_Cal_Balance_Amount__c = subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_VN_Total_Amount__c;
                
                subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_Commit_Amount__c += requestItem.ASI_CRM_Amount__c;
                subBrandExpenditureMap.get(requestItem.ASI_CRM_Subbrand__c).ASI_CRM_Cal_Balance_Amount__c -= requestItem.ASI_CRM_Amount__c;
            }
        }

        if (subBrandExpenditureMap.values().size() > 0)
            update subBrandExpenditureMap.values();

    }
}