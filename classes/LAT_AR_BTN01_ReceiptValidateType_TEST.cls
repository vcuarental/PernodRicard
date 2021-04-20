/******************************************************************************************
*   Company:Valuenet    Developers:   Denis Aranda                       Date:15/05/2014  *
*******************************************************************************************/
@isTest

public with sharing class LAT_AR_BTN01_ReceiptValidateType_TEST {

	static testmethod void unitTest1(){
		
        List<CS002_FIeldsIds__c> Listcs002 = new List<CS002_FIeldsIds__c>();
        
        CS002_FIeldsIds__c cs002_1 = new CS002_FIeldsIds__c(
            FieldApiName__c='ReceiptNo_AR__c',
            Name = 'name1',
            FieldId__c= '0001',
            ObjectApiName__c='DPT_Deposit_ARG__c'
        );
        
        Listcs002.add(cs002_1);

        CS002_FIeldsIds__c cs002_2 = new CS002_FIeldsIds__c(
            FieldApiName__c='AccType_AR__c',
            Name = 'name2',
            FieldId__c= '0002',
            ObjectApiName__c='DPT_Deposit_ARG__c'
        );
        
        Listcs002.add(cs002_2);
        insert Listcs002;
        
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
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
        	Account_AR__c = accAR.id
        );
        
        insert receipt;
        LAT_AR_BTN01_ReceiptValidateType.ReceiptValidateType(receipt.id);
        
        receipt.LAT_AR_DepositAccountType__c = 'C';
        update receipt;
        
        LAT_AR_BTN01_ReceiptValidateType.ReceiptValidateType(receipt.id);
        
        receipt.LAT_AR_DepositAccountType__c = 'R';
        update receipt;
        
        LAT_AR_BTN01_ReceiptValidateType.ReceiptValidateType(receipt.id);
        
	}
}