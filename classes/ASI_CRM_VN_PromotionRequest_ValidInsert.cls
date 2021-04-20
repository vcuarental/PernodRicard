/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromotionRequest_ValidInsert
 * Description: Apex class for ASI_CRM_VN_PromotionRequest_ValidInsert
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-05       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_VN_PromotionRequest_ValidInsert {
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> requestList   = (List<ASI_GiftBox_Request_Header__c>) newList;

        Set<Id> planIds = ASI_CRM_VN_Util_Pluck.ids(requestList, ASI_GiftBox_Request_Header__c.ASI_CRM_Trade_A_P_Plan__c);

        Map<Id, ASI_CRM_Trade_A_P_Plan__c> plansByIds = new Map<Id, ASI_CRM_Trade_A_P_Plan__c>(
        [SELECT Id, ASI_CRM_PROS_Image__c, ASI_CRM_Outlet_Sub_Type__c, ASI_CRM_Outlet_Balance__c, (SELECT ASI_CRM_Customer__c FROM Gift_Box_POSM_Requests__r) FROM ASI_CRM_Trade_A_P_Plan__c WHERE Id IN :planIds]
        );

        // Not allow insert if request's plan has no balance and it is new outlet for plan
        for (ASI_GiftBox_Request_Header__c requestHeader : requestList) {
            ASI_CRM_Trade_A_P_Plan__c plan = plansByIds.get(requestHeader.ASI_CRM_Trade_A_P_Plan__c);
            if (plan == null) {
                continue;
            }

            if(String.isNotBlank(plan.ASI_CRM_PROS_Image__c) && String.isNotBlank(requestHeader.ASI_CRM_VN_Image_Level__c) &&
               plan.ASI_CRM_PROS_Image__c.contains(requestHeader.ASI_CRM_VN_Image_Level__c) == false) {
                requestHeader.addError('Image Level does not match!');
            }
            
            if(String.isNotBlank(plan.ASI_CRM_Outlet_Sub_Type__c) &&
               plan.ASI_CRM_Outlet_Sub_Type__c.contains(requestHeader.ASI_CRM_Outlet_Sub_Type__c) == false) {
                requestHeader.addError('Outlet Sub Type does not match');
            }
            
            if (plan.ASI_CRM_Outlet_Balance__c <= 0) {
                Boolean newOutlet = true;
                for (ASI_GiftBox_Request_Header__c requestHeader2 : plan.Gift_Box_POSM_Requests__r) {
                    if (requestHeader.ASI_CRM_Customer__c == requestHeader2.ASI_CRM_Customer__c) {
                       newOutlet = false;
                    }
                }
                if (newOutlet) {
                    requestHeader.addError('Not enough outlet balance.');
                }
            }
        }
    }

}