/*********************************************************************************
 * Name: ASI_CRM_JP_SOAssignAPCode
 * Description: Assign the default A&P value to Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/04/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_SOAssignAPCode extends ASI_CRM_JP_TriggerAbstract {
    
    private final static String ENTERTAINMENT_SALES_RECORD_TYPE = 'ASI_CRM_JP_Entertainment_Sales';
    private final static String INACTIVE_SALES_ORDER_RECORD_TYPE = 'ASI_CRM_JP_Inactive_Sales_Order';
    
    public ASI_CRM_JP_SOAssignAPCode() {
        super('ASI_CRM_JP_SOAssignAPCode');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = filterSalesOrder((List<ASI_CRM_JP_Sales_Order__c>)sObjList, (Map<Id, ASI_CRM_JP_Sales_Order__c>)oldMap);
    	
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : filteredSalesOrderList) {
        	Id tempUserId;
            if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + ENTERTAINMENT_SALES_RECORD_TYPE)) {
            	if(String.isNotBlank(salesOrder.ASI_CRM_JP_Entertainment_Owner__c)) {
                    tempUserId = salesOrder.ASI_CRM_JP_Entertainment_Owner__c;
                } else {
                    tempUserId = salesOrder.OwnerId;
                }
            }
            userIdSet.add(tempUserId);
        }
        
        Map<Id, User> userMap = retrieveUser(userIdSet);
        for(ASI_CRM_JP_Sales_Order__c salesOrder : filteredSalesOrderList) {
            
            if(salesOrder.ASI_CRM_JP_Company_Event_HR_Only__c) {
            	salesOrder.ASI_CRM_AP_Code__c = '8999';
                continue;
            }
            
            User u;
        	if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + ENTERTAINMENT_SALES_RECORD_TYPE)) {
            	if(String.isNotBlank(salesOrder.ASI_CRM_JP_Entertainment_Owner__c)) {
                    u = userMap.get(salesOrder.ASI_CRM_JP_Entertainment_Owner__c);
                } else {
                    u = userMap.get(salesOrder.OwnerId);
                }
            }
            
            if(u != NULL && String.isNotBlank(u.ASI_TnE_Sub_Ledger__c)) {
                salesOrder.ASI_CRM_AP_Code__c = '8' + u.ASI_TnE_Sub_Ledger__c.substring(u.ASI_TnE_Sub_Ledger__c.length()-3, u.ASI_TnE_Sub_Ledger__c.length());
            }
        }
    }
    
    private List<ASI_CRM_JP_Sales_Order__c> filterSalesOrder(List<ASI_CRM_JP_Sales_Order__c> salesOrderList, Map<Id, ASI_CRM_JP_Sales_Order__c> oldSOMap) {
    	List<ASI_CRM_JP_Sales_Order__c> filteredSalesOrderList = new List<ASI_CRM_JP_Sales_Order__c>();
        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(salesOrder.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + ENTERTAINMENT_SALES_RECORD_TYPE)) {
            	if(oldSOMap.get(salesOrder.Id).RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_JP_Sales_Order__c' + INACTIVE_SALES_ORDER_RECORD_TYPE) ||
                   oldSOMap.get(salesOrder.Id).ASI_CRM_JP_Entertainment_Owner__c != salesOrder.ASI_CRM_JP_Entertainment_Owner__c || 
                   oldSOMap.get(salesOrder.Id).ownerId != salesOrder.ownerId) {
            		filteredSalesOrderList.add(salesOrder);	
                }
            }
            
            if(salesOrder.ASI_CRM_JP_Company_Event_HR_Only__c || oldSOMap.get(salesOrder.Id).ASI_CRM_JP_Company_Event_HR_Only__c) {
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