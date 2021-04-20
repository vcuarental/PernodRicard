public without sharing class EUR_CRM_EUAccountCreatePRSegHandler extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_EUAccountCreatePRSegHandler(){
        super('EUR_CRM_EUAccountCreatePRSegHandler');
    }

    private final Set<String> validRecordTypes = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.KeySet();

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){       
        Map<Id, EUR_CRM_Account__c> euAccMap = new Map<Id, EUR_CRM_Account__c>();
        List<RecordType> euAccountRTList = Global_RecordTypeCache.getRTList('EUR_CRM_Account__c');
        Map<Id, RecordType> euAccountRTMap = new Map<Id, RecordType>();

        for(RecordType rt : euAccountRTList){
            euAccountRTMap.put(rt.Id, rt);
        }

        for (EUR_CRM_Account__c euAcc : (List<EUR_CRM_Account__c>) sObjList){
            if( ! euAcc.EUR_CRM_Is_PRS_Exist__c && validRecordTypes.contains(euAccountRTMap.get(euAcc.RecordTypeId).DeveloperName)) {
                euAccMap.put(euAcc.id, euAcc);
            }
        }

        if(euAccMap.size() > 0) {
            List<EUR_CRM_PRS_Segmentation__c> prSegList = new List<EUR_CRM_PRS_Segmentation__c>();
            Map<Id,EUR_CRM_PRS_Segmentation__c> euAccPRSMap = new Map<Id,EUR_CRM_PRS_Segmentation__c>(); // key: acc Id

            for(EUR_CRM_PRS_Segmentation__c prSeg : [SELECT Id, EUR_CRM_Account__c 
                                                    FROM EUR_CRM_PRS_Segmentation__c
                                                    WHERE EUR_CRM_Account__c IN : euAccMap.KeySet()])
            {
                euAccPRSMap.put(prSeg.EUR_CRM_Account__c, prSeg);
            }
            
             for (EUR_CRM_Account__c euAcc : euAccMap.values()) {             
                if (!euAccPRSMap.containsKey(euAcc.Id) || euAccPRSMap.get(euAcc.id) == null) {
                    EUR_CRM_PRS_Segmentation__c prs = new EUR_CRM_PRS_Segmentation__c();
                    prs.EUR_CRM_Account__c = euAcc.Id;
                    String prsSegRT = EUR_CRM_RecordTypeHelper.getAccountCreatePRSegHandler_RecordTypeId(euAccountRTMap.get(euAcc.RecordTypeId).DeveloperName);
                    if(prsSegRT != null) {
                        prs.RecordTypeId = prsSegRT;

                        // TODO: Move this to a list of 'default' values for PRS
                        if(euAccountRTMap.get(euAcc.RecordTypeId).DeveloperName == 'EUR_BE_Off_Trade'){
                            prs.EUR_CRM_Business_Potential__c = euAcc.EUR_CRM_Business_Potential__c;
                        }

                        prSegList.add(prs);                        
                    }
                    system.debug('prSegList' + prSegList);
                }
            }

            if (prSegList.size() > 0){
                insert prSegList;
            }
        }
    }
}