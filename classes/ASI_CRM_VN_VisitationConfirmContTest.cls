/*
*********************************************************************************
     * Name: ASI_CRM_VN_VisitationConfirmContTest
     * Description: Test Class for ASI_CRM_VN_VisitationConfirmController  
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    ---------------------------------
     * 05/11/2015       Laputa: Neha             Created
********************************************************************************
*/

@isTest
public with sharing class ASI_CRM_VN_VisitationConfirmContTest {
    public static testMethod void visitationConfirmProcessTest() {
    
        PageReference initRedirectPage;
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_VisitationPlanGenerator visitGen = new ASI_HK_CRM_VisitationPlanGenerator();
        ASI_CRM_SG_VisitationPlanDetailGenerator visitDetailGen = new ASI_CRM_SG_VisitationPlanDetailGenerator();
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',emailencodingkey='UTF-8', lastname='Testing', 
                            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id,isactive = true,
                            timezonesidkey='America/Los_Angeles',username='systemadmin@visitationconfirmprocesstest.com');
        
        final Integer numOfAcct = 3;
        List<Account> acctList = new List<Account>();
        for (Integer i = 0; i < numOfAcct; i++) {
              acctList.add(acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT));
        }
        List<ASI_CRM_AccountsAdditionalField__c> customers= new List<ASI_CRM_AccountsAdditionalField__c>();
        if(acctList.size()>0){
              customers = ASI_CRM_VN_TestDataFactory.generateCustomers(acctList.size(),acctList,true,'ASI_CRM_SG_Outlet',
                                                                                    'ASI_CRM_AccountsAdditionalField__c');
        }

        ASI_HK_CRM_Visitation_Plan__c visit = visitGen.generateVisitationPlan();
        insert visit;
        visit = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c FROM ASI_HK_CRM_Visitation_Plan__c 
                                                                                                                WHERE Id = :visit.Id];
        Integer visitYear = Integer.valueOf(visit.ASI_HK_CRM_Year__c);
        Integer visitMonth = ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(visit.ASI_HK_CRM_Month__c);
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Integer countDay = 1;
        for (ASI_CRM_AccountsAdditionalField__c cus : customers) {
              Date visitDate = Date.newInstance(visitYear, visitMonth, countDay);
              ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail = visitDetailGen.generateVisitationPlanDetail(visit, cus, visitDate);
              visitDetails.add(visitDetail);
              countDay++;
        }
        insert visitDetails;
        ApexPages.StandardController stdController = new ApexPages.StandardController(visit);
        
        Test.startTest();
        PageReference testPage = Page.ASI_CRM_VN_VisitationConfirmPage;
        Test.setCurrentPageReference(testPage);
        ASI_CRM_VN_VisitationConfirmController testCon = new ASI_CRM_VN_VisitationConfirmController(stdController);
        System.runAs(u) {
             initRedirectPage = testCon.initPage();
        }
        
        Test.stopTest();
    }
    
    public static testMethod void visitationContactManagerTest() {
        PageReference initRedirectPage;
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_VisitationPlanGenerator visitGen = new ASI_HK_CRM_VisitationPlanGenerator();
        ASI_CRM_SG_VisitationPlanDetailGenerator visitDetailGen = new ASI_CRM_SG_VisitationPlanDetailGenerator();
       
        final Integer numOfAcct = 3;
        List<Account> acctList = new List<Account>();
        for (Integer i = 0; i < numOfAcct; i++) {
          acctList.add(acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT));
        }
        List<ASI_CRM_AccountsAdditionalField__c> customers= new List<ASI_CRM_AccountsAdditionalField__c>();
        if(acctList.size()>0){
            customers = ASI_CRM_VN_TestDataFactory.generateCustomers(acctList.size(),acctList,true,'ASI_CRM_SG_Outlet',
                                                                                    'ASI_CRM_AccountsAdditionalField__c');
        }

        ASI_HK_CRM_Visitation_Plan__c visit = visitGen.generateVisitationPlan();
        insert visit;
        visit = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c FROM ASI_HK_CRM_Visitation_Plan__c 
                                                                                                                WHERE Id = :visit.Id];
        Integer visitYear = Integer.valueOf(visit.ASI_HK_CRM_Year__c);
        Integer visitMonth = ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(visit.ASI_HK_CRM_Month__c);
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Integer countDay = 1;
        for (ASI_CRM_AccountsAdditionalField__c cus : customers) {
          Date visitDate = Date.newInstance(visitYear, visitMonth, countDay);
          ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail = visitDetailGen.generateVisitationPlanDetail(visit, cus, visitDate);
          visitDetails.add(visitDetail);
          countDay++;
        }
        insert visitDetails;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(visit);
        
        Test.startTest();
        PageReference testPage = Page.ASI_CRM_VN_VisitationConfirmPage;
        Test.setCurrentPageReference(testPage);
        ASI_CRM_VN_VisitationConfirmController testCon = new ASI_CRM_VN_VisitationConfirmController(stdController);
        
        initRedirectPage = testCon.initPage();
       
        Test.stopTest();
        System.assertEquals(null, initRedirectPage );
    }
    
     public static testMethod void visitationAlreadyConfirmedTest() {
        PageReference initRedirectPage;
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_VisitationPlanGenerator visitGen = new ASI_HK_CRM_VisitationPlanGenerator();
        ASI_CRM_SG_VisitationPlanDetailGenerator visitDetailGen = new ASI_CRM_SG_VisitationPlanDetailGenerator();
         Profile p = [select id from profile where name='System Administrator'];
          User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', 
                            languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id,isactive = true ,
                            timezonesidkey='America/Los_Angeles',
                            username='systemadmin@visitationalreadyconfirmedtest.com');
        final Integer numOfAcct = 3;
        List<Account> acctList = new List<Account>();
        for (Integer i = 0; i < numOfAcct; i++) {
          acctList.add(acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT));
        }
        List<ASI_CRM_AccountsAdditionalField__c> customers= new List<ASI_CRM_AccountsAdditionalField__c>();
        if(acctList.size()>0){
            customers = ASI_CRM_VN_TestDataFactory.generateCustomers(acctList.size(),acctList,true,'ASI_CRM_SG_Outlet',
                                                                                        'ASI_CRM_AccountsAdditionalField__c');
        }

        ASI_HK_CRM_Visitation_Plan__c visit = visitGen.generateVisitationPlan();
        insert visit;
        visit = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c FROM ASI_HK_CRM_Visitation_Plan__c 
                                                                                                        WHERE Id = :visit.Id];
        Integer visitYear = Integer.valueOf(visit.ASI_HK_CRM_Year__c);
        Integer visitMonth = ASI_HK_CRM_VisitationPlanGenerator.convertMonthPLValueToInteger(visit.ASI_HK_CRM_Month__c);
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitDetails = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Integer countDay = 1;
        for (ASI_CRM_AccountsAdditionalField__c cus : customers) {
          Date visitDate = Date.newInstance(visitYear, visitMonth, countDay);
          ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail = visitDetailGen.generateVisitationPlanDetail(visit, cus, visitDate);
          visitDetails.add(visitDetail);
          countDay++;
        }
        insert visitDetails;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(visit);
        Test.startTest();
        
        PageReference testPage = Page.ASI_CRM_VN_VisitationConfirmPage;
        Test.setCurrentPageReference(testPage);
        ASI_CRM_VN_VisitationConfirmController testCon = new ASI_CRM_VN_VisitationConfirmController(stdController);
        System.runAs(u) {
        
        testCon.initPage();
        
        visit = [SELECT Id, Name, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c, ASI_HK_CRM_Confirmed__c FROM ASI_HK_CRM_Visitation_Plan__c 
                                                                                                                WHERE Id = :visit.Id];
        stdController = new ApexPages.StandardController(visit);
        testCon = new ASI_CRM_VN_VisitationConfirmController(stdController);
        
        initRedirectPage = testCon.initPage();
        }
        
        Test.stopTest();
        System.assertEquals(null, initRedirectPage );
    }
     
}