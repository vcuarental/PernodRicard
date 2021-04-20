/*********************************************************************************
 * Name: ASI_CRM_TW_VolPotentialHandler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/03/2015       Introv: Twinkle         Cloned from ASI_CRM_VolPotentialHandler
*********************************************************************************/

public with sharing class ASI_CRM_TW_VolPotentialHandler extends ASI_CRM_TW_TriggerAbstract {
    
    public ASI_CRM_TW_VolPotentialHandler(){
        super('ASI_CRM_TW_VolPotentialHandler');
    }
    
    public final String UK_TOTAL_SPIRITS_VOLUME_STATEMENT = 'What is total spirits volume per year in bottles?';
    public final String UK_TOTAL_CHAMPAGNE_VOLUME_STATEMENT = 'What is total Champagne volume per year in bottles?';
    public final String VOLUME_POTENTIAL = 'Annual Potential Volume';
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<ASI_CRM_Pros_Volume_Potential__c> volPotentials = (List<ASI_CRM_Pros_Volume_Potential__c>) sObjList;
        Set<Id> prosSegIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> criteriaThreasholdIds = new Set<Id>();
        
        for(ASI_CRM_Pros_Volume_Potential__c volPotential : volPotentials){
            prosSegIds.add(volPotential.ASI_CRM_SG_Pros_Segmentation__c);
            criteriaThreasholdIds.add(volPotential.ASI_CRM_SG_Criteria_Threshold__c);
        }
        
        Map<Id,ASI_CRM_Pros_Segmentation__c> prosSegMap = new Map<Id,ASI_CRM_Pros_Segmentation__c>(
        [select id,ASI_CRM_SG_Customer__c from ASI_CRM_Pros_Segmentation__c where id in: prosSegIds]);
        
        for(Id key : prosSegMap.keySet()){
            accountIds.add(prosSegMap.get(key).ASI_CRM_SG_Customer__c);
        }
        Map<Id,ASI_CRM_AccountsAdditionalField__c> accountMap= new Map<Id,ASI_CRM_AccountsAdditionalField__c>(
        [select id from ASI_CRM_AccountsAdditionalField__c where id in: accountIds]);
        
        Map<Id,ASI_CRM_AccountsAdditionalField__c> prosToAccountMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
        
        for(Id key: prosSegMap.keySet()){
            prosToAccountMap.put(key,accountMap.get(prosSegMap.get(key).ASI_CRM_SG_Customer__c));
        }
        
        Map<Id,ASI_CRM_Criteria_Threshold__c> criteriaThresholdMap = new Map<Id,ASI_CRM_Criteria_Threshold__c>(
        [select id,ASI_CRM_SG_Question__c from ASI_CRM_Criteria_Threshold__c where id in: criteriaThreasholdIds]);
        
        Map<Id,ASI_CRM_AccountsAdditionalField__c> eu_accounts = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_Pros_Volume_Potential__c volPotential : volPotentials){
            ASI_CRM_Pros_Segmentation__c pros = prosSegMap.get(volPotential.ASI_CRM_SG_Pros_Segmentation__c);            
                
                system.debug('++');
                
                ASI_CRM_AccountsAdditionalField__c temp_account = prosToAccountMap.get(pros.id);
                
                if(eu_accounts.get(temp_account.id) == null){
                    eu_accounts.put(temp_account.id,temp_account);
                }
                ASI_CRM_AccountsAdditionalField__c eu_account =  eu_accounts.get(temp_account.id);                
                
                ASI_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdMap.get(volPotential.ASI_CRM_SG_Criteria_Threshold__c);
                                  
        }
        
        //update the eu account
        if(eu_accounts.values().size() > 0){
            update eu_accounts.values();
        }        
    }
}