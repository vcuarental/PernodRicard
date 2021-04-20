/******************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:21/03/2013     *
*******************************************************************************************/
@isTest
public with sharing class BTN04_GenerateReceipt_AR_TEST {
    
    @isTest    
        static void unitTest() {
        
        system.Test.startTest();
            
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
            
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id, 
        CNPJ__c = '20354266645',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Segmentation_Type_on_trade__c = 'Restaurant_ARG',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test');
        
        insert acc;

        system.Test.stopTest();
        
        list<Titulos__c> listTitulos = new list<Titulos__c>();
        
        Titulos__c tit = new Titulos__c(
        Cliente__c = acc.id,
        Internal_id_pk__c = 'test',
        codigoCia__c = '123',
        tipoDocumento__c = 'RU',
        ReceiptNumber_AR__c = 123,
        dataEmissao__c = date.today(),
        dataVencimentoOriginal__c = date.today(),
        DeliveryNote_AR__c ='asd',
        numeroDocumento__c = 1234,
        valorOriginalTitulo__c = 123, 
        dataVencimentoAtual__c = date.today() ,
        parcela__c = 'asd' , 
        valorSaldo__c = 123
        );
        
        listTitulos.add(tit);
        
        Titulos__c tito = new Titulos__c(
        Cliente__c = acc.id,
        Internal_id_pk__c = 'test747',
        codigoCia__c = '12344',
        tipoDocumento__c = 'R1',
        ReceiptNumber_AR__c = 1234,
        dataEmissao__c = date.today(),
        dataVencimentoOriginal__c = date.today(),
        DeliveryNote_AR__c ='asd',
        numeroDocumento__c = 123444,
        valorOriginalTitulo__c = 1234, 
        dataVencimentoAtual__c = date.today() ,
        parcela__c = 'asd' , 
        valorSaldo__c = 1234
        );
        
        listTitulos.add(tito);
        
        Titulos__c tito3 = new Titulos__c(
        Cliente__c = acc.id,
        Internal_id_pk__c = 'test74sdfsd',
        codigoCia__c = '12344',
        valorSaldo__c = 100,
        NetSRReceipts_AR__c = 100,
        tipoDocumento__c = 'FA',
        ReceiptNumber_AR__c = 1234,
        dataEmissao__c = date.today(),
        dataVencimentoOriginal__c = date.today(),
        DeliveryNote_AR__c ='asd',
        numeroDocumento__c = 123444,
        valorOriginalTitulo__c = 1234, 
        dataVencimentoAtual__c = date.today() ,
        parcela__c = 'asd'
        );
        
        listTitulos.add(tito3);
        
        insert listTitulos;
        
        list<Id> listIds1 = new list<Id>();
        list<Id> listIds2 = new list<Id>();
        list<Id> listIds3 = new list<Id>();
        
        
        listIds1.add(listTitulos[0].id);
        listIds2.add(listTitulos[1].id);
        listIds3.add(listTitulos[2].id);
        
        BTN04_GenerateReceipt_AR.GenerateReceipt(listIds1);
        BTN04_GenerateReceipt_AR.GenerateReceipt(listIds2);
        BTN04_GenerateReceipt_AR.GenerateReceipt(listIds3);
        
        BTN04_GenerateReceipt_AR.AccountIdSelected(listIds1, acc.id);
        BTN04_GenerateReceipt_AR.AccountIdSelected(listIds2, '');
        
        }
}