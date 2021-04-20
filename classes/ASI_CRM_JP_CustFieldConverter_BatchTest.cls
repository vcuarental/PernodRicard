/**********************************************************************************
 * Name : ASI_CRM_JP_CustFieldConverter_BatchTest
 * Created : DC @04/18/2016 12:33 PM
 * Revision History:
 * 1. 04/18/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_CustFieldConverter_BatchTest {
    
    @TestSetup
    private static void createCustomersForBatch() {
        
        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('JP Bar Supplier').getRecordTypeId();

        List<ASI_CRM_AccountsAdditionalField__c> lstTestCustomers =
            new List<ASI_CRM_AccountsAdditionalField__c>();

        for(Integer index = 0; index < 50; index ++) {
            lstTestCustomers.add( new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test' + index,
                ASI_CRM_Customer_Name_Katakana__c = 'Test' + index,
                ASI_CRM_CN_Phone_Number__c = '01234567899',
                ASI_CRM_Street_Number__c = '93T',
                ASI_CRM_Building_Floor_Number__c = '7',
                RecordTypeId = customerRecTypeId
            ));
        }
        
        insert lstTestCustomers;
    }

    static testMethod void testConversionByBatch() {
        
        System.Test.startTest();
        Id jobId = Database.executeBatch(new ASI_CRM_JP_CustomerFieldConverter_Batch(), 50);
        System.Test.stopTest();
    }
}