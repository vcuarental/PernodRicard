/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ManagePromotionReqController
 * Description: Apex class for ASI_CRM_VN_ManagePromotionRequestPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-12-28       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_VN_ManagePromotionReqController {
    private ASI_GiftBox_Request_Header__c promotionRequest;
    public Boolean readOnly;
    public String lineItemListJson;
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public ASI_CRM_VN_ManagePromotionReqController(ApexPages.StandardController stdController) {
        this.promotionRequest = (ASI_GiftBox_Request_Header__c) stdController.getRecord();
    }

    public String getPromotionPlanItemsJSON() {
        Id promotionPlanId = this.promotionRequest.ASI_CRM_Trade_A_P_Plan__c;
        List<ASI_CRM_Trade_A_P_Plan_Item__c> promotionPlanItems = [SELECT ASI_CRM_Promotion_Scheme__c, ASI_CRM_Balance_Quantity__c, ASI_CRM_Unit_Price__c FROM ASI_CRM_Trade_A_P_Plan_Item__c WHERE ASI_CRM_Trade_A_P_Plan__c = :promotionPlanId];

        return JSON.serialize(promotionPlanItems);
    }

    public String getPromotionRequestItemsJSON() {
        Id promotionRequestId = this.promotionRequest.Id;
        List<ASI_GiftBox_Request_Item__c> promotionRequestItems = [SELECT ASI_CRM_Promotion_Scheme__c, ASI_GiftBox_Request_Item_Unit_Price__c, ASI_GiftBox_Request_Quantity__c, ASI_CRM_Amount__c FROM ASI_GiftBox_Request_Item__c WHERE ASI_GiftBox_Request_Id__c = :promotionRequestId];

        return JSON.serialize(promotionRequestItems);
    }


    public PageReference saveRecord() {
        Id headerId = ApexPages.currentPage().getParameters().get('id');
        String jsonString = ApexPages.currentPage().getParameters().get('updateLineItemListJson');
        Boolean isQuickSave = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isQuickSave'));

        List<ASI_GiftBox_Request_Item__c> newList = (List<ASI_GiftBox_Request_Item__c>) JSON.deserialize(jsonString, List<ASI_GiftBox_Request_Item__c>.class);

//        remove all old promotion request item
        List<ASI_GiftBox_Request_Item__c> oldItems = [SELECT Id FROM ASI_GiftBox_Request_Item__c WHERE ASI_GiftBox_Request_Id__c = :headerId];
        delete oldItems;

        List<ASI_GiftBox_Request_Item__c> requestItems = new List<ASI_GiftBox_Request_Item__c>();
        for (ASI_GiftBox_Request_Item__c newItem : newList) {
            newItem.ASI_GiftBox_Request_Id__c = headerId;
            newItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Item__cASI_CRM_VN_Promotion_Request_Item');
            requestItems.add(newItem);
        }

        insert requestItems;

        if (isQuickSave) {
            //Init the page if is quick save
            //            init(header.Id);
            return null;
        }

        PageReference pageRef = new PageReference('/' + headerId);
        pageRef.setRedirect(true);
        return pageRef;

    }
}