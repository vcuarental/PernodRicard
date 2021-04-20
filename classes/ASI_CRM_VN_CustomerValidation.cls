/*********************************************************************************
 * Name: ASI_CRM_VN_CustomerValidation
 * Description: Validate when update customer object
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/02/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_CustomerValidation {
    
    private static final Set<String> ACTIVE_CONTRACT_STATUS_SET = new Set<String>{
    	'Draft', 
        'Submitted',
        'Pending Verification',
        'Approved',
        'Submit for Termination'
    };
    
    public ASI_CRM_VN_CustomerValidation() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
    	List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) newList;
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c>) oldMap;
        
        List<ASI_CRM_AccountsAdditionalField__c> filteredCustomerList = filterCustomer(customerList, customerMap);
        if(filteredCustomerList != null) {
        	validateCustomer(filteredCustomerList);
        }
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> filterCustomer(List<ASI_CRM_AccountsAdditionalField__c> customerList, Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap) {
    	if(customerMap == null) {
        	return null;
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> filteredCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            ASI_CRM_AccountsAdditionalField__c oldCustomer = customerMap.get(customer.Id);
            
            if(String.isNotBlank(customer.ASI_CRM_CN_Parent_Outlet__c) && String.isBlank(oldCustomer.ASI_CRM_CN_Parent_Outlet__c)) {
                filteredCustomerList.add(customer);
            } else if(customer.ASI_CRM_Contracted_Outlet__c != oldCustomer.ASI_CRM_Contracted_Outlet__c) {
                filteredCustomerList.add(customer);
            } else if(customer.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet_Inactive') && 
                      oldCustomer.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet')) {
                filteredCustomerList.add(customer);
            } else if(!customer.ASI_CRM_Active__c && oldCustomer.ASI_CRM_Active__c){
                filteredCustomerList.add(customer);
            }
        }
        
        return filteredCustomerList;
    }
    
    private void validateCustomer(List<ASI_CRM_AccountsAdditionalField__c> customerList) {
        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) customerIdSet.add(customer.Id);
        
        Set<Id> hasContractOutletIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract__c contract : retrieveContractList(customerIdSet)) {
            if(contract.ASI_CRM_End_Date__c < Date.today() || contract.ASI_CRM_Closed_Date__c < Date.today())
                continue;
            
        	hasContractOutletIdSet.add(contract.ASI_CRM_Outlet_WS__c);
        }
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            if(hasContractOutletIdSet.contains(customer.Id)) {
            	customer.addError('You are not able to update the outlet when its linked to an opened contract!');
            }
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract__c> retrieveContractList(Set<Id> customerIdSet) {
    	String query = 'SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_End_Date__c, ASI_CRM_Closed_Date__c ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'WHERE ASI_CRM_Contract_Status__c in :ACTIVE_CONTRACT_STATUS_SET ' + 
                       'AND ASI_CRM_Outlet_WS__c in :customerIdSet ';
        
    	return (List<ASI_CRM_VN_Contract__c>) Database.query(query);
  	}
}