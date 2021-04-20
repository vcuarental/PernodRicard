public with sharing class EUR_CRM_ZA_AccountVolTrackerYTDExt {
        
        private final static String POURING_GROUP_NAME = 'Finland - Pouring';
        private final static String SELECTION_GROUP_NAME = 'Finland - Selection';
        private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_GROUP_NAME = new Set<String>{POURING_GROUP_NAME.toUpperCase(), SELECTION_GROUP_NAME.toUpperCase()};
        public final static String POURING_REFUND_WINES = 'Pouring Refund Wines';
        public final static String SELECTION_BRANDS_WINES = 'Selection Brands Wines';
        public final static String LISTING = 'Listing';
        public final static String EXCLUSIVITY = 'Exclusivity';
        public final static String HOUSE_POUR = 'House pour';
        public final static String STOCK_DEAL = 'Stok deals';
        public final static String EVENTS= 'Events';
        public final static String POS_MATERIAL = 'Marketing Activity Wines';
        public final static String UNIFORMS = 'Uniforms';
        public final static String DRINKS_MENU = 'Drinks Menu';
        public final static String BAR_STYLING = 'Bar Styling';
        public final static String TRAININGS = 'Trainings';
        public final static String DISPLAYS = 'Displays';
        public final static String PROMOTIONS = 'Promotions';
        private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_BQ_GROUP = new Set<String>{LISTING,EXCLUSIVITY,HOUSE_POUR,STOCK_DEAL};
        private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_BRAND_GROUP = new Set<String>{EVENTS,POS_MATERIAL,UNIFORMS,DRINKS_MENU,BAR_STYLING,TRAININGS,DISPLAYS,PROMOTIONS};

        
        
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
        public Integer columnCtr {get;set;}

        public List<Recordtype> euAcctRectypes = new List<Recordtype>();
        public Map<id, Recordtype> euAcctMapRecTypes = new Map<id, Recordtype>();

        public static String EU_ACCOUNT_ZA_OFF_TRADE = 'EUR_ZA_Off_Trade';
        public static String EU_ACCOUNT_ZA_ON_TRADE_DIRECT = 'EUR_ZA_On_Trade_Direct';
        public static String EU_ACCOUNT_ZA_ON_TRADE_INDIRECT = 'EUR_ZA_On_Trade_Indirect';
        public static String EU_ACCOUNT_ZA_ON_TRADE_INFORMAL = 'EUR_ZA_On_Trade_Informal';
        public static String EU_ACCOUNT_ZA_DISTRIBUTOR = 'EUR_ZA_Distributor';

        public static Set<String> OFF_TRADE_ZA = new Set<String>{EU_ACCOUNT_ZA_OFF_TRADE,EU_ACCOUNT_ZA_DISTRIBUTOR};
        public static Set<String> ON_TRADE_ZA = new Set<String>{EU_ACCOUNT_ZA_ON_TRADE_DIRECT,EU_ACCOUNT_ZA_ON_TRADE_INDIRECT,EU_ACCOUNT_ZA_ON_TRADE_INFORMAL};
        
        public EUR_CRM_ZA_AccountVolTrackerYTDExt(ApexPages.StandardController standardController){
            this.standardController = standardController;
            
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
            List<EUR_CRM_Account_Volume_Tracker_Period__c> periodList = new List<EUR_CRM_Account_Volume_Tracker_Period__c>();

            for(EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
                periodList = new List<EUR_CRM_Account_Volume_Tracker_Period__c>();
                EUR_CRM_Account_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Account_Volume_Tracker_Period__c();
                trackPeriod.EUR_CRM_Volume_by_Bottles__c = 0;

                periodList.add(trackPeriod);
                columnCtr = periodList.size();
                volTrackItemPeriodList.add(new VolumeTrackerItemPeriodWrapper(volTrack, periodList, null, null));
            }
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
                                                                    EUR_CRM_Account_Volume_Tracker_Line_Item__c,
                                                                    EUR_CRM_Actual_Week_1_Volume__c,
                                                                    EUR_CRM_Actual_Week_2_Volume__c,
                                                                    EUR_CRM_Actual_Week_3_Volume__c,
                                                                    EUR_CRM_Actual_Week_4_Volume__c 
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
        
        public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> retrieveVolumeTrackerLineItems(Id volumeTrackerId){
            Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            
            for (EUR_CRM_Account_Volume_Tracker_Line_Item__c volItem: [SELECT Id, Name, 
                                                                EUR_CRM_Account_Volume_Tracker__c,
                                                                EUR_CRM_Brand_Quality__c,
                                                                EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Brand_Quality_Name__c,
                                                                EUR_CRM_Brand_Quality_Size__c,
                                                                EUR_CRM_Brand_Quality_Size__r.Name,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Enable_Account_Volume_Tracking__c,
                                                                EUR_CRM_Actual_YTD__c,
                                                                EUR_CRM_Target__c,
                                                                EUR_CRM_Distance_to_Go__c
                                                                FROM EUR_CRM_Account_Volume_Tracker_Line_Item__c
                                                                WHERE EUR_CRM_Account_Volume_Tracker__c=:volumeTrackerId
                                                                AND EUR_CRM_Active__c = TRUE
                                                                //AND EUR_CRM_Brand_Quality__r.EUR_CRM_Enable_Account_Volume_Tracking__c = TRUE
                                                                LIMIT 49999
                                                                ]){
                System.debug('@@ITEMS: '+volItem.EUR_CRM_Brand_Quality_Name__c);
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
        
        public Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(){
            Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_Account_Volume_Tracker_Line_Item__c>();
            List<EUR_CRM_Quality__c> enabledBrandQualities = new List<EUR_CRM_Quality__c>();
            Map<Id,EUR_CRM_Quality__c> bqLineItemMap = new Map<Id,EUR_CRM_Quality__c>();
            Map<Id,EUR_CRM_Size__c> bqsLineItemMap = new Map<Id,EUR_CRM_Size__c>();

            if(ON_TRADE_ZA.contains(euAcctMapRecTypes.get(euAccount.RecordtypeId).DeveloperName)){
                bqLineItemMap = EUR_CRM_ZA_UtilClass.retrieveBrandQualityItems();
                for(EUR_CRM_Quality__c bq : bqLineItemMap.values()){
                    EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackerItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
                    volTrackerItem.EUR_CRM_Brand_Quality__c = bq.Id;
                    volTrackerItem.EUR_CRM_Brand_Quality_Name__c = bq.Name;
                    if (volumeTrackerObj != null){
                        volTrackerItem.EUR_CRM_Account_Volume_Tracker__c = volumeTrackerObj.Id;
                    }

                    volTrackerItems.put(bq.Id, volTrackerItem);
                }
            } else{
                bqsLineItemMap = EUR_CRM_ZA_UtilClass.retrieveBrandQualitySizeItems();
                for(EUR_CRM_Size__c bqs : bqsLineItemMap.values()){
                    EUR_CRM_Account_Volume_Tracker_Line_Item__c volTrackerItem = new EUR_CRM_Account_Volume_Tracker_Line_Item__c();
                    volTrackerItem.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
                    volTrackerItem.EUR_CRM_Brand_Quality_Name__c = bqs.Name;
                    if (volumeTrackerObj != null){
                        volTrackerItem.EUR_CRM_Account_Volume_Tracker__c = volumeTrackerObj.Id;
                    }

                    volTrackerItems.put(bqs.Id, volTrackerItem);
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
                List<EUR_CRM_Account_Volume_Tracker_Period__c> upsertTrackerPeriod = new List<EUR_CRM_Account_Volume_Tracker_Period__c>();

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
                EUR_CRM_Account_Volume_Tracker_Period__c trackPeriod = new EUR_CRM_Account_Volume_Tracker_Period__c();
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
                
                System.debug('**LATEST: '+latestActualEndDate);
            }
        }
    }