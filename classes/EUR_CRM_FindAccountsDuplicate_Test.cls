@isTest

public class EUR_CRM_FindAccountsDuplicate_Test {

    @TestSetup
    static void setup() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> duplicateAccounts = new List<EUR_CRM_Account__c>();
        List<Contact> contacts = new List<Contact>();
        List<EUR_CRM_PRS_Segmentation__c> PRSSegmentationList = new List<EUR_CRM_PRS_Segmentation__c>();
        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackingList = new List<EUR_CRM_Competitor_Promo_Tracking__c>();
        List<EUR_CRM_Sales_Order__c> salesOrderList = new List<EUR_CRM_Sales_Order__c>();
        List<EUR_CRM_Visit__c> visitList = new List<EUR_CRM_Visit__c>();
        List<EUR_CRM_Account_in_Target_Group__c> AccountInTargetGroupList = new List<EUR_CRM_Account_in_Target_Group__c>();
        EUR_CRM_Account_Target_Group__c AccountTargetGroup = new EUR_CRM_Account_Target_Group__c(Name = 'TestTargetGroup');
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c();
        EUR_CRM_Find_Accounts_Duplicate_Keys__c customSettingSearchKey = new EUR_CRM_Find_Accounts_Duplicate_Keys__c();
        customSettingSearchKey.Name = 'aWn0Q0000008OI5';
        customSettingSearchKey.keys__c = 'Name, EUR_CRM_Street__c, EUR_CRM_City__c, EUR_CRM_Email__c';
        insert customSettingSearchKey;
        for (Integer i = 0; i < 2; i++) {
            acc = new EUR_CRM_Account__c(Name = 'N\'am\'e 12\'!"№;%:?*()_ЄЖ,ЮБ, 4', EUR_CRM_Postal_Code__c = '0000' + i);
            accounts.add(acc);
            acc = new EUR_CRM_Account__c(Name = '_', EUR_CRM_Postal_Code__c = '0001' + i, EUR_CRM_City__c = 'TestCity', EUR_CRM_Street__c = 'Street');
            accounts.add(acc);
        }

        insert accounts;
        insert AccountTargetGroup;

        for (Integer i = 0; i < 4; i++) {
            contacts.add(new Contact(LastName = 'TestContact', AssistantPhone = ('131231' + i), EUR_CRM_Account__c = accounts.get(i).Id));
            PRSSegmentationList.add(new EUR_CRM_PRS_Segmentation__c(EUR_CRM_Account__c = accounts.get(i).Id));
            competitorPromoTrackingList.add(new EUR_CRM_Competitor_Promo_Tracking__c(EUR_CRM_Account_Name__c = accounts.get(i).Id));
            salesOrderList.add(new EUR_CRM_Sales_Order__c(EUR_CRM_Account__c = accounts.get(i).Id));
            visitList.add(new EUR_CRM_Visit__c(EUR_CRM_Account__c = accounts.get(i).Id));
            AccountInTargetGroupList.add(new EUR_CRM_Account_in_Target_Group__c(EUR_CRM_Account__c = accounts.get(i).Id, EUR_CRM_Account_Target_Group__c = AccountTargetGroup.Id));
        }

        insert contacts;
        insert PRSSegmentationList;
        insert competitorPromoTrackingList;
        insert salesOrderList;
        insert visitList;
        insert AccountInTargetGroupList;
        duplicateAccounts = accounts;

    }

    @IsTest static void testMethod1() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_FindAccountsDuplicate());
        Test.stopTest();
        System.debug([SELECT Id,EUR_CRM_Postal_Code__c, Name FROM EUR_CRM_Account__c]);
        System.assertEquals(2, [SELECT COUNT() FROM EUR_CRM_Account__c]);
        System.assertEquals(2, [SELECT COUNT() FROM Contact]);
        System.assertEquals(2, [SELECT COUNT() FROM EUR_CRM_PRS_Segmentation__c]);
        System.assertEquals(4, [SELECT COUNT() FROM EUR_CRM_Competitor_Promo_Tracking__c]);

    }

    @IsTest static void testMethod2() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : [SELECT Id, Name, EUR_CRM_City__c, EUR_CRM_Street__c, EUR_CRM_Email__c FROM EUR_CRM_Account__c]) {
            acc.Name = 'Test';
            acc.EUR_CRM_City__c = 'Test';
            acc.EUR_CRM_Street__c = 'Test';
            acc.EUR_CRM_Email__c = 'Test@gmail.com';
            accounts.add(acc);
        }
        update accounts;
        Test.startTest();
        Database.executeBatch(new EUR_CRM_FindAccountsDuplicate());
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM EUR_CRM_Account__c]);
    }

    @IsTest static void testMethod3() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : [SELECT Id, Name, EUR_CRM_City__c, EUR_CRM_Street__c, EUR_CRM_Email__c FROM EUR_CRM_Account__c]) {
            acc.Name = 'Test';
            acc.EUR_CRM_City__c = null;
            acc.EUR_CRM_Street__c = null;
            acc.EUR_CRM_Email__c = null;
            accounts.add(acc);
        }
        update accounts;
        Test.startTest();
        Database.executeBatch(new EUR_CRM_FindAccountsDuplicate());
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM EUR_CRM_Account__c]);
    }
    @IsTest static void testMethod4() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_PRS_Segmentation__c> pRSSegmentationList = new List<EUR_CRM_PRS_Segmentation__c>();
        List<Contact> contacts = new List<Contact>();
        for (EUR_CRM_PRS_Segmentation__c segmentation : [SELECT Id FROM EUR_CRM_PRS_Segmentation__c LIMIT 3]) {
            pRSSegmentationList.add(segmentation);
        }
        for (Contact contact : [SELECT Id FROM Contact LIMIT 3]) {
            contacts.add(contact);
        }
        delete pRSSegmentationList;
        delete contacts;
        Test.startTest();
        Database.executeBatch(new EUR_CRM_FindAccountsDuplicate());
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM EUR_CRM_Account__c]);
    }
    @IsTest static void testMethod5() {
        delete [SELECT Id FROM Contact];
        delete [SELECT Id FROM EUR_CRM_PRS_Segmentation__c];
        delete [SELECT Id FROM EUR_CRM_Competitor_Promo_Tracking__c];
        delete [SELECT Id FROM EUR_CRM_Sales_Order__c];
        delete [SELECT Id FROM EUR_CRM_Visit__c];
        delete [SELECT Id FROM EUR_CRM_Account_in_Target_Group__c];
        delete [SELECT Id FROM EUR_CRM_Account_Target_Group__c];
        Test.startTest();
        Database.executeBatch(new EUR_CRM_FindAccountsDuplicate());
        Test.stopTest();
        System.debug([SELECT Id,EUR_CRM_Postal_Code__c, Name FROM EUR_CRM_Account__c]);
        System.assertEquals(2, [SELECT COUNT() FROM EUR_CRM_Account__c]);


    }



}