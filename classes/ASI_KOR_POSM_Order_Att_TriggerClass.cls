/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Att_TriggerClass
* Description: Trigger class for ASI_KOR_POSM_Order_Attachment's trigger(s)
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-27       Alan Lau                Created
****************************************************************************************************************************/

public without sharing class ASI_KOR_POSM_Order_Att_TriggerClass {

    public static void blockAttachmentForFinalizedRequest(List<ASI_KOR_POSM_Order_Attachment__c> triggerNew) {
        final List<String> recordTypeBlockList = new List<String>{
                'ASI_KOR_Finalized_Bar_Styling_Item_Request'
        };
        List<String> posmHeaderIdList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_POSM_Order_Request__c');
        Map<Id, ASI_KOR_POSM_Order_Request__c> mapOfIdToPOSMHeader = new Map<Id, ASI_KOR_POSM_Order_Request__c>([
                SELECT Id,
                        ASI_KOR_Status__c,
                        RecordType.DeveloperName
                FROM ASI_KOR_POSM_Order_Request__c
                WHERE Id IN :posmHeaderIdList
        ]);

        for (ASI_KOR_POSM_Order_Attachment__c attachment : triggerNew) {
            if (mapOfIdToPOSMHeader.containsKey(attachment.ASI_KOR_POSM_Order_Request__c)
                    && recordTypeBlockList.contains(mapOfIdToPOSMHeader.get(attachment.ASI_KOR_POSM_Order_Request__c).RecordType.DeveloperName)) {
                attachment.addError('Attachment editing is blocked when the status is Final.');
            }
        }

    }

}