/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
@isTest
public with sharing class LAT_BR_BTN04_ValForApprovalCredAnTest {
	static testMethod void UnitTest(){ 
	     
    Test.startTest();
      User vendas = [SELECT Id FROM user WHERE Profile.Name = 'Vendas' AND isActive = true limit 1];         
      system.runas(vendas){  
      Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
      insert acc;
      
      Analise_de_credito__c ac = new Analise_de_credito__c();
      ac.Conta__c = acc.id;
      ac.LAT_BR_Status__c = 'Ativo';
      insert ac;

        
      String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac.Id);
      System.assertEquals(Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage, result);

      ac.LAT_BR_Status__c = 'Em Preenchimento';
      update ac;
      result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac.Id);
      //System.assertEquals('', result);

              
      result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac.Id);
      //System.assertEquals(Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage2, result);


      }
   
     
    Test.stopTest();  
  }
  
  static testMethod void UnitTestB(){ 
       
    Test.startTest();
      User vendas = [SELECT Id FROM user WHERE (Profile.Name = 'LAT_BR2_Vendas' OR Profile.Name = 'Vendas')  AND isActive = true limit 1];         
      system.runas(vendas){  
      Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
      insert acc;
      
      Analise_de_credito__c ac = new Analise_de_credito__c();
      ac.Conta__c = acc.id;
      ac.LAT_BR_Status__c = 'Ativo';
      insert ac;

        
      String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac.Id);
      System.assertEquals(Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage, result);

      ac.LAT_BR_Status__c = 'Em Preenchimento';
      update ac;
      result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac.Id);
      //System.assertEquals('', result);

              
      result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac.Id);
      //System.assertEquals(Label.LAT_BR_VFC14_CreditAnalysisApprovalMessage2, result);


      }
   
     
    Test.stopTest();  
  }
  static testMethod void UnitTest2(){ 
       
    Test.startTest();
      User vendas = [SELECT Id FROM user WHERE Profile.Name = 'Vendas' AND isActive = true limit 1];         
      system.runas(vendas){  
        Account acc2 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc2;

        Analise_de_credito__c ac2 = new Analise_de_credito__c();
        ac2.Conta__c = acc2.id;
        ac2.LAT_BR_Status__c = 'Inativo';
        insert ac2;
        

        String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac2.Id);
        //System.assertEquals(Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg, result);
     }
     Test.stopTest();   
  }  

  static testMethod void UnitTest2B(){ 
       
    Test.startTest();
      User vendas = [SELECT Id FROM user WHERE (Profile.Name = 'LAT_BR2_Vendas' OR Profile.Name = 'Vendas') AND isActive = true limit 1];         
      system.runas(vendas){  
        Account acc2 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc2;

        Analise_de_credito__c ac2 = new Analise_de_credito__c();
        ac2.Conta__c = acc2.id;
        ac2.LAT_BR_Status__c = 'Inativo';
        insert ac2;
        

        String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac2.Id);
        //System.assertEquals(Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg, result);
     }
     Test.stopTest();   
  } 
  static testMethod void UnitTest3(){ 
       
    Test.startTest();
      
      Account acc3 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
      insert acc3;

      Analise_de_credito__c ac3 = new Analise_de_credito__c();
      ac3.Conta__c = acc3.id;
      ac3.LAT_BR_Status__c = 'Reprovado';
      insert ac3;
      

      String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac3.Id);
      //System.assertEquals(Label.LAT_BR_VFC15_ApprobalEntryCriteriaErrorMsg, result);
   
    Test.stopTest();   
  }  

  static testMethod void UnitTest4(){ 
       
    Test.startTest();
      User vendas = [SELECT Id FROM user WHERE Profile.Name = 'Vendas' AND isActive = true limit 1];         
      system.runas(vendas){  
        Account acc4 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc4;

        Analise_de_credito__c ac4 = new Analise_de_credito__c();
        ac4.Conta__c = acc4.id;
        ac4.LAT_BR_Status__c = 'Reprovado';
        insert ac4;
        

        String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac4.Id);
        //System.assertEquals('', result);
      }
   Test.stopTest();   
  }  

  static testMethod void UnitTest4B(){ 
       
    Test.startTest();
      User vendas = [SELECT Id FROM user WHERE (Profile.Name = 'LAT_BR2_Vendas' OR Profile.Name = 'Vendas') AND isActive = true limit 1];         
      system.runas(vendas){  
        Account acc4 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc4;

        Analise_de_credito__c ac4 = new Analise_de_credito__c();
        ac4.Conta__c = acc4.id;
        ac4.LAT_BR_Status__c = 'Reprovado';
        insert ac4;
        

        String result = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(ac4.Id);
        //System.assertEquals('', result);
      }
    Test.stopTest();   
  } 
}