/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:12/09/2013    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_AP01_Account_TEST {

    


    static testMethod void unitTest1() {
            
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E528',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;} catch(exception e){}
        
        System.test.startTest();
        
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        acc.CNPJ__c = 'LOZM701213E52';
        
        try{update acc;} catch(exception e){}

        /*acc.LAT_MX_FiscalEntityType__c = 'Company';
        acc.CNPJ__c = 'LOZM701213E52';
            
        try{update acc;} catch(exception e){}
        
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        acc.CNPJ__c = 'LOZM701213E5(';
        
        try{update acc;} catch(exception e){}
        
        acc.LAT_MX_FiscalEntityType__c = 'Company';
        
        try{update acc;} catch(exception e){}
        
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        acc.CNPJ__c = 'LOZM701213E56';
        
        try{update acc;} catch(exception e){} 
        
        acc.CNPJ__c = 'LOZM701213E5643';
        
        try{update acc;} catch(exception e){}         
        
        acc.CNPJ__c =  'IAW741112UY9';
        acc.LAT_MX_FiscalEntityType__c = 'Company';
        
        try{update acc;} catch(exception e){}
        
        acc.CNPJ__c =  'IAW741112UY93';
        acc.LAT_MX_FiscalEntityType__c = 'Company';
        
        try{update acc;} catch(exception e){}
        
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
          
        try{update acc;} catch(exception e){}
        
        acc.LAT_MX_FiscalEntityType__c = 'Company';
        acc.CNPJ__c =  'IAW741112UY3';     

        try{update acc;} catch(exception e){}  

        acc.CNPJ__c =  'IAW741112UY3234';     

        try{update acc;} catch(exception e){} */
        LAT_MX_AP01_Account.validatesAN8BeforeDeletion(new List<Account>{acc});
        System.test.stopTest();          
    }
   
    static testMethod void unitTest2() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
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
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
        
        Account acc2 = new Account(
            Name = 'TEST',
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
            ParentId = acc.Id,
            RecordTypeId = rtOffMX
        );
        try{insert acc2;} catch(exception e){}
        
        System.test.startTest();
        
        acc2.Type = 'Consignee';
        
        try{insert acc2;}catch(exception e){}
        
        System.test.stopTest();  
            
    }
    @istest
    static  void unitTest3() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
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
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
        
        Account acc2 = new Account(
            Name = 'TEST',
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
            ParentId = acc.Id,
            RecordTypeId = rtOffMX
        );
        try{insert acc2;} catch(exception e){}
        
        System.test.startTest();
        
        acc.SaveDuplicatedFiscalID_AR__c = true;
        
        try{insert acc2;} catch(exception e){} 
        
        System.test.stopTest(); 
    
    }
   
    @istest
    static void unitTest4() {
    
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');

        LAT_MX_CS001_AccountDocuments__c cs001 = new LAT_MX_CS001_AccountDocuments__c(
            Name = 'test',
            LAT_MX_RequiredForChannel__c = '"WS"',
            LAT_MX_TextToShow__c = 'Test Missing'
        );
        
        try{insert cs001;}catch(exception e){}

        LAT_MX_CS001_AccountDocuments__c cs001b = new LAT_MX_CS001_AccountDocuments__c(
            Name = 'test2',
            LAT_MX_RequiredForChannel__c = '"WS"',
            LAT_MX_TextToShow__c = 'Test Missing2'
        );
        
        try{insert cs001b;}catch(exception e){}
        
        Account acc = new Account(
            Name = 'TEST',
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
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
    
        LAT_MX_CS001_AccountDocuments__c cs001c = new LAT_MX_CS001_AccountDocuments__c(
            Name = 'test3',
            LAT_MX_RequiredForChannel__c = '"WS"',
            LAT_MX_TextToShow__c = 'Test Missing2'
        );
        
        try{insert cs001c;}catch(exception e){}
        
        System.test.startTest();
        
        try{update acc;}catch(exception e){}
        
        System.test.stopTest();

    }
    
    @istest
    static void unitTest5() {
    
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Activo MX',
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
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
        
        System.test.startTest();
        
        acc.Status__c = 'Directed to be registered In JDE';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Cliente cadastrado no JDE';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Inactive Account';
        
        try{update acc;} catch(exception e){}
        
        acc.Other_Notes__c = 'test';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Being reactivated';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Modification requested in CRM';
        
        try{update acc;}catch(exception e){}
        
        System.test.stopTest();
        
        
    }
    @istest
    static  void unitTest5B() {
    
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
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
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
        
        System.test.startTest();
        
        acc.Status__c = 'Directed to be registered In JDE';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Cliente cadastrado no JDE';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Inactive Account';
        
        try{update acc;} catch(exception e){}
        
        acc.Other_Notes__c = 'test';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Being reactivated';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Modification requested in CRM';
        
        try{update acc;}catch(exception e){}
        
        System.test.stopTest();
        
        
    }
        
    static testMethod void unitTest6() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        String rtPostalCode = Global_RecordTypeCache.getRtId('LAT_MX_PCD_PostalCode__c' + 'LAT_MX_PCD_Standard');
        
        LAT_MX_PCD_PostalCode__c pc = new LAT_MX_PCD_PostalCode__c(
            Name = '100',
            RecordTypeId = rtPostalCode,
            LAT_MX_NilsenArea__c = 'test'
        );
        
        try{insert pc;}catch(exception e){}
        
        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        
        UDC__c udc = new UDC__c(
            Name = pc.LAT_MX_NilsenArea__c,
            Internal_Id__c = '1',
            CodProd__c = '01',
            CodUs__c = '04',
            RecordTypeId = rtUDC                    
        );
        
        try{insert udc;}catch(exception e){}
        
        UDC__c udc2 = new UDC__c(
            Name = 'test',
            Internal_Id__c = '2',
            CodProd__c = '01',
            CodUs__c = '11',
            RecordTypeId = rtUDC          
        );
        
        try{insert udc2;}catch(exception e){}
        
        String ProfileId = userInfo.getProfileId();
        
        User u = new User(
            Alias = 'testA', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Moreno', 
            FirstName = 'Ilse',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = ProfileId, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com',
            LAT_MX_CommercialRegion__c = 'test'
        );
        
        try{insert u;}catch(exception e){}
                        
        Account acc = new Account(
            Name = 'TEST',
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
            LAT_MX_PostalCode__c = pc.Id,
            SaveDuplicatedFiscalID_AR__c = true,
            Customer_Geographic_Region__c = udc2.Id,
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}  
           
   }

    static testMethod void unitTest7() {

        String rtOnMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
        
        Account acc = new Account(
            Name = 'TEST',
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
            RecordTypeId = rtOnMX
        );
        
        try{insert acc;}catch(exception e){}
        
        System.test.startTest();
                
        acc.Status__c = 'Cliente cadastrado no JDE';
        
        try{update acc;}catch(exception e){}
        
        acc.Status__c = 'Inactive Account';
        
        try{update acc;} catch(exception e){}
        
        acc.Other_Notes__c = 'test';
        
        try{update acc;}catch(exception e){}
        
        System.test.stopTest();
                  
    }
    
    /*static testMethod void unitTest8() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            credit_line__c = 1000000,
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
        
        Account acc2 = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Consignee',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            ParentId = acc.Id,
            RecordTypeId = rtOffMX
        );
        try{insert acc2;}catch(exception e){}
        
        System.test.startTest();
                
        try{delete acc2;}catch(exception e){}
        
        System.test.stopTest();
                  
    }*/
    
    static testMethod void unitTest9() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            credit_line__c = 1000000,
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Company',
            RecordTypeId = rtOffMX
        );
        
        try{insert acc;}catch(exception e){}
        
        System.test.startTest();
        
        acc.CNPJ__c = 'LOZM701213E5';
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
                
        try{insert acc;}catch(exception e){}
        
        System.test.stopTest();
                  
    }

      static testMethod void testSetRegional() {

        String ProfileId = userInfo.getProfileId();
        
        // Creo UDC para regional 'C'
        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        UDC__c udc2 = new UDC__c(
            Name = 'CENTRO',
            CodProd__c = '01',
            CodUs__c = '02',
            CodDefUsuario__c = 'C',
            Internal_Id__c = '12-C-01-02',
            RecordTypeId = rtUDC          
        );
        try{insert udc2;}catch(exception e){}

        // Creo usuario (vendedor) con codigo C3
        User u = new User(
            Alias = 'testA', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Moreno', 
            FirstName = 'Ilse',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = ProfileId, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com',
            C_digo_JDE__c = 'C3'
        );
        try{insert u;}catch(exception e){}


        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        List<Account> accounts = new List<Account>{};
        Account acc = new Account(
            Owner = u,
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'EME910610G1A',
            Corporate_Name__c = 'TEST',
            credit_line__c = 1000000,
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Company',
            RecordTypeId = rtOffMX
        );
        accounts.add(acc);
                
        System.test.startTest();
        try{insert accounts;}catch(exception e){}
        System.test.stopTest();
                  
    }


}