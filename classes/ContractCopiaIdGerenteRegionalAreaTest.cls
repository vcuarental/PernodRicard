@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA O TESTE DE COBERTURA DOS SEGUINTES CÓDIGOS:
*              TRCustomerInterface - 75%
*              CriaCriterioRegional - 100%
*              CasoCopiaIdGerenteRegionalArea - 100%
*              ContaCopiaIdGerenteRegionalArea - 100%
*              ContratoCopiaIdGerenteRegionalArea - 100%
*              UserDAO - 100%
* NAME: ContractCopiaIdGerenteRegionalAreaTest.CLS
* AUTHOR: CARLOS CARVALHO                           DATE: 12/03/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 14/05/2012
* AUTHOR: CARLOS CARVALHO                           DATE: 24/05/2012
* AUTHOR: MARCOS DOBROWOLSKI                        DATE: 26/12/2012
********************************************************************************/
private class ContractCopiaIdGerenteRegionalAreaTest {

    static testMethod void ContractCopiaIdGerenteRegionalAreaTest() 
    {
         //Cria Regional
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        UDC__c regional = new UDC__c(
         CodDefUsuario__c = '2',
         CodProd__c     = '01',
         CodUs__c     = '01',
         Internal_Id__c   = '01-01',
         RecordTypeId = idRecTypeUdc
       );
        insert regional;
        
        //Cria novo Account. 
        Account acc = new Account(
         Name = 'Conta teste Trigger',
         CNPJ__c = '48843971000120',
         Type = 'Outros',
         Status__c = 'Cliente cadastrado no JDE',
         Agency__c = '000',
         Checking_account__c = '000',
         Current_account__c = '0',
         Corporate_Name__c = 'Teste',
         Regional__c = regional.id,
         Channel_Type__c = 'Indireto',
         RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
       );
        insert acc;
        
        test.startTest();
        
        LAT_Contract__c lContrato = new LAT_Contract__c(
         Account__c = acc.Id,
         Status__c = 'Em elaboração',
         StartDate__c = System.today(),
         ContractTerm__c = 12,
         Status_do_processo__c='Estudo em elaboração', 
         RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato'),
         ROI_Comentarios_Negativo__c = 'teste'
        );
        insert lContrato;
        
        test.stopTest();   
    }
}