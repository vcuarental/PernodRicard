public with sharing class EUR_CRM_ForceImageLevelHandler extends EUR_CRM_TriggerAbstract{

    private Boolean run = true;
    private static Set<String> euAccountRecordTypeSet = EUR_CRM_RecordtypeHelper.ForceImageLevelHandler_validRecordTypes;

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(euAccountRecordTypeSet);
            
            return TRt;
        }private set;
    }



    public EUR_CRM_ForceImageLevelHandler(){
        super('EUR_CRM_ForceImageLevelHandler');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if( runOnce() ) {
            process(tAction, (List<EUR_CRM_Account__c>) sObjList, (Map<ID, EUR_CRM_Account__c>) newMap, (Map<ID, EUR_CRM_Account__c>) oldMap);
        } 
    }

    private void process(TriggerAction tAction, List<EUR_CRM_Account__c> sObjList, Map<ID, EUR_CRM_Account__c> newMap,Map<ID, EUR_CRM_Account__c> oldMap){
        System.Debug('EUR_CRM_ForceImageLevelHandler');
        Set<Id> euAccounts = new Set<Id>();
        // Retrieve account recordtypes
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id, Recordtype> accountRecordTypesMap = new Map<Id, Recordtype>();
        // Initialize the lists
        Map<String, Map<String, Id>> imageLevelMap = new Map<String, Map<String, Id>>();
        Map<Id, EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>(); 
        // Create recordtype Map  
        for(Recordtype rt : accountRecordTypes){
            accountRecordTypesMap.put(rt.Id, rt);
        }      
        // Recordtype boundry
        for(EUR_CRM_Account__c acc : sObjList){
            if(euAccountRecordTypeSet.contains(accountRecordTypesMap.get(acc.RecordtypeId).DeveloperName)){
                if(tAction == TriggerAction.BEFORE_INSERT && acc.EUR_CRM_Force_Image_Level__c != null)
                {
                    euAccounts.add(acc.Id);
                } else if(tAction == TriggerAction.BEFORE_UPDATE && ( acc.EUR_CRM_Force_Image_Level__c != oldMap.get(acc.Id).EUR_CRM_Force_Image_Level__c
                                                                        || acc.EUR_CRM_Image_Level__c  != oldMap.get(acc.Id).EUR_CRM_Image_Level__c ))
                {
                    euAccounts.add(acc.Id);
                }
            } else {
                continue;
            }
        }
        System.debug(euAccounts);
        if(euAccounts.size()>0){
            for(EUR_CRM_Image_Level__c imageLevel: [SELECT Id, EUR_CRM_Name__c, EUR_CRM_Country_Code__c FROM EUR_CRM_Image_Level__c])
            {
                if(imageLevelMap.get(imageLevel.EUR_CRM_Country_Code__c) == null){
                    imageLevelMap.put(imageLevel.EUR_CRM_Country_Code__c, new Map<String, Id>{imageLevel.EUR_CRM_Name__c => imageLevel.Id});
                } else {
                    imageLevelMap.get(imageLevel.EUR_CRM_Country_Code__c).put(imageLevel.EUR_CRM_Name__c, imageLevel.Id);                    
                }
            }
            for(EUR_CRM_Pros_Segmentation__c pros : [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Image_Level_Threshold__c, EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level__c
                                                     FROM EUR_CRM_Pros_Segmentation__c
                                                     WHERE EUR_CRM_Account__c =: euAccounts])
            {
               prosMap.put(pros.EUR_CRM_Account__c, pros);
            }
            System.debug(imageLevelMap);
            System.debug(prosMap);
            for(Id key : euAccounts){
                EUR_CRM_Account__c euAccount = newMap.get(key);
                if(euAccount.EUR_CRM_Force_Image_Level__c != null){
                    euAccount.EUR_CRM_Image_Level__c = imageLevelMap.get(euAccount.EUR_CRM_Country_Code__c).get(euAccount.EUR_CRM_Force_Image_Level__c);
                } else {
                    if(prosMap.get(euAccount.Id) != null && prosMap.get(euAccount.Id).EUR_CRM_Image_Level_Threshold__c != null){
                        euAccount.EUR_CRM_Image_Level__c = prosMap.get(euAccount.Id).EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level__c;
                    } else {
                        euAccount.EUR_CRM_Image_Level__c = null;
                    } 
                }
            }
        }
    }
    
    public Boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}