public with sharing class EUR_CRM_ContractVolumeTrackerExt {
    
    private final static String POURING_GROUP_NAME = 'Pouring';
    private final static String STOCK_GROUP_NAME = 'Stock';
    private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_GROUP_NAME = new Set<String>{POURING_GROUP_NAME.toUpperCase(), STOCK_GROUP_NAME.toUpperCase()};
    
    
    private ApexPages.StandardController standardController {get;set;}
    private Id contractId {
        get{if (this.standardController!=null){
                return this.standardController.getId();                                 
        }   
        return null;
    }}
    
    public EUR_CRM_ContractClass contractClassObject {get; private set;}
    
    public EUR_CRM_Contract__c contractObj{
        get{if (contractClassObject!=null){return contractClassObject.contractDetails;}
            else{ return new EUR_CRM_Contract__c();}}
        set;
    }
    
    public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemMap {get;set;} {volumeTrackerItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();}//Key: BQ ID (lookup)
    public List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList{
        get{
            return volumeTrackerItemMap.values();
        }
    }
    
    public EUR_CRM_GB_Volume_Tracker__c volumeTrackerObj{get;set;}
    
    public EUR_CRM_ContractVolumeTrackerExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        //Init Contract
        contractClassObject = new EUR_CRM_ContractClass(contractId);
        
        //Init Volume Tracker
        if (contractClassObject != null){
            initVolumeTracker(contractClassObject);
        }
    }
    
    private void initVolumeTracker(EUR_CRM_ContractClass contractClassObject){
        volumeTrackerItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();
        
        volumeTrackerObj = retrieveVolumeTracker(contractClassObject.contractDetails.Id);
        System.debug('Volume Tracker:' + volumeTrackerObj);
        
        volumeTrackerItemMap = initVolumeTrackerItems();
        /*if (volumeTrackerObj!=null){
            volumeTrackerItemMap.putAll(retrieveVolumeTrackerLineItems(volumeTrackerObj.Id));
            System.debug('Check Vol Tracker Items 1:' + volumeTrackerItemMap);
        }
        
        //Create Vol Line items
        volumeTrackerItemMap.putAll(createVolumeTrackerLineItems());
        System.debug('Check Vol Tracker Items 2:' + volumeTrackerItemMap);
        */
    }
    
    //private List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>
    private EUR_CRM_GB_Volume_Tracker__c retrieveVolumeTracker(Id contractId){
        List<EUR_CRM_GB_Volume_Tracker__c> volTracker = [SELECT Id, Name, EUR_CRM_Contract__c 
                                                FROM EUR_CRM_GB_Volume_Tracker__c 
                                                WHERE EUR_CRM_Contract__c=:contractId
                                                LIMIT 1];
        if (volTracker.size()>0){
            return volTracker.get(0);
        }                           
        
        return null;            
    }
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> initVolumeTrackerItems (){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();

        //Get existing Volume Tracker Line Items
        if (volumeTrackerObj!=null){
            vtItemMap.putAll(retrieveVolumeTrackerLineItems(volumeTrackerObj.Id));
            System.debug('Check Vol Tracker Items 1:' + vtItemMap);
        }
        
        if (vtItemMap.size()<=0){
            //Get Contract Line Items
            Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> cliVtItemMap = createVolumeTrackerLineItems();
            for (Id key: cliVtItemMap.keySet()){
                EUR_CRM_GB_Volume_Tracker_Line_Item__c cliVtItem = cliVtItemMap.get(key);
                if (vtItemMap.containsKey(key)){
                    EUR_CRM_GB_Volume_Tracker_Line_Item__c vtItem = vtItemMap.get(key);
                    vtItem.EUR_CRM_Initial_Contract_Volume__c = (vtItem.EUR_CRM_Initial_Contract_Volume__c==null)?0:vtItem.EUR_CRM_Initial_Contract_Volume__c;
                    vtItem.EUR_CRM_Initial_Contract_Volume__c += (cliVtItem.EUR_CRM_Initial_Contract_Volume__c==null)?0:cliVtItem.EUR_CRM_Initial_Contract_Volume__c;
                    vtItemMap.put(key, vtItem);
                }else{
                    vtItemMap.put(key, cliVtItem);
                }
            }
        }
        
        System.debug('Check Vol Tracker Items 2:' + vtItemMap);
        
        return vtItemMap;
    }
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> retrieveVolumeTrackerLineItems(Id volumeTrackerId){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        
        for (EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem: [SELECT Id, Name, 
                                                            EUR_CRM_Adjusted_Contract_Volume__c, 
                                                            EUR_CRM_Brand_Quality__c,
                                                            EUR_CRM_Brand_Quality__r.Name,
                                                            EUR_CRM_Confirmed_Contract_to_Date_Volu__c,
                                                            EUR_CRM_Initial_Contract_Volume__c,
                                                            EUR_CRM_Volume_Tracker__c,
                                                            EUR_CRM_Brand_Quality_Name__c
                                                            FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
                                                            WHERE EUR_CRM_Volume_Tracker__c=:volumeTrackerId
                                                            AND EUR_CRM_Brand_Quality__c!= null
                                                            LIMIT 49999
                                                            ]){
                                                                
            volItem.EUR_CRM_Brand_Quality_Name__c = volItem.EUR_CRM_Brand_Quality__r.Name;
            volTrackerItems.put(volItem.EUR_CRM_Brand_Quality__c, volItem);
        }
        return volTrackerItems;
    }
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        List<EUR_CRM_Contract_Line_Item__c> allContractLineItems = new List<EUR_CRM_Contract_Line_Item__c>();
        
        if (contractClassObject!=null){
             for(EUR_CRM_Mechanic_Type__c mType: contractClassObject.contractMechanicTypeMap.values()){
                //Add Pouring and Stock only
                if (VOL_TRACKER_MECHANIC_TYPE_GROUP_NAME.contains(mType.EUR_CRM_Grouping_Name__c.toUpperCase())){
                    //Get Contract Line Item
                    List<EUR_CRM_Contract_Line_Item__c> contractLineItems = (contractClassObject.contractLineItemMap.containsKey(mType.Id))?contractClassObject.contractLineItemMap.get(mType.Id):new List<EUR_CRM_Contract_Line_Item__c>();
                    //volTrackerItems.putAll(createVolItemFromContractItem(contractLineItems));
                    allContractLineItems.addAll(contractLineItems);
                }
             }
             
             if (allContractLineItems.size()>0){
                volTrackerItems.putAll(createVolItemFromContractItem(allContractLineItems));
             }
        }
        return volTrackerItems;
    }
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolItemFromContractItem(List<EUR_CRM_Contract_Line_Item__c> contractLineItems){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        
        for(EUR_CRM_Contract_Line_Item__c cli: contractLineItems){
            //if ((cli.EUR_Min_Qty_Per_Annum_9L__c!=null || cli.EUR_Min_Qty_Per_Annum_9L__c>0) && (cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c!=null)){
            if ((cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c!=null)){
                System.debug('Flag - CLI:' + cli);
                
                Id key = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c;
                EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem = new EUR_CRM_GB_Volume_Tracker_Line_Item__c();
                
                if (volumeTrackerItemMap.containsKey(key)){
                    continue;
                    //volItem = volumeTrackerItemMap.get(key);
                    //volItem.EUR_CRM_Initial_Contract_Volume__c += cli.EUR_Min_Qty_Per_Annum_9L__c;
                    System.debug('Flag - createVolItemFromContractItem 1: ' + volItem);
                }else{
                    if (volItems.containsKey(key)){
                        volItem = volItems.get(key);
                        volItem.EUR_CRM_Initial_Contract_Volume__c += cli.EUR_Min_Qty_Per_Annum_9L__c;
                        
                        System.debug('Flag - createVolItemFromContractItem 2: ' + volItem);
                    }
                    else{
                        volItem.EUR_CRM_Brand_Quality__c = key;
                        volItem.EUR_CRM_Brand_Quality_Name__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.Name;
                        volItem.EUR_CRM_Initial_Contract_Volume__c = cli.EUR_Min_Qty_Per_Annum_9L__c;
                        
                        System.debug('Flag - createVolItemFromContractItem 3: ' + volItem);
                    }
                    if (volumeTrackerObj != null){
                        volItem.EUR_CRM_Volume_Tracker__c = volumeTrackerObj.Id;
                    }
    
                    volItems.put(key, volItem);
                }
            }
        }
        system.debug('***********: ' +volItems);
        return volItems;
    }
    
    public PageReference saveVolTracker(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Boolean isQuickSave = Boolean.valueOf(params.get('IS_QUICK_SAVE'));
        
        Id volTrackerId = null;
        
        //Check Volume Tracker
        if (volumeTrackerObj == null){
            EUR_CRM_GB_Volume_Tracker__c volTracker = new EUR_CRM_GB_Volume_Tracker__c(EUR_CRM_Contract__c=contractId);
            
            Database.UpsertResult volTrackerUpsertResult = Database.upsert(volTracker);
            if (volTrackerUpsertResult.isSuccess()){
                volTrackerId = volTrackerUpsertResult.getId();
            }
        }else{
            volTrackerId = volumeTrackerObj.Id;
        }
        
        if (volTrackerId != null){
            for (EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem:volumeTrackerItemMap.values()){
                if (volItem.EUR_CRM_Volume_Tracker__c == null){
                    volItem.EUR_CRM_Volume_Tracker__c = volTrackerId;
                }
            }
            
            Database.UpsertResult[] volTrackerItemsUpsertResult = Database.upsert(volumeTrackerItemMap.values());
        }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+contractObj.Id);
        }
        
        
        return pageRef;
    }

}