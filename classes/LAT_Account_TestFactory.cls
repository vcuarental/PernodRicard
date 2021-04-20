@isTest(seeAllData=true)
public with sharing class LAT_Account_TestFactory {
    public LAT_Account_TestFactory() {
        
    }


    public static RecordType getRecordType(String name){
        return Global_RecordTypeCache.getRtRec('Account' + name);
    }

    public static Account getAccountOffTradeArg(){
        return new Account(Name='TEST', Corporate_Name__c = 'Target Corp',recordtypeid = getRecordType('ACC_1_OffTrade_ARG').id,CNPJ__c = '30685140221' );
    }

    public static Account getAccountOffTradeArgComplete(){
        return getAccountBase('ACC_1_OffTrade_ARG');
    }

    public static Account getAccountOnTradeArgComplete(){
        return getAccountBase('ACC_3_OnTrade_ARG');
    }


    public static Account getAccountOnTradeBraComplete(){
        Account acco = getAccountBase('On_Trade');
        acco.CNPJ__c = '48843971000120';
        acco.Type = 'Outros';
        acco.Status__c = 'Cliente cadastrado no JDE';
        return acco;
    }
    
     public static Account getAccountOffTradeBraComplete(){
        Account acco = getAccountBase('Off_Trade');
          acco.Name = 'Conta teste Trigger';
          acco.CNPJ__c = '48843971000120';
        acco.Type = 'Outros';
          acco.Status__c = 'Cliente cadastrado no JDE';
          acco.Agency__c = '000';
          acco.Checking_account__c = '000';
          acco.Current_account__c = '0';
          acco.Corporate_Name__c = 'Teste';
          //Regional__c = regional.id,
          acco.Channel_Type__c = 'Indireto';
          acco.Price_Group__c = 'x';
          acco.Client_code_AN8__c = '123451236';
          acco.Client_country_AN8__c = '91823';
        return acco;
    }

    public static Account getAccountOffTradeArgStatus(){
        Account acco = getAccountOffTradeArgComplete();
        acco.Overdue__c = false;
        acco.Status__c = 'Em análise - Crédito e Cobrança';
        return acco;
    }
    
    public static Account getBRAAccountBase(String rType){
        //Cria novo Account.      
        Account Acc = new Account();      
        Acc.Name = 'TestCota';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.Recordtypeid = getRecordType(rType).id;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'Off Trade';      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        Acc.Sub_Channel__c = 'Atacadista';
        return Acc;
    }
    
    public static Account getAccountBase(String rType){
        Account acco = new Account(
            CNPJ__c = '20354266645',
            Recordtypeid = getRecordType(rType).id,
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
            Billing_Country__c ='test');
        return acco;
    }




            

    

}