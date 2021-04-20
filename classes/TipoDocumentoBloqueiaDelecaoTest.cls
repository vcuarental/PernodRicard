@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Realiza teste de cobertura do seguinte código: TipoDocumentoBloqueiaDelecao.trigger
*
* NAME: TipoDocumentoBloqueiaDelecaoTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
private class TipoDocumentoBloqueiaDelecaoTest {

    static testMethod void myUnitTest() {
        Id idRecTypeTD = RecordTypeForTest.getRecType('Tipo_de_Documento__c', 'Tipo_de_Documento');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
        UDC__c udc = new UDC__c( 
            CodDefUsuario__c = '2',
            CodProd__c = '00',
            CodUs__c = 'DT',
            Descricao2__c = '1',
            Internal_Id__c = '0123',
            RecordTypeId = idRecTypeUDC
        );
        insert udc;
        
        UDC__c regional = new UDC__c( 
            CodDefUsuario__c = '2',
            CodProd__c = '01',
            CodUs__c = '01',
            Descricao2__c = '1',
            Internal_Id__c = '01-01',
            RecordTypeId = idRecTypeUDC
        );
        insert regional;
        
        UDC__c customerOrg = new UDC__c( 
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '10',
            Internal_Id__c   = '1234',
            RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' )
        );
	    insert customerOrg;
        
        Account lConta = new Account( 
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Regional__c = regional.Id,
            Customer_Organization__c = customerOrg.Id,
            RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade'),
            Segmentation_Type_on_trade__c = 'Bar',
            Channel__c = 'Off Trade',
            Channel_Type__c = 'Indireto',
            Rating = 'Cliente'
        );
	    insert lConta;
        
        LAT_Contract__c lContract = new LAT_Contract__c( 
            Account__c = lConta.Id,
            Status__c = 'Em elaboração',
            Status_do_processo__c='Estudo em elaboração',
            StartDate__c = System.today(),
            ContractTerm__c = 12,
            RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'),
            ROI_Comentarios_Negativo__c = 'teste'
        );
        insert lContract;
        
        Tipo_de_Documento__c td = new Tipo_de_Documento__c();
        td.LAT_Contract__c = lContract.id;
        td.Codigo_do_Documento__c = udc.id;
        td.RecordTypeId = idRecTypeTD;
        insert td;
        
        lContract.Status__c = 'Ativo' ;
        update lContract;
        try{
            delete td;
        }catch(DMLException e){
        	System.debug(e.getMessage());
        }
        
    }
}