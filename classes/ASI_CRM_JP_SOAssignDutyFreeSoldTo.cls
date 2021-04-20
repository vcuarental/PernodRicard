/*********************************************************************************
 * Name: ASI_CRM_JP_SOAssignDutyFreeSoldTo
 * Description: Assign the Sold To to sales order when order type is sample so or posm
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOAssignDutyFreeSoldTo extends ASI_CRM_JP_TriggerAbstract {
    
    //Field Map
	private final static Map<String, Schema.SObjectField> CUSTOMER_FIELD_MAP = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
    
    private static Set<String> ORDER_TYPE_FILTER_SET = new Set<String> {
    	'Sample Sales',
        'POSM'
    };
    
    private static String RECORD_TYPE_FILTER_STRING = 'ASI_CRM_JP_Duty_Free_SO';
    
    private static String DEFAULT_SOLD_TO_CODE = '99999995';
    
    public ASI_CRM_JP_SOAssignDutyFreeSoldTo() {
        super('ASI_CRM_JP_SOAssignDutyFreeSoldTo');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
       	
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = filterSalesOrder(salesOrderList);
        assignDefaultSoldTo(filteredSalesOrderList);
    }
    
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrder(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        
        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            customerIdSet.add(salesOrder.ASI_CRM_Sold_To__c);
        }
        Map<Id, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<Id, ASI_CRM_AccountsAdditionalField__c>(retrieveCustomer(customerIdSet));
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + RECORD_TYPE_FILTER_STRING)) {
            	if(ORDER_TYPE_FILTER_SET.contains(salesOrder.ASI_CRM_Order_Type__c) && 
                   (String.isBlank(salesOrder.ASI_CRM_Sold_To__c) ||
                   customerMap.get(salesOrder.ASI_CRM_Sold_To__c).ASI_CRM_CN_JDE_Code__c != DEFAULT_SOLD_TO_CODE)) {
                    filteredSalesOrderList.add(salesOrder);
                }
            }
        }
        
        return filteredSalesOrderList;
    }
    
  	private void assignDefaultSoldTo(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
        ASI_CRM_AccountsAdditionalField__c customer = retrieveCustomerFromCode(DEFAULT_SOLD_TO_CODE);
        
        if(customer == null) {
        	return;
        }
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            salesOrder.ASI_CRM_Sold_To__c  = customer.Id;
            salesOrder.ASI_CRM_Tax_Area__c = customer.ASI_CRM_SG_Tax_Rate_Area__c;
            salesOrder.ASI_CRM_Tax_Code__c = customer.ASI_CRM_SG_Tax_Expl_Code__c;
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomer(Set<Id> customerIdSet) {
        String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_AccountsAdditionalField__c ' + 
		               'Where Id in :customerIdSet';
		return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
    
    private ASI_CRM_AccountsAdditionalField__c retrieveCustomerFromCode(String customerCode) {
		String query = 'SELECT ' + genQueryField(CUSTOMER_FIELD_MAP) + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_AccountsAdditionalField__c ' + 
		               'Where ASI_CRM_CN_JDE_Code__c = :customerCode';
		List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
		return customerList.size() == 0 ? null : customerList.get(0);
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