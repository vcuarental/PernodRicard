/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Realiza teste de cobertura do seguinte código: OportunidadeDataEntrega.cls
* NAME: OportunidadeDataEntregaTest.cls
* AUTHOR: CARLOS CARVALHO                            DATE: 20/02/2013
*
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
@isTest(seeallData=true)
private class OportunidadeDataEntregaTest {

    static testMethod void myUnitTest() {
        Utils.setMigrationDoneTest(false);      
        UDC__c UdcTest = new UDC__c(
          CodUs__c = 'DF',
          CodProd__c = 'CRM',
          Name = 'KA',
          Internal_Id__c = 'CRM-DF',
          RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
          CodDefUsuario__c = '03'
        );
        insert UdcTest;
     
        Account acc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '40658510000175',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Channel_Type__c = 'Indireto',
            Price_Group__c = '0',
            Client_code_AN8__c = '000000',
            Business_Unit__c = UdcTest.Id,
            Carriers_Numbers__c = '151764',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')
        );
        insert acc;

        Product2 produto = new Product2(
            Name = 'Cloud2b - Produto',
            IsActive = true,
            CD_Unit__c = 'UN',
            Internal_id__c = '123',
            QT_lead_time__c = 5,
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')
        );
        insert produto;
        
        List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1];
        
        PricebookEntry entradaCatalogoPreco = new PricebookEntry(
            Pricebook2Id = catalogoPreco[0].Id,  
            Product2Id = produto.Id,
            UnitPrice = 1000.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert entradaCatalogoPreco;  
        
        test.startTest();
        Utils.setMigrationDoneTest(false);  
        Opportunity oportunidade = new Opportunity(
            Name = 'Cloud2b - Oportunidade',
            AccountId = acc.Id,
            CloseDate = Date.today()+1,
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade'),
            Cancelar_pedido__c = false
        );
        insert oportunidade;
        
        OpportunityLineItem produtosOportunidade = new OpportunityLineItem(
            OpportunityId = oportunidade.Id,
            PricebookEntryId = entradaCatalogoPreco.Id,
            Quantity = 1,
            UnitPrice = 1000.00
        );
        insert produtosOportunidade;
        
        List<String> lStr = new List<String>();
        lStr.add(oportunidade.id);
        
        OportunidadeDataEntrega oppDtEntr = new OportunidadeDataEntrega(lStr);
        oppDtEntr.atualizaPedido(oportunidade.id);
        
        System.test.stopTest();      
      
    }

    static testMethod void myUnitTest2() {
        Utils.setMigrationDoneTest(true);      
        UDC__c UdcTest = new UDC__c(
          CodUs__c = 'DF',
          CodProd__c = 'CRM',
          Name = 'KA',
          Internal_Id__c = 'CRM-DF',
          RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
          CodDefUsuario__c = '03'
        );
        insert UdcTest;
     
        Account acc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '40658510000175',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Channel_Type__c = 'Indireto',
            Price_Group__c = '0',
            Client_code_AN8__c = '000000',
            Business_Unit__c = UdcTest.Id,
            Carriers_Numbers__c = '151764',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')
        );
        insert acc;

        
            LAT_Product__c produto = new LAT_Product__c(
            Name = 'Cloud2b - Produto',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'UN',
            LAT_ExternalId__c = '123',
            LAT_QTLeadTime__c = 5,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard')
        );
        insert produto;
        

        
        test.startTest();
        Utils.setMigrationDoneTest(true);  

        LAT_Opportunity__c oportunidade = new LAT_Opportunity__c(
            Name = 'Cloud2b - Oportunidade',
            LAT_Account__c = acc.Id,
            LAT_CloseDate__c = Date.today()+1,
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'),
            LAT_CancelOrder__c = false
        );
        insert oportunidade;
        
        LAT_OpportunityLineItem__c produtosOportunidade = new LAT_OpportunityLineItem__c(
            LAT_Opportunity__c = oportunidade.Id,
            LAT_Product__c = produto.Id,
            LAT_Quantity__c = 1,
            LAT_UnitPrice__c = 1000.00
        );
        insert produtosOportunidade;
        
        List<String> lStr = new List<String>();
        lStr.add(oportunidade.id);
        
        OportunidadeDataEntrega oppDtEntr = new OportunidadeDataEntrega(lStr);
        oppDtEntr.atualizaPedido(oportunidade.id);
        
        System.test.stopTest();      
      
    }    
}