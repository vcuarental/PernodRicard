@isTest
public with sharing class ASI_CRM_SG_WholesalerAgreementCtrTest {
    static testMethod void testMethod1()
    {
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.Name = 'TestCase1';
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__c'+'ASI_CRM_SG_Wholesaler');
        customer.ASI_CRM_Wholesaler_Type__c = 'Key Wholesaler';
        insert customer;

        ASI_CRM_AccountsAdditionalField__c customer_SG_Outlet = new ASI_CRM_AccountsAdditionalField__c();
        customer_SG_Outlet.Name = 'SG_Outlet';
        customer_SG_Outlet.ASI_CRM_CN_Parent_Outlet__c = customer.id;
        customer_SG_Outlet.ASI_CRM_Business_Registration_Number__c = 'Testing 123';
        customer_SG_Outlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__c'+'ASI_CRM_SG_Outlet');
        insert customer_SG_Outlet;
        
        PageReference pageRef = Page.ASI_CRM_SG_GenWholesalerAgreementPDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Today','Today');
        ApexPages.currentPage().getParameters().put('currentDay','currentDay');
        ApexPages.currentPage().getParameters().put('currentP60Days','currentP60Days');
        ApexPages.currentPage().getParameters().put('customDate','customDate');
        ApexPages.currentPage().getParameters().put('customMonth','customMonth');
        ApexPages.currentPage().getParameters().put('money1','money1');
        ApexPages.currentPage().getParameters().put('money2','money2');
        ApexPages.currentPage().getParameters().put('money3','money3');
        ApexPages.currentPage().getParameters().put('money4','money4');
        ApexPages.currentPage().getParameters().put('recordId',customer.Id);

        ASI_CRM_SG_WholesalerAgreementCtr testClass = new ASI_CRM_SG_WholesalerAgreementCtr();

        ASI_CRM_SG_WholesalerAgreementCtr.customerWithRN testClass2 = ASI_CRM_SG_WholesalerAgreementCtr.getCustomerInfo(customer.Id);

    }
}