@IsTest
public with sharing class EUR_CRM_PRS_ForceImLevelHandlerTest {
    public static testmethod void testing() {
        Id recTypeId =EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Seg_Aspect__c', 'EUR DB PRS Segmentation Aspect Image Level');
        insert new EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic',RecordTypeId = recTypeId);
        insert new EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Leading',RecordTypeId = recTypeId);

        EUR_CRM_Account__c acct = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_DB_On_Trade_Account')[0];
        acct.EUR_CRM_Force_PRS_Image_Level__c = 'Leading';
        insert acct;

        acct.EUR_CRM_Force_PRS_Image_Level__c = 'Iconic';
        Test.startTest();
        update acct;
        Test.stopTest();
        System.assertEquals('Iconic',[SELECT EUR_CRM_PRS_Image_Level__r.EUR_CRM_Name__c FROM EUR_CRM_Account__c WHERE Id=:acct.Id][0].EUR_CRM_PRS_Image_Level__r.EUR_CRM_Name__c);
    }

}