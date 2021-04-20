public with sharing class EUR_CRM_DeleteOldProsImageVolPotHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_DeleteOldProsImageVolPotHandler(){
        super('EUR_CRM_DeleteOldProsImageVolPotHandler');
    }
    
    Set<Id> prosSegmentations = new Set<Id>();
    Set<Id> criteriaThresholds = new Set<Id>();
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if(sObjList.get(0) instanceof EUR_CRM_Pros_Image_Level__c){       
            deleteProsImageLevels((List<EUR_CRM_Pros_Image_Level__c>) sObjList,newMap.keySet());
        }else if(sObjList.get(0) instanceof EUR_CRM_Pros_Volume_Potential__c){
            deleteProsVolumePotentials((List<EUR_CRM_Pros_Volume_Potential__c >) sObjList,newMap.keySet());
        }
    }
    
    public void deleteProsImageLevels(List<EUR_CRM_Pros_Image_Level__c> prosImageList, Set<Id> prosImages){
        for(EUR_CRM_Pros_Image_Level__c prosImage : prosImageList){
            prosSegmentations.add(prosImage.EUR_CRM_Pros_Segmentation__c);
            criteriaThresholds.add(prosImage.EUR_CRM_Criteria_Threshold__c);
        }
        
        //select all pros image level where its under the same pros segmentation and same criteria threshold
        //then delet
        List<EUR_CRM_Pros_Image_Level__c> toDeleteProsImageLevels = [select id from EUR_CRM_Pros_Image_Level__c
        where EUR_CRM_Pros_Segmentation__c in:prosSegmentations 
        and EUR_CRM_Criteria_Threshold__c in:criteriaThresholds
        and id not in:prosImages];
        
        if(toDeleteProsImageLevels != null && toDeleteProsImageLevels.size() > 0){
            try{
                delete toDeleteProsImageLevels;
                system.debug('Succesfully deleted pros image levels: ' + toDeleteProsImageLevels); 
            }catch(DMLException e){
                system.debug('Error in Deleting PROS Image Level: ' + e);
            }
        }
    }
    
    public void deleteProsVolumePotentials(List<EUR_CRM_Pros_Volume_Potential__c > prosVolPotList, Set<Id> prosVolpots){
        for(EUR_CRM_Pros_Volume_Potential__c prosVolPot : prosVolPotList){
            prosSegmentations.add(prosVolPot.EUR_CRM_Pros_Segmentation__c);
            criteriaThresholds.add(prosVolPot.EUR_CRM_Criteria_Threshold__c);
        }
        
        //select all pros image level where its under the same pros segmentation and same criteria threshold
        //then delet
        List<EUR_CRM_Pros_Volume_Potential__c > toDeleteProsVolPots = [select id from EUR_CRM_Pros_Volume_Potential__c
        where EUR_CRM_Pros_Segmentation__c in:prosSegmentations 
        and EUR_CRM_Criteria_Threshold__c in:criteriaThresholds
        and id not in:prosVolpots];
        
        if(toDeleteProsVolPots != null && toDeleteProsVolPots.size() > 0){
            try{
                delete toDeleteProsVolPots;
                system.debug('Succesfully deleted vol potentials: ' + toDeleteProsVolPots); 
            }catch(DMLException e){
                system.debug('Error in Deleting PROS Volume Potentials: ' + e);
            }
        }
    }
}