/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Planejamento__c
*******************************************************************************/

public with sharing class LAT_MX_AP01_Planejamento{

    private static BusinessHours stdBusinessHours;    
       
    /*****************************************************************************************
    * Nombre del metodo: newPlanejamentoValidations
    * Descripcion: Method that creates the Visits for a Planemiento
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 28/10/2013
    * Modo: before insert
    *****************************************************************************************/
    public static void newPlanejamentoValidations (List<Planejamento__c> triggerNew){
        map<String, Date> monthYearFirstMonday = new map<String, Date>();
        map<String, String> mapPlanVisit = new map<String, String>();
        map<String, Id> mapVisit = new map<String, Id>();
        map<String, Id> mapPlan = new map<String, Id>();
        list<Planejamento__c> listPlanejamentos = new list< Planejamento__c>();
        Set<String> setPlanjementoOwners = new Set<String>();
        list<String> listIdsPlan = new list<String>();
    
        String rtVisita = Global_RecordTypeCache.getRtId('Visitas__c'+'LAT_MX_VTS_PlannedVisit');
        String rtVisitaON = Global_RecordTypeCache.getRtId('Visitas__c'+'LAT_MX_VTS_PlannedVisitON');
        String rtPlanej = Global_RecordTypeCache.getRtId('Planejamento__c'+'LAT_MX_PLV_NewPlanning');
        String rtAccountOff = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        String rtAccountOn = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
        
        for(Planejamento__c p : triggerNew){
            listIdsPlan.add(p.Id);
            setPlanjementoOwners.add(p.OwnerId);
        }
        
        if(setPlanjementoOwners.size() == 0 ) return;
        
        stdBusinessHours = [SELECT Id FROM Businesshours WHERE isDefault = TRUE];  
        
        //Recupera todas as contas que possuem proprietarios que estão dentro da lista de proprietarios dos planejamentos.
        //Filtrar se a conta é desse planejamento
        map<Id, list<Account>> mapOwnerAccount = new map<Id, list<Account>>();
        
        Set<id> setIdAccounts = new Set<id>();
        
        List<Account> listAccount = [SELECT Id, Name, Channel__c, Regional__c, Frequency_of_Visits__c, OwnerId,Status__c, Type,RecordTypeId
                                     FROM Account 
                                     WHERE OwnerId IN: setPlanjementoOwners AND Status__c != 'Inactive Account' 
                                     AND (RecordTypeId =: rtAccountOn OR (RecordTypeId =: rtAccountOff AND Type != 'Execution Store' AND Type != 'Store that provides information'))];
                              
        for(Account acc: listAccount){
            if(mapOwnerAccount.containsKey(acc.OwnerId)){
                mapOwnerAccount.get(acc.OwnerId).add(acc);
            }else{
                mapOwnerAccount.put(acc.OwnerId, new list<Account>{acc});
            }
            setIdAccounts.add(acc.Id);
        }
        if(mapOwnerAccount.isEmpty())return;
        
        listPlanejamentos = [SELECT Id FROM Planejamento__c WHERE Id =: listIdsPlan AND RecordTypeId =: rtPlanej];        
        Map<Id,User> usuariosMobileMX = new Map<Id,User>([SELECT Id, Name, LAT_MX_PlansVisitsAutomatically__c 
                                                           FROM User Where Profile.Name = 'LAT_MX2_Vendedor' 
                                                           OR Profile.Name = 'LAT_MX2_OnPremise'
                                                           OR Profile.Name = 'LAT_MX2_Vendedor_OnPremise']);
        //Creacion de visitas
        List<Visitas__c> lVisitaList = new List<Visitas__c>();
        for(Planejamento__c p : triggerNew){

            if(usuariosMobileMX.keySet().contains(p.OwnerId)) {
                if (usuariosMobileMX.get(p.OwnerId).LAT_MX_PlansVisitsAutomatically__c) {
                    //Se recorren todos los account del owner del planejamento y por cada uno se crean un conjunto de visitas
                    for(Account lAcc: mapOwnerAccount.get(p.OwnerId)){
                        Integer lMonth = getMonth(p.M_s_de_Ref_rencia__c);
                        Integer lNumVisitas = getPeriodicity(lAcc.Frequency_of_Visits__c, integer.ValueOf(p.Ano_de_Referencia__c), lMonth);
                        
                        String recordTVis = rtVisita;
                        if (lAcc.RecordTypeId == rtAccountOn) {
                            recordTVis = rtVisitaON;
                        }

                        //Se crean las visitas segun la cantidad correspondiente a la frecuencia del cliente
                        for(Integer i = 0; i <= lNumVisitas - 1; i++){
                            String nome = 'Planejamento de visitas - '+ lAcc.Name;
                            Visitas__c vis = new Visitas__c(
                                Name = nome.length() > 80 ? nome.substring(0,79) : nome,
                                Planejamento__c = p.Id,
                                Conta__c = lAcc.Id,
                                RecordTypeId = recordTVis,
                                Trigger_on__c = true
                            );
                            if(vis!=null){lVisitaList.add(vis);}
                        }
                    }
                }
            }
        }
        //Verifica se existe visitas para serem inseridas no ambiente.
        if(lVisitaList.size() > 0){
            try{
                insert lVisitaList;
            } catch(DmlException e){
                for(Planejamento__c p : triggerNew){
                    p.addError('Error: '+e.getDmlMessage(0));
                }
                return;
            }
        }
        
        if(listPlanejamentos.size() > 0){
            try{
                update listPlanejamentos;
            }catch(DMLException e){
                System.debug(e.getMessage());
            }
        }    
    }
    
    public static Integer getMonth(String aMonth){
        Map<String,Integer> monthOfYear = new Map<String,Integer>();
        monthOfYear.put('Janeiro', 1);
        monthOfYear.put('Fevereiro', 2);
        monthOfYear.put('Março', 3);
        monthOfYear.put('Abril', 4);
        monthOfYear.put('Maio', 5);
        monthOfYear.put('Junho', 6);
        monthOfYear.put('Julho', 7);
        monthOfYear.put('Agosto', 8);
        monthOfYear.put('Setembro', 9);
        monthOfYear.put('Outubro', 10);
        monthOfYear.put('Novembro', 11);
        monthOfYear.put('Dezembro', 12);
        return monthOfYear.get(aMonth);
    }
    
    public static Integer getPeriodicity(String aPeriodicity, Integer aYear, Integer aMonth){
        if(aPeriodicity == 'Diária') return getBusinessDay(aYear, aMonth);
        else if(aPeriodicity == '2 x Semana') return 8;
        else if(aPeriodicity == 'Semanal') return 4;
        else if(aPeriodicity == 'Quinzenal') return 2;
        else if(aPeriodicity == 'Mensal') return 1;
        else return 0;
    }
    
    public static Integer getBusinessDay(Integer aYear, Integer aMonth){
             
        Integer lQtt = Date.daysInMonth(aYear, aMonth);
        Integer lCount = 0;
        
        for (Integer i = 1; i <= lQtt; i++){
            Date lCheckDate = date.newInstance(aYear, aMonth, i);
            DateTime lDate = BusinessHours.add(stdBusinessHours.Id, lCheckDate, 1).date();
            if (lDate.isSameDay(lCheckDate)) 
                lCount++;
        }
        if(lCount == 0){
            for(Integer i=1; i<=lQtt; i++){
                DateTime lCheckDate = Datetime.newInstance(aYear, aMonth, i);
                String lDayOfWeek = lCheckDate.format('EEE');
                if(!lDayOfWeek.equalsIgnoreCase('SAT') && !lDayOfWeek.equalsIgnoreCase('SUN'))
                    lCount++;
            }
        }
        return lCount;
    }
    
    /*****************************************************************************************
    * Nombre del metodo: changeNametoPlanejamento
    * Descripcion: Cambia el nombre del planejamiento según la siguiente estructura: ‘Nombre del Usuario que ejecuta el proceso’ + guion + 'M_s_de_Ref_rencia__c/Ano_de_Referencia__c’
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 29/10/2013
    * Modo: before insert
    *****************************************************************************************/
    public static void changeNametoPlanejamento(List<Planejamento__c> newTrigger){
        map<String, String> mapPickValueTraslate = new map<String, String>();

        Schema.DescribeFieldResult F = Planejamento__c.M_s_de_Ref_rencia__c.getDescribe();
        List <Schema.PicklistEntry> picklistValues = F.getPicklistValues();
    
        for(Schema.PicklistEntry entry :picklistValues){
            if(entry != null){
                mapPickValueTraslate.put(entry.getValue(), entry.getLabel());
            }
        }
    
        for(Planejamento__c reg :newTrigger){
            User kam = [SELECT id, FirstName, LastName FROM User WHERE id = :reg.OwnerId];
            reg.Name = kam.FirstName + ' ' + kam.LastName + ' - ' + mapPickValueTraslate.get(reg.M_s_de_Ref_rencia__c) + '/' + reg.Ano_de_Referencia__c;
        }
    }

    public static void setVisitFrequencyAtApproval(Map<Id,Planejamento__c> newMap, Map<Id,Planejamento__c> oldMap) {
        System.debug('entramos en setVisitFrequencyAtApproval ');
        List<Planejamento__c> toUpdate = new List<Planejamento__c>(); 
        for (Planejamento__c plan : OldMap.values()) {
            System.debug('entramos en setVisitFrequencyAtApproval en el for plan : '+plan.RecordType.DeveloperName);
            if (plan.RecordTypeId == Global_RecordTypeCache.getRtId('Planejamento__c'+'LAT_MX_PLV_NewPlanning') ||  (plan.Status_do_Planejamento__c == 'Approved' && (OldMap.get(plan.Id).Status_do_Planejamento__c == 'Modification proposed' || OldMap.get(plan.Id).Status_do_Planejamento__c == 'Aguardando Aprovação'))) {
                toUpdate.add(plan);
                System.debug('entramos en setVisitFrequencyAtApproval agregamos a ToUpdate ');
            }
        }

        if (toUpdate.size() > 0) {
            Map<String, Planejamento__c> plansByOwnerIds = new Map<String, Planejamento__c>();
            for (Planejamento__c p : toUpdate) {
                plansByOwnerIds.put(p.OwnerId, p);
            }
            List<AggregateResult> ag = [SELECT SUM(LAT_Account__r.LAT_MX_Periodicity__c) totalVisitas, OwnerId FROM Account WHERE OwnerId IN :plansByOwnerIds.keySet() GROUP BY OwnerId];
            for (AggregateResult ar : ag)  {
                System.debug('totalVisitas : ' + ar.get('totalVisitas'));
                System.debug('OwnerId : ' + ar.get('OwnerId'));
                String owner = String.valueOf(ar.get('OwnerId'));
                newMap.get(plansByOwnerIds.get(owner).Id).MX_Month_Visits__c = (Decimal)ar.get('totalVisitas');
            }

        }
    }
}