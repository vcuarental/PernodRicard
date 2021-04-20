/*********************************************************************************
 * Name: ASI_CRM_JP_SODeleteInactiveBatch
 * Description: Delete the inactive sales order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/08/2017       Hugo Cheung             Created          
*/
global class ASI_CRM_JP_SODeleteInactiveBatch implements Database.Batchable<sObject> {
    
    private static Set<String> DELETE_RECORD_TYPE_SET = new Set<String> {
    	'ASI_CRM_JP_Inactive_Sales_Order'
    };
    
    private static String queryStr = 'SELECT Id ' + 
                                     'FROM ASI_CRM_JP_Sales_Order__c ' + 
                                     'WHERE RecordType.DeveloperName in :DELETE_RECORD_TYPE_SET';
    
    public ASI_CRM_JP_SODeleteInactiveBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext contextInstance, List<Sobject> sObjectList) {
        delete sObjectList;
    }
    
    global void finish(Database.BatchableContext contextInstance) {}
}