/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/
@isTest
public with sharing class LAT_MX_VFC02_EditVisitController_TEST {
    
    static testMethod void editAllTheVisitTest(){
        
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario;  
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;

        //Cria novo planejamento.
        Planejamento__c plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = string.ValueOf(date.today().year());
        plan.M_s_de_Ref_rencia__c = 'Dezembro';
        plan.Name = 'Teste';
        plan.OwnerId = usuario.Id;
        plan.RecordTypeId = Global_RecordTypeCache.getRtId( 'Planejamento__c'+ 'LAT_MX_PLV_NewPlanning' );
        insert plan;
          
        //Cria nova visita
        Visitas__c visita = new Visitas__c();
        visita.Name = 'Teste';
        visita.Data_da_Visita__c = date.newInstance(date.today().year(),12,31);
        visita.Hora_da_Visita__c = '08:00';
        visita.Planejamento__c = plan.Id;
        visita.Tipo_de_Visita__c = 'Execução';
        visita.Conta__c = acc.Id;
        visita.Status__c = 'Planejada';
        visita.RecordTypeId = Global_RecordTypeCache.getRtId( 'Visitas__c'+ 'LAT_MX_VTS_PlannedVisit' );
        visita.Resumo_da_Visita__c = 'TEste';
        insert visita;
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(new List<Visitas__c>{visita});
        
        ApexPages.currentPage().getParameters().put('idPlan', plan.Id);
        LAT_MX_VFC02_EditVisitController edit = new LAT_MX_VFC02_EditVisitController(controller);
        edit.save();
        
        ApexPages.currentPage().getParameters().put('idsVis', visita.Id);
        ApexPages.currentPage().getParameters().remove('idPlan');
        LAT_MX_VFC02_EditVisitController edit2 = new LAT_MX_VFC02_EditVisitController(controller);
        edit2.save();
    }
}