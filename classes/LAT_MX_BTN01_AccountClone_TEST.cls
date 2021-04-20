/******************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck               Date:26/09/2013  *
*******************************************************************************************/
@isTest

public with sharing class LAT_MX_BTN01_AccountClone_TEST {
    
    
    static testmethod void unitTest1(){
     User admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        admin.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator'); 
        insert admin;
        system.runas(admin){ 
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        List<CS002_FIeldsIds__c> Listcs002 = new List<CS002_FIeldsIds__c>();
        
        CS002_FIeldsIds__c cs002_1 = new CS002_FIeldsIds__c(
            FieldApiName__c='Credit_line__c',
            Name = 'name1',
            FieldId__c= '0001',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_1);

        CS002_FIeldsIds__c cs002_2 = new CS002_FIeldsIds__c(
            FieldApiName__c='Reason_for_Inactivation__c',
            Name = 'name2',
            FieldId__c= '0002',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_2);

        CS002_FIeldsIds__c cs002_3 = new CS002_FIeldsIds__c(
            FieldApiName__c='Status__c',
            Name = 'name3',
            FieldId__c= '0003',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_3);

        CS002_FIeldsIds__c cs002_4 = new CS002_FIeldsIds__c(
            FieldApiName__c='ParentId',
            Name = 'name4',
            FieldId__c= '0004',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_4);
        
        CS002_FIeldsIds__c cs002_5 = new CS002_FIeldsIds__c(
            FieldApiName__c='ParentName',
            Name = 'name5',
            FieldId__c= '0005',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_5);
        
        CS002_FIeldsIds__c cs002_6 = new CS002_FIeldsIds__c(
            FieldApiName__c='SaveDuplicatedFiscalID_AR__c',
            Name = 'name6',
            FieldId__c= '0006',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_6);
        
        CS002_FIeldsIds__c cs002_7 = new CS002_FIeldsIds__c(
            FieldApiName__c='Reason_for_not_approved__c',
            Name = 'name7',
            FieldId__c= '0007',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_7);
        
        CS002_FIeldsIds__c cs002_8 = new CS002_FIeldsIds__c(
            FieldApiName__c='Rating',
            Name = 'name8',
            FieldId__c= '0008',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_8);
        
        CS002_FIeldsIds__c cs002_9 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_APStep__c',
            Name = 'name9',
            FieldId__c= '0009',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_9);
        
        CS002_FIeldsIds__c cs002_10 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_MissingDocuments__c',
            Name = 'name10',
            FieldId__c= '0010',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_10);
        
        CS002_FIeldsIds__c cs002_11 = new CS002_FIeldsIds__c(
            FieldApiName__c='Client_code_AN8__c',
            Name = 'name11',
            FieldId__c= '0011',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_11);

        CS002_FIeldsIds__c cs002_12 = new CS002_FIeldsIds__c(
            FieldApiName__c='Credit_line__c',
            Name = 'name12',
            FieldId__c= '0012',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_12);
        
        CS002_FIeldsIds__c cs002_13 = new CS002_FIeldsIds__c(
            FieldApiName__c='CNPJ__c',
            Name = 'name13',
            FieldId__c= '0013',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_13);
        
        CS002_FIeldsIds__c cs002_14 = new CS002_FIeldsIds__c(
            FieldApiName__c='Return_JDE_Integration__c',
            Name = 'name14',
            FieldId__c= '0014',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_14);
        
        CS002_FIeldsIds__c cs002_15 = new CS002_FIeldsIds__c(
            FieldApiName__c='Contact_Schedule__c',
            Name = 'name15',
            FieldId__c= '0015',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_15);
                
        insert Listcs002;   
        
        test.startTest(); 
                 
        list<Account> listAccount = new list<Account>();
        
        Account acc2 = new Account(
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
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        //listAccount.add(acc2);
        
        Account acc3 = new Account(
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
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = rtOffMX
        );
        
        //listAccount.add(acc3);
        
        //insert listAccount;
        insert acc3;
        
           
        
            LAT_MX_BTN01_AccountClone.AccountClone(acc3.id);
        
        }
        
        test.stopTest();  
    
    }
    

    static testmethod void unitTest2(){

        List<CS002_FIeldsIds__c> Listcs002 = new List<CS002_FIeldsIds__c>();
        
        CS002_FIeldsIds__c cs002_1 = new CS002_FIeldsIds__c(
            FieldApiName__c='Credit_line__c',
            Name = 'name1',
            FieldId__c= '0001',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_1);

        CS002_FIeldsIds__c cs002_2 = new CS002_FIeldsIds__c(
            FieldApiName__c='Reason_for_Inactivation__c',
            Name = 'name2',
            FieldId__c= '0002',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_2);

        CS002_FIeldsIds__c cs002_3 = new CS002_FIeldsIds__c(
            FieldApiName__c='Status__c',
            Name = 'name3',
            FieldId__c= '0003',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_3);

        CS002_FIeldsIds__c cs002_4 = new CS002_FIeldsIds__c(
            FieldApiName__c='ParentId',
            Name = 'name4',
            FieldId__c= '0004',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_4);
        
        CS002_FIeldsIds__c cs002_5 = new CS002_FIeldsIds__c(
            FieldApiName__c='ParentName',
            Name = 'name5',
            FieldId__c= '0005',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_5);
        
        CS002_FIeldsIds__c cs002_6 = new CS002_FIeldsIds__c(
            FieldApiName__c='SaveDuplicatedFiscalID_AR__c',
            Name = 'name6',
            FieldId__c= '0006',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_6);
        
        CS002_FIeldsIds__c cs002_7 = new CS002_FIeldsIds__c(
            FieldApiName__c='Reason_for_not_approved__c',
            Name = 'name7',
            FieldId__c= '0007',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_7);
        
        CS002_FIeldsIds__c cs002_8 = new CS002_FIeldsIds__c(
            FieldApiName__c='Rating',
            Name = 'name8',
            FieldId__c= '0008',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_8);
        
        CS002_FIeldsIds__c cs002_9 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_APStep__c',
            Name = 'name9',
            FieldId__c= '0009',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_9);
        
        CS002_FIeldsIds__c cs002_10 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_MissingDocuments__c',
            Name = 'name10',
            FieldId__c= '0010',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_10);
        
        CS002_FIeldsIds__c cs002_11 = new CS002_FIeldsIds__c(
            FieldApiName__c='Client_code_AN8__c',
            Name = 'name11',
            FieldId__c= '0011',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_11);

        CS002_FIeldsIds__c cs002_12 = new CS002_FIeldsIds__c(
            FieldApiName__c='Credit_line__c',
            Name = 'name12',
            FieldId__c= '0012',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_12);
        
        CS002_FIeldsIds__c cs002_13 = new CS002_FIeldsIds__c(
            FieldApiName__c='CNPJ__c',
            Name = 'name13',
            FieldId__c= '0013',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_13);
        
        CS002_FIeldsIds__c cs002_14 = new CS002_FIeldsIds__c(
            FieldApiName__c='Return_JDE_Integration__c',
            Name = 'name14',
            FieldId__c= '0014',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_14);
        
        CS002_FIeldsIds__c cs002_15 = new CS002_FIeldsIds__c(
            FieldApiName__c='Contact_Schedule__c',
            Name = 'name15',
            FieldId__c= '0015',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_15);
                
        insert Listcs002;
        
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
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
            RecordTypeId = rtOffMX
        );
        
        insert acc;
        
        test.startTest();
          
        Account acc1 = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'la',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'NME970625KP9',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,            
            ParentId = acc.id
        );
        
        insert acc1;

        User admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
        system.runas(admin){           
            LAT_MX_BTN01_AccountClone.AccountClone(acc1.id);    
        }
        test.stopTest();
    
    }
    
    static testmethod void unitTest3(){
        /*              
        List<CS002_FIeldsIds__c> Listcs002 = new List<CS002_FIeldsIds__c>();
        
        CS002_FIeldsIds__c cs002_1 = new CS002_FIeldsIds__c(
            FieldApiName__c='Credit_line__c',
            Name = 'name1',
            FieldId__c= '0001',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_1);

        CS002_FIeldsIds__c cs002_2 = new CS002_FIeldsIds__c(
            FieldApiName__c='Reason_for_Inactivation__c',
            Name = 'name2',
            FieldId__c= '0002',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_2);

        CS002_FIeldsIds__c cs002_3 = new CS002_FIeldsIds__c(
            FieldApiName__c='Status__c',
            Name = 'name3',
            FieldId__c= '0003',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_3);

        CS002_FIeldsIds__c cs002_4 = new CS002_FIeldsIds__c(
            FieldApiName__c='ParentId',
            Name = 'name4',
            FieldId__c= '0004',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_4);
        
        CS002_FIeldsIds__c cs002_5 = new CS002_FIeldsIds__c(
            FieldApiName__c='ParentName',
            Name = 'name5',
            FieldId__c= '0005',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_5);
        
        CS002_FIeldsIds__c cs002_6 = new CS002_FIeldsIds__c(
            FieldApiName__c='SaveDuplicatedFiscalID_AR__c',
            Name = 'name6',
            FieldId__c= '0006',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_6);
        
        CS002_FIeldsIds__c cs002_7 = new CS002_FIeldsIds__c(
            FieldApiName__c='Reason_for_not_approved__c',
            Name = 'name7',
            FieldId__c= '0007',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_7);
        
        CS002_FIeldsIds__c cs002_8 = new CS002_FIeldsIds__c(
            FieldApiName__c='Rating',
            Name = 'name8',
            FieldId__c= '0008',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_8);
        
        CS002_FIeldsIds__c cs002_9 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_APStep__c',
            Name = 'name9',
            FieldId__c= '0009',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_9);
        
        CS002_FIeldsIds__c cs002_10 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_MissingDocuments__c',
            Name = 'name10',
            FieldId__c= '0010',
            ObjectApiName__c='Account'
        );
        
        Listcs002.add(cs002_10);
        
        CS002_FIeldsIds__c cs002_11 = new CS002_FIeldsIds__c(
            FieldApiName__c='Client_code_AN8__c',
            Name = 'name11',
            FieldId__c= '0011',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_11);

        CS002_FIeldsIds__c cs002_12 = new CS002_FIeldsIds__c(
            FieldApiName__c='Credit_line__c',
            Name = 'name12',
            FieldId__c= '0012',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_12);
        
        CS002_FIeldsIds__c cs002_13 = new CS002_FIeldsIds__c(
            FieldApiName__c='CNPJ__c',
            Name = 'name13',
            FieldId__c= '0013',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_13);
        
        CS002_FIeldsIds__c cs002_14 = new CS002_FIeldsIds__c(
            FieldApiName__c='Return_JDE_Integration__c',
            Name = 'name14',
            FieldId__c= '0014',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_14);
        
        CS002_FIeldsIds__c cs002_15 = new CS002_FIeldsIds__c(
            FieldApiName__c='Contact_Schedule__c',
            Name = 'name15',
            FieldId__c= '0015',
            ObjectApiName__c='Account'
        );
               
        Listcs002.add(cs002_15);
                
        insert Listcs002;
          
                 
        list<Account> listAccount = new list<Account>();
        
        Account acc2 = new Account(
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
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')
        );
        
        listAccount.add(acc2);
        
        Account acc3 = new Account(
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
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')
        );
        
        listAccount.add(acc3);
        
        test.startTest();
        
        insert listAccount;
        
        User admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
        system.runas(admin){   
        
            LAT_MX_BTN01_AccountClone.AccountClone(listAccount[1].id);
        } 
        test.stopTest();  
    */
    }
}