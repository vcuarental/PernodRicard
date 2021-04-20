public class EUR_CRM_FI_AdminConsoleController{
    public List<EUR_CRM_Visit_Action__c> getVisitActions(){
        return (List<EUR_CRM_Visit_Action__c>)Database.query(EUR_CRM_FI_CreateVisitActionFollowUps.generateQuery());
    }
    public PageReference createFollowUp(){
        EUR_CRM_FI_CreateVisitActionFollowUps.createFollowUps(getVisitActions());
        return null;
    }
    public List<EUR_CRM_Visit_Action__c> getVisitActionsForAccrue(){
        return (List<EUR_CRM_Visit_Action__c>)Database.query(EUR_CRM_FI_AccrueAchievements.generateQuery());
    }
    public PageReference accrue(){
        EUR_CRM_FI_AccrueAchievements.accrue(getVisitActionsForAccrue());
        return null;
    }
     public PageReference refresh(){ 
        return null;
    }
     public PageReference deactiveOPMappings(){
        List<EUR_CRM_ObjPromo_Account_Mapping__c > up = new List<EUR_CRM_ObjPromo_Account_Mapping__c >();
        for( EUR_CRM_ObjPromo_Account_Mapping__c  f : [select id,  EUR_CRM_Is_Active__c from EUR_CRM_ObjPromo_Account_Mapping__c   where EUR_CRM_ObjPromo__c in (select id from EUR_CRM_ObjPromo__c where EUR_CRM_Status__c in ('Ended','Under Evaluation') AND RECORDTYPE.developername in('EUR_FI_On_Trade_O_P','EUR_FI_Off_Trade_O_P')) 
                    AND EUR_CRM_Is_Active__c = true  limit 9000
                    ]){
                    f.EUR_CRM_Is_Active__c = false;
                    up.add(f); 
        } update up; return null; 
                
    }

    public List<EUR_CRM_Survey_Header__c> getSurveyHeaders(){
        return [select name, EUR_CRM_Description__c,EUR_CRM_Valid_From__c, EUR_CRM_Valid_Until__c from EUR_CRM_Survey_Header__c where recordtype.developername in('EUR_FI_OFF_Trade_Survey_Header','EUR_FI_ON_Trade_Survey_Header') and EUR_CRM_Active__c = true and EUR_CRM_Valid_Until__c < today];
    }

    public void deactiveSurveys(){
        String q = EUR_CRM_DeactivateSurveys.generateQuery();
       EUR_CRM_DeactivateSurveys.deactivateSurveys((List<EUR_CRM_Survey__c>)Database.query(q));
    }
}