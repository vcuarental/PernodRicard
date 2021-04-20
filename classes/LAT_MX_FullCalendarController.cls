global without sharing class LAT_MX_FullCalendarController {
    
    global class EventCalendar{
        global String Id {get;set;}
        global Datetime StartDate {get;set;}
        global Datetime EndDate {get;set;}
        global String Tittle {get;set;}
        global Boolean isAllDayEvent {get;set;}
        global EventCalendar(){}
    }
    
    @RemoteAction
    global static List<EventCalendar> getEvents(String startDate, String endDate, String idPlan){
        
        List<EventCalendar> events = new List<EventCalendar>();
        
        for(Visitas__c vis: [SELECT id, Name, Data_da_Visita__c, Hora_da_Visita__c, Visita_n_o_realizada__c, RecordType.DeveloperName, Conta__c, Conta__r.Name FROM Visitas__c WHERE Planejamento__c =: idPlan AND Data_da_Visita__c != NULL AND Hora_da_Visita__c != NULL]){
            if(!vis.Visita_n_o_realizada__c){
                EventCalendar evCal = new EventCalendar();
                evCal.Id = vis.Id;
                evCal.StartDate = DateTime.newInstance(vis.Data_da_Visita__c.year(), vis.Data_da_Visita__c.month(), vis.Data_da_Visita__c.day(), integer.valueOf(vis.Hora_da_Visita__c.Split(':')[0]),   integer.valueOf(vis.Hora_da_Visita__c.Split(':')[1]), 0);
                evCal.EndDate   = DateTime.newInstance(vis.Data_da_Visita__c.year(), vis.Data_da_Visita__c.month(), vis.Data_da_Visita__c.day(), integer.valueOf(vis.Hora_da_Visita__c.Split(':')[0])+1, integer.valueOf(vis.Hora_da_Visita__c.Split(':')[1]), 0);
                /*
                if(UserInfo.getLocale() == 'es_MX'){
                    evCal.StartDate = evCal.StartDate.addHours(-3);
                    evCal.EndDate = evCal.EndDate.addHours(-3);
                }
                */
                evCal.Tittle = '- ' + vis.Conta__r.Name + ' - ' + vis.Name;
                evCal.isAllDayEvent = false;
                events.add(evCal);
            }
        }
        
        return events;
    } 
    
    @RemoteAction
    global static EventCalendar CreateEvent(String Tittle, String startDate, String endDate,String allDay){
        /*
        event.StartDate = convertStringDateTime(startDate);
        event.EndDate = convertStringDateTime(endDate);
        event.Tittle =Tittle;
        event.isAllDayEvent =boolean.valueof(allDay);    
        insert event;
        return event;
        */
        return null;
    } 
    
    @RemoteAction
    global static String updateEvent(String id, String Tittle, String startDate, String endDate, Boolean isAllDayEvent, String ciente){
        
        String MessageRtn = '';
        
        Visitas__c vis = [Select id from Visitas__c where id =: id];
        vis.Data_da_Visita__c = convertStringDateTime(startDate).Date();
        vis.Hora_da_Visita__c = convertStringDateTime(startDate).Hour()<10?('0'+convertStringDateTime(startDate).Hour()):(String.valueOf(convertStringDateTime(startDate).Hour()));
        vis.Hora_da_Visita__c += ':';
        vis.Hora_da_Visita__c += convertStringDateTime(startDate).Minute()<10?('0'+convertStringDateTime(startDate).Minute()):(String.ValueOf(convertStringDateTime(startDate).Minute()));
        vis.ciente__c = Boolean.valueOf(ciente);
        
        DataBase.Saveresult visSR = DataBase.update(vis, false);
        if (!visSR.isSuccess()) {
            Database.Error[] errors = visSR.getErrors();
            MessageRtn = errors.get(0).getMessage();
        }
        
        return MessageRtn;
    }
    
    @RemoteAction
    global static void deleteEvent(String id){
        delete [Select id from Visitas__c where id =: id];
    }
    
    /********************************************************************************/
    /*                          METODOS PRIVADOS                                     /  
    /********************************************************************************/
    private static DateTime convertStringDateTime(String stringDate){
        Datetime dt = DateTime.newInstance(long.valueof(stringDate));
        /*
        if(UserInfo.getLocale() == 'es_MX'){
            dt = dt.addHours(3);
        }
        */
        return dt;
    }
}