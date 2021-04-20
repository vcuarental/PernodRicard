@isTest
private class EUR_CRM_Pros_Volume_Potential_AftUpdtTst{

    static testMethod void myUnitTest(){
        EUR_CRM_Pros_Segmentation__c seg = new EUR_CRM_Pros_Segmentation__c();
        insert seg;
        EUR_CRM_Pros_Volume_Potential__c vol = new EUR_CRM_Pros_Volume_Potential__c();
        vol.EUR_CRM_Pros_Segmentation__c = seg.Id;
        insert vol;
        update vol;
    
    }
}