public with sharing class EUR_CRM_ZA_ContractVolTrackExtendedExt {
        
    private final static String POURING_GROUP_NAME = 'Finland - Pouring';
    private final static String SELECTION_GROUP_NAME = 'Finland - Selection';
    private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_GROUP_NAME = new Set<String>{POURING_GROUP_NAME.toUpperCase(), SELECTION_GROUP_NAME.toUpperCase()};
    public final static String POURING_REFUND_WINES = 'Pouring Refund Wines';
    public final static String SELECTION_BRANDS_WINES = 'Selection Brands Wines';
    public final static String LISTING = 'Listing';
    public final static String EXCLUSIVITY = 'Exclusivity';
    public final static String HOUSE_POUR = 'House pour';
    public final static String STOCK_DEAL = 'Stock deals';
    public final static String REBATE_STOCK_DEAL = 'Rebate Stock Deals';
    public final static String EVENTS= 'Events';
    public final static String POS_MATERIAL = 'Marketing Activity Wines';
    public final static String UNIFORMS = 'Uniforms';
    public final static String DRINKS_MENU = 'Drinks Menu';
    public final static String BAR_STYLING = 'Bar Styling';
    public final static String TRAININGS = 'Trainings';
    public final static String DISPLAYS = 'Displays';
    public final static String PROMOTIONS = 'Promotions';
    private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_BQ_GROUP = new Set<String>{LISTING,EXCLUSIVITY,HOUSE_POUR,STOCK_DEAL,REBATE_STOCK_DEAL};
    private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_BRAND_GROUP = new Set<String>{EVENTS,POS_MATERIAL,UNIFORMS,DRINKS_MENU,BAR_STYLING,TRAININGS,DISPLAYS,PROMOTIONS};

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
    
    public Boolean volTrackItemIsEmpty {get{return this.volTrackItemPeriodList.size()==0;} set;}

    public EUR_CRM_GB_Volume_Tracker__c volumeTrackerObj{get;set;}

    public List<EUR_CRM_Volume_Tracker_Period__c> volumeTrackerPeriodList {get;set;}

    public List<VolumeTrackerItemPeriodWrapper> volTrackItemPeriodList {get;set;}

    public Integer columnCtr {get;set;}
    
    public EUR_CRM_ZA_ContractVolTrackExtendedExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        //Init Contract
        contractClassObject = new EUR_CRM_ContractClass(contractId);

        //Init VolTrackerPeriodList
        volumeTrackerPeriodList = new List<EUR_CRM_Volume_Tracker_Period__c>();
        
        //Init Volume Tracker
        if (contractClassObject != null){
            initVolumeTracker(contractClassObject);
        }
    }
    
    public void initVolumeTracker(EUR_CRM_ContractClass contractClassObject){
        volumeTrackerItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();
        
        volumeTrackerObj = retrieveVolumeTracker(contractClassObject.contractDetails.Id);
        System.debug('Volume Tracker:' + volumeTrackerObj);
        
        volumeTrackerItemMap = initVolumeTrackerItems();
    }
    
    //private List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>
    public EUR_CRM_GB_Volume_Tracker__c retrieveVolumeTracker(Id contractId){
        List<EUR_CRM_GB_Volume_Tracker__c> volTracker = [SELECT Id, Name, EUR_CRM_Contract__c 
                                                FROM EUR_CRM_GB_Volume_Tracker__c 
                                                WHERE EUR_CRM_Contract__c=:contractId
                                                LIMIT 1];
        if (volTracker.size()>0){
            return volTracker.get(0);
        }                           
        
        return null;            
    }
    
    public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> initVolumeTrackerItems (){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();

        //Get existing Volume Tracker Line Items
        if (volumeTrackerObj!=null){
            vtItemMap.putAll(retrieveVolumeTrackerLineItems(volumeTrackerObj.Id));
            System.debug('Check Vol Tracker Items 1:' + vtItemMap);
            initVolumeTrackerPeriodExistWrapper(vtItemMap.values());
        }
        
        if (vtItemMap.size()<=0){
            //Get Contract Line Items
            Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> cliVtItemMap = createVolumeTrackerLineItems();
            System.debug('@@CLITVITEM: '+cliVtItemMap);
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
            initVolumeTrackerPeriodNewWrapper(vtItemMap.values());
        }
        
        System.debug('$$Check Vol Tracker Items 2:' + vtItemMap);
        
        return vtItemMap;
    }

    private void initVolumeTrackerPeriodNewWrapper(List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList){
        volTrackItemPeriodList = new List<VolumeTrackerItemPeriodWrapper>();
        List<EUR_CRM_Volume_Tracker_Period__c> periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

        for(EUR_CRM_GB_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();
            EUR_CRM_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Volume_Tracker_Period__c();
            trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;
            trackPeriod.EUR_CRM_Start_Date__c = contractObj.EUR_CRM_Start_Date__c;

            periodList.add(trackPeriod);

            columnCtr = periodList.size();

            volTrackItemPeriodList.add(new VolumeTrackerItemPeriodWrapper(volTrack, periodList, contractObj.EUR_CRM_Start_Date__c, contractObj.EUR_CRM_End_Date__c));
        }
    }

    private void initVolumeTrackerPeriodExistWrapper(List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList){
        volTrackItemPeriodList = new List<VolumeTrackerItemPeriodWrapper>();
        List<EUR_CRM_Volume_Tracker_Period__c> periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();
        Set<Id> trackerItemIds = new Set<Id>();
        Map<Id, List<EUR_CRM_Volume_Tracker_Period__c>> trackerPeriodMap = new Map<Id, List<EUR_CRM_Volume_Tracker_Period__c>>();
        for(EUR_CRM_GB_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            trackerItemIds.add(volTrack.Id);
        }

        for(EUR_CRM_Volume_Tracker_Period__c volTrackPeriod : [SELECT 
                                                                Id, 
                                                                EUR_CRM_End_Date__c, 
                                                                EUR_CRM_Start_Date__c,
                                                                EUR_CRM_Volume_by_Bottles__c, 
                                                                EUR_CRM_Volume_Tracker_Line_Item__c
                                                            FROM 
                                                                EUR_CRM_Volume_Tracker_Period__c
                                                            WHERE
                                                                EUR_CRM_Volume_Tracker_Line_Item__c
                                                            IN
                                                                :trackerItemIds
                                                            ORDER BY
                                                                CreatedDate ASC]){
            if(trackerPeriodMap.containskey(volTrackPeriod.EUR_CRM_Volume_Tracker_Line_Item__c)){
                trackerPeriodMap.get(volTrackPeriod.EUR_CRM_Volume_Tracker_Line_Item__c).add(volTrackPeriod);
            } else{
                trackerPeriodMap.put(volTrackPeriod.EUR_CRM_Volume_Tracker_Line_Item__c, new List<EUR_CRM_Volume_Tracker_Period__c>{volTrackPeriod});
            }     
        }

        for(EUR_CRM_GB_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

            if(trackerPeriodMap.containskey(volTrack.Id)){
                periodList = trackerPeriodMap.get(volTrack.Id);
            }

            if(periodList.size() <= 0){
                EUR_CRM_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Volume_Tracker_Period__c();
                trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;
                trackPeriod.EUR_CRM_Start_Date__c = contractObj.EUR_CRM_Start_Date__c;

                periodList.add(trackPeriod);
            }
            columnCtr = periodList.size();
            volTrackItemPeriodList.add(new VolumeTrackerItemPeriodWrapper(volTrack, periodList, contractObj.EUR_CRM_Start_Date__c, contractObj.EUR_CRM_End_Date__c));
        }
    }
    
    private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> retrieveVolumeTrackerLineItems(Id volumeTrackerId){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        
        for (EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem: [SELECT Id, Name, 
                                                            EUR_CRM_Adjusted_Contract_Volume__c, 
                                                            EUR_CRM_Brand_Quality__c,
                                                            EUR_CRM_Brand_Quality__r.Name,
                                                            EUR_CRM_Brand_Quality_Size__c,
                                                            EUR_CRM_Brand_Quality_Size__r.Name,
                                                            EUR_CRM_SKU__c,
                                                            EUR_CRM_SKU__r.Name,
                                                            EUR_CRM_Brand__c,
                                                            EUR_CRM_Brand__r.Name,
                                                            EUR_CRM_Confirmed_Contract_to_Date_Volu__c,
                                                            EUR_CRM_Initial_Contract_Volume__c,
                                                            EUR_CRM_Volume_Tracker__c,
                                                            EUR_CRM_Brand_Quality_Name__c,
                                                            EUR_CRM_Brand_Quality_Size_Name__c,
                                                            EUR_CRM_Mechanic_Type_Name__c,
                                                            EUR_CRM_Forecast__c,
                                                            EUR_CRM_Index__c
                                                            FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
                                                            WHERE EUR_CRM_Volume_Tracker__c=:volumeTrackerId
                                                            //AND EUR_CRM_Brand_Quality_Size__c!= null
                                                            //AND EUR_CRM_Initial_Contract_Volume__c <> 0
                                                            ORDER BY EUR_CRM_Mechanic_Type_Name__c
                                                            LIMIT 49999
                                                            ]){
                                                                
            if(VOL_TRACKER_MECHANIC_TYPE_BQ_GROUP.contains(volItem.EUR_CRM_Mechanic_Type_Name__c)){
                volItem.EUR_CRM_Brand_Quality_Size_Name__c = volitem.EUR_CRM_Brand_Quality__r.Name;
                volTrackerItems.put(volItem.EUR_CRM_Brand_Quality__c, volItem);
            } 
            else if(VOL_TRACKER_MECHANIC_TYPE_BRAND_GROUP.contains(volItem.EUR_CRM_Mechanic_Type_Name__c)){
                volItem.EUR_CRM_Brand_Quality_Size_Name__c = volItem.EUR_CRM_Brand__r.Name;
                volTrackerItems.put(volItem.EUR_CRM_Brand__c, volItem);
            }
        }
        return volTrackerItems;
    }
    
    public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        List<EUR_CRM_Contract_Product_Item__c> allContractLineItems = new List<EUR_CRM_Contract_Product_Item__c>();
        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> productLineItemMap = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();

        productLineItemMap = EUR_CRM_ZA_UtilClass.retrieveContractProductLineItems(contractClassObject.contractDetails.Id);
        System.debug('@@PRODUCT_ITEMS:' + productLineItemMap);
        
        if (contractClassObject!=null){
            System.debug('$$MECHTYPEVALUES: '+contractClassObject.contractMechanicTypeMap.values());

            for(EUR_CRM_Mechanic_Type__c mType: contractClassObject.contractMechanicTypeMap.values()){
                if(mType.Name == STOCK_DEAL || mType.EUR_CRM_Grouping_Name__c == REBATE_STOCK_DEAL){
                    List<EUR_CRM_Contract_Product_Item__c> contractLineItems = (productLineItemMap.containsKey(mType.Id))?productLineItemMap.get(mType.Id):new List<EUR_CRM_Contract_Product_Item__c>();
                    allContractLineItems.addAll(contractLineItems);
                }
            }
            
            for(List<EUR_CRM_Contract_Product_Item__c> prodList : productLineItemMap.values()){
                system.debug('Entered into prodList forloop');
                system.debug(prodList);
                for(EUR_CRM_Contract_Product_Item__c prod : prodList){
                    system.debug('Entered into prod forloop');
                    system.debug(prod);
                    if((prod.EUR_CRM_Contract_activity_Item__r.EUR_CRM_Mechanic__c != null) && 
                    	(prod.EUR_CRM_Contract_activity_Item__r.EUR_CRM_Mechanic__r.EUR_CRM_Enable_Contract_Volume_Tracking__c == true)){
                        allContractLineItems.add(prod);
                    }
                }
            }

            System.debug('@@ALL_CONTRACT_ITEMS:' + allContractLineItems);
            System.debug('@@ALL_CONTRACT_ITEMS-SIZE:' + allContractLineItems.size());
            

            if (allContractLineItems.size()>0){
                volTrackerItems.putAll(createVolItemFromContractItem(allContractLineItems));
            }
        }
        return volTrackerItems;
    }
    
    public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolItemFromContractItem(List<EUR_CRM_Contract_Product_Item__c> contractLineItems){
        Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        
        for(EUR_CRM_Contract_Product_Item__c cli: contractLineItems){
            if ((cli.EUR_CRM_Brand_Quality__c!=null) || (cli.EUR_CRM_Brand__c!=null) ){
                System.debug('Flag - CLI:' + cli);
                
                Id key;
                if(cli.EUR_CRM_Brand_Quality__c != null){
                    key = cli.EUR_CRM_Brand_Quality__c;
                }
                if(cli.EUR_CRM_Brand__c!=null){
                    key = cli.EUR_CRM_Brand__c;
                }
                EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem = new EUR_CRM_GB_Volume_Tracker_Line_Item__c();
                
                if (volumeTrackerItemMap.containsKey(key)){
                    System.debug('Flag - createVolItemFromContractItem 1: ' + volItem);
                    continue;
                }else{
                    System.debug('!!!MECHTYPE: '+cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name);
                    if(VOL_TRACKER_MECHANIC_TYPE_BQ_GROUP.contains(cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name)){
                        volItem.EUR_CRM_Brand_Quality__c = key;
                        volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_Brand_Quality__r.Name;
                    } 
                    else if(VOL_TRACKER_MECHANIC_TYPE_BRAND_GROUP.contains(cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name)){
                        volItem.EUR_CRM_Brand__c = key;
                        volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_Brand_Name__c;
                    }
                
                    volItem.EUR_CRM_Initial_Contract_Volume__c = cli.EUR_CRM_Quantity__c;
                    volItem.EUR_CRM_Mechanic_Type_Name__c = cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name;
                    
                    System.debug('&&KEY: ' + key);
                    System.debug('Flag - createVolItemFromContractItem 3: ' + volItem);

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
            List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> upsertTrackerItems = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
            List<EUR_CRM_Volume_Tracker_Period__c> upsertTrackerPeriod = new List<EUR_CRM_Volume_Tracker_Period__c>();

            for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){
                if(periodWrap.volumeTrackerItem.EUR_CRM_Volume_Tracker__c == null){
                    periodWrap.volumeTrackerItem.EUR_CRM_Volume_Tracker__c = volTrackerId;
                }
                upsertTrackerItems.add(periodWrap.volumeTrackerItem);
            }
            upsert upsertTrackerItems;

            Boolean isError = false;
            Boolean isError2 = false;
            Boolean isError3 = false;
            Boolean isError4 = false;
            for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){

                

                for(Integer i=0 ; i < periodWrap.volTrackerPeriods.size(); i++){

                    Date startDate = volTrackItemPeriodList[0].volTrackerPeriods[i].EUR_CRM_Start_Date__c;
                    Date endDate = volTrackItemPeriodList[0].volTrackerPeriods[i].EUR_CRM_End_Date__c;

                    if(startDate != null && endDate != null){
                        System.debug('##START-END: '+startDate+' : '+endDate);
                        if(endDate >= startDate){
                            periodWrap.volTrackerPeriods[i].EUR_CRM_Volume_Tracker_Line_Item__c = periodWrap.volumeTrackerItem.Id;
                            periodWrap.volTrackerPeriods[i].EUR_CRM_Start_Date__c = startDate;
                            periodWrap.volTrackerPeriods[i].EUR_CRM_End_Date__c = endDate;

                            upsertTrackerPeriod.add(periodWrap.volTrackerPeriods[i]);
                        }else{
                            isError = true;
                        }

                        if(i > 0){
                            if(startDate <= volTrackItemPeriodList[0].volTrackerPeriods[i-1].EUR_CRM_End_Date__c){
                                isError2 = true;
                            }
                        }
                        //contractObj.EUR_CRM_Start_Date__c, contractObj.EUR_CRM_End_Date__c
                        if(endDate > contractObj.EUR_CRM_End_Date__c){
                            isError3 = true;
                        }
                        if(startDate < contractObj.EUR_CRM_Start_Date__c){
                            isError4 = true;
                        }
                    } 
                }

            }
            if(isError == true || isError2 == true || isError3 == true || isError4 == true){

                if(isError2 == true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Overlap of time periods. Please modify.');
                    ApexPages.addMessage(myMsg);
                } 
                if(isError == true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'End date cannot be before Start date.');
                    ApexPages.addMessage(myMsg);
                }
                if(isError3 == true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'End Date of Actual Period exceeding the Contract\'s End Date');
                    ApexPages.addMessage(myMsg);
                }
                if(isError4 == true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Start Date of Actual Period is before the Contract\'s Start Date');
                    ApexPages.addMessage(myMsg);
                }
                
                return null;
            } else{
                upsert upsertTrackerPeriod;
            }           
        }

        if (contractClassObject != null){
            initVolumeTracker(contractClassObject);
        }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+contractObj.Id);
        }
        
        
        return pageRef;
    }

    public PageReference addNewVolumePeriod(){
        PageReference pageRef = null;
        //volumeTrackerPeriodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

        for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){
            EUR_CRM_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Volume_Tracker_Period__c();
            trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;
            if(periodWrap.endDate != null){
                trackPeriod.EUR_CRM_Start_Date__c = periodWrap.endDate + 1;
            }
            

            periodWrap.volTrackerPeriods.add(trackPeriod);
            columnCtr = periodWrap.volTrackerPeriods.size();
            system.debug('FLAG - CTR: '+columnCtr);
        }
        return pageRef;
    }

    public class VolumeTrackerItemPeriodWrapper{

        public EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTrackerItem {get;set;}
        public List<EUR_CRM_Volume_Tracker_Period__c> volTrackerPeriods {get;set;}
        public Decimal totalActual {get;set;}
        public Decimal distanceToGo {get;set;}
        public Decimal forecast {get;set;}
        public Decimal index {get;set;}
        public Decimal contractFromIndex {get;set;}
        public Decimal contractToIndex {get;set;}
        public Date endDate;
        public Date contractStartDate;
        public Date contractEndDate;

        public VolumeTrackerItemPeriodWrapper(EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTrackerItem, List<EUR_CRM_Volume_Tracker_Period__c> volTrackerPeriods, Date contractStartDate, Date contractEndDate){
            this.volumeTrackerItem = volumeTrackerItem;
            this.volTrackerPeriods = volTrackerPeriods;
            this.contractStartDate = contractStartDate;
            this.contractEndDate = contractEndDate;

            totalActual = 0;
            distanceToGo = 0;
            Date latestActualEndDate;
            for(EUR_CRM_Volume_Tracker_Period__c trackerPeriod : volTrackerPeriods){
                totalActual = totalActual + trackerPeriod.EUR_CRM_Volume_by_Bottles__c;
                if(trackerPeriod.EUR_CRM_End_Date__c != null){
                    endDate = trackerPeriod.EUR_CRM_End_Date__c;
                }
                if(trackerPeriod.Id != null){
                    latestActualEndDate = trackerPeriod.EUR_CRM_End_Date__c;
                }
            }

            System.debug('**LATEST: '+latestActualEndDate);

            if(latestActualEndDate != null){
                Double daysBetweenContract = contractStartDate.daysBetween(contractEndDate);
                Double daysBetweenContractActual = contractStartDate.daysBetween(latestActualEndDate);
                Double calculateContractActual = (daysBetweenContractActual / daysBetweenContract);

                distanceToGo = volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c - totalActual;

                contractFromIndex = calculateContractActual * 100;
                System.debug('**Contract FROM INDEX1: '+contractFromIndex);
                contractFromIndex = contractFromIndex.setScale(0);

                contractToIndex = 100 - contractFromIndex;
                                    
                System.debug('**TOTAL ACTUAL: '+totalActual);
                System.debug('**Contract FROM INDEX: '+contractFromIndex);
                System.debug('**Contract FROM INDEX22: '+((1-calculateContractActual) * 100));
            }
        }
    }
}