/*********************************************************************************
 * Name: ASI_CRM_VN_FOCRequest_AssignDefaultVal
 * Description: Assign default value to FOC Request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_FOCRequest_AssignDefaultVal {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
    
    public ASI_CRM_VN_FOCRequest_AssignDefaultVal() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> requestList   = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> requestMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        
        List<ASI_GiftBox_Request_Header__c> filteredRequestList = filterRequest(requestList, requestMap);
        assignDefaultValue(filteredRequestList);
    }
    
    private List<ASI_GiftBox_Request_Header__c> filterRequest(List<ASI_GiftBox_Request_Header__c> requestList, Map<Id, ASI_GiftBox_Request_Header__c> requestMap) {
        return requestList;
    }
    
    private void assignDefaultValue(List<ASI_GiftBox_Request_Header__c> requestList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            contractIdSet.add(request.ASI_CRM_VN_Contract__c);
        }
        
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = new Map<Id, ASI_CRM_VN_Contract__c>(retrieveContract(contractIdSet));
        
        for(ASI_GiftBox_Request_Header__c request : requestList) {
            ASI_CRM_VN_Contract__c contract = contractMap.get(request.ASI_CRM_VN_Contract__c);
            
            request = copyDataFromContract(request, contract);
        }
        
    }
    
    private ASI_GiftBox_Request_Header__c copyDataFromContract(ASI_GiftBox_Request_Header__c request, ASI_CRM_VN_Contract__c contract) {
        request.ASI_CRM_Customer__c                   = contract.ASI_CRM_Outlet_WS__c;
        request.ASI_GiftBox_Delivery_Address__c       = contract.ASI_CRM_Outlet_Address__c;
        request.ASI_CRM_VN_Channel__c                 = contract.ASI_CRM_Outlet_Type__c;
        request.ASI_CRM_VN_Contract_Type__c           = contract.ASI_CRM_Type__c;
        request.ASI_CRM_VN_Contract_Start_Date__c     = contract.ASI_CRM_Start_Date__c;
       	request.ASI_CRM_VN_Contract_Ending_Date__c    = contract.ASI_CRM_End_Date__c;
        request.ASI_CRM_VN_Contract_Duration__c       = contract.ASI_CRM_No_Of_Months__c;
        request.ASI_CRM_VN_Image_Level__c             = contract.ASI_CRM_Outlet_Image__c;
        request.ASI_CRM_VN_Spirit_Volume_Potential__c = contract.ASI_CRM_Spirit_Volume_Potential__c;
        request.ASI_CRM_VN_Wine_Volume_Potential__c   = contract.ASI_CRM_Wine_Volume_Potential__c;
        request.ASI_CRM_VN_Outlet_Role__c             = contract.ASI_CRM_Outlet_Role__c;
        request.ASI_GiftBox_Region__c                 = contract.ASI_CRM_Outlet_Region__c;
        return request;
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