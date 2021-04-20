/*********************************************************************************
 * Name: ASI_CRM_JP_SOAssignSalesman
 * Description: Assign the salesman to Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOAssignSalesman extends ASI_CRM_JP_TriggerAbstract {
    
    private final static String INACTIVE_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Inactive_Sales_Order';
    
    public ASI_CRM_JP_SOAssignSalesman() {
        super('ASI_CRM_JP_SOAssignSalesman');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap;
        
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = filterSalesOrderList(salesOrderList, salesOrderMap);
        System.debug(filteredSalesOrderList);
        assignSalesmanCodeGroup(filteredSalesOrderList);
    }
    
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrderList(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> salesOrderMap) {
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrderMap == null) {
                if(salesOrder.RecordTypeId != Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + INACTIVE_SALES_ORDER_RECORD_TYPE) &&
                   String.isNotBlank(salesOrder.ASI_CRM_Salesman__c)) {
                    filteredSalesOrderList.add(salesOrder);
                }
            } else {
            	if(String.isNotBlank(salesOrder.ASI_CRM_Salesman__c) && 
                   salesOrder.ASI_CRM_Salesman__c != salesOrderMap.get(salesOrder.Id).ASI_CRM_Salesman__c) {
                    filteredSalesOrderList.add(salesOrder);
                }
            }
        }
        
        return filteredSalesOrderList;
    }
    
    private void assignSalesmanCodeGroup(List<ASI_CRM_JP_Sales_Order__c> salesOrderList) {
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            userIdSet.add(salesOrder.ASI_CRM_Salesman__c);
        }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
       	for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(userMap.containsKey(salesOrder.ASI_CRM_Salesman__c) == false) {
            	continue;
            }
            User salesman = userMap.get(salesOrder.ASI_CRM_Salesman__c);
            salesOrder.ASI_CRM_Salesman_Code__c  = salesman.ASI_TnE_Sub_Ledger__c;
            salesOrder.ASI_CRM_JP_Sales_Group__c = salesman.ASI_KOR_User_Branch_Code__c;
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
    private Map<Id, User> retrieveUser(Set<Id> userIdSet) {
        String query = 'SELECT Id, ASI_KOR_User_Branch_Code__c, ASI_TnE_Sub_Ledger__c ' + 
                       'FROM User ' + 
                       'WHERE Id in : userIdSet ' + 
                       'AND UserRole.Name LIKE \'JP%\'';
        return new Map<Id, User>((List<User>) Database.query(query));
    }
}