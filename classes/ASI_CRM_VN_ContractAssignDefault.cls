/*********************************************************************************
 * Name: ASI_CRM_VN_ContractAssignDefault
 * Description: Assign PROS Segmentation from 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractAssignDefault {
    
    private final static Id CAPSULE_AGREEMENT_RTID = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract__c' + 'ASI_CRM_VN_Capsule_Agreement_Contract');
    
    private final static Map<String, Schema.SObjectField> PROS_SEGMENTATION_FIELD_MAP = Schema.SObjectType.ASI_CRM_Pros_Segmentation__c.fields.getMap();
    
    public ASI_CRM_VN_ContractAssignDefault() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        assignDefaultValue(filteredContractList);
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
		return contractList;
    }
    
    private void assignDefaultValue(List<ASI_CRM_VN_Contract__c> contractList) {
        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            customerIdSet.add(contract.ASI_CRM_Outlet_WS__c);
        }
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerList(customerIdSet));
        
        Map<Id, ASI_CRM_Pros_Segmentation__c> customerPROSMap = new Map<Id, ASI_CRM_Pros_Segmentation__c>();
        for(ASI_CRM_Pros_Segmentation__c prosSegmentation : retrievePROSSegmentationList(customerIdSet)) {
            customerPROSMap.put(prosSegmentation.ASI_CRM_SG_Customer__c, prosSegmentation);
        }
        
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(customerPROSMap.containsKey(contract.ASI_CRM_Outlet_WS__c) == false) {
                continue;
            }
            
            ASI_CRM_AccountsAdditionalField__c customer = customerMap.get(contract.ASI_CRM_Outlet_WS__c);
            if(customer.ASI_CRM_Contracted_Outlet__c == false) {
                if(contract.RecordTypeId == CAPSULE_AGREEMENT_RTID) {
                	contract.addError('You are not able to create the Capsule Agreement when Outlet\'s contracted outlet flag is not checked');
                } else {
                	contract.ASI_CRM_Activation_Support__c = true;
                }
            }
            
            ASI_CRM_Pros_Segmentation__c prosSegmentation = customerPROSMap.get(contract.ASI_CRM_Outlet_WS__c);
            contract.ASI_CRM_Spirit_Volume_Potential__c   = prosSegmentation.ASI_CRM_Spirit_Champagne_Volume_Level__c;
            contract.ASI_CRM_Wine_Volume_Potential__c     = prosSegmentation.ASI_CRM_Wine_Volume_Level__c;
            contract.ASI_CRM_Outlet_Role__c               = prosSegmentation.ASI_CRM_DAMD_Action__c;
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
	private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
        String query = 'SELECT Id, ASI_CRM_Contracted_Outlet__c ' +
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE Id in :customerIdSet ';
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private List<ASI_CRM_Pros_Segmentation__c> retrievePROSSegmentationList(Set<Id> customerIdSet) {
    	String query = 'SELECT ' + genQueryField(PROS_SEGMENTATION_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Pros_Segmentation__c ' + 
                       'WHERE ASI_CRM_SG_Customer__c in :customerIdSet';
        
    	return (List<ASI_CRM_Pros_Segmentation__c>) Database.query(query);
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