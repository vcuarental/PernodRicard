/**********************************************************************************************************************************
                                                                                                                                      
    Developer: Francisco Orzabal                                                                                                   
    Created Date: 03/06/2014                                                                                                        
                                                                                                                                      
    Description: Se encarga de testear la clase LAT_BR_PCS01_ContractAccRatingBatch.

    Last Modified Date:                                                                                                                     
    Last Developer:                                                                                                   
    
    Versión:
    V1.0 - 03/06/2014 - Initial version [FO]
    
/**********************************************************************************************************************************/
@istest
public with sharing class LAT_BR_PCS01_ContractAccRatingBatchTest {

    @istest
    public static void unitTest() {

     //Recupera os IDS de tipo de registro.
      Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
      Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
      

      User usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
      
      //Cria nova UDC.
      UDC__c regional = new UDC__c();
      regional.CodDefUsuario__c = '1';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      //Cria nova UDC.
      
        delete [Select id from UDC__c where Internal_Id__c = '01-06'];
      UDC__c bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '01-06';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      
      //Cria novo Account.
      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idRecTypeAcc;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Channel_Type__c = 'Indireto';
      acc.Client_code_AN8__c = '557799';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      acc.Revenue_UF__c = 'SP';
      acc.Regional_Manager__c = usuario.id;
      insert acc;
      
      LAT_Contract__c lContrato = new LAT_Contract__c();
      lContrato.Account__c = acc.id;
      lContrato.Status__c = 'Em elaboração';
      lContrato.StartDate__c = System.today();
      lContrato.ContractTerm__c = 12;
      lContrato.OwnerId = usuario.Id;
      lContrato.trigger_on__c = true;
      lContrato.RecordTypeId = idrecTypeLatCon;
      lContrato.ROI_Comentarios_Negativo__c = 'Teste';
      insert lContrato;
      
        System.Test.startTest();
            LAT_BR_PCS01_ContractAccRatingBatch testBatch = new LAT_BR_PCS01_ContractAccRatingBatch();
            database.executeBatch(testBatch, 1);
        System.Test.stopTest();
  
  }
  
}