public with sharing class EUR_CRM_FI_ContractHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_FI_ContractHandler(){
        super('EUR_CRM_FI_ContractHandler');
    } 

    private final Set<String> validContractRecordTypes = new Set<String>{
      'EUR_FI_Chain_Contract',
      'EUR_FI_Independent_Contract'
    };

    public final String POURING_REFUND_SPIRITS = 'Pouring Refund Spirits';
    public final String POURING_REFUND_WINES = 'Pouring Refund Wines';
    public final String SELECTION_BRANDS_SPIRITS = 'Selection Brands Spirits';
    public final String SELECTION_BRANDS_WINES = 'Selection Brands Wines';
    public final String MARKETING_ACTIVITY_SPIRITS= 'Marketing Activity Spirits';
    public final String MARKETING_ACTIVITY_WINES = 'Marketing Activity Wines';
    public final String TRIPS = 'Trips';
    public final String FREE_STOCK = 'Free stock';

    Set<String> PROFIT_GROUP = new Set<String>{POURING_REFUND_SPIRITS,POURING_REFUND_WINES,SELECTION_BRANDS_SPIRITS,SELECTION_BRANDS_WINES};
    Set<String> MARKETING_GROUP = new Set<String>{MARKETING_ACTIVITY_SPIRITS,MARKETING_ACTIVITY_WINES,TRIPS,FREE_STOCK  };

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){

//        List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract__c');
//        Map<Id,Recordtype> contractRecordTypesMap = new Map<Id,Recordtype>();
        Set<Id> contractIds = new Set<Id>();
        Set<Id> activityIds = new Set<Id>();
        Map<Id,String> mechanicTypeMap = new Map<Id,String>();
        Map<Id,List<EUR_CRM_Contract_Activity_Item__c>> contractMap = new Map<Id,List<EUR_CRM_Contract_Activity_Item__c>>();
        Map<Id,List<EUR_CRM_Contract_Product_Item__c>> productMap = new Map<Id,List<EUR_CRM_Contract_Product_Item__c>>();

        Map<Id, RecordTypeInfo> rtInfoByRTId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosById();
        List<EUR_CRM_Contract__c> contractsToProcess = this.getContractsToProcess((List<EUR_CRM_Contract__c>) sObjList, rtInfoByRTId);
        System.debug('\n contractToProcess.size() => ' + contractsToProcess.size() + '\n');
        System.debug('\n contractToProcess => ' + JSON.serializePretty(contractsToProcess) + '\n');
        if (contractsToProcess.isEmpty()) { return; }
        
//        for(Recordtype rt : contractRecordTypes){
//           contractRecordTypesMap.put(rt.id,rt);
//        }

        if(tAction == TriggerAction.BEFORE_UPDATE){

            for(EUR_CRM_Mechanic_Type__c mType : [SELECT Id, EUR_CRM_Mechanic_Type_Name_English__c FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_Country_Code__c = 'FI']){
                mechanicTypeMap.put(mType.Id, mType.EUR_CRM_Mechanic_Type_Name_English__c);
            }

            for(EUR_CRM_Contract__c euContract : contractsToProcess) {
                String devName = rtInfoByRTId.get(euContract.recordTypeId).getDeveloperName();
                EUR_CRM_Contract__c oldRecord = (EUR_CRM_Contract__c ) oldMap.get(euContract.id);
                if(validContractRecordTypes.contains(devname) && 
                    euContract.EUR_CRM_Is_Calculate_Profit__c == true && 
                    oldRecord.EUR_CRM_Is_Calculate_Profit__c != euContract.EUR_CRM_Is_Calculate_Profit__c){

                    contractIds.add(euContract.Id);
                }
            }

            for(EUR_CRM_Contract_Activity_Item__c activityItem : [SELECT Id, EUR_CRM_Contract__c, EUR_CRM_Mechanic_Type__c, EUR_CRM_Lumpsum_Value__c 
                                                                    FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Contract__c IN :contractIds]){
                activityIds.add(activityItem.Id);
                if (contractMap.containsKey(activityItem.EUR_CRM_Contract__c)){
                    contractMap.get(activityItem.EUR_CRM_Contract__c).add(activityItem);
                }
                else{
                    contractMap.put(activityItem.EUR_CRM_Contract__c, new  List<EUR_CRM_Contract_Activity_Item__c> {activityItem});
                }
            }

            for(EUR_CRM_Contract_Product_Item__c productItem : [SELECT Id, EUR_CRM_Amount__c, EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c, EUR_CRM_Quantity__c, 
                                                                EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c, EUR_CRM_Contract_Activity_Item__c, 
                                                                EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c, EUR_CRM_Marketing_Amount__c 
                                                                 FROM EUR_CRM_Contract_Product_Item__c WHERE EUR_CRM_Contract_Activity_Item__c IN :activityIds]){
                if (productMap.containsKey(productItem.EUR_CRM_Contract_Activity_Item__c)){
                    productMap.get(productItem.EUR_CRM_Contract_Activity_Item__c).add(productItem);
                }
                else{
                    productMap.put(productItem.EUR_CRM_Contract_Activity_Item__c, new  List<EUR_CRM_Contract_Product_Item__c> {productItem});
                }

                System.debug('$$BRAND_CM: '+productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c);
                System.debug('$$BQ_CM: '+productItem.EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c);
                System.debug('$$BQS_CM: '+productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c);
                System.debug('$$SKU_CM: '+productItem.EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c);
            }

            for(EUR_CRM_Contract__c euContract : contractsToProcess){
                if(contractMap.containskey(euContract.Id)){
                    Decimal totalCM = 0;
                    Decimal totalCMRetro = 0;
                    Decimal totalLumpSum = 0;

                    System.debug('&&ACTIVITYMAP: '+contractMap);
                    System.debug('&&ACTIVITYMAPTEST: '+contractMap.get(euContract.Id));
                    System.debug('&&ACTIVITYMAPTESTSIZE: '+contractMap.get(euContract.Id).size());
                    Decimal testCTR = 0;
                    for(EUR_CRM_Contract_Activity_Item__c activity : contractMap.get(euContract.Id)){

                        testCTR++;
                        System.debug('&&CTR: '+testCTR);
                        if(MARKETING_GROUP.contains(mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c))){
                            if(activity.EUR_CRM_Lumpsum_Value__c != null){
                                totalLumpSum += activity.EUR_CRM_Lumpsum_Value__c;
                            }
                        }

                        System.debug('&&ACT: '+mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c)+ ' : ' +activity.Id);
                        System.debug('&&PRODMAP: '+productMap);
                        System.debug('&&ACTID: '+activity.Id);
                        if(productMap.containskey(activity.Id)){
                            for(EUR_CRM_Contract_Product_Item__c productItem : productMap.get(activity.Id)){

                                Decimal cm = 0;
                                System.debug('&&MECHTYPE: '+productItem.Id);
                                if(PROFIT_GROUP.contains(mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c))){

                                    if(mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c) == POURING_REFUND_SPIRITS || mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c) == SELECTION_BRANDS_SPIRITS){
                                        cm = productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c == null ? 0 : productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c;
                                    } else if(mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c) == POURING_REFUND_WINES){
                                        cm = productItem.EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c == null ? 0 : productItem.EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c;
                                    } else if(mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c) == SELECTION_BRANDS_WINES){
                                        cm = productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c == null ? 0 : productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c;
                                    }  
                                    
                                    cm = cm.setScale(2);

                                    Decimal volume = productItem.EUR_CRM_Quantity__c == null ? 0 : productItem.EUR_CRM_Quantity__c;
                                    Decimal retro = productItem.EUR_CRM_Amount__c == null ? 0 : productItem.EUR_CRM_Amount__c; 
                                    totalCM += (cm * volume);
                                    totalCMRetro += (retro * volume);
                                }

                                if(MARKETING_GROUP.contains(mechanicTypeMap.get(activity.EUR_CRM_Mechanic_Type__c))){
                                    totalLumpSum += productItem.EUR_CRM_Marketing_Amount__c == null ? 0 : productItem.EUR_CRM_Marketing_Amount__c;
                                }
                            }
                        }
                        
                    }

                    Decimal contractMaterial = totalCM - (totalLumpSum + totalCMRetro);
                    System.debug('&&CM: '+totalCM);
                    System.debug('&&LUMPSUM: '+totalLumpSum);
                    System.debug('&&SMRETRO: '+totalCMRetro);
                    System.debug('&&TESTMATERIAL: '+contractMaterial);

                    euContract.EUR_CRM_Is_this_contract_material__c = contractMaterial;
                    euContract.EUR_CRM_Is_this_contract_profitable__c = totalCM == 0 ? 0 : (contractMaterial/totalCM) * 100;
                    euContract.EUR_CRM_Is_Calculate_Profit__c = false;
                }



            }

            
        }

    }

    private List<EUR_CRM_Contract__c> getContractsToProcess(List<EUR_CRM_Contract__c> contracts, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        List<EUR_CRM_Contract__c> contractsToProcess = new List<EUR_CRM_Contract__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            if (validContractRecordTypes.contains(rtInfoByRTId.get(contract.RecordTypeId).getDeveloperName())) {
                contractsToProcess.add(contract);
            }
        }
        return contractsToProcess;
    }

}