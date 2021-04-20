public without sharing class EUR_CRM_VolPotentialHandler extends EUR_CRM_TriggerAbstract {
    
    public EUR_CRM_VolPotentialHandler(){
        super('EUR_CRM_VolPotentialHandler');
    }
    
    public final String UK_TOTAL_SPIRITS_VOLUME_STATEMENT = 'What is total spirits volume per year in bottles?';
    public final String UK_TOTAL_CHAMPAGNE_VOLUME_STATEMENT = 'What is total Champagne volume per year in bottles?';
    public final String AT_VOLUME_POTENTIAL = 'Annual Potential Volume';
    /**
        
    */
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<EUR_CRM_Pros_Volume_Potential__c> volPotentials = (List<EUR_CRM_Pros_Volume_Potential__c>) sObjList;
        Set<Id> prosSegIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> criteriaThreasholdIds = new Set<Id>();
        
        for(EUR_CRM_Pros_Volume_Potential__c volPotential : volPotentials){
            prosSegIds.add(volPotential.EUR_CRM_Pros_Segmentation__c);
            criteriaThreasholdIds.add(volPotential.EUR_CRM_Criteria_Threshold__c);
        }
        
        Map<Id,EUR_CRM_Pros_Segmentation__c> prosSegMap = new Map<Id,EUR_CRM_Pros_Segmentation__c>(
        [select id,EUR_CRM_Country_Code__c,EUR_CRM_Account__c from EUR_CRM_Pros_Segmentation__c where id in: prosSegIds]);
        
        for(Id key : prosSegMap.keySet()){
            accountIds.add(prosSegMap.get(key).EUR_CRM_Account__c);
        }
        Map<Id,EUR_CRM_Account__c> accountMap= new Map<Id,EUR_CRM_Account__c>(
        [select id,EUR_CRM_Total_Spirits_Volume__c,EUR_CRM_Total_Champaign_Volume__c from EUR_CRM_Account__c where id in: accountIds]);
        
        Map<Id,EUR_CRM_Account__c> prosToAccountMap = new Map<Id,EUR_CRM_Account__c>();
        
        for(Id key: prosSegMap.keySet()){
            prosToAccountMap.put(key,accountMap.get(prosSegMap.get(key).EUR_CRM_Account__c));
        }
        
        Map<Id,EUR_CRM_Criteria_Threshold__c> criteriaThresholdMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>(
        [select id,EUR_CRM_Question__c,EUR_CRM_Total_Spirits_Volume__c ,
        EUR_CRM_Total_Champagne_Volume__c  from EUR_CRM_Criteria_Threshold__c where id in: criteriaThreasholdIds]);
        
        Map<Id,EUR_CRM_Account__c> eu_accounts = new Map<Id,EUR_CRM_Account__c>();
        
        for(EUR_CRM_Pros_Volume_Potential__c volPotential : volPotentials){
            EUR_CRM_Pros_Segmentation__c pros = prosSegMap.get(volPotential.EUR_CRM_Pros_Segmentation__c);            
            if(pros.EUR_CRM_Country_Code__c == 'GB' || pros.EUR_CRM_Country_Code__c == 'UK'){
                //copy spirit and champaign
                system.debug('++ pros' + pros.id);
                
                EUR_CRM_Account__c temp_account = prosToAccountMap.get(pros.id);
                
                if(eu_accounts.get(temp_account.id) == null){
                    eu_accounts.put(temp_account.id,temp_account);
                }
                EUR_CRM_Account__c eu_account =  eu_accounts.get(temp_account.id);                
                //EUR_CRM_Total_Champagne_Volume__c
                //EUR_CRM_Total_Spirit_Volume__c
                EUR_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdMap.get(volPotential.EUR_CRM_Criteria_Threshold__c);
                if(criteriaThreshold.EUR_CRM_Total_Spirits_Volume__c){
                    eu_account.EUR_CRM_Total_Spirits_Volume__c = Decimal.valueOf(volPotential.EUR_CRM_Answer__c); 
                }else if(criteriaThreshold.EUR_CRM_Total_Champagne_Volume__c ){
                    eu_account.EUR_CRM_Total_Champaign_Volume__c = Decimal.valueOf(volPotential.EUR_CRM_Answer__c); 
                }
                    
            }
            if(pros.EUR_CRM_Country_Code__c == 'AT'){
                //copy spirit and champaign
                system.debug('++: ' + pros.id);
                
                EUR_CRM_Account__c temp_account = prosToAccountMap.get(pros.id);
                
                if(eu_accounts.get(temp_account.id) == null){
                    eu_accounts.put(temp_account.id,temp_account);
                }
                EUR_CRM_Account__c eu_account =  eu_accounts.get(temp_account.id);                
                
                EUR_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdMap.get(volPotential.EUR_CRM_Criteria_Threshold__c);
                if(criteriaThreshold.EUR_CRM_Question__c  == AT_VOLUME_POTENTIAL ){
                    eu_account.EUR_CRM_Volume_Potential_Amount__c = Decimal.valueOf(volPotential.EUR_CRM_Answer__c); 
                }                    
            }
        }
        
        //update the eu account
        if(eu_accounts.values().size() > 0){
            update eu_accounts.values();
        }
        
    }
}