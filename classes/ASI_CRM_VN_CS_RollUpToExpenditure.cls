/*********************************************************************************
 * Name: ASI_CRM_VN_CS_RollUpToExpenditure
 * Description: Roll up CS amount to expenditure
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/08/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_CS_RollUpToExpenditure {

    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    
    private final static String APPROVED_STATUS = 'Approved';
    private final static String LUMP_SUM_CONTRACT_EXPENDITURE = 'Lump Sum';
    
    public ASI_CRM_VN_CS_RollUpToExpenditure() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> requestList   = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> requestMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        List<ASI_GiftBox_Request_Header__c> filteredRequestList = filterRequest(requestList, requestMap);
        rollupToContractExpenditure(filteredRequestList);
    }
    
    private List<ASI_GiftBox_Request_Header__c> filterRequest(List<ASI_GiftBox_Request_Header__c> requestList, Map<Id, ASI_GiftBox_Request_Header__c> requestMap) {
        if(requestMap == null) {
            return new List<ASI_GiftBox_Request_Header__c>();
        }
        
        List<ASI_GiftBox_Request_Header__c> filteredRequestList = new List<ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            if(request.ASI_GiftBox_Status__c == APPROVED_STATUS &&
               requestMap.get(request.Id).ASI_GiftBox_Status__c != APPROVED_STATUS) {
                filteredRequestList.add(request);
            }
        }
        
        return filteredRequestList;
    }
    
    private void rollupToContractExpenditure(List<ASI_GiftBox_Request_Header__c> requestList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            contractIdSet.add(request.ASI_CRM_VN_Contract__c);
        }
        
        Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap = new Map<Id, ASI_CRM_VN_Contract_Expenditure__c>();
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : retrieveContractExpenditureList(contractIdSet)) {
            contractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Contract__c, contractExpenditure);
        }
        
        List<ASI_CRM_VN_Contract_Expenditure__c> updateContractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            Decimal amount = request.ASI_CRM_VN_Amount__c;
            
            ASI_CRM_VN_Contract_Expenditure__c tempContractExpenditure = contractExpenditureMap.get(request.ASI_CRM_VN_Contract__c);

            if(tempContractExpenditure.ASI_CRM_Commit_Amount__c == null) {
                tempContractExpenditure.ASI_CRM_Commit_Amount__c = 0;
            }
            tempContractExpenditure.ASI_CRM_Commit_Amount__c += amount == null ? 0 : amount;
            updateContractExpenditureList.add(tempContractExpenditure);
        }
        
        if(updateContractExpenditureList.size() > 0) {
            update updateContractExpenditureList;
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Set<Id> contractIdSet) {
        String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +  
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_Currency__c ' + 
                       ', ASI_CRM_VN_Contract__r.ASI_CRM_To_VND_Exchange_Rate__c, ASI_CRM_VN_Contract__r.ASI_CRM_To_USD_Exchange_Rate__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND ASI_CRM_VN_Item__c = :LUMP_SUM_CONTRACT_EXPENDITURE';
        
        return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
    }
    
    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}