public with sharing class EUR_CRM_BrandSecurityInfringementTrigHan extends EUR_CRM_TriggerHandler {

    override protected void afterInsert() {
        new EUR_CRM_AccRelObjSharingService().createSharing((List<EUR_CRM_Brand_Security_Infringement__c>)Trigger.new);
        EUR_CRM_AccountChildrenSharingBatch.addShares(Trigger.new);
    }

}