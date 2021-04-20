/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:09/10/2013    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_AP01_Attachment_TEST {

   static testMethod void unitTest() {
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        insert acc;
        
        LAT_MX_CS001_AccountDocuments__c cs001a = new LAT_MX_CS001_AccountDocuments__c(
            Name = 'Form01',
            LAT_MX_RequiredForChannel__c = '"WS"',
            LAT_MX_TextToShow__c = 'Test Missing'
        );
        
        
        LAT_MX_CS001_AccountDocuments__c cs001b = new LAT_MX_CS001_AccountDocuments__c(
            Name = 'Form02',
            LAT_MX_RequiredForChannel__c = 'WS',
            LAT_MX_TextToShow__c = 'Test Missing'
        );
        


        LAT_MX_CS001_AccountDocuments__c cs001c = new LAT_MX_CS001_AccountDocuments__c(
            Name = 'Form03',
            LAT_MX_RequiredForChannel__c = 'WS',
            LAT_MX_TextToShow__c = 'Test Missing'
        );
        insert new List<LAT_MX_CS001_AccountDocuments__c>{cs001a,cs001b,cs001c};
        test.startTest();

        Blob b = Blob.valueOf('Test Data');  
          
        Attachment attach = new Attachment(
            ParentId = acc.Id,
            Name = 'Form01' + acc.Id,
            Body = b
        );  
          
        insert attach;
        
        Attachment attach1 = new Attachment(
            ParentId = acc.Id,
            Name = 'Form02',
            Body = b
        );  
          
        ///insert attach1;
        LAT_MX_AP01_Attachment.UpdatesFieldMissingInformation (new List<Attachment>{attach1,attach}, 'update');
        LAT_MX_AP01_Attachment.UpdatesFieldMissingInformation (new List<Attachment>{attach1,attach}, 'insert');
        test.stopTest(); 
        
   }

}