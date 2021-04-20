public with sharing class EUR_CRM_DE_ContractVolumeTrackerExt extends EUR_CRM_DE_Contract_Class{

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

    public EUR_CRM_Contract__c contractObj{get;set;}
    
    public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemMap {get;set;} {volumeTrackerItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();}//Key: BQ ID (lookup)
    public List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList{
        get{
                        return volumeTrackerItemMap.values();
        }
    }
    
    public EUR_CRM_GB_Volume_Tracker__c volumeTrackerObj{get;set;}
    
    public EUR_CRM_DE_ContractVolumeTrackerExt(ApexPages.StandardController standardController){
        super(standardController.getId());
        this.standardController = standardController;
        
        contractObj = retrieveContractDetails(contractId);
        
        //Init Volume Tracker
        if (contractObj != null){
                initVolumeTracker(contractObj);
        }
    }
    
    private void initVolumeTracker(EUR_CRM_Contract__c contractObj){
        volumeTrackerItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();
        
        volumeTrackerObj = retrieveVolumeTracker(contractObj.Id);
        System.debug('Volume Tracker:' + volumeTrackerObj);
        
        volumeTrackerItemMap = initVolumeTrackerItems(contractObj);
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
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> initVolumeTrackerItems (EUR_CRM_Contract__c contractObj){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();

        //Get existing Volume Tracker Line Items
        if (volumeTrackerObj!=null){
                vtItemMap.putAll(retrieveVolumeTrackerLineItems(contractObj));
                System.debug('Check Vol Tracker Items 1:' + vtItemMap);
        }
        
        if (vtItemMap.size()<=0){
                //Get Contract Line Items
                Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> cliVtItemMap = createVolumeTrackerLineItems(contractObj);
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
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> retrieveVolumeTrackerLineItems(EUR_CRM_Contract__c contractObj){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        
        for (EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem: [SELECT Id, Name, 
                                                                                                                EUR_CRM_Adjusted_Contract_Volume__c, 
                                                                                                                EUR_CRM_Brand_Quality__c,
                                                                                                                EUR_CRM_Brand_Quality__r.Name,
                                                                                                                EUR_CRM_Brand__c,
                                                                                                                EUR_CRM_Brand__r.Name,
                                                                                                                EUR_CRM_Confirmed_Contract_to_Date_Volu__c,
                                                                                                                EUR_CRM_Initial_Contract_Volume__c,
                                                                                                                EUR_CRM_Volume_Tracker__c,
                                                                                                                EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c,
                                                                                                                EUR_CRM_Brand_Quality_Name__c,
                                                                                                                EUR_CRM_Name__c,
                                                                                                                EUR_CRM_Unit__c
                                                                                                                FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
                                                                                                                WHERE EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__c=:contractObj.Id
                                                                                                                AND (EUR_CRM_Brand_Quality__c!= NULL OR EUR_CRM_Brand__c!=NULL)
                                                                                                                LIMIT 49999
                                                                                                                ]){
                Id key = (volItem.EUR_CRM_Brand_Quality__c!=null)?volItem.EUR_CRM_Brand_Quality__c:volItem.EUR_CRM_Brand__c;                                                                                                    
                volItem.EUR_CRM_Name__c = (volItem.EUR_CRM_Brand_Quality__c!=null)?volItem.EUR_CRM_Brand_Quality__r.Name:volItem.EUR_CRM_Brand__r.Name;
                if (key != null){
                        volTrackerItems.put(key, volItem);
                }
                }
        return volTrackerItems;
    }
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(EUR_CRM_Contract__c contractObj){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        //List<EUR_CRM_Contract_Line_Item__c> allContractLineItems = new List<EUR_CRM_Contract_Line_Item__c>();
        
        Map <Id, EUR_CRM_Mechanic_Type__c> mechanicTypeMap = retrieveMechanicTypes(contractObj);
        List<EUR_CRM_Mechanic_Type__c> mechanicsForCompliance = new List<EUR_CRM_Mechanic_Type__c>();
        
        if (contractObj!=null){
                 for(EUR_CRM_Mechanic_Type__c mType: mechanicTypeMap.values()){
                                //Selected mechanic type only
                        if (mType.EUR_CRM_For_Compliance_Check__c != null && mType.EUR_CRM_For_Compliance_Check__c==true){
                                mechanicsForCompliance.add(mType);
                        }
                 }
                 
                 if (mechanicsForCompliance.size()>0){
                        volTrackerItems.putAll(createVolumeTrackerItems(contractObj, mechanicsForCompliance));
                 }
        }
        return volTrackerItems;
        }
        
        private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerItems(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Mechanic_Type__c>mechanicTypes){
                Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
                Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> productItemsMap = retrieveContractProductItems(contractObj, mechanicTypes);

                System.debug('Flag - Create Volume Tracker Items - Check Mechanic Types:'+mechanicTypes);
                System.debug('Flag - Create Volume Tracker Items - Check Product Items:'+productItemsMap);
                for (String prodItemMapKey:productItemsMap.keySet()){
                        Map <String, EUR_CRM_Contract_Product_Item__c> itemMap = productItemsMap.get(prodItemMapKey);
                        System.debug('Flag - ###' + itemMap);
                        System.debug('Flag - ###' + itemMap.values());
                        for (EUR_CRM_Contract_Product_Item__c prodItem: itemMap.values()){
                                EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem;// = new EUR_CRM_GB_Volume_Tracker_Line_Item__c();
                                Id key = null;
                                //Id key = (prodItem.EUR_CRM_Brand_Quality__c!=null)?prodItem.EUR_CRM_Brand_Quality__c :null;
                                //System.debug('Flag - Create Volume Tracker Items - Check Product Key 1:' + key+'-'+prodItem);
                                //key = (key==null && prodItem.EUR_CRM_Brand__c!=null)?prodItem.EUR_CRM_Brand__c :null;
                                System.debug('Flag - Create Volume Tracker Items - Check Product Item:'+prodItem);
                                if (prodItem.EUR_CRM_Brand_Quality__c!=null && prodItem.EUR_CRM_Brand__c==null){
                                        key = prodItem.EUR_CRM_Brand_Quality__c;
                                        System.debug('Flag - Create Volume Tracker Items - Check Product Key 1:' + key+'-'+prodItem);
                                }
                                else if(prodItem.EUR_CRM_Brand_Quality__c==null && prodItem.EUR_CRM_Brand__c!=null){
                                        key = prodItem.EUR_CRM_Brand__c;
                                        System.debug('Flag - Create Volume Tracker Items - Check Product Key 2:' + key+'-'+prodItem);
                                }
                                
                                if (key!=null && (!volItems.containsKey(key))){
                                        volItem = new EUR_CRM_GB_Volume_Tracker_Line_Item__c(); 
                                        volItem.EUR_CRM_Volume_Tracker__c = (volumeTrackerObj!=null && volumeTrackerObj.Id!=null)?volumeTrackerObj.Id:null;
                                        volItem.EUR_CRM_Initial_Contract_Volume__c = prodItem.EUR_CRM_Quantity__c;
                                        volItem.EUR_CRM_Unit__c = prodItem.EUR_CRM_Unit__c;
                                }
                                else if (key!=null && volItems.containsKey(key)){
                                        volItem = volItems.get(key);
                                        volItem.EUR_CRM_Initial_Contract_Volume__c += prodItem.EUR_CRM_Quantity__c;
                                }
                                
                                if (volItem!=null && prodItem.EUR_CRM_Brand_Quality__c!=null){
                                        volItem.EUR_CRM_Brand_Quality__c = prodItem.EUR_CRM_Brand_Quality__c;
                                        volItem.EUR_CRM_Name__c = prodItem.EUR_CRM_Brand_Quality__r.Name;
                                        volItems.put(key, volItem);
                                }else if(volItem!=null && prodItem.EUR_CRM_Brand__c!=null){
                                        volItem.EUR_CRM_Brand__c = prodItem.EUR_CRM_Brand__c;
                                        volItem.EUR_CRM_Name__c = prodItem.EUR_CRM_Brand__r.Name;
                                        volItems.put(key, volItem);
                                }
                        }
                }
                System.debug('Flag - Create Volume Tracker Items - Check Res:'+volItems);
                
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