public with sharing class EUR_CRM_ZA_AccountVolumeTrackDisplayExt {

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
    public List<EUR_CRM_Account_Volume_Tracker_Period__c> volumeTrackerPeriodList {get;set;}
    public List<VolumeTrackerItemPeriodWrapper> volTrackItemPeriodList {get;set;}
    public Boolean hasVolumeTrackerPeriods {get;set;}
    public Integer columnCtr {get;set;}

    public String strURL {get;set;}
    public Boolean shouldRedirect {get;set;}
    
    public List<Recordtype> euAcctRectypes = new List<Recordtype>();
    public Map<id, Recordtype> euAcctMapRecTypes = new Map<id, Recordtype>();

    public static String EU_ACCOUNT_ZA_OFF_TRADE = 'EUR_ZA_Off_Trade';
    public static String EU_ACCOUNT_ZA_ON_TRADE_DIRECT = 'EUR_ZA_On_Trade_Direct';
    public static String EU_ACCOUNT_ZA_ON_TRADE_INDIRECT = 'EUR_ZA_On_Trade_Indirect';
    public static String EU_ACCOUNT_ZA_ON_TRADE_INFORMAL = 'EUR_ZA_On_Trade_Informal';
    public static String EU_ACCOUNT_ZA_DISTRIBUTOR = 'EUR_ZA_Distributor';

    public static Set<String> OFF_TRADE_ZA = new Set<String>{EU_ACCOUNT_ZA_OFF_TRADE,EU_ACCOUNT_ZA_DISTRIBUTOR};
    public static Set<String> ON_TRADE_ZA = new Set<String>{EU_ACCOUNT_ZA_ON_TRADE_DIRECT,EU_ACCOUNT_ZA_ON_TRADE_INDIRECT,EU_ACCOUNT_ZA_ON_TRADE_INFORMAL};

    public EUR_CRM_ZA_AccountVolumeTrackDisplayExt(ApexPages.StandardController standardController){
        this.standardController = standardController;

        hasVolumeTrackerPeriods = FALSE;
        shouldRedirect = FALSE;
        
        //Init Account
        euAccount = [SELECT Id, Name, RecordtypeId FROM EUR_CRM_Account__c where Id = :accountId];

        //Init VolTrackerPeriodList
        volumeTrackerPeriodList = new List<EUR_CRM_Account_Volume_Tracker_Period__c>();
        
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
            if(volTrackItemPeriodList.size() > 0){
                hasVolumeTrackerPeriods = true;
            }
        }
     
        return vtItemMap;
    }

    public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> retrieveVolumeTrackerLineItems(Id volumeTrackerId){
        Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
        
        for (EUR_CRM_Account_Volume_Tracker_Line_Item__c volItem: [SELECT Id, Name, 
                                                            EUR_CRM_Account_Volume_Tracker__c,
                                                            EUR_CRM_Brand_Quality__c,
                                                            EUR_CRM_Brand_Quality__r.Name,
                                                            EUR_CRM_Brand_Quality_Name__c,
                                                            EUR_CRM_Brand_Quality_Size__c,
                                                            EUR_CRM_Brand_Quality_Size__r.Name,
                                                            EUR_CRM_Brand_Quality__r.EUR_CRM_Enable_Account_Volume_Tracking__c
                                                            FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c
                                                            WHERE EUR_CRM_Account_Volume_Tracker__c=:volumeTrackerId
                                                            AND EUR_CRM_Active__c = TRUE
                                                            //AND EUR_CRM_Brand_Quality__r.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE
                                                            LIMIT 49999
                                                            ]){

            if(ON_TRADE_ZA.contains(euAcctMapRecTypes.get(euAccount.RecordtypeId).DeveloperName)){
                volItem.EUR_CRM_Brand_Quality_Name__c = volItem.EUR_CRM_Brand_Quality__r.Name;
                volTrackerItems.put(volItem.EUR_CRM_Brand_Quality__c, volItem);
            } else {
                volItem.EUR_CRM_Brand_Quality_Name__c = volItem.EUR_CRM_Brand_Quality_Size__r.Name;
                volTrackerItems.put(volItem.EUR_CRM_Brand_Quality_Size__c, volItem);
            }

        }
        return volTrackerItems;
    }

    public void initVolumeTrackerPeriodExistWrapper(List<EUR_CRM_Account_Volume_Tracker_Line_Item__c> volumeTrackerItemList){
        volTrackItemPeriodList = new List<VolumeTrackerItemPeriodWrapper>();
        List<EUR_CRM_Account_Volume_Tracker_Period__c> periodList = new List<EUR_CRM_Account_Volume_Tracker_Period__c>();
        Set<Id> trackerItemIds = new Set<Id>();
        Map<Id, List<EUR_CRM_Account_Volume_Tracker_Period__c>> trackerPeriodMap = new Map<Id, List<EUR_CRM_Account_Volume_Tracker_Period__c>>();
        for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            trackerItemIds.add(volTrack.Id);
        }
        
        for(EUR_CRM_Account_Volume_Tracker_Period__c volTrackPeriod : [SELECT 
                                                                Id, 
                                                                EUR_CRM_End_Date__c, 
                                                                EUR_CRM_Start_Date__c,
                                                                EUR_CRM_Volume_by_Bottles__c, 
                                                                EUR_CRM_Account_Volume_Tracker_Line_Item__c 
                                                            FROM 
                                                                EUR_CRM_Account_Volume_Tracker_Period__c
                                                            WHERE
                                                                EUR_CRM_Account_Volume_Tracker_Line_Item__c
                                                            IN
                                                                :trackerItemIds
                                                            ORDER BY
                                                                CreatedDate ASC]){
            if(trackerPeriodMap.containskey(volTrackPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c)){
                trackerPeriodMap.get(volTrackPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c).add(volTrackPeriod);
            } else{
                trackerPeriodMap.put(volTrackPeriod.EUR_CRM_Account_Volume_Tracker_Line_Item__c, new List<EUR_CRM_Account_Volume_Tracker_Period__c>{volTrackPeriod});
            }
        }

        system.debug('##TRACKER PERIODS: '+trackerPeriodMap);

        for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
            periodList = new List<EUR_CRM_Account_Volume_Tracker_Period__c>();

            if(trackerPeriodMap.containskey(volTrack.Id)){
                periodList = trackerPeriodMap.get(volTrack.Id);
            }

            if(periodList.size() <= 0){
                EUR_CRM_Account_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Account_Volume_Tracker_Period__c();
                trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;
                trackPeriod.EUR_CRM_Start_Date__c = null;

                periodList.add(trackPeriod);
            }

            columnCtr = periodList.size();
            volTrackItemPeriodList.add(new VolumeTrackerItemPeriodWrapper(volTrack, periodList, null, null));
        }
    }

    public class VolumeTrackerItemPeriodWrapper{

        public EUR_CRM_Account_Volume_Tracker_Line_Item__c volumeTrackerItem {get;set;}
        public List<EUR_CRM_Account_Volume_Tracker_Period__c> volTrackerPeriods {get;set;}
        public Decimal totalActual {get;set;}
        public Decimal distanceToGo {get;set;}
        public Decimal forecast {get;set;}
        public Decimal indexPercent {get;set;}
        public Decimal contractFromIndex {get;set;}
        public Decimal contractToIndex {get;set;}
        public Date endDate;
        public Date contractStartDate;
        public Date contractEndDate;

        public VolumeTrackerItemPeriodWrapper(EUR_CRM_Account_Volume_Tracker_Line_Item__c volumeTrackerItem, List<EUR_CRM_Account_Volume_Tracker_Period__c> volTrackerPeriods, Date contractStartDate, Date contractEndDate){
            this.volumeTrackerItem = volumeTrackerItem;
            this.volTrackerPeriods = volTrackerPeriods;
            this.contractStartDate = contractStartDate;
            this.contractEndDate = contractEndDate;

            totalActual = 0;
            distanceToGo = 0;
            Date latestActualEndDate;
            for(EUR_CRM_Account_Volume_Tracker_Period__c trackerPeriod : volTrackerPeriods){
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

    public PageReference openAccountVolumeTracker(){
        strURL = '/apex/EUR_CRM_ZA_AccountVolumeTracker?id='+euAccount.Id;
        PageReference pageRef = new PageReference(strURL);
        pageRef.setredirect(true);
        shouldRedirect = TRUE;
        return null;
    }
}