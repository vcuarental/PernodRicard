public class EUR_CRM_ZA_AdminConsoleController{
    public String countryCode;
    
    EUR_CRM_MassUpdateCriteriaSetBatch criteriaBatchCon;
    EUR_CRM_MassUpdateImageLevelThreshold imageLevelThresholdCon;
    EUR_CRM_MassUpdateVolumeLevelThreshold volumeLevelThresholdCon;
    public EUR_CRM_ZA_AdminConsoleController(){
        countryCode = 'ZA';
               
        criteriaBatchCon = new EUR_CRM_MassUpdateCriteriaSetBatch();
        criteriaBatchCon.countryCodeStr = countryCode;

        imageLevelThresholdCon = new EUR_CRM_MassUpdateImageLevelThreshold();
        imageLevelThresholdCon.countryCodeStr = countryCode;
        volumeLevelThresholdCon = new EUR_CRM_MassUpdateVolumeLevelThreshold();
        volumeLevelThresholdCon.countryCodeStr = countryCode;
    }

    public void massUpdateImageLevelThreshold(){
        imageLevelThresholdCon.runBatchJob();
    }
    public void massUpdateVolumeLevelThreshold(){
        volumeLevelThresholdCon.runBatchJob();
    }

    public void massUpdateCriteriaSetImageLevel(){ 
        criteriaBatchCon.runImageBatchJob();
    }
    public void massUpdateCriteriaSetVolumeLevel(){ 
        criteriaBatchCon.runVolumeBatchJob();           
    }    
    
    public List<EUR_CRM_Visit_Action__c> getVisitActions(){
        // TODO: Generate query 2
        //return Database.getQueryLocator(EUR_CRM_ZA_CreateVisitActionFollowUps.generateQuery2());
        //System.debug('$TEST: '+EUR_CRM_ZA_CreateVisitActionFollowUps.generateQuery2());
        //return EUR_CRM_ZA_CreateVisitActionFollowUps.getVisitActionList();
        return null;
    }
    public PageReference createFollowUp(){
        //EUR_CRM_FI_CreateVisitActionFollowUps.createFollowUps(getVisitActions());
        //EUR_CRM_ZA_CreateVisitActionFollowUps createFollowUps = new EUR_CRM_ZA_CreateVisitActionFollowUps();
        EUR_CRM_ZA_MassUpdateOPAccountMapping createFollowUps = new EUR_CRM_ZA_MassUpdateOPAccountMapping(); 
        Database.executeBatch(createFollowUps, 200);
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