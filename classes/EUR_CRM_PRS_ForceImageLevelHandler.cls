public with sharing class EUR_CRM_PRS_ForceImageLevelHandler extends EUR_CRM_TriggerAbstract {
    private static Map<String, Map<String, Id>> aspectMap = new Map<String, Map<String, Id>>();
    private static Set<Id> euAccounts = new Set<Id>();
    public static Integer afterUpdateFireCount = 0;

    public EUR_CRM_PRS_ForceImageLevelHandler() {
        super('EUR_CRM_PRS_ForceImageLevelHandler');
    }

    private static final String CURREN_CLASS_NAME = 'EUR_CRM_PRS_ForceImageLevelHandler';
    private static Set<String> euAccountRecordTypeSet = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CURREN_CLASS_NAME, 'euAccountRecordTypeSet');
//    private static Set<String> euAccountRecordTypeSet = new Set<String>{
//            'EUR_DB_On_Trade_Account',
//            'EUR_IDL_On_Trade_Account',
//            'EUR_SE_On_Trade',
//            'EUR_IT_On_Trade_Account',
//            'EUR_NL_On_Trade'
//    };

    public static Set<String> TargetRecordSet {
        get {
            Set<String> TRt = new Set<String>();
            TRt.addAll(euAccountRecordTypeSet);
            return TRt;
        }
        private set;
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (afterUpdateFireCount != 0) { return; }
        System.debug('\n forceILhandlerAfterUpdateFireCount => ' + afterUpdateFireCount + '\n');
        if (tAction == TriggerAction.BEFORE_UPDATE) {
            this.process(tAction, (List<EUR_CRM_Account__c>) sObjList, (Map<ID, EUR_CRM_Account__c>) newMap, (Map<ID, EUR_CRM_Account__c>) oldMap);
        }
        if (tAction == TriggerAction.AFTER_UPDATE) {
            this.updateSegmentationsAfterUpdate(tAction, (List<EUR_CRM_Account__c>) sObjList, (Map<ID, EUR_CRM_Account__c>) newMap, (Map<ID, EUR_CRM_Account__c>) oldMap);
        }

    }

    private void process(TriggerAction tAction, List<EUR_CRM_Account__c> sObjList, Map<ID, EUR_CRM_Account__c> newMap, Map<ID, EUR_CRM_Account__c> oldMap) {
        System.Debug('EUR_CRM_PRS_ForceImageLevelHandler');

//        Set<Id> euAccounts = new Set<Id>();
        // Retrieve account recordtypes
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id, Recordtype> accountRecordTypesMap = new Map<Id, Recordtype>();
        // Initialize the lists
//        Map<String, Map<String, Id>> aspectMap = new Map<String, Map<String, Id>>();
        aspectMap = new Map<String, Map<String, Id>>();
        Map<Id, EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>();
        // Create recordtype Map
        for (Recordtype rt : accountRecordTypes) {
            accountRecordTypesMap.put(rt.Id, rt);
        }
        // Recordtype boundry
        for (EUR_CRM_Account__c acc : sObjList) {
            if (euAccountRecordTypeSet.contains(accountRecordTypesMap.get(acc.RecordtypeId).DeveloperName)) {
                if (tAction == TriggerAction.BEFORE_UPDATE && acc.EUR_CRM_Force_PRS_Image_Level__c != oldMap.get(acc.Id).EUR_CRM_Force_PRS_Image_Level__c
                    && String.isNotBlank(acc.EUR_CRM_Force_PRS_Image_Level__c)) {
                    euAccounts.add(acc.Id);
                }
            }
        }

        if (euAccounts.size() > 0) {
            for (EUR_CRM_PRS_Seg_Aspect__c aspect : [SELECT Id, EUR_CRM_Name__c, EUR_CRM_Country_Code__c FROM EUR_CRM_PRS_Seg_Aspect__c]) {
                if (!aspectMap.containsKey(aspect.EUR_CRM_Country_Code__c)) {
                    aspectMap.put(aspect.EUR_CRM_Country_Code__c, new Map<String, Id>{
                            aspect.EUR_CRM_Name__c => aspect.Id
                    });
                } else {
                    aspectMap.get(aspect.EUR_CRM_Country_Code__c).put(aspect.EUR_CRM_Name__c, aspect.Id);
                }
            }
            for (Id key : euAccounts) {
                EUR_CRM_Account__c euAccount = newMap.get(key);
                if (aspectMap.containsKey(euAccount.EUR_CRM_Country_Code__c)) {
                    euAccount.EUR_CRM_PRS_Image_Level__c = aspectMap.get(euAccount.EUR_CRM_Country_Code__c).get(euAccount.EUR_CRM_Force_PRS_Image_Level__c);
                }
            }
        }
    }

    private void updateSegmentationsAfterUpdate(TriggerAction tAction, List<EUR_CRM_Account__c> accounts, Map<ID, EUR_CRM_Account__c> newMap, Map<ID, EUR_CRM_Account__c> oldMap) {
        System.debug('\n euAccounts.size() => ' + euAccounts.size() + '\n');
        System.debug('\n euAccounts => ' + JSON.serializePretty(euAccounts) + '\n');
        System.debug('\n aspectMap.size() => ' + aspectMap.size() + '\n');
        System.debug('\n aspectMap => ' + aspectMap + '\n');
        if (euAccounts.isEmpty()) { return; }
        List<EUR_CRM_PRS_Segmentation__c> segmentations =  [SELECT Id, EUR_CRM_Image_Level__c, EUR_CRM_Account__c,
            EUR_CRM_Account__r.EUR_CRM_Country_Code__c,
            EUR_CRM_Account__r.EUR_CRM_Force_PRS_Image_Level__c
        FROM EUR_CRM_PRS_Segmentation__c Where EUR_CRM_Account__c IN :euAccounts];
        Map<Id,List<EUR_CRM_PRS_Segmentation__c>> segmentationsByAccId = new Map<Id,List<EUR_CRM_PRS_Segmentation__c>>();
        for (EUR_CRM_PRS_Segmentation__c segm : segmentations) {
            if (segmentationsByAccId.containsKey(segm.EUR_CRM_Account__c)) {
                segmentationsByAccId.get(segm.EUR_CRM_Account__c).add(segm);
            } else {
                segmentationsByAccId.put(segm.EUR_CRM_Account__c, new List<EUR_CRM_PRS_Segmentation__c> { segm });
            }
        }
        List<EUR_CRM_PRS_Segmentation__c> segmentationsToUpdate =  new List<EUR_CRM_PRS_Segmentation__c>();

        for (List<EUR_CRM_PRS_Segmentation__c> segms : segmentationsByAccId.values()) {
            for (EUR_CRM_PRS_Segmentation__c segm : segms) {
                if (aspectMap.containsKey(segm.EUR_CRM_Account__r.EUR_CRM_Country_Code__c)) {
                    segm.EUR_CRM_Image_Level__c = aspectMap.get(segm.EUR_CRM_Account__r.EUR_CRM_Country_Code__c).get(segm.EUR_CRM_Account__r.EUR_CRM_Force_PRS_Image_Level__c);
                    segmentationsToUpdate.add(segm);
                }
            }
        }

        System.debug('\n segmentationsByAccId.size() => ' + segmentationsByAccId.size() + '\n');
        System.debug('\n segmentationsByAccId => ' + JSON.serializePretty(segmentationsByAccId) + '\n');
        System.debug('\n segmentationsToUpdate.size() => ' + segmentationsToUpdate.size() + '\n');
        System.debug('\n segmentationsToUpdate => ' + JSON.serializePretty(segmentationsToUpdate) + '\n');
        if (segmentationsToUpdate.isEmpty()) { return; }
        this.increaseAfterUpdateFireCount();
        List<Database.SaveResult> saveResults = Database.update(segmentationsToUpdate);
        System.debug('\n forceILhandlerAfterUpdateFireCount => ' + afterUpdateFireCount + '\n');
        for (Database.SaveResult saveResult : saveResults) {
            List<Database.Error> errors = saveResult.getErrors();
            for (Database.Error error : errors) {
                System.debug('error.getMessage() => ' + error.getMessage() + ' ' + error.getFields());
            }

        }


    }

    private void increaseAfterUpdateFireCount() {
        afterUpdateFireCount++;
    }


}