global class LAT_BR_Check_Pending_Visits_Batch implements Database.Batchable<sObject> {

    String query;

    // Constructor
    //si hay Visitas que están en planeamientos que son de un owner distinto al owner de la visita,
    //hacer el reparenting
    global LAT_BR_Check_Pending_Visits_Batch() {
        
        query = 'Select Id, Conta__r.ownerid, Hora_da_Visita__c, Planejamento__c, Planejamento__r.ownerid, Planejamento__r.Ano_de_Referencia__c, Planejamento__r.M_s_de_Ref_rencia__c From Visitas__c ';

        if(!Test.isRunningTest()){
            query += ' where status__c != \'Encerrada\' and createddate = Last_N_Months:2 ';
        }

    }

    // Start
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }

    // Execute
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<Visitas__c> visitas = (List<Visitas__c>)scope;
        Set<Id> differentOwners = new Set<Id>();
        List<Visitas__c> visitasToUpdate = new List<Visitas__c>();

        system.debug('visitas size: ' + visitas.size());

        for (Visitas__c visita : visitas) {
            if(visita.Conta__r.ownerid != visita.Planejamento__r.ownerid){
                differentOwners.add(visita.Conta__r.ownerid);
                visitasToUpdate.add(visita);
            }
        }

        system.debug('differentOwners size: ' + differentOwners.size());

        Map <String, Planejamento__c> pvpsNewOwner = new Map<String, Planejamento__c>();

        List<Planejamento__c> listaPVP = [select id, ownerid, M_s_de_Ref_rencia__c, Ano_de_Referencia__c from Planejamento__c where ownerid in :differentOwners and createddate = Last_N_Months:6];

        system.debug('listaPVP batch size: ' + listaPVP.size());

        for(Planejamento__c plan :listaPVP){
            
            pvpsNewOwner.put(plan.M_s_de_Ref_rencia__c+plan.Ano_de_Referencia__c, plan);

            system.debug('pvp name: ' + plan);
        }

        for (Visitas__c visita : visitasToUpdate) {
            
            if(visita.Hora_da_Visita__c == null){
                visita.Hora_da_Visita__c = '08:00';
            }

            if(!pvpsNewOwner.isEmpty() && pvpsNewOwner.get(visita.Planejamento__r.M_s_de_Ref_rencia__c+visita.Planejamento__r.Ano_de_Referencia__c) != null){
                
                visita.Planejamento__c = pvpsNewOwner.get(visita.Planejamento__r.M_s_de_Ref_rencia__c+visita.Planejamento__r.Ano_de_Referencia__c).id;
            }
        }

        system.debug('visitasToUpdate  size: ' + visitasToUpdate.size());

        update visitasToUpdate;
        
    }

    // Finish process
    global void finish(Database.BatchableContext BC) {
        
    }   

}