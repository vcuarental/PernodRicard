/*******************************************************************************
*                     Copyright (C) 2013 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de teste para cobertura da trigger PlanejamentoAtribuiKam
*
* NAME: PlanejamentoAtribuiKamTest.cls
* AUTHOR: MARCOS DOBROWOLSKI                        DATE: 19/03/2013
*
*******************************************************************************/

@isTest
private class PlanejamentoAtribuiKamTest {

  static testMethod void myUnitTest() {
    Profile perfil = SObjectInstance.createProfile();
    
    User usuario = SObjectInstance.createUser();
    usuario.ProfileId = perfil.Id;
    Database.insert( usuario, false );

    UDC__c udc = SObjectInstance.createUDC();
    udc.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
    Database.insert( udc, false );
    
    Account contaPai = SObjectInstance.createAccount();
    contaPai.OwnerId = usuario.Id;
    Database.insert( contaPai, false );

    Account contaFilho = SObjectInstance.createAccount();
    contaFilho.Name = 'Conta Teste2';
    contaFilho.CNPJ__c = '26747186000130';
    contaFilho.Client_code_AN8__c = '557799';
    contaFilho.ParentId = contaPai.Id;
    contaFilho.Sub_Channel_Rating__c = udc.Id;
    Database.insert ( contaFilho, false );
    
    Planejamento__c plan = SObjectInstance.createPlanejamento();
    Database.insert( plan, false );
    
    Visitas__c visita = SObjectInstance.createVisitas();
    visita.Conta__c = contaFilho.Id;
    visita.Planejamento__c = plan.Id;
    visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
    Database.insert( visita, false );
    
    
    Database.update( plan, false );
  }
}