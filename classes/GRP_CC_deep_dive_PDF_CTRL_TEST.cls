@isTest
public with sharing class GRP_CC_deep_dive_PDF_CTRL_TEST {

    @TestSetup
    static void makeData() {
        CORE_Region__c region = new CORE_Region__c();
        region.Name = 'EMEA';
        insert region;

        CORE_Country__c country = new CORE_Country__c();
        country.Name = 'test Country';
        country.CORE_Region__c = region.Id;
        insert country;

        GRP_CC_Group__c group1 = new GRP_CC_Group__c();
        group1.Name = 'group';
        group1.GRP_CC_GroupeResponsible__c = 'zegfze@zgesd.ciom';
        group1.GRP_CC_Domain__c = 'sdgsdg';
        insert group1;

        GRP_CC_Chain__c chain = new GRP_CC_Chain__c();
        chain.Name = 'test Chain';
        chain.GRP_CC_Group__c = group1.Id;
        insert chain;

        GRP_CC_ChainAccount__c chainAccount = new GRP_CC_ChainAccount__c();
        chainAccount.Name = 'test ChainAccount';
        chainAccount.GRP_CC_ChainAccountResponsible__c = 'test.chainAccount@pernod-ricard.com';
        chainAccount.GRP_CC_Chain__c = chain.Id;
        chainAccount.GRP_CC_Country__c = country.Id;
        chainAccount.GRP_CC_Region__c = region.Id;
        insert chainAccount;

        GRP_CC_Deep_dive__c deepDive = new GRP_CC_Deep_dive__c();
        deepDive.Name = 'test deepDive';
        deepDive.GRP_CC_Chain_Account__c = chainAccount.Id;
        insert deepDive;
    }

    @isTest
    static void testInit() {
        GRP_CC_Deep_dive__c deepDive = [SELECT Id, GRP_CC_Chain_Account__r.Name FROM GRP_CC_Deep_dive__c WHERE Name = 'test deepDive'];
        ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(deepDive);
        ApexPages.currentPage().getParameters().put('id', deepDive.Id);
        Test.startTest();
        GRP_CC_deep_dive_PDF_CTRL deepDivePDFCtrl = new GRP_CC_deep_dive_PDF_CTRL(sc2);
        Test.stopTest();
    }

}