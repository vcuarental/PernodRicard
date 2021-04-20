/*********************************************************************************
 * Name: ASI_CRM_SG_SalesOrderTransactionDTCls
 * Description: The trigger handler the access right of sales order line item delete operation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/05/2016       Laputa:Hugo             Created
 *              
*/
public with sharing class ASI_CRM_SG_SalesOrderTransactionDTCls extends ASI_CRM_SG_TriggerAbstract {

    public static String ERROR_Message = 'You do not allow to remove the sales order line item';
    public static Set<String> PERMIT_PROFILE_NAMES = new Set<String> {
        'ASI SG External User'
    };
    public static Set<String> DECLINE_RECORD_TYPE = new Set<String> {
        'ASI_CRM_SG_Wholesaler'
    };

    public ASI_CRM_SG_SalesOrderTransactionDTCls() {
        super('ASI_CRM_SG_SalesOrderTransactionDTCls');
    }

    public override void executeTriggerAction(
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        List<ASI_KOR_Sales_Order_Transaction__c> soReqDetails = (List<ASI_KOR_Sales_Order_Transaction__c>)sObjList;
        
        Id profileId = UserInfo.getProfileId();
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        for (ASI_KOR_Sales_Order_Transaction__c soReqDetail : soReqDetails) {
            String tempRecordType = Global_RecordTypeCache.getRt(soReqDetail.RecordTypeId).DeveloperName;

            if(DECLINE_RECORD_TYPE.contains(tempRecordType) && !PERMIT_PROFILE_NAMES.contains(userProfile.Name)) {
                soReqDetail.addError(ERROR_Message);
            }

        }
    }

}