/*********************************************************************************
 * Name: ASI_CRM_TH_DeleteOldProsImageHandler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_DeleteOldProsImageHandler
*********************************************************************************/
public without sharing class ASI_CRM_TH_DeleteOldProsImageHandler extends ASI_CRM_TH_TriggerAbstract {

    public ASI_CRM_TH_DeleteOldProsImageHandler(){
        super('ASI_CRM_TH_DeleteOldProsImageHandler');
    }    
    Set<Id> prosSegmentations = new Set<Id>();
    Set<Id> criteriaThresholds = new Set<Id>();
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if(sObjList.get(0) instanceof ASI_CRM_Pros_Image_Level__c)       
            deleteProsImageLevels((List<ASI_CRM_Pros_Image_Level__c>) sObjList,newMap.keySet());
    }
    
    public void deleteProsImageLevels(List<ASI_CRM_Pros_Image_Level__c> prosImageList, Set<Id> prosImages){
        for(ASI_CRM_Pros_Image_Level__c prosImage : prosImageList){
            prosSegmentations.add(prosImage.ASI_CRM_SG_Pros_Segmentation__c);
            criteriaThresholds.add(prosImage.ASI_CRM_SG_Criteria_Threshold__c);
        }
        
        //select all pros image level where its under the same pros segmentation and same criteria threshold
        //then delet
        List<ASI_CRM_Pros_Image_Level__c> toDeleteProsImageLevels = [select id from ASI_CRM_Pros_Image_Level__c
                                                                     where ASI_CRM_SG_Pros_Segmentation__c in:prosSegmentations 
                                                                     and ASI_CRM_SG_Criteria_Threshold__c in:criteriaThresholds
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
}