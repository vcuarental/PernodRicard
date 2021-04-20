public with sharing class EUR_CRM_AccountVolumeTrackerExt {

    private ApexPages.StandardController standardController {get;set;}
    private Id accountId {
        get{if (this.standardController!=null){
                return this.standardController.getId();                                 
        }   
        return null;
    }}
    
    public EUR_CRM_Account__c euAccount {get; private set;}
    public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> volumeTrackerItemMap {get;set;} {volumeTrackerItemMap = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> ();}//Key: BQ ID (lookup)
    public List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volumeTrackerItemList{
        get{
            return volumeTrackerItemMap.values();
        }
    }
    
    public EUR_CRM_Account_Volume_Tracker__c volumeTrackerObj{get;set;}
    public List<EUR_CRM_Volume_Tracker_Period__c> volumeTrackerPeriodList {get;set;}
    public List<VolumeTrackerItemPeriodWrapper> volTrackItemPeriodList {get;set;}
    public Integer columnCtr {get;set;}
    public List<Recordtype> euAcctRectypes = new List<Recordtype>();
    public Map<id, Recordtype> euAcctMapRecTypes = new Map<id, Recordtype>();

    public static Set<String> validRecordTypes = new Set<String>{
        'EUR_RU_Direct_Off_Trade',
        'EUR_RU_Direct_Type_2_Off_Trade',
        'EUR_RU_Indirect_Off_Trade',
        'EUR_RU_On_Trade'
    };
    
    public EUR_CRM_AccountVolumeTrackerExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        //Init Account
        euAccount = [SELECT Id, Name, RecordtypeId FROM EUR_CRM_Account__c where Id = :accountId];

        //Init VolTrackerPeriodList
        volumeTrackerPeriodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

        //INIT Rectypes
        euAcctRectypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        for(Recordtype rt : euAcctRectypes){
            euAcctMapRecTypes.put(rt.Id, rt);
        }
        
        //Init Volume Tracker
        if (euAccount != null){
            initVolumeTracker(euAccount);
        }
    }
    
    public void initVolumeTracker(EUR_CRM_Account__c euAccount){
        volumeTrackerItemMap = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> ();
        
        volumeTrackerObj = retrieveVolumeTracker(euAccount.Id);
        System.debug('Volume Tracker:' + volumeTrackerObj);
        
        volumeTrackerItemMap = initVolumeTrackerItems();
    }
    
    //private List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>
    public EUR_CRM_Account_Volume_Tracker__c retrieveVolumeTracker(Id accountId){
        List<EUR_CRM_Account_Volume_Tracker__c> volTracker = [SELECT Id, Name, EUR_CRM_Account__c 
                                                FROM EUR_CRM_Account_Volume_Tracker__c 
                                                WHERE EUR_CRM_Account__c=:accountId
                                                LIMIT 1];
        if (volTracker.size()>0){
            return volTracker.get(0);
        }                           
        
        return null;            
    }
    
    public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> initVolumeTrackerItems (){
        Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> vtItemMap = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> ();

        //Get existing Volume Tracker Line Items
        if (volumeTrackerObj!=null){
            vtItemMap.putAll(retrieveVolumeTrackerLineItems(volumeTrackerObj.Id));
            System.debug('Check Vol Tracker Items 1:' + vtItemMap);
            initVolumeTrackerPeriodExistWrapper(vtItemMap.values());
        }
        
        if (vtItemMap.size()<=0){
            //Get Contract Line Items
            Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> cliVtItemMap = createVolumeTrackerLineItems();
            System.debug('@@CLITVITEM: '+cliVtItemMap);
            for (Id key: cliVtItemMap.keySet()){
                EUR_CRM_Account_Volume_Tracker_Line_Item__c cliVtItem = cliVtItemMap.get(key);
                vtItemMap.put(key, cliVtItem);
            }
            System.debug('##VITEMMAP: '+vtItemMap);
            initVolumeTrackerPeriodNewWrapper(vtItemMap.values());
        }
        
        
        return vtItemMap;
    }

    public void initVolumeTrackerPeriodNewWrapper(List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volumeTrackerItemList){
        volTrackItemPeriodList = new List<VolumeTrackerItemPeriodWrapper>();
        List<EUR_CRM_Volume_Tracker_Period__c> periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

        for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();
            EUR_CRM_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Volume_Tracker_Period__c();
            trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;

            periodList.add(trackPeriod);
            columnCtr = periodList.size();
            volTrackItemPeriodList.add(new VolumeTrackerItemPeriodWrapper(volTrack, periodList, null, null));
        }
    }

    public void initVolumeTrackerPeriodExistWrapper(List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volumeTrackerItemList){
        volTrackItemPeriodList = new List<VolumeTrackerItemPeriodWrapper>();
        List<EUR_CRM_Volume_Tracker_Period__c> periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();
        Set<Id> trackerItemIds = new Set<Id>();
        Map<Id, List<EUR_CRM_Volume_Tracker_Period__c>> trackerPeriodMap = new Map<Id, List<EUR_CRM_Volume_Tracker_Period__c>>();
        for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            trackerItemIds.add(volTrack.Id);
        }

        
        for(EUR_CRM_Volume_Tracker_Period__c volTrackPeriod : [SELECT 
                                                                Id, 
                                                                EUR_CRM_End_Date__c, 
                                                                EUR_CRM_Start_Date__c,
                                                                EUR_CRM_Volume_by_Bottles__c, 
                                                                EUR_CRM_Volume_Tracker_Line_Item__c,
                                                                EUR_CRM_Account_Volume_Tracker_Line_Item__c 
                                                            FROM 
                                                                EUR_CRM_Volume_Tracker_Period__c
                                                            WHERE
                                                                EUR_CRM_Account_Volume_Tracker_Line_Item__c
                                                            IN
                                                                :trackerItemIds
                                                            ORDER BY
                                                                CreatedDate ASC]){
            if(trackerPeriodMap.containskey(volTrackPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c)){
                trackerPeriodMap.get(volTrackPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c).add(volTrackPeriod);
            } else{
                trackerPeriodMap.put(volTrackPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c, new List<EUR_CRM_Volume_Tracker_Period__c>{volTrackPeriod});
            }
            
        }

        system.debug('##TRACKER PERIODS: '+trackerPeriodMap);

        for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

            if(trackerPeriodMap.containskey(volTrack.Id)){
                //periodList.add(trackerPeriodMap.get(volTrack.Id));
                periodList = trackerPeriodMap.get(volTrack.Id);
            }

            if(periodList.size() <= 0){
                EUR_CRM_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Volume_Tracker_Period__c();
                trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;
                trackPeriod.EUR_CRM_Start_Date__c = null;

                periodList.add(trackPeriod);
            }

            columnCtr = periodList.size();
            volTrackItemPeriodList.add(new VolumeTrackerItemPeriodWrapper(volTrack, periodList, null, null));
        }
    }
    
    public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> retrieveVolumeTrackerLineItems(Id volumeTrackerId){
        Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
        
        for (EUR_CRM_Account_Volume_Tracker_Line_Item__c volItem: [SELECT Id, Name, 
                                                            EUR_CRM_Account_Volume_Tracker__c,
                                                            EUR_CRM_Brand__c,
                                                            EUR_CRM_Brand__r.Name,
                                                            EUR_CRM_Brand__r.EUR_CRM_Enable_Account_Volume_Tracking__c,
                                                            EUR_CRM_Active__c,
                                                            EUR_CRM_Actual_YTD__c,
                                                            EUR_CRM_Month_To_Date__c,
                                                            EUR_CRM_Plan__c,
                                                            EUR_CRM_Plan_Fulfillment__c,
                                                            EUR_CRM_Quarter_to_Date__c
                                                            FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c
                                                            WHERE EUR_CRM_Account_Volume_Tracker__c=:volumeTrackerId
                                                            AND EUR_CRM_Active__c = TRUE
                                                            AND EUR_CRM_Brand__r.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE
                                                            LIMIT 49999
                                                            ]){
            //System.debug('@@ITEMS: '+volItem.EUR_CRM_Brand_Name__c);
            if(validRecordTypes.contains(euAcctMapRecTypes.get(euAccount.RecordtypeId).DeveloperName)){
                volTrackerItems.put(volItem.EUR_CRM_Brand__c, volItem);
            }
        }
        return volTrackerItems;
    }
    
    public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(){

        Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
        Map<Id,EUR_CRM_Brand__c> bqLineItemMap = new Map<Id,EUR_CRM_Brand__c>();

        if(validRecordTypes.contains(euAcctMapRecTypes.get(euAccount.RecordtypeId).DeveloperName)){
            bqLineItemMap = new Map<Id, EUR_CRM_Brand__c>([SELECT Id, Name, EUR_CRM_Active__c, EUR_CRM_Enable_Account_Volume_Tracking__c
                            FROM EUR_CRM_Brand__c
                            WHERE EUR_CRM_Enable_Account_Volume_Tracking__c = true]);
            for(EUR_CRM_Brand__c bq : bqLineItemMap.values()){
                EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackerItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
                volTrackerItem.EUR_CRM_Brand__c = bq.Id;
                volTrackerItem.EUR_CRM_Active__c = true;
                if (volumeTrackerObj != null){
                    volTrackerItem.EUR_CRM_Account_Volume_Tracker__c = volumeTrackerObj.Id;
                }

                volTrackerItems.put(bq.Id, volTrackerItem);
            }
        }

        return volTrackerItems;
    }
    
    public PageReference saveVolTracker(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Boolean isQuickSave = Boolean.valueOf(params.get('IS_QUICK_SAVE'));
        
        Id volTrackerId = null;
        
        //Check Volume Tracker
        if (volumeTrackerObj == null){
            EUR_CRM_Account_Volume_Tracker__c volTracker = new EUR_CRM_Account_Volume_Tracker__c(EUR_CRM_Account__c=accountId);
            
            Database.UpsertResult volTrackerUpsertResult = Database.upsert(volTracker);
            if (volTrackerUpsertResult.isSuccess()){
                volTrackerId = volTrackerUpsertResult.getId();
            }
        }else{
            volTrackerId = volumeTrackerObj.Id;
        }
        
        if (volTrackerId != null){

            List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> upsertTrackerItems = new List<EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            List<EUR_CRM_Volume_Tracker_Period__c> upsertTrackerPeriod = new List<EUR_CRM_Volume_Tracker_Period__c>();

            for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){
                if(periodWrap.volumeTrackerItem.EUR_CRM_Account_Volume_Tracker__c == null){
                    periodWrap.volumeTrackerItem.EUR_CRM_Account_Volume_Tracker__c = volTrackerId;
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
                            periodWrap.volTrackerPeriods[i].EUR_CRM_Account_Volume_Tracker_Line_Item__c = periodWrap.volumeTrackerItem.Id;
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

        if (euAccount != null){
            initVolumeTracker(euAccount);
        }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+euAccount.Id);
        }
        
        
        return pageRef;
    }

    public PageReference addNewVolumePeriod(){
        PageReference pageRef = null;

        for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){
            EUR_CRM_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Volume_Tracker_Period__c();
            trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;
            System.debug('##PERIODEND: '+periodWrap.endDate);
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

        public EUR_CRM_Account_Volume_Tracker_Line_Item__c volumeTrackerItem {get;set;}
        public List<EUR_CRM_Volume_Tracker_Period__c> volTrackerPeriods {get;set;}
        public Decimal totalActual {get;set;}
        public Decimal distanceToGo {get;set;}
        public Decimal forecast {get;set;}
        public Decimal indexPercent {get;set;}
        public Decimal contractFromIndex {get;set;}
        public Decimal contractToIndex {get;set;}
        public Date endDate;
        public Date contractStartDate;
        public Date contractEndDate;

        public VolumeTrackerItemPeriodWrapper(EUR_CRM_Account_Volume_Tracker_Line_Item__c volumeTrackerItem, List<EUR_CRM_Volume_Tracker_Period__c> volTrackerPeriods, Date contractStartDate, Date contractEndDate){
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
        }
    }
}