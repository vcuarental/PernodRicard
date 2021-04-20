public with sharing class EUR_CRM_NG_AssignVisitFrequencyHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_NG_AssignVisitFrequencyHandler(){
        super('EUR_CRM_NG_AssignVisitFrequencyHandler');
    } 

    private static Set<String> allEUAccountRecordTypeSet = new Set<String>{
          'EUR_NG_On_Trade',
          'EUR_NG_Off_Trade_Traditional',
          'EUR_NG_Off_Trade_Modern'
    };
/*
    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(allEUAccountRecordTypeSet);
            return TRt;
        }private set;
    }*/

    private static String ON_TRADE = 'ON TRADE';
    private static String OFF_TRADE = 'OFF TRADE';
    private static String ON_TRADE_VISIT_FREQUENCY = 'EUR_NG_Visit_Frequency_Criteria_On_Trade';
    private static String OFF_TRADE_VISIT_FREQUENCY = 'EUR_NG_Visit_Frequency_Criteria_Off_Trade';

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){ 
/*
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        List<Recordtype> visitFrequencyCriteriaTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Frequency_Criteria__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        Map<Id,Recordtype> visitFrequencyCriteriaTypesMap = new Map<Id,Recordtype>();
        Map<String,EUR_CRM_Visit_Frequency_Criteria__c> vfCriteriaOnMap = new Map<String,EUR_CRM_Visit_Frequency_Criteria__c>();
        Map<String,EUR_CRM_Visit_Frequency_Criteria__c> vfCriteriaOffMap = new Map<String,EUR_CRM_Visit_Frequency_Criteria__c>();

        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
        for(Recordtype rt : visitFrequencyCriteriaTypes){
           visitFrequencyCriteriaTypesMap.put(rt.id,rt);
        }

        for(EUR_CRM_Visit_Frequency_Criteria__c vfCriteria : [SELECT
                                                                Id,
                                                                EUR_CRM_Group_Outlet_Type__c,
                                                                EUR_CRM_Image_Level__c,
                                                                EUR_CRM_Visit_Frequency__c,
                                                                EUR_CRM_Volume_Potential__c,
                                                                EUR_CRM_Outlet_Classification__c,
                                                                EUR_CRM_Outlet_Classification_Type__c,
                                                                RecordtypeId
                                                              FROM
                                                                EUR_CRM_Visit_Frequency_Criteria__c
                                                              WHERE
                                                                RecordtypeId
                                                              IN
                                                                :visitFrequencyCriteriaTypesMap.keyset()]){

            String key;
            if(visitFrequencyCriteriaTypesMap.get(vfCriteria.RecordtypeId).DeveloperName == ON_TRADE_VISIT_FREQUENCY){
                key = vfCriteria.EUR_CRM_Group_Outlet_Type__c + ':' + vfCriteria.EUR_CRM_Image_Level__c + ':' + vfCriteria.EUR_CRM_Volume_Potential__c;
                vfCriteriaOnMap.put(key,vfCriteria);
            } else if(visitFrequencyCriteriaTypesMap.get(vfCriteria.RecordtypeId).DeveloperName == OFF_TRADE_VISIT_FREQUENCY){
                key = vfCriteria.EUR_CRM_Outlet_Classification__c + ':' +vfCriteria.EUR_CRM_Outlet_Classification_Type__c;
                vfCriteriaOffMap.put(key,vfCriteria);
            }
            
        }

        System.debug('###VFMAP_ON: '+vfCriteriaOnMap.keyset());
        System.debug('###VFMAP_ON_SIZE: '+vfCriteriaOnMap.size());
        System.debug('###VFMAP_OFF: '+vfCriteriaOffMap.keyset());

        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){

            String accountRecordTypeDeveloperName = accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName;
            EUR_CRM_Account__c oldEuAccount = tAction == TriggerAction.BEFORE_UPDATE ? ((EUR_CRM_Account__c) oldMap.get(euAccount.id)) : null;
            

            if(tAction == TriggerAction.BEFORE_UPDATE || tAction == TriggerAction.BEFORE_INSERT){
                if(euAccount.EUR_CRM_Channel__c == ON_TRADE && tAction == TriggerAction.BEFORE_UPDATE){
                    if((euAccount.EUR_CRM_Group_Outlet_Type__c != oldEuAccount.EUR_CRM_Group_Outlet_Type__c ||
                        euAccount.EUR_CRM_Image_Level__c != oldEuAccount.EUR_CRM_Image_Level__c ||
                        euAccount.EUR_CRM_Volume_Potential__c != oldEuAccount.EUR_CRM_Volume_Potential__c) &&
                        (euAccount.EUR_CRM_Group_Outlet_Type__c != null && 
                            euAccount.EUR_CRM_Image_Level__c != null &&
                            euAccount.EUR_CRM_Volume_Potential__c != null)){

                        String freqKey = euAccount.EUR_CRM_Group_Outlet_Type__c + ':' + euAccount.EUR_CRM_Image_Level__c + ':' +euAccount.EUR_CRM_Volume_Potential__c;

                        //System.debug('###FREQ: '+freqKey);
                        //System.debug('###FREQ2: '+vfCriteriaOnMap.get(freqKey));

                        if(vfCriteriaOnMap.containskey(freqKey)){
                            euAccount.EUR_CRM_Visit_Frequency__c = vfCriteriaOnMap.get(freqKey).EUR_CRM_Visit_Frequency__c;
                        }

                    }
                }

                System.debug('###@OUTLET: '+euAccount.EUR_CRM_Outlet_Classification__c);
                System.debug('###@OUTLET2: '+euAccount.EUR_CRM_Outlet_Classification_Type__c);
                System.debug('###@TEST1: '+euAccount.EUR_CRM_Channel__c);
                System.debug('###@TEST2: '+tAction);

                if(euAccount.EUR_CRM_Channel__c == OFF_TRADE){
                    if(tAction == TriggerAction.BEFORE_INSERT){
                        System.debug('###OUTLET: '+euAccount.EUR_CRM_Outlet_Classification__c);
                        System.debug('###OUTLET2: '+euAccount.EUR_CRM_Outlet_Classification_Type__c);
                        if(euAccount.EUR_CRM_Outlet_Classification__c != '--None--' && 
                            euAccount.EUR_CRM_Outlet_Classification_Type__c != '--None--'){

                            String freqKey = euAccount.EUR_CRM_Outlet_Classification__c + ':' + euAccount.EUR_CRM_Outlet_Classification_Type__c;

                            if(vfCriteriaOffMap.containskey(freqKey)){
                                System.debug('##TEST');
                                euAccount.EUR_CRM_Visit_Frequency__c = vfCriteriaOffMap.get(freqKey).EUR_CRM_Visit_Frequency__c;
                            }
                        }
                    }
                    if(tAction == TriggerAction.BEFORE_UPDATE){
                        if((euAccount.EUR_CRM_Outlet_Classification__c != oldEuAccount.EUR_CRM_Outlet_Classification__c ||
                            euAccount.EUR_CRM_Outlet_Classification_Type__c != oldEuAccount.EUR_CRM_Outlet_Classification_Type__c) &&
                            (euAccount.EUR_CRM_Outlet_Classification__c != '--None--' && 
                                euAccount.EUR_CRM_Image_Level__c != '--None--')){

                            String freqKey = euAccount.EUR_CRM_Outlet_Classification__c + ':' + euAccount.EUR_CRM_Outlet_Classification_Type__c;

                            if(vfCriteriaOffMap.containskey(freqKey)){
                                euAccount.EUR_CRM_Visit_Frequency__c = vfCriteriaOffMap.get(freqKey).EUR_CRM_Visit_Frequency__c;
                            }
                        }
                    }
                }

            }

        }
*/
    }

}