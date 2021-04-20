@istest

public with sharing class LAT_BR_FullCalendarController_TEST {
    
    static testMethod void UnitTest(){
        
        datetime hoy = date.today();
        datetime hoyMasDos = date.today().addDays(2);
        string title = 'Themap';
        string title2 = 'true';
        
        string digits = string.valueOfGmt(hoy);
        digits = digits.replace(' ', '');
        digits =+ digits.replace('-', '');
        digits =+ digits.replace(':', '');
        
        string digits2 = string.valueOfGmt(hoyMasDos);
        digits2 = digits2.replace(' ', '');
        digits2 =+ digits2.replace('-', '');
        digits2 =+ digits2.replace(':', '');
        
        LAT_BR_FullCalendarController.CreateEvent(title, digits,digits2, title2);
        
        User usuario;
        try{usuario = [SELECT Id, Name, ProfileId FROM User WHERE IsActive = true LIMIT 1];}catch(Exception e){}
        
        Planejamento__c plan0 = new Planejamento__c(
            Name = 'Test0', 
            Ano_de_Referencia__c = '2012', 
            M_s_de_Ref_rencia__c = 'Dezembro', 
            Solicitar_aprova_o_para__c = 'Planejamento semana 2', 
            Aprovado_semana_1__c = true, 
            OwnerId = usuario.id
        );
        insert plan0;
        
        Visitas__c vis = new Visitas__c(
            Name = 'testVis', 
            Planejamento__c = plan0.id, 
            Hora_da_Visita__c = '01:00', 
            Data_da_Visita__c = date.today().addDays(-3), 
            Resumo_da_Visita__c = '123', 
            Status__c = 'Planejada'
        );
        insert vis;
        
        test.startTest();
        
        LAT_BR_FullCalendarController.getEvents(digits,digits2, plan0.Id);
        LAT_BR_FullCalendarController.updateEvent(vis.Id, title, digits, digits2, false, 'true');
        LAT_BR_FullCalendarController.deleteEvent(vis.Id);
        
        test.stopTest();
    }
}