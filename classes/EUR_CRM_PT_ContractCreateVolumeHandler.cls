public class EUR_CRM_PT_ContractCreateVolumeHandler extends EUR_CRM_TriggerAbstract {
    
    public EUR_CRM_PT_ContractCreateVolumeHandler() {
        super('EUR_CRM_PT_ContractCreateVolumeHandler');
    }
    
    private static final Set<String> validContractRecordTypes = new Set<String>{
        'EUR_PT_Outlet_Contract'
    };
    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(validContractRecordTypes);

            return TRt;
        }private set;
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract__c');
        Map<Id,Recordtype> contractRecordTypesMap = new Map<Id,Recordtype>();
        Set<Id> contractIdSet = new Set<Id>();
        for(Recordtype rt : contractRecordTypes){
           contractRecordTypesMap.put(rt.id,rt);
        }
        
        for(EUR_CRM_Contract__c contract : (List<EUR_CRM_Contract__c>) sObjList){ 
            String devName = contractRecordTypesMap.get(contract.recordTypeId).developername;
            EUR_CRM_Contract__c oldRecord = (EUR_CRM_Contract__c ) oldMap.get(contract.id);
            
            if(validContractRecordTypes.contains(devname) 
                && contract.EUR_CRM_Status__c == 'Activated' &&
                oldRecord.EUR_CRM_Status__c  != contract.EUR_CRM_Status__c){
              contractIdSet.add(contract.Id);
            }   
        }
        
        If(contractIdSet.size() > 0){
            Map<Id, List<EUR_CRM_Contract_Product_Item__c>> productMap = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();
            List<EUR_CRM_Contract_Activity_Item__c> acticityList = 
                [Select Id,
                        EUR_CRM_Contract__c,
                        (Select Id,
                                EUR_CRM_Contract_Activity_Item__r.Id,
                                EUR_CRM_Brand_Quality_Size__c,
                                EUR_CRM_Quantity__c
                         From Contract_Product_Items__r
                        )
                 From EUR_CRM_Contract_Activity_Item__c
                 Where EUR_CRM_Mechanic_Type__r.Name = 'Volume Targets and Rebates'
                 AND EUR_CRM_Contract__c In :contractIdSet
                ];


            Map<Id, EUR_CRM_GB_Volume_Tracker__c> volumeMap = new Map<Id, EUR_CRM_GB_Volume_Tracker__c>();
            List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeLineList = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();

            for(EUR_CRM_Contract_Activity_Item__c activity:acticityList){
                for(EUR_CRM_Contract_Product_Item__c item:activity.Contract_Product_Items__r){ 
                    List<EUR_CRM_Contract_Product_Item__c> productList = new List<EUR_CRM_Contract_Product_Item__c>(); 
                    if(productMap.get(activity.EUR_CRM_Contract__c) == null){
                        productList.add(item);
                        productMap.put(activity.EUR_CRM_Contract__c, productList);	
                    }else{
                        productList = productMap.get(activity.EUR_CRM_Contract__c);
                        productList.add(item);
                        productMap.put(activity.EUR_CRM_Contract__c, productList);
                    }	
                }

            }

            for(Id key:productMap.keySet()){
                EUR_CRM_GB_Volume_Tracker__c tracker = new EUR_CRM_GB_Volume_Tracker__c(EUR_CRM_Contract__c = key,recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_GB_Volume_Tracker__cEUR_PT_Contract_Volume_Tracker'));	
                volumeMap.put(key, tracker);
            }

            if(volumeMap.values().size() > 0){
              insert volumeMap.values();
            }

            for(Id key:productMap.keySet()){
                for(EUR_CRM_Contract_Product_Item__c lineItem:productMap.get(key)){
                    EUR_CRM_GB_Volume_Tracker_Line_Item__c newItem = new EUR_CRM_GB_Volume_Tracker_Line_Item__c
                    (EUR_CRM_Volume_Tracker__c = volumeMap.get(key).Id,
                     EUR_CRM_Brand_Quality_Size__c = lineItem.EUR_CRM_Brand_Quality_Size__c,
                     EUR_CRM_Initial_Contract_Volume__c = lineItem.EUR_CRM_Quantity__c,
                     EUR_CRM_Contract_Activity_Item__c = lineItem.EUR_CRM_Contract_Activity_Item__r.Id,
                     RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_GB_Volume_Tracker_Line_Item__cEUR_PT_Contract_Volume_Tracker_Line_Item')
                    );
                    volumeLineList.add(newItem);	
                }
            }

            if(volumeLineList.size() > 0){
              insert volumeLineList;
            }
        }
    }
    
}