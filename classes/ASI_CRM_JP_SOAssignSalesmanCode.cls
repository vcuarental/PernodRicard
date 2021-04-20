/*********************************************************************************
 * Name: ASI_CRM_JP_SOAssignSalesmanCode
 * Description: Assign the default salesman value to Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOAssignSalesmanCode extends ASI_CRM_JP_TriggerAbstract {
    
    private final static String SAMPLE_SALES_RECORD_TYPE              = 'ASI_CRM_JP_Sample_Sales';
    private final static String MARKETING_FOC_RECORD_TYPE             = 'ASI_CRM_JP_Marketing_FOC';
    private final static String ENTERTAINMENT_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Entertainment_Sales';
    
    public ASI_CRM_JP_SOAssignSalesmanCode() {
        super('ASI_CRM_JP_SOAssignSalesmanCode');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = filterSalesOrder((List<ASI_CRM_JP_Sales_Order__c>)sObjList, (Map<Id, ASI_CRM_JP_Sales_Order__c>)oldMap);
        
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : filteredSalesOrderList) {
            if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + ENTERTAINMENT_SALES_ORDER_RECORD_TYPE) && 
               String.isNotBlank(salesOrder.ASI_CRM_JP_Entertainment_Owner__c)) {
            	userIdSet.add(salesOrder.ASI_CRM_JP_Entertainment_Owner__c);
            } else {
            	userIdSet.add(salesOrder.OwnerId);
            }
        }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
        for(ASI_CRM_JP_Sales_Order__c salesOrder : filteredSalesOrderList) {
            if(salesOrder.ASI_CRM_JP_Company_Event_HR_Only__c) {
            	salesOrder.ASI_CRM_Salesman_Code__c = '5999';
                continue;
            }
            
        	User u = userMap.get(salesOrder.OwnerId);
            if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + ENTERTAINMENT_SALES_ORDER_RECORD_TYPE) && 
               String.isNotBlank(salesOrder.ASI_CRM_JP_Entertainment_Owner__c)) {
                u = userMap.get(salesOrder.ASI_CRM_JP_Entertainment_Owner__c);
            }
            salesOrder.ASI_CRM_Salesman_Code__c = u.ASI_TnE_Sub_Ledger__c;
        }
    }
    
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrder(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> oldSOMap) {
    	List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + SAMPLE_SALES_RECORD_TYPE) || 
               salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + MARKETING_FOC_RECORD_TYPE) ||
               salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + ENTERTAINMENT_SALES_ORDER_RECORD_TYPE) || 
               salesOrder.ASI_CRM_JP_Company_Event_HR_Only__c != oldSOMap.get(salesOrder.Id).ASI_CRM_JP_Company_Event_HR_Only__c) {
            	filteredSalesOrderList.add(salesOrder);	
            }
        }
        
        return filteredSalesOrderList;
    }
    
    /***************
	Data Retrievement Function
	***************/
    private Map<Id, User> retrieveUser(Set<Id> userIdSet) {
        String query = 'SELECT Id, ASI_TnE_Sub_Ledger__c ' + 
                       'FROM User ' + 
                       'WHERE Id in : userIdSet';
        return new Map<Id, User>((List<User>) Database.query(query));
    }
    
}