public with sharing class LAT_BR_VFC02_VisitasCalenController {
    
    public list<Visitas__c> listaVisitas {get;set;}
    public List<wrapper> listWrapper {get;set;}
    public list<LAT_CWH_ClientWorkHour__c> listaClientWorkHour {get;set;}
    public Id idPlanejamento {get;set;}
    public String country {get;set;}
    public String month {get;set;}
    public String year {get;set;}
    
    private Set<Id> setIdCuentas;
    
    public class wrapper {
        public boolean isCheckbox {get;set;}
        public Visitas__c visita {get;set;}
        public wrapper(Visitas__c visitaParam){
            isCheckbox = false;
            this.visita = visitaParam;
        }
    }
    
    public LAT_BR_VFC02_VisitasCalenController(){
        
        idPlanejamento = ApexPages.currentPage().getparameters().get('idPlanejamento');
        setIdCuentas = new Set<Id>();
        listWrapper = new List<wrapper>();
        if(idPlanejamento != null){
            listaVisitas = [SELECT Id, Name, Data_da_Visita__c, Hora_da_Visita__c, Visita_n_o_realizada__c, Tipo_de_Visita__c, Status__c, Conta__c FROM Visitas__c WHERE Planejamento__c =: idPlanejamento ORDER BY Data_da_Visita__c, Hora_da_Visita__c, Conta__c];
            for (Visitas__c v: listaVisitas){
                setIdCuentas.add(v.Conta__c);
                if(v.Visita_n_o_realizada__c){
                    listWrapper.add(new wrapper(v));
                }
            }
            
            listaClientWorkHour = [SELECT Name, Account__c, // Frequency_of_Visits__c,
                            Monday_1st_period_begin_Time__c, Monday_1st_period_End_Time__c, Monday_2nd_period_begin_Time__c, Monday_2nd_period_End_Time__c,
                            Tuesday_1st_period_begin_Time__c, Tuesday_1st_period_End_Time__c, Tuesday_2nd_period_begin_Time__c, Tuesday_2nd_period_End_Time__c,
                            Wednesday_1st_period_begin_Time__c, Wednesday_1st_period_End_Time__c, Wednesday_2nd_period_begin_Time__c, Wednesday_2nd_period_End_Time__c,
                            Thursday_1st_period_begin_Time__c, Thursday_1st_period_End_Time__c, Thursday_2nd_period_begin_Time__c, Thursday_2nd_period_End_Time__c,
                            Friday_1st_period_begin_Time__c, Friday_1st_period_End_Time__c, Friday_2nd_period_begin_Time__c, Friday_2nd_period_End_Time__c,
                            Saturday_1st_period_begin_Time__c, Saturday_1st_period_End_Time__c, Saturday_2nd_period_begin_Time__c, Saturday_2nd_period_End_Time__c,
                            Sunday_1st_period_begin_Time__c, Sunday_1st_period_End_Time__c, Sunday_2nd_period_begin_Time__c, Sunday_2nd_period_End_Time__c, Account__r.Frequency_of_Visits__c
                            FROM LAT_CWH_ClientWorkHour__c
                            WHERE Account__c in: setIdCuentas];
        }   
        
        
        Planejamento__c Plan = [ SELECT Id, RecordType.DeveloperName, Ano_de_Referencia__c, M_s_de_Ref_rencia__c FROM Planejamento__c WHERE Id =: idPlanejamento ];       
        if(Plan.RecordType.DeveloperName == 'BRA_Standard'){ country = 'BR';
            Map<String,String> mapMonths = new Map<String,String> {
                'Janeiro' => '0', 'Fevereiro' => '1', 'Março' => '2', 'Abril' => '3', 'Maio' => '4', 'Junho' => '5', 'Julho' => '6',
                'Agosto' => '7', 'Setembro' => '8', 'Outubro' => '9', 'Novembro' => '10', 'Dezembro' => '11'
            };
            year = plan.Ano_de_Referencia__c;
            month = mapMonths.get(plan.M_s_de_Ref_rencia__c);  
        }
        if(Plan.RecordType.DeveloperName == 'PLV_Standard_AR' || Plan.RecordType.DeveloperName == 'PLV_Standard_UY'){ 
            country = 'AR';
            year = string.valueof(date.today().year());
            month = string.valueof(date.today().month());
        }
        if(Plan.RecordType.DeveloperName == 'LAT_MX_PLV_Approved' || Plan.RecordType.DeveloperName == 'LAT_MX_PLV_NewPlanning'){ 
            country = 'MX';
            year = string.valueof(date.today().year());
            month = string.valueof(date.today().month());
        }

             
        
    }
    
    public pageReference doVolver(){
        // Método que sirve para volver al planejamento
        return new pagereference ('/'+idPlanejamento);
    }
    
    public void doRecuperar(){
        list<Visitas__c> listaVisitasToUpdate = new list<Visitas__c>();
        
        Boolean isError = false;
        for(Integer i=0; i<listWrapper.size(); i++){
            if(listWrapper[i].isCheckbox){
                if(listWrapper[i].visita.Data_da_Visita__c == null){
                    listWrapper[i].visita.Data_da_Visita__c.addError(Label.LAT_BR_VFC10_00002);
                    isError = true;
                }
                if(listWrapper[i].visita.Hora_da_Visita__c == null){
                    listWrapper[i].visita.Hora_da_Visita__c.addError(Label.LAT_BR_VFC10_00002);
                    isError = true;
                }
            }
        }
        
        if(isError){
            return;
        }
        
        for(Integer i=0; i<listWrapper.size(); i++){
            if(listWrapper[i].isCheckbox){
                listWrapper[i].visita.Visita_n_o_realizada__c = false;
                listWrapper[i].visita.Poss_veis_motivos__c = '';
                listWrapper[i].visita.Descrever_Motivo__c = '';
                listaVisitasToUpdate.add(listWrapper[i].visita);
                listWrapper.remove(i);
                i--;
            }
        }
        
        try{update listaVisitasToUpdate;}catch(exception e){}
    }
}