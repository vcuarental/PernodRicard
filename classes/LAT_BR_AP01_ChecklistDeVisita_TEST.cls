/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:12/05/2014    *
*******************************************************************************/

@istest
public with sharing class LAT_BR_AP01_ChecklistDeVisita_TEST {

    static testMethod void unitTest() {
        
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

        test.startTest();
       
        Planejamento__c plan = new Planejamento__c(
            Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Janeiro', 
            Ano_de_Referencia__c = '2013', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard')
        );
        insert plan;
        
        Visitas__c vis = new Visitas__c(
            Name = 'TEST', 
            Data_da_Visita__c = date.today(), 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '02:00', 
            Descrever_Motivo__c = 'Test', 
            Resumo_da_Visita__c = 'Test', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard')
        );
        insert vis;
        
        Checklist_de_visita__c check = new Checklist_de_visita__c(
            Visita__c = vis.Id, 
            Tempo_Gasto_no_Cliente_Minutos__c = 12,
            LAT_BR_ValidOnTradeChecklist__c = false,
            RecordTypeId = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade')
        );
        insert check;

        check.LAT_BR_ValidOnTradeChecklist__c = true;
        
        update check;
        
        test.stopTest();
 
    }
}