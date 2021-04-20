/*********************************************************************************
 * Name: ASI_CRM_VN_CSRequest_UnlinkActualOfftake
 * Description: Unlink the CS Request to ActualOfftake
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/04/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_CSRequest_UnlinkActualOfftake {
    
    private class ContractWrapper {
    	private ASI_CRM_VN_Contract__c contract                        {get; set;}
        private List<ASI_TH_CRM_Actual_Offtake__c>  actualOfftakeList  {get; set;}
        
        private ContractWrapper(ASI_CRM_VN_Contract__c contract) {
            this.contract               = contract;
            this.actualOfftakeList      = new List<ASI_TH_CRM_Actual_Offtake__c>();
        }
        
        private void addActualOfftake(ASI_TH_CRM_Actual_Offtake__c actualOfftake) {
            actualOfftakeList.add(actualOfftake);
        }
    }
    
	private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP       = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> ACTUAL_OFFTAKE_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c.fields.getMap();
    
    private final static Set<String> OUTLET_RECORD_TYPE_SET = new Set<String> {
    	'ASI_CRM_VN_Outlet',
        'ASI_CRM_VN_Outlet_Inactive',
        'ASI_CRM_VN_PG_Outlets',
        'ASI_CRM_VN_Inactive_Off_Trade_Outlet',
        'ASI_CRM_VN_Off_Trade_Outlet'
    };
    
    private final static String ACTUAL_OFFTAKE_RECORD_TYPE = 'ASI_CRM_VN_Actual_Offtake';
    
    public ASI_CRM_VN_CSRequest_UnlinkActualOfftake() {        
    }
    
    public void executeTrigger(Map<Id, sObject> oldMap) {
        Map<Id, ASI_GiftBox_Request_Header__c> requestMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        unlinkActualOfftake(requestMap.values());
    }
    
    private void unlinkActualOfftake(List<ASI_GiftBox_Request_Header__c> requestList) {
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, ASI_GiftBox_Request_Header__c> contractRequestMap = new Map<Id, ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            contractIdSet.add(request.ASI_CRM_VN_Contract__c);
            contractRequestMap.put(request.ASI_CRM_VN_Contract__c, request);
        }
        
        List<ASI_CRM_VN_Contract__c> contractList = retrieveContract(contractIdSet);
        
        Map<Id, ContractWrapper> contractWrapperMap = new Map<Id, ContractWrapper>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            contractWrapperMap.put(contract.Id, new ContractWrapper(contract));
        }
        
        Date contractStartDate;
        Date contractEndDate;
        Map<Id, Id> customerContractIdMap = new Map<Id, Id>();
        for(ContractWrapper contractWrapper : contractWrapperMap.values()) {
            customerContractIdMap.put(contractWrapper.contract.ASI_CRM_Outlet_WS__c, contractWrapper.contract.Id);
            
            if(contractStartDate == null || 
               contractStartDate > contractWrapper.contract.ASI_CRM_Start_Date__c) {
            	contractStartDate = contractWrapper.contract.ASI_CRM_Start_Date__c;
            }
            
            if(contractEndDate == null || 
               contractEndDate < contractWrapper.contract.ASI_CRM_End_Date__c) {
                contractEndDate = contractWrapper.contract.ASI_CRM_End_Date__c;
            }
        }
        
        contractStartDate = contractStartDate.toStartOfMonth();
        Integer endMonthNumberOfDays = Date.daysInMonth(contractEndDate.year(), contractEndDate.month());
        contractEndDate = Date.newInstance(contractEndDate.year(), contractEndDate.month(), endMonthNumberOfDays);
        
        Map<Id, ASI_CRM_AccountsAdditionalField__c> childCustomerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomerList());

        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : childCustomerMap.values()) {
            customerIdSet.add(customer.ASI_CRM_CN_Parent_Outlet__c);
        }

        for(ASI_CRM_AccountsAdditionalField__c customer : retrieveCustomerList(customerIdSet)) {
            childCustomerMap.put(customer.Id, customer);
        }
        
        Map<Id, Id> parentChildCustomerContractIdMap = new Map<Id, Id>();
        
        ASI_CRM_VN_OutletHierarchy outletHierarchyHelper = new ASI_CRM_VN_OutletHierarchy(childCustomerMap.values());
        for(Id customerId : customerContractIdMap.keySet()) {
            Id contractId = customerContractIdMap.get(customerId);
        	for(ASI_CRM_AccountsAdditionalField__c customer : outletHierarchyHelper.getAllOutlet(customerId)) {
                parentChildCustomerContractIdMap.put(customer.Id, contractId);
            }
            parentChildCustomerContractIdMap.put(customerId, contractId);
        }
        
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = retrieveActualOfftakeList(parentChildCustomerContractIdMap.keySet(), contractStartDate, contractEndDate);
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {
            Id contractId = parentChildCustomerContractIdMap.get(actualOfftake.ASI_CRM_SG_Customer__c);
            ContractWrapper contractWrapper = contractWrapperMap.get(contractId);
            
            Date startDate = contractWrapper.contract.ASI_CRM_Start_Date__c.toStartOfMonth();
            Date endDate = contractWrapper.contract.ASI_CRM_End_Date__c;
            Integer numberOfDays = Date.daysInMonth(endDate.year(), endDate.month());
            endDate = Date.newInstance(endDate.year(), endDate.month(), numberOfDays);
            
            if(actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c >= startDate &&
               actualOfftake.ASI_TH_CRM_Offtake_G_L_Date__c <= endDate) {
            	contractWrapper.addActualOfftake(actualOfftake);
            }
        }
        
        List<ASI_TH_CRM_Actual_Offtake__c> updateActualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            ContractWrapper tempContractWrapper = contractWrapperMap.get(request.ASI_CRM_VN_Contract__c);
            
            for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : tempContractWrapper.actualOfftakeList) {
                if(actualOfftake.ASI_CRM_Payment_Time__c != null) {
                	if(actualOfftake.ASI_CRM_Payment_Time__c.contains(String.valueOf(actualOfftake.ASI_CRM_Payment_Time__c))) {
                    	actualOfftake.ASI_CRM_Payment_Time__c = 
                            actualOfftake.ASI_CRM_Payment_Time__c.replace(String.valueOf(actualOfftake.ASI_CRM_Payment_Time__c) + ',', '');
                    	actualOfftake.ASI_CRM_Payment_Time__c 
                            = actualOfftake.ASI_CRM_Payment_Time__c.replace(String.valueOf(actualOfftake.ASI_CRM_Payment_Time__c), '');
                    	updateActualOfftakeList.add(actualOfftake);
                    }
                }
            }
        }
        
        if(updateActualOfftakeList.size() > 0) update updateActualOfftakeList;
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract__c> retrieveContract(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where Id in :contractIdSet ';
        
    	return (List<ASI_CRM_VN_Contract__c>) Database.query(query);
  	}
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList() {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE RecordType.DeveloperName in :OUTLET_RECORD_TYPE_SET ' + 
                       'AND ASI_CRM_CN_Parent_Outlet__c != null';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList(Set<Id> customerIdSet) {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE Id in :customerIdSet ';

        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private List<ASI_TH_CRM_Actual_Offtake__c> retrieveActualOfftakeList(Set<Id> customerIdSet, Date offtakeStartDate, Date offtakeEndDate) {
    	String query = 'SELECT ' + genQueryField(ACTUAL_OFFTAKE_FIELD_MAP) +  
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_TH_CRM_Actual_Offtake__c ' + 
                       'WHERE ASI_CRM_SG_Customer__c in :customerIdSet ' + 
                       'AND ASI_TH_CRM_Offtake_G_L_Date__c >= :offtakeStartDate ' + 
                       'AND ASI_TH_CRM_Offtake_G_L_Date__c <= :offtakeEndDate ' + 
                       'AND RecordType.DeveloperName = :ACTUAL_OFFTAKE_RECORD_TYPE ';
        
    	return (List<ASI_TH_CRM_Actual_Offtake__c>) Database.query(query);
  	}
    
	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      	String queryField = '';
      	for(String fields : fieldMap.keySet()) {
       		queryField += fields + ',';
   		}
    	return queryField.subString(0, queryField.length() - 1);
    }
}