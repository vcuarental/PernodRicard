@isTest
public class LAT_BR_VFP30_MobileOverride_Test {
     static testMethod void myUnitTest(){
        String rtOnMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = rtOnMX
        );
        
        try{insert acc;}catch(exception e){}
        
        Planejamento__c plan0 = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2012', M_s_de_Ref_rencia__c = 'Dezembro', OwnerId = userinfo.getUserId() );
        insert plan0;
      
        Visitas__c vis = new Visitas__c(Name = 'testVis', Planejamento__c = plan0.id, Hora_da_Visita__c = '01:00', Data_da_Visita__c = date.today().addDays(-3), Resumo_da_Visita__c = '123', Status__c = 'Planejada', conta__c = acc.id );
        insert vis;
        
         ApexPages.StandardController stdVisita= new ApexPages.StandardController(vis);
         LAT_BR_VFP30_MobileOverride overrideController = new lat_br_vfp30_mobileoverride(stdVisita);
         overrideController.authorized();
 

        
     
     }     

     static testMethod void myUnitTest2(){
        String rtOnMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = rtOnMX
        );
        
        try{insert acc;}catch(exception e){}
        
        Planejamento__c plan0 = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2012', M_s_de_Ref_rencia__c = 'Dezembro', OwnerId = userinfo.getUserId() );
        insert plan0;
      
        Visitas__c vis = new Visitas__c(Name = 'testVis', Planejamento__c = plan0.id, Hora_da_Visita__c = '01:00', Data_da_Visita__c = date.today().addDays(-3), Resumo_da_Visita__c = '123', Status__c = 'Planejada', conta__c = acc.id );
        insert vis;
        
         ApexPages.StandardController stdPlan= new ApexPages.StandardController(plan0);
         
         LAT_BR_VFP30_PlanejamentoOverride overrideController = new LAT_BR_VFP30_PlanejamentoOverride(stdPlan);
         overrideController.authorized();
 

        
     
     }
    

}