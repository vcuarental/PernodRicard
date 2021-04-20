/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe DemandaInterna
* NAME: DemandaInternaTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 09/11/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

@isTest(seealldata=true)
private class DemandaInternaTest {
  
    static testMethod void myTest() {
        
        Utils.setMigrationDoneTest(false);
        Set< Id > setRecTypeAcc = new Set< Id >();
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
        
       
          
        Account lAcc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Channel_Type__c = 'Indireto',
            Price_Group__c = '0',
            Client_code_AN8__c = '123451',
            RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
          );
          insert lAcc;
          Test.startTest();
           //Recupera o ID do perfil desejado
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        insert usuario;
          
          
          
        DemandaInterna.criademanda(null, usuario.Id, 'Contrato - assinatura de prorrogação de contrato', lAcc.Id, null,
                'Prorrogação de Contrato',
                'Entregar docto de prorrogação ao cliente', 
                'Entregar documento de prorrogação ao cliente',
                'Colher assinaturas da empresa, entregar documento de prorrogação ao cliente e encaminhar outras 2 vias para arquivamento junto ao contrato original.', null, null );
    }

    static testMethod void myTestB() {
        
        Utils.setMigrationDoneTest(true);
        Set< Id > setRecTypeAcc = new Set< Id >();
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));
       
          
        Account lAcc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Channel_Type__c = 'Indireto',
            Price_Group__c = '0',
            Client_code_AN8__c = '123453',
            RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
          );
          insert lAcc;
          Test.startTest();
           //Recupera o ID do perfil desejado
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        insert usuario;
          
          
        DemandaInterna.criademanda(null, usuario.Id, 'Contrato - assinatura de prorrogação de contrato', lAcc.Id, null,
                'Prorrogação de Contrato',
                'Entregar docto de prorrogação ao cliente', 
                'Entregar documento de prorrogação ao cliente',
                'Colher assinaturas da empresa, entregar documento de prorrogação ao cliente e encaminhar outras 2 vias para arquivamento junto ao contrato original.', null, null );
    }

}