/******************************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck-Tomás Etchegaray  Date:21/03/2013    *
*******************************************************************************************/
@isTest
public with sharing class BTN11_Checklistvalidations_AR_TEST {

@isTest (SeeAllData = true)   
    static void unitTest() {
    
        
       /* RecordType rec = new RecordType(
        DeveloperName = 'ACC_1_OffTrade_ARG',
        Name = 'ACC_1_OffTrade_ARG', 
        SobjectType='Account');*/
        
        //insert rec;
        
        list<RecordType> record = [select id, DeveloperName from RecordType where DeveloperName = 'ACC_1_OffTrade_ARG' OR DeveloperName = 'PLV_Standard_AR']; 
        
        Account acc = new Account(
        RecordTypeId = record[1].Id, 
        CNPJ__c = '20354266645',
        checkList_AR__c = 'POS Wholesalers_ARG',
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
        Billing_Country__c ='test'
        );
        insert acc;
        
        Planejamento__c plan = new Planejamento__c();
        plan.RecordTypeId = record[0].Id;
        plan.CurrencyIsoCode = 'ARS';
        plan.M_s_de_Ref_rencia__c = 'Abril';
        insert plan;
        
        //system.Test.startTest();
         
        Visitas__c visit = new Visitas__c();
        visit.Conta__c = acc.id;
        visit.Hora_da_Visita__c = '18:00';
        visit.Planejamento__c = plan.id;
        visit.Data_da_Visita__c = date.today();
        visit.Resumo_da_Visita__c = 'dfg';        
        insert visit;
        
        
        /*
        Visitas__c visit2 = new Visitas__c();
        visit.Conta__c = acc.id;
        visit.Hora_da_Visita__c = '16:00';
        visit.Planejamento__c = plan.id;
        visit.Data_da_Visita__c = date.today();
        //visit.Visita_n_o_realizada__c = true;
        visit.Resumo_da_Visita__c = 'dfg';        
        insert visit2;
        */
        /*
        Visitas__c visi3 = new Visitas__c();
        visit.Conta__c = acc.id;
        visit.Hora_da_Visita__c = '18:00';
        visit.Planejamento__c = plan.id;
        visit.Data_da_Visita__c = null;
        visit.Resumo_da_Visita__c = 'dfg';        
        insert visi3;
        */
        
        BTN11_Checklistvalidations_AR.checkValidations(visit.id);
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Supermarkets_ARG', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Wholesalers_ARG', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Distributors On_ARG', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('CLV_DirectOffTrade_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('CLV_POSDirectOffTrade_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('CLV_IndirectOffTrade_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Distributors_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('order_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Direct On-Trade_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Indirect On-Trade_URU', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('POS Wineries_ARG', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Indirect On-Trade_ARG', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('POS Wineries_ARG', 'ACC_1_OffTrade_ARG');
        BTN11_Checklistvalidations_AR.returnRecordtypeNAme('Wineries_ARG', 'ACC_1_OffTrade_ARG');
        
        
        //system.Test.stopTest();
    }
}