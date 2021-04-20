public  class EUR_CRM_ZA_ProductEnabledBQSHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_ProductEnabledBQSHandler(){
        super('EUR_CRM_ZA_ProductEnabledBQSHandler');
    }

    private final Set<String> validBQSRecordTypes = new Set<String>{
      'EUR_ZA_Size'
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
        List<Recordtype> bqsRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Size__c');
        Map<Id,Recordtype> bqsRecordTypesMap = new Map<Id,Recordtype>();

        Set<Id> disabledBqsIds = new Set<Id>();
        Set<Id> enabledBqsIds = new Set<Id>();
        
        for(Recordtype rt : accRecordTypes){
           accRecordTypesMap.put(rt.id,rt);
        }
        
        for(Recordtype rt : bqsRecordTypes){
           bqsRecordTypesMap.put(rt.id,rt);
        }
        
        for(EUR_CRM_Size__c bqs : (List<EUR_CRM_Size__c>) sObjList){ 

            String devName = bqsRecordTypesMap.get(bqs.recordTypeId).developername;
            EUR_CRM_Size__c oldRecord = (EUR_CRM_Size__c) oldMap.get(bqs.id);

            if(validBQSRecordTypes.contains(devName)){
                if(tAction == TriggerAction.AFTER_INSERT){

                }
                if(tAction == TriggerAction.AFTER_UPDATE){
                    System.debug('$$TRACK: '+bqs.EUR_CRM_Enable_Account_Volume_Tracking__c);
                    if(bqs.EUR_CRM_Enable_Account_Volume_Tracking__c == FALSE && bqs.EUR_CRM_Enable_Account_Volume_Tracking__c != oldRecord.EUR_CRM_Enable_Account_Volume_Tracking__c){
                        disabledBqsIds.add(bqs.Id);
                    }

                    if(bqs.EUR_CRM_Enable_Account_Volume_Tracking__c == TRUE && bqs.EUR_CRM_Enable_Account_Volume_Tracking__c != oldRecord.EUR_CRM_Enable_Account_Volume_Tracking__c){
                        enabledBqsIds.add(bqs.Id);
                    }
                }
            }
        }
        
        
        if(disabledBqsIds.size() > 0){
            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> actVolTrackToUpdate = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Brand_Quality_Size__c FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c WHERE EUR_CRM_Brand_Quality_Size__c IN :disabledBqsIds]){
                volTrack.EUR_CRM_Active__c = FALSE;
                actVolTrackToUpdate.add(volTrack);
            } 

            if(actVolTrackToUpdate.size() > 0){
                update actVolTrackToUpdate;
            }
        }

        if(enabledBqsIds.size() > 0){
            Set<Id> bqsIdsToUpdate = new Set<Id>();
            Set<Id> bqsIdsToInsert = new Set<Id>();
            Set<Id> acctVolTrackerIds = new Set<Id>();
            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> actVolTrackToUpdate = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Account_Volume_Tracker__c FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c WHERE EUR_CRM_Brand_Quality_Size__c IN :enabledBqsIds]){
                volTrack.EUR_CRM_Active__c = TRUE;
                bqsIdsToUpdate.add(volTrack.EUR_CRM_Brand_Quality_Size__c);
                actVolTrackToUpdate.add(volTrack);
                acctVolTrackerIds.add(volTrack.EUR_CRM_Account_Volume_Tracker__c);
            } 

            if(actVolTrackToUpdate.size() > 0){
                update actVolTrackToUpdate;
            }

            for(Id key : enabledBqsIds){
                if(!bqsIdsToUpdate.contains(key)){
                    bqsIdsToInsert.add(key);
                }
            }

            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackToInsert = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            Set<Id> uniqueVolTrackIds = new Set<Id>();
            /*for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : [SELECT Id, EUR_CRM_Active__c, EUR_CRM_Account_Volume_Tracker__c, EUR_CRM_Account__c FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c]){
                if(bqIdsToInsert.size() > 0){
                    for(Id key : bqIdsToInsert){
                        if(!uniqueVolTrackIds.contains(volTrack.EUR_CRM_Account_Volume_Tracker__c)){
                            
                            uniqueVolTrackIds.add(volTrack.EUR_CRM_Account_Volume_Tracker__c);
                            
                        }
                    }
                } 
            }*/

            for(EUR_CRM_Account_Volume_Tracker__c volTrack : [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Account__r.RecordtypeId FROM EUR_CRM_Account_Volume_Tracker__c]){
                if(OFF_TRADE_ZA.contains(accRecordTypesMap.get(volTrack.EUR_CRM_Account__r.RecordtypeId).DeveloperName)){
                    if(bqsIdsToInsert.size() > 0){
                        for(Id key : bqsIdsToInsert){
                                EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
                                volTrackItem.EUR_CRM_Active__c = TRUE;
                                //volTrackItem.EUR_CRM_Account__c = volTrack.EUR_CRM_Account__c;
                                volTrackItem.EUR_CRM_Brand_Quality_Size__c = key;
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
            }
        }
        
    }
}