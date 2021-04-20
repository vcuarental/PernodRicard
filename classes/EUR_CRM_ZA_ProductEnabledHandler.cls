public  class EUR_CRM_ZA_ProductEnabledHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_ProductEnabledHandler(){
        super('EUR_CRM_ZA_ProductEnabledHandler');
    }

    private final Set<String> validBQRecordTypes = new Set<String>{
      'EUR_ZA_Quality'
    };
    
    public static String EU_ACCOUNT_ZA_OFF_TRADE = 'EUR_ZA_Off_Trade';
    public static String EU_ACCOUNT_ZA_ON_TRADE_DIRECT = 'EUR_ZA_On_Trade_Direct';
    public static String EU_ACCOUNT_ZA_ON_TRADE_INDIRECT = 'EUR_ZA_On_Trade_Indirect';
    public static String EU_ACCOUNT_ZA_ON_TRADE_INFORMAL = 'EUR_ZA_On_Trade_Informal';
    public static String EU_ACCOUNT_ZA_DISTRIBUTOR = 'EUR_ZA_Distributor';

    public static Set<String> OFF_TRADE_ZA = new Set<String>{EU_ACCOUNT_ZA_OFF_TRADE,EU_ACCOUNT_ZA_DISTRIBUTOR};
    public static Set<String> ON_TRADE_ZA = new Set<String>{EU_ACCOUNT_ZA_ON_TRADE_DIRECT,EU_ACCOUNT_ZA_ON_TRADE_INDIRECT,EU_ACCOUNT_ZA_ON_TRADE_INFORMAL};
        
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> accRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accRecordTypesMap = new Map<Id,Recordtype>();
        List<Recordtype> bqRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Quality__c');
        Map<Id,Recordtype> bqRecordTypesMap = new Map<Id,Recordtype>();

        Set<Id> disabledBqIds = new Set<Id>();
        Set<Id> enabledBqIds = new Set<Id>();
        
        for(Recordtype rt : accRecordTypes){
           accRecordTypesMap.put(rt.id,rt);
        }
        
        for(Recordtype rt : bqRecordTypes){
           bqRecordTypesMap.put(rt.id,rt);
        }
        
        for(EUR_CRM_Quality__c bq : (List<EUR_CRM_Quality__c>) sObjList){ 

            String devName = bqRecordTypesMap.get(bq.recordTypeId).developername;
            EUR_CRM_Quality__c oldRecord = (EUR_CRM_Quality__c) oldMap.get(bq.id);

            if(validBQRecordTypes.contains(devName)){
                if(tAction == TriggerAction.AFTER_INSERT){

                }
                if(tAction == TriggerAction.AFTER_UPDATE){
                    System.debug('$$TRACK: '+bq.EUR_CRM_Enable_Account_Volume_Tracking__c);
                    if(bq.EUR_CRM_Enable_Account_Volume_Tracking__c == FALSE && bq.EUR_CRM_Enable_Account_Volume_Tracking__c != oldRecord.EUR_CRM_Enable_Account_Volume_Tracking__c){
                        disabledBqIds.add(bq.Id);
                    }

                    if(bq.EUR_CRM_Enable_Account_Volume_Tracking__c == TRUE && bq.EUR_CRM_Enable_Account_Volume_Tracking__c != oldRecord.EUR_CRM_Enable_Account_Volume_Tracking__c){
                        enabledBqIds.add(bq.Id);
                    }
                }
            }
        }

        if(disabledBqIds.size() > 0){
            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> actVolTrackToUpdate = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Brand_Quality__c FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c WHERE EUR_CRM_Brand_Quality__c IN :disabledBqIds]){
                volTrack.EUR_CRM_Active__c = FALSE;
                actVolTrackToUpdate.add(volTrack);
            } 

            if(actVolTrackToUpdate.size() > 0){
                update actVolTrackToUpdate;
            }
        }

        if(enabledBqIds.size() > 0){
            Set<Id> bqIdsToUpdate = new Set<Id>();
            Set<Id> bqIdsToInsert = new Set<Id>();
            Set<Id> acctVolTrackerIds = new Set<Id>();
            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> actVolTrackToUpdate = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Brand_Quality__c, EUR_CRM_Account_Volume_Tracker__c FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c WHERE EUR_CRM_Brand_Quality__c IN :enabledBqIds]){
                volTrack.EUR_CRM_Active__c = TRUE;
                bqIdsToUpdate.add(volTrack.EUR_CRM_Brand_Quality__c);
                actVolTrackToUpdate.add(volTrack);
                acctVolTrackerIds.add(volTrack.EUR_CRM_Account_Volume_Tracker__c);
            } 

            if(actVolTrackToUpdate.size() > 0){
                update actVolTrackToUpdate;
            }

            System.debug('$$TOUPDATE: '+bqIdsToUpdate);
            for(Id key : enabledBqIds){
                if(bqIdsToUpdate.size() > 0){
                    if(bqIdsToUpdate.contains(key)){
                        bqIdsToInsert.add(key);
                    }
                } else {
                    bqIdsToInsert.add(key);
                }
                
            }

            System.debug('$$ENABLED: '+enabledBqIds);
            System.debug('$$TOINSERT: '+bqIdsToInsert);

            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackToInsert = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();

            for(EUR_CRM_Account_Volume_Tracker__c volTrack : [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Account__r.RecordtypeId FROM EUR_CRM_Account_Volume_Tracker__c]){
                if(ON_TRADE_ZA.contains(accRecordTypesMap.get(volTrack.EUR_CRM_Account__r.RecordtypeId).DeveloperName)){
                    if(bqIdsToInsert.size() > 0){
                        for(Id key : bqIdsToInsert){
                                EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
                                volTrackItem.EUR_CRM_Active__c = TRUE;
                                //volTrackItem.EUR_CRM_Account__c = volTrack.EUR_CRM_Account__c;
                                volTrackItem.EUR_CRM_Brand_Quality__c = key;
                                volTrackItem.EUR_CRM_Account_Volume_Tracker__c = volTrack.Id;
                                   
                                if(!acctVolTrackerIds.contains(volTrack .Id)){
                                    volTrackToInsert.add(volTrackItem);
                                }
                                
                        }
                    }
                }
            }

            if(volTrackToInsert.size() > 0){
                insert volTrackToInsert;

                Set<Id> vTItemIds = new Set<Id>();
                for(EUR_CRM_Account_Volume_Tracker_Line_Item__c item : volTrackToInsert){
                    vTItemIds.add(item.Id);
                }

                Set<Id> uniqueVolTrackIds = new Set<Id>();
                List<EUR_CRM_Volume_Tracker_Period__c> periodsToInsert = new List<EUR_CRM_Volume_Tracker_Period__c>();
                for(EUR_CRM_Volume_Tracker_Period__c periods : [Select Id, EUR_CRM_End_Date__c, EUR_CRM_Start_Date__c, EUR_CRM_Account_Volume_Tracker_Line_Item__c, EUR_CRM_Account_Volume_Tracker_Line_Item__r.EUR_CRM_Account_Volume_Tracker__c FROM EUR_CRM_Volume_Tracker_Period__c WHERE EUR_CRM_Account_Volume_Tracker_Line_Item__c <> null]){
                    if(!uniqueVolTrackIds.contains(periods.EUR_CRM_Account_Volume_Tracker_Line_Item__r.EUR_CRM_Account_Volume_Tracker__c)){
                        for(Id key : vTItemIds){
                            EUR_CRM_Volume_Tracker_Period__c vtPeriod = new EUR_CRM_Volume_Tracker_Period__c();
                            vtPeriod.EUR_CRM_End_Date__c = periods.EUR_CRM_End_Date__c;
                            vtPeriod.EUR_CRM_Start_Date__c = periods.EUR_CRM_Start_Date__c;
                            vtPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c = key;

                            periodsToInsert.add(vtPeriod);
                            uniqueVolTrackIds.add(periods.EUR_CRM_Account_Volume_Tracker_Line_Item__r.EUR_CRM_Account_Volume_Tracker__c);
                        }
                    }
                }
            }
        }
        
    }
}