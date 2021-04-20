/**

Description:
    Object - EUR_CRM_Image_Level_Threshold__c
    Trigger - EUR_CRM_Image_Level_Threshold_BeforeUpdate
    Behaviour - Before update of EUR_CRM_Image_Level_Threshold__c records
    this handler check if there's a change on the weight field from old value to new.
    If there is EUR_CRM_Is_Weight_Changed__c is set to true.
     
*/
public class EUR_CRM_ImageLevelThresholdChanged extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_ImageLevelThresholdChanged(){
        super('EUR_CRM_ImageLevelThresholdChanged');
    }    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if(Trigger.isUpdate && Trigger.isBefore){
            for(EUR_CRM_Image_Level_Threshold__c imageLevelThreshold : (List<EUR_CRM_Image_Level_Threshold__c>) sObjList){
                EUR_CRM_Image_Level_Threshold__c oldImageLevelThreshold = (EUR_CRM_Image_Level_Threshold__c) oldMap.get(imageLevelThreshold.id);
                imageLevelThreshold.EUR_CRM_Is_Weight_Changed__c = imageLevelThreshold.EUR_CRM_Min_Weight__c != oldImageLevelThreshold.EUR_CRM_Min_Weight__c;
            }
        }
    }
 
}