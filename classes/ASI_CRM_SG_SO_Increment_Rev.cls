/*********************************************************************************
 * Name:ASI_CRM_SG_SO_Increment_Rev 
 * Description: Class to increment Sales Order Revision when it's rejected
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/03/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_SO_Increment_Rev extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_SO_Increment_Rev  () {
        super('ASI_CRM_SG_SO_Increment_Rev');
        
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_KOR_Sales_Order_Request__c> soList = (List<ASI_KOR_Sales_Order_Request__c>)sObjList;
        Map<ID, ASI_KOR_Sales_Order_Request__c> soOldMap = (Map<ID, ASI_KOR_Sales_Order_Request__c>)oldMap;
        
        for(ASI_KOR_Sales_Order_Request__c so : soList) {
            if(so.ASI_KOR_Order_Status__c == 'Submitted' && soOldMap.get(so.id).ASI_KOR_Order_Status__c == 'Rejected') {
                Decimal revNo = so.ASI_CRM_SG_Version_No__c == null ? 0 : so.ASI_CRM_SG_Version_No__c;
                revNo++;
                so.ASI_CRM_SG_Version_No__c = revNo;
            }
        }
        
    }
}