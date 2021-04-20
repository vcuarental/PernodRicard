/**********************************************************************************
 * Name : ASI_CRM_JP_EncodingConverterTest
 * Created : DC @04/18/2016
 * Revision History:
 * 1. 04/18/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_EncodingConverterTest {

    static ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
   
    static testMethod void testConverterBeforeInsert() {
        
        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('JP Bar Supplier').getRecordTypeId();        

        customer.Name = 'Ｔｅｓｔ1';
        customer.ASI_CRM_Customer_Name_Katakana__c = 'ＴｅｓｔOne';
        customer.ASI_CRM_CN_Phone_Number__c = '０１２３４５６７８９';
        customer.ASI_CRM_Street_Number__c = '９３Ｔ';
        customer.ASI_CRM_Building_Floor_Number__c = '７';
        customer.RecordTypeId = customerRecTypeId;
        
        Test.startTest(); // Starts the scope of test
            insert customer;
        Test.stopTest(); // Ends the scope of test
    }

    static testMethod void testConverterBeforeupdate() {

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('JP Bar Supplier').getRecordTypeId();        

        customer.Name = 'Ｔｅｓｔ1';
        customer.ASI_CRM_Customer_Name_Katakana__c = 'ＴｅｓｔOne';
        customer.ASI_CRM_CN_Phone_Number__c = '０１２３４５６７８９';
        customer.ASI_CRM_Street_Number__c = '９３Ｔ';
        customer.ASI_CRM_Building_Floor_Number__c = '７';
        customer.RecordTypeId = customerRecTypeId;
        
        insert customer;
       
        //customer.Name = 'TEST123';
        customer.ASI_CRM_Customer_Name_Katakana__c = 'TESTONEUPDATED';
        customer.ASI_CRM_CN_Phone_Number__c = '1234567890';
        customer.ASI_CRM_Street_Number__c = '93/AB';
        customer.ASI_CRM_Building_Floor_Number__c = '6';
        
        Test.startTest(); // Starts the scope of test
            update customer;
        Test.stopTest(); // Ends the scope of test
    }
    
    static testMethod void testConverterWithBlankValues() {
        
        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('JP Bar Supplier').getRecordTypeId();        
        
        customer.Name = 'Test25';
        customer.ASI_CRM_Customer_Name_Katakana__c = '';
        customer.ASI_CRM_CN_Phone_Number__c = '';
        customer.ASI_CRM_Street_Number__c = '';
        customer.ASI_CRM_Building_Floor_Number__c = '';
        customer.RecordTypeId = customerRecTypeId;
        
        Test.startTest(); // Starts the scope of test
            insert customer;
        Test.stopTest(); // Ends the scope of test
    }
}