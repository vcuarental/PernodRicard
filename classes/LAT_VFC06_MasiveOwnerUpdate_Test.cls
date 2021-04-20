@isTest 
public with sharing class LAT_VFC06_MasiveOwnerUpdate_Test {

    @testSetup
    public static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        
    }

    static testMethod void  Test_01() {
        insert new LAT_GeneralConfig__c (Name = 'ACCOUNT_OWNER_UPDATE', LAT_Value__c = 'ARS;');
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
            RecordTypeId = rtOffMX,
            client_country_an8__c = '12-1234'
        );
        insert acc;
        String thisUserId = UserInfo.getUserId();   

        LAT_VFC06_MasiveOwnerUpdate controller = new LAT_VFC06_MasiveOwnerUpdate();
        controller.toParse = blob.valueOf('AN8,New Owner\r\n1234,' + thisUserId + '\r\n');
        controller.upload();
    }


    @isTest static void Test_02() {
        insert new LAT_GeneralConfig__c (Name = 'ACCOUNT_OWNER_UPDATE', LAT_Value__c = 'ARS;');
        User usuario = [SELECT id FROM User WHERE Profile.name = 'LAT_SystemAdministrator' AND isActive = True LIMIT 1];
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        

        Account acc = new Account(
            OwnerId = usuario.Id,
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
            RecordTypeId = rtOffMX,
            client_country_an8__c = '12-1234'
        );
        insert acc;
        Test.startTest();
        LAT_MasiveOwnerHeader__c header = new LAT_MasiveOwnerHeader__c();
        header.LAT_Status__c = 'New';
        header.LAT_Approver__c = UserInfo.getUserId();
        insert header;

        header.LAT_Status__c = 'Execution';
        update header;
        Test.stopTest();
    }

    @isTest static void Test_03() {
        insert new LAT_GeneralConfig__c (Name = 'ACCOUNT_OWNER_UPDATE', LAT_Value__c = 'ARS;');
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        User usuario = [SELECT id FROM User WHERE Profile.name = 'LAT_SystemAdministrator' AND isActive = True LIMIT 1];
        
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
            OwnerId = usuario.Id,
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,
            client_country_an8__c = '12-1234',
            Credit_line__c = 10
        );
        insert acc;

        Test.startTest();
        LAT_MasiveOwnerHeader__c header = new LAT_MasiveOwnerHeader__c();
        header.LAT_Status__c = 'New';
        header.LAT_Approver__c = UserInfo.getUserId();
        insert header;

        LAT_MasiveOwnerLine__c line = new LAT_MasiveOwnerLine__c();
        line.LAT_Account__c = acc.id;
        line.LAT_AccountAN8__c = acc.client_country_an8__c;
        line.LAT_OldValue__c = acc.OwnerId;
        line.LAT_Header__c = header.Id;
        line.LAT_NewValue__c = UserInfo.getUserId();

        insert line;

        header.lat_status__c = 'Execution';
        update header;

        line.LAT_NewValue__c = UserInfo.getUserId();
        update line;
        Test.stopTest();
    }   
    
    static testMethod void  Test_04() {
        insert new LAT_GeneralConfig__c (Name = 'ACCOUNT_OWNER_UPDATE', LAT_Value__c = 'ARS;');
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
            RecordTypeId = rtOffMX,
            client_country_an8__c = '1-1234'
        );
        insert acc;
        String thisUserId = UserInfo.getUserId();   

        LAT_VFC06_MasiveOwnerUpdate controller = new LAT_VFC06_MasiveOwnerUpdate();
        controller.toParse = blob.valueOf('AN8,New Owner\r\n1234,DBLQT' + thisUserId + 'DBLQT\r\n');
        controller.upload();
        controller.toParse = blob.valueOf('Id,name,New Owner\n'+acc.Id+',hola hola,' + thisUserId + '\n');
        controller.upload();
    }
    
    
      static testMethod void  Test_05() {
        insert new LAT_GeneralConfig__c (Name = 'ACCOUNT_OWNER_UPDATE', LAT_Value__c = 'ARS;');
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
            RecordTypeId = rtOffMX,
            client_country_an8__c = '1-1234'
        );
        insert acc;
        String thisUserId = UserInfo.getUserId();   

        LAT_VFC06_MasiveOwnerUpdate controller = new LAT_VFC06_MasiveOwnerUpdate();
        controller.toParse = blob.valueOf('AN8,New Owner\r\n0011234,DBLQT' + thisUserId + 'aaaDBLQT\r\n');
        controller.upload();
    }
}