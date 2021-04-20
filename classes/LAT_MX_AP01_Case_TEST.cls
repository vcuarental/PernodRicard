/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:09/10/2013    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@istest
public with sharing class LAT_MX_AP01_Case_TEST {

   static testMethod void unitTest() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        String UserId = UserInfo.getUserId();
        
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
            RecordTypeId = rtOffMX,    
            LAT_MX_CreditAndCollectionsExecutive__c = UserId
        );
        try{insert acc;} catch(exception e){}
        
        String rtCase = Global_RecordTypeCache.getRtId('Case' + 'LAT_MX_CSE_AccountAlterationCreditAndCollections');
        
        Case caso = new Case(
            AccountId = acc.Id,
            RecordTypeId = rtCase,
            Type = 'Credits and Collections',
            Reason = 'Registration deposit cash payment',
            Origin = 'Demanda Interna PRB',
            Status = 'Novo',
            Description = 'test'
        );
        
        try{insert caso;} catch(exception e){}
                
        String userName = UserInfo.getUserName();
        
        CS006_DefaultUsers__c CsUserId = new CS006_DefaultUsers__c(
            Name = 'test',
            LAT_MX_UserName1__c = userName
        );
        
        try{insert CsUserId;} catch(exception e){}
        
        Case caso1 = new Case(
            AccountId = acc.Id,
            RecordTypeId = rtCase,
            Type = 'Credits and Collections',
            Reason = 'Payment Term Modification',
            Origin = 'Demanda Interna PRB',
            Status = 'Novo',
            Description = 'test'
        );
        
        try{insert caso1;} catch(exception e){}
        
        test.startTest();
        
        acc.LAT_MX_CreditAndCollectionsExecutive__c = null;
        acc.Channel__c = 'SS';
        try{update acc;} catch(exception e){}
        
         Case caso2 = new Case(
            AccountId = acc.Id,
            RecordTypeId = rtCase,
            Type = 'Credits and Collections',
            Reason = 'Payment Term Modification',
            Origin = 'Demanda Interna PRB',
            Status = 'Novo',
            Description = 'test'
        );
        
        try{insert caso2;} catch(exception e){}   
        
        test.stopTest();        
              
   }
   //MIGRATED 21/11/2016
   static testMethod void unitTestLATCase() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        String UserId = UserInfo.getUserId();
        
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
            RecordTypeId = rtOffMX,    
            LAT_MX_CreditAndCollectionsExecutive__c = UserId
        );
        try{insert acc;} catch(exception e){}
        
        String rtCase = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'LAT_MX_CSE_AccountAlterationCreditAndCollections');
        
        LAT_Case__c caso = new LAT_Case__c(
            LAT_Account__c = acc.Id,
            RecordTypeId = rtCase,
            LAT_Type__c = 'Credits and Collections',
            LAT_Reason__c = 'Registration deposit cash payment',
            LAT_Origin__c = 'Demanda Interna PRB',
            LAT_Status__c = 'Novo',
            LAT_Description__c = 'test'
        );
        
        try{insert caso;} catch(exception e){}
                
        String userName = UserInfo.getUserName();
        
        CS006_DefaultUsers__c CsUserId = new CS006_DefaultUsers__c(
            Name = 'test',
            LAT_MX_UserName1__c = userName
        );
        
        try{insert CsUserId;} catch(exception e){}
        
        LAT_Case__c caso1 = new LAT_Case__c(
            LAT_Account__c = acc.Id,
            RecordTypeId = rtCase,
            LAT_Type__c = 'Credits and Collections',
            LAT_Reason__c = 'Payment Term Modification',
            LAT_Origin__c = 'Demanda Interna PRB',
            LAT_Status__c = 'Novo',
            LAT_Description__c = 'test'
        );
        
        try{insert caso1;} catch(exception e){}
        
        test.startTest();
        
        acc.LAT_MX_CreditAndCollectionsExecutive__c = null;
        acc.Channel__c = 'SS';
        try{update acc;} catch(exception e){}
        
         LAT_Case__c caso2 = new LAT_Case__c(
            LAT_Account__c = acc.Id,
            RecordTypeId = rtCase,
            LAT_Type__c = 'Credits and Collections',
            LAT_Reason__c = 'Payment Term Modification',
            LAT_Origin__c = 'Demanda Interna PRB',
            LAT_Status__c = 'Novo',
            LAT_Description__c = 'test'
        );
        
        try{insert caso2;} catch(exception e){}   
        
        test.stopTest();        
              
   }
}