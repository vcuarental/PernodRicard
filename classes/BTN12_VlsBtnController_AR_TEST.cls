@IsTest
public with sharing class  BTN12_VlsBtnController_AR_TEST {

    static testMethod void UnitTest(){
    
        //system.Test.startTest();
    
        RecordType recordtAR = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName ='ACC_1_OffTrade_ARG'];
        
        Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp',recordtypeid = recordtAR.id,CNPJ__c = '30685140221' );
        insert acco;
        
        RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id);
        insert recibo;
        
        //system.Test.stopTest();
       
        DPT_Deposit_ARG__c deposito = new DPT_Deposit_ARG__c (ReceiptNo_AR__c = recibo.id, Amount_AR__c = 1); 
        insert deposito;
        
        VLS_Values_ARG__c value1 = new VLS_Values_ARG__c ( ReceiptNo_AR__c = recibo.id,Amount_AR__c = 1, Bank_AR__c = 'ABC', BranBranch_AR__c = 'ABC');
        insert value1;
        
        List<Id> myList = new List<Id>();
        myList.add(value1.id);
       
        BTN12_VlsBtnController_AR.idPage(deposito.id, myList);
        
    }
    
  }