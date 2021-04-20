/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:09/10/2013    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_AP01_CreditAnalysis_TEST {

   static testMethod void unitTest1() {

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
        try{insert acc;} catch(exception e){}
        
        String rtCraOffMX = Global_RecordTypeCache.getRtId('CRA_CredAnalysis_ARG__c' + 'LAT_MX_CRA_Standard');
        
        CRA_CredAnalysis_ARG__c cra = new CRA_CredAnalysis_ARG__c(
            SalesmanComments_ARG__c = 'test',
            CreditAnalystComment_ARG__c = 'test',
            LastFinancialPresentedDate_ARG__c = date.today(),
            Account_ARG__c = acc.Id,
            CommercialGuarantee_ARG__c = true, 
            CommercialGuarantExpDate_ARG__c = date.today(),
            CreditRiskIndex_ARG__c = '03',
            RevisionDate_ARG__c = date.today(),
            LastCreditReview_ARG__c = date.today(),
            LAT_MX_Deposit__c = 1000,
            LAT_MX_Mortgage__c = 1000,
            CreditLimitRequested_ARG__c = 100,
            CreditLimitGranted_ARG__c = 100,
            LAT_MX_ApprovalProcessAproved__c = false,
            RecordTypeId = rtCraOffMX
        );
        
        try{insert cra;} catch(exception e){}
        
        test.startTest();
        
        try{update cra;} catch(exception e){}
        
        
        LAT_MX_CLA_CreditLimitAudit__c creditAudit = new LAT_MX_CLA_CreditLimitAudit__c(
            LAT_MX_Reason__c = 'test',
            LAT_MX_ThresholdValue__c = 90
            
        );
        
        try{insert creditAudit;} catch(exception e){}
        
        cra.LAT_MX_ApprovalProcessAproved__c = true;
        try{update cra;} catch(exception e){}
        
        cra.CreditLimitGranted_ARG__c = 80;
        try{update cra;} catch(exception e){}
        
        test.stopTest(); 
        
   }

   static testMethod void unitTest2() {

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
        try{insert acc;} catch(exception e){}
        
        String rtCraOffMX = Global_RecordTypeCache.getRtId('CRA_CredAnalysis_ARG__c' + 'LAT_MX_CRA_Standard');
        
        CRA_CredAnalysis_ARG__c cra = new CRA_CredAnalysis_ARG__c(
            SalesmanComments_ARG__c = 'test',
            CreditAnalystComment_ARG__c = 'test',
            LastFinancialPresentedDate_ARG__c = date.today(),
            Account_ARG__c = acc.Id,
            CommercialGuarantee_ARG__c = true, 
            CommercialGuarantExpDate_ARG__c = date.today(),
            CreditRiskIndex_ARG__c = '03',
            RevisionDate_ARG__c = date.today(),
            LastCreditReview_ARG__c = date.today(),
            LAT_MX_Deposit__c = 1000,
            LAT_MX_Mortgage__c = 1000,
            CreditLimitRequested_ARG__c = 100,
            CreditLimitGranted_ARG__c = 100,
            LAT_MX_ApprovalProcessAproved__c = false,
            RecordTypeId = rtCraOffMX
        );
        
        try{insert cra;} catch(exception e){}
        
        test.startTest();
        
        acc.Channel__c = 'SS';
        try{update acc;} catch(exception e){}
        
        String userName = UserInfo.getUserName();
        
        CS006_DefaultUsers__c CsUserId = new CS006_DefaultUsers__c(
            Name = 'test',
            LAT_MX_UserName2__c = UserName,
            LAT_MX_UserName1__c = UserName
        );
        
        try{insert CsUserId;} catch(exception e){}

        CRA_CredAnalysis_ARG__c cra1 = new CRA_CredAnalysis_ARG__c(
            SalesmanComments_ARG__c = 'test',
            CreditAnalystComment_ARG__c = 'test',
            LastFinancialPresentedDate_ARG__c = date.today(),
            Account_ARG__c = acc.Id,
            CommercialGuarantee_ARG__c = true, 
            CommercialGuarantExpDate_ARG__c = date.today(),
            CreditRiskIndex_ARG__c = '03',
            RevisionDate_ARG__c = date.today(),
            LastCreditReview_ARG__c = date.today(),
            LAT_MX_Deposit__c = 1000,
            LAT_MX_Mortgage__c = 1000,
            CreditLimitRequested_ARG__c = 100,
            CreditLimitGranted_ARG__c = 100,
            LAT_MX_ApprovalProcessAproved__c = false,
            RecordTypeId = rtCraOffMX
        );
        
        try{insert cra1;} catch(exception e){}

        acc.Channel__c = 'WS';
        try{update acc;} catch(exception e){}

        CRA_CredAnalysis_ARG__c cra2 = new CRA_CredAnalysis_ARG__c(
            SalesmanComments_ARG__c = 'test',
            CreditAnalystComment_ARG__c = 'test',
            LastFinancialPresentedDate_ARG__c = date.today(),
            Account_ARG__c = acc.Id,
            CommercialGuarantee_ARG__c = true, 
            CommercialGuarantExpDate_ARG__c = date.today(),
            CreditRiskIndex_ARG__c = '03',
            RevisionDate_ARG__c = date.today(),
            LastCreditReview_ARG__c = date.today(),
            LAT_MX_Deposit__c = 1000,
            LAT_MX_Mortgage__c = 1000,
            CreditLimitRequested_ARG__c = 100,
            CreditLimitGranted_ARG__c = 100,
            LAT_MX_ApprovalProcessAproved__c = false,
            RecordTypeId = rtCraOffMX
        );
        
        try{insert cra2;} catch(exception e){}

        String UserId = UserInfo.getUserId();
                
        acc.LAT_MX_CreditAndCollectionsExecutive__c = UserId;
        try{update acc;} catch(exception e){}

        CRA_CredAnalysis_ARG__c cra3 = new CRA_CredAnalysis_ARG__c(
            SalesmanComments_ARG__c = 'test',
            CreditAnalystComment_ARG__c = 'test',
            LastFinancialPresentedDate_ARG__c = date.today(),
            Account_ARG__c = acc.Id,
            CommercialGuarantee_ARG__c = true, 
            CommercialGuarantExpDate_ARG__c = date.today(),
            CreditRiskIndex_ARG__c = '03',
            RevisionDate_ARG__c = date.today(),
            LastCreditReview_ARG__c = date.today(),
            LAT_MX_Deposit__c = 1000,
            LAT_MX_Mortgage__c = 1000,
            CreditLimitRequested_ARG__c = 100,
            CreditLimitGranted_ARG__c = 100,
            LAT_MX_ApprovalProcessAproved__c = false,
            RecordTypeId = rtCraOffMX
        );
        
        try{insert cra3;} catch(exception e){}
        
        test.stopTest();      
        
   }
}