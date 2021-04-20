/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz teste de cobertura da trigger AnexoContarParaPagto 
* NAME: AnexoContarParaPagtoTest.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 13/09/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013
*******************************************************************************/

@isTest
private class AnexoContarParaPagtoTest {

    static testMethod void myUnitTest() 
    {
	    
	    Account Acc = new Account();      
			Acc.Name = 'Teste';
			Acc.Rating = 'Cliente';
			Acc.Status__c = 'Cliente cadastrado no JDE';
			Acc.CNPJ__c = '48843971000120';      
			insert Acc;
	    
	    Pagamento__c lPg = new  Pagamento__c();
			lPg.Cliente__c = Acc.Id; 
			lPg.RecordTypeId = RecordTypeForTest.getRecType('Pagamento__c', 'Dinheiro' );
			insert lPg;
			
	    
	    Attachment lAtt = new Attachment();
	    lAtt.ParentId = lPg.id; 
	    lAtt.name = 'Teste';
	    lAtt.Body = Blob.valueof( 'asdasd' );
	    insert lAtt;
	    
	    delete lAtt;
    }
}