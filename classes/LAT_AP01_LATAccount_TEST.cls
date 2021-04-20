/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

@isTest
public with sharing class LAT_AP01_LATAccount_TEST {

    static testMethod void unitTestAR(){
        
        String rtOffAR = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG');
        Account accAR = new Account(
            CNPJ__c = '30500008454',
            Name = 'testAccount123',
            Overdue__c = true,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c ='test4',
            Revenue_Country__c ='test5',
            Billing_Country__c ='test8',
            Status__c = 'Em aprovação - Financeiro',
            RecordTypeId = rtOffAR,
            Client_code_AN8__c = '0'
        );
        insert accAR;
        
        test.startTest();
        
        List<LAT_ACCOUNT__c> listAR = [SELECT Id FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: accAR.Id];
        System.assertEquals(1, listAR.size());
        
        test.stopTest();
        
    }

    static testMethod void unitTestBR(){
        
        Account accBR = new Account(
			RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
			CNPJ__c = '54651716001150',
			Name = 'testAccount',
			Type = 'Prospect_ARG',
			Corporate_Name__c = 'test',
			Channel_Type__c = 'Direto',
			Sub_Channel__c = 'Delicatessen',
			AddressLine1_AR__c= 'test',
			Shipping_Neighbourhood__c = 'test',
			Revenue_Neighbourhood__c = 'test',
			Billing_Neighbourhood__c ='test',
			Shipping_Country__c ='test',
			Revenue_Country__c ='test',
			Client_code_AN8__c = '123697',
			Billing_Country__c ='test'
		);
		insert accBR;
        
        test.startTest();
        
        List<LAT_ACCOUNT__c> listBR = [SELECT Id FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: accBR.Id];
                
        System.assertEquals(1, listBR.size());

        test.stopTest();

    }

    static testMethod void unitTestMX(){
        
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        Account accMX = new Account(
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
        insert accMX;
        
        test.startTest();
        
        List<LAT_ACCOUNT__c> listMX = [SELECT Id FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: accMX.Id];
        System.assertEquals(1, listMX.size());
        
        test.stopTest(); 
    }
}