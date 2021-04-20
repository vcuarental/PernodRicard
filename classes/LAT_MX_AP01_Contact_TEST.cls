/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:19/02/2014    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_AP01_Contact_TEST {

    static testMethod void unitTest1() {
        
        setup();

        Account acc1 = new Account(
            Name = 'TEST1',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')
        );
        
        Account acc2 = new Account(
            Name = 'TEST2',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'KME020731UDA',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Company',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')
        );
        
        insert new List<Account>{acc1,acc2};
        
        test.startTest();
        
        Contact con = new Contact(
            AccountId = acc1.Id,
            FirstName = 'test',
            LastName = 'test',
            Description = 'Desc 1',
            RecordTypeId = Global_RecordTypeCache.getRtId('Contact' + 'LAT_MX_CTC_Standard')
        );
        
        insert con;
        
        con.AccountId = acc2.Id;
        
        update con;

        test.stopTest();          
    }
    
    static testMethod void unitTest2() {
        
        setup();

        Account acc1 = new Account(
            Name = 'TEST1',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')
        );
        
        insert acc1;
                  
        test.startTest();
        
        Contact con = new Contact(
            AccountId = acc1.Id,
            FirstName = 'test',
            LastName = 'test',
            Description = 'Desc 1',
            RecordTypeId = Global_RecordTypeCache.getRtId('Contact' + 'LAT_MX_CTC_Standard')
        );
        
        insert con;
        
        delete con;

        test.stopTest();          
    }

    public static void setup(){

        LAT_GeneralConfig__c cs = new LAT_GeneralConfig__c(
                      Name = 'MX_ON_TRADE_NO_KAM_USERS',
                    LAT_Value__c = 'Luis Fernando Gonzalez');
        insert cs;
    }
    
}