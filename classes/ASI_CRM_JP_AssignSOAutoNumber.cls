/*********************************************************************************
 * Name: ASI_CRM_JP_AssignSOAutoNumber
 * Description: Class to Assign Custom Auto Number to Sales Order JP Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/02/2017       Hugo Cheung             Created          
*/
public with sharing class ASI_CRM_JP_AssignSOAutoNumber extends ASI_CRM_JP_TriggerAbstract {

	private static final String DIRECT_SALES_RECORD_TYPE        = 'ASI_CRM_JP_Direct_Sales';
	private static final String DUTY_FREE_SO_RECORD_TYPE        = 'ASI_CRM_JP_Duty_Free_SO';
	private static final String EMPLOYEE_SALES_RECORD_TYPE      = 'ASI_CRM_JP_Employee_Sales';
	private static final String ENTERTAINMENT_SALES_RECORD_TYPE = 'ASI_CRM_JP_Entertainment_Sales';
	private static final String MARKETING_FOC_RECORD_TYPE       = 'ASI_CRM_JP_Marketing_FOC';
	private static final String NORMAL_SO_RECORD_TYPE           = 'ASI_CRM_JP_Normal_SO';
	private static final String SAMPLE_SALES_RECORD_TYPE        = 'ASI_CRM_JP_Sample_Sales';	

	private static final String SALES_ORDER_OBJECT_NAME = 'ASI_CRM_JP_Sales_Order__c';

	public ASI_CRM_JP_AssignSOAutoNumber() {
		super('ASI_CRM_JP_AssignSOAutoNumber');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		List<ASI_CRM_JP_Sales_Order__c> salesOrderList = (List<ASI_CRM_JP_Sales_Order__c>) sObjList;
        Map<Id, ASI_CRM_JP_Sales_Order__c> oldSalesOrderMap = (Map<Id, ASI_CRM_JP_Sales_Order__c>) oldMap;
        
        Map<String, ASI_CRM_JP_AutoNumberAssignment> autoNumAssignMap = new Map<String, ASI_CRM_JP_AutoNumberAssignment>();
        autoNumAssignMap.put(DIRECT_SALES_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + DIRECT_SALES_RECORD_TYPE));
        autoNumAssignMap.put(DUTY_FREE_SO_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + DUTY_FREE_SO_RECORD_TYPE));
        autoNumAssignMap.put(EMPLOYEE_SALES_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + EMPLOYEE_SALES_RECORD_TYPE));
        autoNumAssignMap.put(ENTERTAINMENT_SALES_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + ENTERTAINMENT_SALES_RECORD_TYPE));
        autoNumAssignMap.put(MARKETING_FOC_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + MARKETING_FOC_RECORD_TYPE));
        autoNumAssignMap.put(NORMAL_SO_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + NORMAL_SO_RECORD_TYPE));
        autoNumAssignMap.put(SAMPLE_SALES_RECORD_TYPE, new ASI_CRM_JP_AutoNumberAssignment(SALES_ORDER_OBJECT_NAME + SAMPLE_SALES_RECORD_TYPE));

        for(ASI_CRM_JP_Sales_Order__c salesOrder : salesOrderList) {
            if(oldSalesOrderMap == null || oldSalesOrderMap.get(salesOrder.Id).Name == '[Auto Number]') {
                String recordTypeName = Global_RecordTypeCache.getRt(salesOrder.RecordTypeId).developerName;
                if(autoNumAssignMap.containsKey(recordTypeName)) {
                    salesOrder.Name = autoNumAssignMap.get(recordTypeName).nextAutoNumStr();
                }
            }
        }

        for(ASI_CRM_JP_AutoNumberAssignment autoNumAssign : autoNumAssignMap.values()) {
        	autoNumAssign.writeToDB();
        }
	}

}