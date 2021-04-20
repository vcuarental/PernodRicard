public with sharing class EUR_CRM_Route_Template_SummaryPage_Ext {

    private EUR_CRM_Route_Template__c routeTemplateObj {get; set;}
    private Set<String> countriesToOverRideDetails = new Set<String> {'DK'};
    public Set<String> missingFieldsSet {get; set;}
    public Map<String, String> missingFieldsLabelMap {get; set;}
    public Map<String, String> missingFieldsMap {get; set;}
    public String missingFieldsMapString {get{return JSON.serialize(missingFieldsMap);} set;}
    public String missingFieldsLabelMapString {get{return JSON.serialize(missingFieldsLabelMap);} set;}
    public Boolean showStandardDetail {get; set;}

    public EUR_CRM_Route_Template_SummaryPage_Ext(ApexPages.StandardController standardController){
        routeTemplateObj = (EUR_CRM_Route_Template__c)standardController.getRecord();
        showStandardDetail = true;

        if(countriesToOverRideDetails.contains(routeTemplateObj.EUR_CRM_Country_Code__c)){
            showStandardDetail = false;

            missingFieldsSet = new Set<String>{'EUR_CRM_Max_Planning_Period_Week__c', 'EUR_CRM_Planning_Period__c', 'EUR_CRM_Reminder_Day__c'};

            missingFieldsMap = new Map<String, String>();
            missingFieldsLabelMap = new Map<String, String>{
                'EUR_CRM_Max_Planning_Period_Week__c' => 'Max Planning Period (Week)',
                'EUR_CRM_Planning_Period__c' => 'Planning Period', 
                'EUR_CRM_Reminder_Day__c' => 'Reminder Day'
            };


            
            EUR_CRM_Route_Template__c tempRouteTemplate = [SELECT Id, EUR_CRM_Max_Planning_Period_Week__c, EUR_CRM_Planning_Period__c, EUR_CRM_Reminder_Day__c
                                                            FROM EUR_CRM_Route_Template__c 
                                                            WHERE Id =: routeTemplateObj.Id];
            for(String key : missingFieldsSet){
                System.debug(tempRouteTemplate);
                System.debug(key);
                System.debug(tempRouteTemplate.get(key));
                system.debug(missingFieldsMap);
                if(tempRouteTemplate.get(key) != null){
                    missingFieldsMap.put(key, String.valueOf(tempRouteTemplate.get(key)));
                }
            }
            System.debug(tempRouteTemplate);
        }
    }
}