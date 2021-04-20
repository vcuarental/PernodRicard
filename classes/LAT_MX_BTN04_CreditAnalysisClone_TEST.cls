/**********************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                        *                                                                                      *
*   Date:09/10/2013     Descripcion: Clase test de la clase LAT_MX_BTN04_CreditAnalysisClone                                        *
***********************************************************************************************************************************/

@isTest

public with sharing class LAT_MX_BTN04_CreditAnalysisClone_TEST {
    static testmethod void unitTest(){
                                
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'NME970625KP9',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        test.startTest();
        
        LAT_MX_PMN_PromissoryNote__c pagare = new LAT_MX_PMN_PromissoryNote__c(
            LAT_MX_Executor__c = acc.Id
        );
        
        insert pagare;
        
        CRA_CredAnalysis_ARG__c cra = new CRA_CredAnalysis_ARG__c(
            SalesmanComments_ARG__c = 'test',
            CreditAnalystComment_ARG__c = 'test',
            LastFinancialPresentedDate_ARG__c = date.today(),
            LAT_MX_PromissoryNoteNumber__c = pagare.Id,
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
            RecordTypeId = Global_RecordTypeCache.getRtId('CRA_CredAnalysis_ARG__c' + 'LAT_MX_CRA_Standard')
        );
        
        insert cra;
        
        LAT_MX_BTN04_CreditAnalysisClone.CloneCreditAnalysis(cra.Id);
        
        List<CS002_FIeldsIds__c> Listcs002 = new List<CS002_FIeldsIds__c>();
        
        CS002_FIeldsIds__c cs002_1 = new CS002_FIeldsIds__c(
            FieldApiName__c='Account_ARG__c',
            Name = 'name1',
            FieldId__c= '0001',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_1);

        CS002_FIeldsIds__c cs002_2 = new CS002_FIeldsIds__c(
            FieldApiName__c='SalesmanComments_ARG__c',
            Name = 'name2',
            FieldId__c= '0002',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_2);

        CS002_FIeldsIds__c cs002_3 = new CS002_FIeldsIds__c(
            FieldApiName__c='CreditAnalystComment_ARG__c',
            Name = 'name3',
            FieldId__c= '0003',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_3);

        CS002_FIeldsIds__c cs002_4 = new CS002_FIeldsIds__c(
            FieldApiName__c='LastFinancialPresentedDate_ARG__c',
            Name = 'name4',
            FieldId__c= '0004',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_4);
        
        CS002_FIeldsIds__c cs002_5 = new CS002_FIeldsIds__c(
            FieldApiName__c='CommercialGuarantee_ARG__c',
            Name = 'name5',
            FieldId__c= '0005',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_5);
        
        CS002_FIeldsIds__c cs002_6 = new CS002_FIeldsIds__c(
            FieldApiName__c='CommercialGuarantExpDate_ARG__c',
            Name = 'name6',
            FieldId__c= '0006',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_6);
        
        CS002_FIeldsIds__c cs002_7 = new CS002_FIeldsIds__c(
            FieldApiName__c='CreditRiskIndex_ARG__c',
            Name = 'name7',
            FieldId__c= '0007',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_7);
        
        CS002_FIeldsIds__c cs002_8 = new CS002_FIeldsIds__c(
            FieldApiName__c='RevisionDate_ARG__c',
            Name = 'name8',
            FieldId__c= '0008',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_8);
        
        CS002_FIeldsIds__c cs002_9 = new CS002_FIeldsIds__c(
            FieldApiName__c='LastCreditReview_ARG__c',
            Name = 'name9',
            FieldId__c= '0009',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_9);
        
        CS002_FIeldsIds__c cs002_10 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_PromissoryNoteNumber__c',
            Name = 'name10',
            FieldId__c= '0010',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
        
        Listcs002.add(cs002_10);
        
        CS002_FIeldsIds__c cs002_11 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_Deposit__c',
            Name = 'name11',
            FieldId__c= '0011',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
               
        Listcs002.add(cs002_11);
        
        CS002_FIeldsIds__c cs002_12 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_Mortgage__c',
            Name = 'name12',
            FieldId__c= '0012',
            ObjectApiName__c='CRA_CredAnalysis_ARG__c'
        );
               
        Listcs002.add(cs002_12);
                
        insert Listcs002;
                      
        LAT_MX_BTN04_CreditAnalysisClone.CloneCreditAnalysis(cra.Id);
        
        test.stopTest();   
        
    }
}