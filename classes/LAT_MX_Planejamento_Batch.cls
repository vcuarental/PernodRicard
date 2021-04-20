global class LAT_MX_Planejamento_Batch implements Database.Batchable<sObject> {
    
    String query;
    
    global LAT_MX_Planejamento_Batch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> integrationUsers = LAT_GeneralConfigDao.getValueAsStringArray('INTEGRATION_USERS',',');
        if(integrationUsers == null){
            integrationUsers = new List<String>();
        }
        List<AggregateResult> owners = [SELECT owner.id FROM Account where (recordtype.developerName = 'LAT_MX_ACC_OffTrade' or recordtype.developerName = 'LAT_MX_ACC_OnTrade') AND  Rating <> 'Cliente inativo'  AND Status__c != 'Não aprovado' AND owner.name not in: integrationUsers group by owner.id];
        query = 'SELECT Id FROM User where id in (\'\'' ;
        
        for(AggregateResult ar : owners){
            query += ',\'' + ar.get('id') + '\'';
        }
        query += ')';


        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        generateMonthlyPlans(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    /*****************************************************************************************
    * Nombre del metodo: generateMonthlyPlans
    * Descripcion: Genera los planes para todos los vendedores para el mes siguiente
    * Desarrollador: Zimmic
    * Fecha: 04/07/2017
    *****************************************************************************************/
    public static void generateMonthlyPlans(List<User> owners){
        Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
        List<Planejamento__c> toInsert = new List<Planejamento__c>();
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');

        Date nextMonth = Date.today().addMonths(3);
        for(User ar : owners){
            Planejamento__c plan = new Planejamento__c();
            plan.RecordTypeId = rtpla;
            plan.name = 'Name';
            plan.Status_do_Planejamento__c = 'Não Iniciado';
            plan.Ano_de_Referencia__c = String.valueOf(nextMonth.year());
            plan.M_s_de_Ref_rencia__c = monthsByNum.get(nextMonth.month());
            plan.ownerId = ar.id;
            toInsert.add(plan);
        }

        Database.SaveResult[] results = Database.Insert(toInsert, false);
        
    }
    
}