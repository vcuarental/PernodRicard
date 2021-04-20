public class EUR_CRM_ZA_RT_Clear_Calendar{

    public EUR_CRM_Route_Template__c rTemplate {get;set;}
    public Integer eventCtr {get;set;}
    public Date dateToday {get;set;}
    public Boolean isDisabled {get;set;}

    public EUR_CRM_ZA_RT_Clear_Calendar(ApexPages.StandardController stdController) {
        this.rTemplate = (EUR_CRM_Route_Template__c)stdController.getRecord();
        dateToday = Date.Today();
        eventCtr = 0;
        isDisabled = TRUE;
        checkEvents();
    }
    
    public void checkEvents(){
        String rtId = String.valueOf(rTemplate.Id).substring(0, 15);
        Date deleteDate = Date.Today() + 1;
        Datetime dt = Datetime.newInstance(deleteDate.year(), deleteDate.month(),deleteDate.day());
        List<Event> eventDelete = [SELECT Id FROM Event WHERE StartDateTime > :dt AND EUR_CRM_Route_Template__c =:rtId];

        eventCtr = eventDelete.size();
        if(eventDelete.size() > 0){
            isDisabled = FALSE;
        }
    }

    public pageReference deleteEvents(){
        Id rtempId = apexpages.currentpage().getparameters().get('id');
        
        Date deleteDate = Date.Today() + 1;
        Datetime dt = Datetime.newInstance(deleteDate.year(), deleteDate.month(),deleteDate.day());

        String rtId = String.valueOf(rtempId).substring(0, 15);

        List<Event> eventDelete = new List<Event>();
        Set<Id> rtItemIds = new Set<Id>();

        for(Event e : [SELECT Id, EUR_CRM_Route_Template_Item__c FROM Event WHERE StartDateTime > :dt AND EUR_CRM_Route_Template__c =:rtId]){
            eventDelete.add(e);
            rtItemIds.add(e.EUR_CRM_Route_Template_Item__c);
        }
        
        eventCtr = eventDelete.size();
        
        if(eventDelete.size() > 0){
            delete eventDelete;
        }
        
        List<EUR_CRM_Route_Template_Item__c> rtItemDelete = [SELECT Id FROM EUR_CRM_Route_Template_Item__c WHERE Id IN :rtItemIds];
        
        if(rtItemDelete.size() > 0){
            delete rtItemDelete;
        }

        //rTemplate = [SELECT Id, EUR_CRM_Active__c FROM EUR_CRM_Route_Template__c WHERE Id = :rtempId];

        rTemplate.EUR_CRM_Active__c = FALSE;
        update rTemplate;
        
        return new Pagereference('/' + rTemplate.Id);
    }

}