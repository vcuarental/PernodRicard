/*********************************************************************************
 * Name: ASI_CRM_JP_CustomerAssignApprover
 * Description: Assign the approver of customer
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_CustomerAssignApprover extends ASI_CRM_JP_TriggerAbstract {
    
	private final static Map<String, Schema.SObjectField> ROUTE_TYPE_FIELD_MAP        = Schema.SObjectType.ASI_CRM_Route_Type__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> ROUTE_TYPE_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Route_Rule_Detail__c.fields.getMap();
    
    private final static String ROUTE_TYPE_RECORD_TYPE = 'ASI_CRM_JP_Customer_Route_Type';
    
    private final static String CUSTOMER_DIRECT_SALES_RECORD_TYPE = 'ASI_CRM_JP_Inactive_Direct_Sales_Customer';
    
    private final static String ROUTE_TYPE_MODULE = 'Customer';
    private final static String ROUTE_TYPE_MODULE_RECORD_TYPE = 'Direct Sales Customer';
    
    private final static String MARKETING_USER_ROUTE_TYPE_NAME = 'JP Customer Direct Sales Customer Marketing User';
    
    public ASI_CRM_JP_CustomerAssignApprover() {
        super('ASI_CRM_JP_CustomerAssignApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) sObjList;
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = (Map<Id, ASI_CRM_AccountsAdditionalField__c>) oldMap;
        
        List<ASI_CRM_AccountsAdditionalField__c> filteredCustomerList = filterCustomerList(customerList, customerMap);
        if(filteredCustomerList == null && filteredCustomerList.size() == 0) {
            return;
        }
        
    	assignApprover(filteredCustomerList);
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> filterCustomerList(List<ASI_CRM_AccountsAdditionalField__c> customerList, Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap) {
    	if(customerMap != null) {
            return null;
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> filteredCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            if(customer.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__c' + CUSTOMER_DIRECT_SALES_RECORD_TYPE)) {
                filteredCustomerList.add(customer);
            }
        }
        
        return filteredCustomerList;
    }
    
    private void assignApprover(List<ASI_CRM_AccountsAdditionalField__c> customerList) {
    	Map<String, ASI_CRM_Route_Type__c> routeTypeMap = retrieveRouteTypeMap();
        if(routeTypeMap == null || routeTypeMap.size() == 0) {
        	return;
        }
        
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            userIdSet.add(customer.ownerId);
        }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            ASI_CRM_Route_Type__c routeType = routeTypeMap.get(ROUTE_TYPE_MODULE_RECORD_TYPE);
            if(userMap.get(customer.OwnerId).Department == 'Marketing') {
                routeType = routeTypeMap.get(ROUTE_TYPE_MODULE_RECORD_TYPE + '_' + MARKETING_USER_ROUTE_TYPE_NAME);
            }
            Integer approverIndex = 1;
            for(ASI_CRM_Route_Rule_Detail__c routeTypeDetail : routeType.ASI_CRM_Route_Rule_Details__r) {
                if(routeTypeDetail.ASI_CRM_JP_Approver_Type__c == 'Line Manager') {
                	customer.put('ASI_CRM_CN_Sys_Approver_' + approverIndex + '__c', userMap.get(customer.OwnerId).ManagerId);
                } else {
                	customer.put('ASI_CRM_CN_Sys_Approver_' + approverIndex + '__c', routeTypeDetail.ASI_CRM_Approver__c);
                }
                approverIndex++;
            }
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
    private Map<String, ASI_CRM_Route_Type__c> retrieveRouteTypeMap() {
        String query = 'SELECT ' + genQueryField(ROUTE_TYPE_FIELD_MAP) + ' ' + 
                       ', (SELECT ' + genQueryField(ROUTE_TYPE_DETAIL_FIELD_MAP) + ' FROM ASI_CRM_Route_Rule_Details__r ORDER BY ASI_CRM_JP_Approval_Sequence__c) ' + 
                       'FROM ASI_CRM_Route_Type__c ' + 
                       'WHERE RecordType.DeveloperName = :ROUTE_TYPE_RECORD_TYPE ' + 
                       'AND ASI_CRM_Module__c = :ROUTE_TYPE_MODULE ' + 
                       'AND ASI_CRM_Module_Record_Type__c = :ROUTE_TYPE_MODULE_RECORD_TYPE ';
        
        Map<String, ASI_CRM_Route_Type__c> routeTypeMap = new Map<String, ASI_CRM_Route_Type__c>();
        for(ASI_CRM_Route_Type__c routeType : (List<ASI_CRM_Route_Type__c>) Database.query(query)) {
            String key = routeType.ASI_CRM_Module_Record_Type__c;
            if(routeType.Name == MARKETING_USER_ROUTE_TYPE_NAME) {
            	key += '_' + routeType.Name;
            }
            /*
            if(String.isNotBlank(routeType.ASI_CRM_User__c)) {
            	key += '_' + routeType.ASI_CRM_User__c;
            }
            if(String.isNotBlank(routeType.ASI_CRM_Role__c)) {
            	key += '_' + routeType.ASI_CRM_Role__c;
            }
            */
            if(routeTypeMap.containsKey(key) == false) {
            	routeTypeMap.put(key, routeType);
            }
        }
        
        return routeTypeMap;
    }
    
    private Map<Id, User> retrieveUser(Set<Id> userIdSet) {
        String query = 'SELECT Id, ManagerId, Department ' + 
                       'FROM User ' + 
                       'WHERE Id in : userIdSet';
        return new Map<Id, User>((List<User>) Database.query(query));
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