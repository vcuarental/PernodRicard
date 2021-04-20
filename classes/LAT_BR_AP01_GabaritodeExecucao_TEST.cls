/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

@isTest
public with sharing class LAT_BR_AP01_GabaritodeExecucao_TEST {
    
    static testMethod void unitTest(){
        
        String rtOffBRCWH = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c' + 'LAT_BR_CWH_Standard');
        String rtOffBRPla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
        String rtOffBRVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
        String rtOffBRCdV = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
        String rtOffBRGab = Global_RecordTypeCache.getRtId('Gabarito_de_Execucao__c' + 'BRA_Standard');
        
        Account acc = new Account(
        RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
        CNPJ__c = '54651716001150',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Client_code_AN8__c = '123697',
        Billing_Country__c ='test'
        );
        insert acc;  
        
        Planejamento__c plan = new Planejamento__c(Name = 'Test', M_s_de_Ref_rencia__c = 'Janeiro', Ano_de_Referencia__c = '2013', RecordTypeId = rtOffBRPla);
        insert plan;
        
        test.startTest();

            Visitas__c vis = new Visitas__c(Name = 'TEST', Data_da_Visita__c = date.today(), Planejamento__c = plan.id, Hora_da_Visita__c = '02:00', Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test', RecordTypeId = rtOffBRVis );
            insert vis;
            
            Checklist_de_visita__c cdvTest = new Checklist_de_visita__c(Visita__c = vis.Id, Tempo_Gasto_no_Cliente_Minutos__c = 12, RecordTypeId = rtOffBRCdV);
            insert cdvTest;
            
            Checklist_de_visita__c cdvTest2 = new Checklist_de_visita__c(Visita__c = vis.Id, Tempo_Gasto_no_Cliente_Minutos__c = 12, RecordTypeId = rtOffBRCdV);
            insert cdvTest2;
            
            Gabarito_de_Execucao__c gab = new Gabarito_de_Execucao__c(Checklist_de_Visita__c = cdvTest.Id, RecordTypeId = rtOffBRGab);
            insert gab;
            
            Gabarito_de_Execucao__c gab2 = new Gabarito_de_Execucao__c(Checklist_de_Visita__c = cdvTest2.Id, RecordTypeId = rtOffBRGab);
            insert gab2;
            
            gab.Comentarios_gerais__c = 'hi';
            update gab;
            
            delete gab;
            
            Gabarito_de_Execucao__c gab4 = new Gabarito_de_Execucao__c(Checklist_de_Visita__c = cdvTest2.Id, RecordTypeId = rtOffBRGab);
            Gabarito_de_Execucao__c gab5 = new Gabarito_de_Execucao__c(Checklist_de_Visita__c = cdvTest2.Id, RecordTypeId = rtOffBRGab);
            
            List<Gabarito_de_Execucao__c> listOfGab = new List<Gabarito_de_Execucao__c>{gab4, gab5};
            
            try{insert listOfGab;}catch(Exception e){}
        
        test.stopTest(); 
    }
    
}