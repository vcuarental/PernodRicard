/**

Description:
    Object - EUR_CRM_Image_Level_Threshold__c
    Trigger - EUR_CRM_Image_Level_Threshold_BeforeUpdate
    Behaviour - Before update of EUR_CRM_Image_Level_Threshold__c records
    this handler check if there's a change on the weight field from old value to new.
    If there is EUR_CRM_Is_Weight_Changed__c is set to true.
     
*/
public class EUR_CRM_VolumePotentialThresholdChanged extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_VolumePotentialThresholdChanged(){
        super('EUR_CRM_VolumePotentialThresholdChanged');
    }    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if(Trigger.isUpdate && Trigger.isBefore){
            for(EUR_CRM_Volume_Potential_Threshold__c volumePotentialThreshold : (List<EUR_CRM_Volume_Potential_Threshold__c>) sObjList){
                EUR_CRM_Volume_Potential_Threshold__c oldVolumePotentialThreshold= (EUR_CRM_Volume_Potential_Threshold__c) oldMap.get(volumePotentialThreshold.id);
                volumePotentialThreshold.EUR_CRM_Is_Weight_Changed__c = volumePotentialThreshold.EUR_CRM_Min_Weight__c != oldVolumePotentialThreshold.EUR_CRM_Min_Weight__c ||
                                    volumePotentialThreshold.EUR_CRM_Max_Weight__c != oldVolumePotentialThreshold.EUR_CRM_Max_Weight__c ;
            }
        }
    }
 
}