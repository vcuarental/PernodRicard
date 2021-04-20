public with sharing class EUR_CRM_FI_ContractVolTrackExtendedExt {
        
        private final static String POURING_GROUP_NAME = 'Finland - Pouring';
        private final static String SELECTION_GROUP_NAME = 'Finland - Selection';
        private final static Set<String> VOL_TRACKER_MECHANIC_TYPE_GROUP_NAME = new Set<String>{POURING_GROUP_NAME.toUpperCase(), SELECTION_GROUP_NAME.toUpperCase()};
        public final static String POURING_REFUND_WINES = 'Pouring Refund Wines';
        public final static String SELECTION_BRANDS_WINES = 'Selection Brands Wines';
        public final static Map<Integer, String> MAPTRACKERPERIODERRORS = new Map<Integer, String>{
            1 => 'End date cannot be before Start date.',            
            2 => 'Overlap of time periods. Please modify.',
            3 => 'End Date of Actual Period exceeding the Contract\'s End Date',
            4 => 'Start Date of Actual Period is before the Contract\'s Start Date'
        };

        private ApexPages.StandardController standardController {get;set;}
        private Id contractId {
            get{ return (this.standardController!=null)? this.standardController.getId(): null;}
        }        
        public EUR_CRM_ContractClass contractClassObject {get; private set;}
        public EUR_CRM_Contract__c contractObj{
            get{ return (contractClassObject!=null)? contractClassObject.contractDetails: new EUR_CRM_Contract__c();}
            set;
        }
        public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemMap {get;set;} {volumeTrackerItemMap = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> ();}//Key: BQ ID (lookup)
        public List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList{
            get{ return volumeTrackerItemMap.values(); }
        }
        public EUR_CRM_GB_Volume_Tracker__c volumeTrackerObj{get;set;}
        public List<EUR_CRM_Volume_Tracker_Period__c> volumeTrackerPeriodList {get;set;}
        public List<VolumeTrackerItemPeriodWrapper> volTrackItemPeriodList {get;set;}
        public Integer columnCtr {get;set;}
        
        public EUR_CRM_FI_ContractVolTrackExtendedExt(ApexPages.StandardController standardController){
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
                initVolumeTrackerPeriodExistWrapper(vtItemMap.values());
            }
            
            if (vtItemMap.size()<=0){
                //Get Contract Line Items
                Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> cliVtItemMap = createVolumeTrackerLineItems();
                for (Id key: cliVtItemMap.keySet()){
                    EUR_CRM_GB_Volume_Tracker_Line_Item__c cliVtItem = cliVtItemMap.get(key);
                    EUR_CRM_GB_Volume_Tracker_Line_Item__c vtItem = vtItemMap.containsKey(key)? vtItemMap.get(key): cliVtItem;
                    if (vtItemMap.containsKey(key)){
                        vtItem.EUR_CRM_Initial_Contract_Volume__c = (vtItem.EUR_CRM_Initial_Contract_Volume__c==null)?0:vtItem.EUR_CRM_Initial_Contract_Volume__c;
                        vtItem.EUR_CRM_Initial_Contract_Volume__c += (cliVtItem.EUR_CRM_Initial_Contract_Volume__c==null)?0:cliVtItem.EUR_CRM_Initial_Contract_Volume__c;
                    }
                    vtItemMap.put(key, vtItem);
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
                                                                    EUR_CRM_Volume_Tracker_Line_Item__c,
                                                                    EUR_CRM_Volume_Tracker_EU__c
                                                                FROM 
                                                                    EUR_CRM_Volume_Tracker_Period__c
                                                                WHERE
                                                                    EUR_CRM_Volume_Tracker_Line_Item__c
                                                                IN
                                                                    :trackerItemIds
                                                                ORDER BY
                                                                    CreatedDate ASC]){
                if(!trackerPeriodMap.containskey(volTrackPeriod.EUR_CRM_Volume_Tracker_Line_Item__c)){
                    trackerPeriodMap.put(volTrackPeriod.EUR_CRM_Volume_Tracker_Line_Item__c, new List<EUR_CRM_Volume_Tracker_Period__c>());
                }
                trackerPeriodMap.get(volTrackPeriod.EUR_CRM_Volume_Tracker_Line_Item__c).add(volTrackPeriod);
            }

            for(EUR_CRM_GB_Volume_Tracker_Line_Item__c volTrack : volumeTrackerItemList){
                periodList = new List<EUR_CRM_Volume_Tracker_Period__c>();

                if(trackerPeriodMap.containskey(volTrack.Id)){
                    //periodList.add(trackerPeriodMap.get(volTrack.Id));
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
                                                                EUR_CRM_Mechanic_Type_Name__c
                                                                FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
                                                                WHERE EUR_CRM_Volume_Tracker__c=:volumeTrackerId
                                                                //AND EUR_CRM_Brand_Quality_Size__c!= null
                                                                //AND EUR_CRM_Initial_Contract_Volume__c <> 0
                                                                ORDER BY EUR_CRM_Mechanic_Type_Name__c
                                                                LIMIT 49999
                                                                ]){
                                                                    
                if(volItem.EUR_CRM_Mechanic_Type_Name__c == POURING_REFUND_WINES){
                    volItem.EUR_CRM_Brand_Quality_Size_Name__c = volItem.EUR_CRM_SKU__r.Name;
                    //volTrackerItems.put(volItem.EUR_CRM_Brand_Quality_Size__c, volItem);
                    volTrackerItems.put(volItem.EUR_CRM_SKU__c, volItem);
                }
                else if(volItem.EUR_CRM_Mechanic_Type_Name__c == SELECTION_BRANDS_WINES){
                    volItem.EUR_CRM_Brand_Quality_Size_Name__c = volItem.EUR_CRM_Brand__r.Name;
                    //volTrackerItems.put(volItem.EUR_CRM_Brand_Quality_Size__c, volItem);
                    volTrackerItems.put(volItem.EUR_CRM_Brand__c, volItem);
                } else{
                    volItem.EUR_CRM_Brand_Quality_Size_Name__c = volItem.EUR_CRM_Brand_Quality_Size__r.Name;
                    volTrackerItems.put(volItem.EUR_CRM_Brand_Quality_Size__c, volItem);
                }
                //volItem.EUR_CRM_Brand_Quality_Size_Name__c = volItem.EUR_CRM_Brand_Quality_Size__r.Name;
                //volTrackerItems.put(volItem.EUR_CRM_Brand_Quality_Size__c, volItem);
            }
            return volTrackerItems;
        }
        
        public Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(){
        //private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerLineItems(){
            Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volTrackerItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
            List<EUR_CRM_Contract_Product_Item__c> allContractLineItems = new List<EUR_CRM_Contract_Product_Item__c>();
            Map<Id, List<EUR_CRM_Contract_Product_Item__c>> productLineItemMap = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();

            productLineItemMap = EUR_CRM_FI_UtilClass.retrieveContractProductLineItems(contractClassObject.contractDetails.Id);
            
            if (contractClassObject!=null){
                System.debug('$$MECHTYPEVALUES: '+contractClassObject.contractMechanicTypeMap.values());
                 for(EUR_CRM_Mechanic_Type__c mType: contractClassObject.contractMechanicTypeMap.values()){
                    //Add Pouring and Stock only
                    if (VOL_TRACKER_MECHANIC_TYPE_GROUP_NAME.contains(mType.EUR_CRM_Grouping_Name__c.toUpperCase())){
                        //Get Contract Line Item
                        List<EUR_CRM_Contract_Product_Item__c> contractLineItems = (productLineItemMap.containsKey(mType.Id))?productLineItemMap.get(mType.Id):new List<EUR_CRM_Contract_Product_Item__c>();
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
        
        private Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolItemFromContractItem(List<EUR_CRM_Contract_Product_Item__c> contractLineItems){
            Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c> volItems = new Map<Id, EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
            
            for(EUR_CRM_Contract_Product_Item__c cli: contractLineItems){
                //if ((cli.EUR_Min_Qty_Per_Annum_9L__c!=null || cli.EUR_Min_Qty_Per_Annum_9L__c>0) && (cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c!=null)){
                //if ((cli.EUR_CRM_Brand_Quality_Size__c!=null)){
                if ((cli.EUR_CRM_Brand_Quality_Size__c!=null) || (cli.EUR_CRM_SKU__c!=null) || (cli.EUR_CRM_Brand__c!=null) ){
                    System.debug('Flag - CLI:' + cli);
                    
                    Id key;
                    if(cli.EUR_CRM_Brand_Quality_Size__c != null){
                        key = cli.EUR_CRM_Brand_Quality_Size__c;
                    }
                    if(cli.EUR_CRM_SKU__c!=null){
                        key = cli.EUR_CRM_SKU__c;
                    }
                    if(cli.EUR_CRM_Brand__c!=null){
                        key = cli.EUR_CRM_Brand__c;
                    }
                    EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem = new EUR_CRM_GB_Volume_Tracker_Line_Item__c();
                    
                    if (volumeTrackerItemMap.containsKey(key)){
                        continue;
                        //volItem = volumeTrackerItemMap.get(key);
                        //volItem.EUR_CRM_Initial_Contract_Volume__c += cli.EUR_Min_Qty_Per_Annum_9L__c;
                        System.debug('Flag - createVolItemFromContractItem 1: ' + volItem);
                    }else{
                        if (volItems.containsKey(key)){
                            volItem = volItems.get(key);
                            volItem.EUR_CRM_Initial_Contract_Volume__c += cli.EUR_CRM_Quantity__c;
                            
                            System.debug('Flag - createVolItemFromContractItem 2: ' + volItem);
                        }
                        else{
                            if(cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name == POURING_REFUND_WINES){
                                volItem.EUR_CRM_SKU__c = key;
                                volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_SKU_Name__c;
                            }
                            else if(cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name == SELECTION_BRANDS_WINES){
                                volItem.EUR_CRM_Brand__c = key;
                                //volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_SKU__r.Name;
                                volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_Brand_Name__c;
                            } else{
                                volItem.EUR_CRM_Brand_Quality_Size__c = key;
                                volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_Brand_Quality_Size__r.Name;
                            }

                            //volItem.EUR_CRM_Brand_Quality_Size__c = key;
                            //volItem.EUR_CRM_Brand_Quality_Size_Name__c = cli.EUR_CRM_Brand_Quality_Size__r.Name;
                            volItem.EUR_CRM_Initial_Contract_Volume__c = cli.EUR_CRM_Quantity__c;
                            volItem.EUR_CRM_Mechanic_Type_Name__c = cli.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name;
                            
                            System.debug('Flag - createVolItemFromContractItem 3: ' + volItem);
                        }
                        if (volumeTrackerObj != null){
                            volItem.EUR_CRM_Volume_Tracker__c = volumeTrackerObj.Id;
                        }
                        /*if(volItem.EUR_CRM_Initial_Contract_Volume__c != 0){
                            volItems.put(key, volItem);
                        }*/
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
                /*for (EUR_CRM_GB_Volume_Tracker_Line_Item__c volItem:volumeTrackerItemMap.values()){
                    if (volItem.EUR_CRM_Volume_Tracker__c == null){
                        volItem.EUR_CRM_Volume_Tracker__c = volTrackerId;
                    }
                }
                
                Database.UpsertResult[] volTrackerItemsUpsertResult = Database.upsert(volumeTrackerItemMap.values());*/

                List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> upsertTrackerItems = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
                List<EUR_CRM_Volume_Tracker_Period__c> upsertTrackerPeriod = new List<EUR_CRM_Volume_Tracker_Period__c>();

                for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){
                    if(periodWrap.volumeTrackerItem.EUR_CRM_Volume_Tracker__c == null){
                        periodWrap.volumeTrackerItem.EUR_CRM_Volume_Tracker__c = volTrackerId;
                    }
                    upsertTrackerItems.add(periodWrap.volumeTrackerItem);
                }
                upsert upsertTrackerItems;

                Integer isError = 0;
                for(VolumeTrackerItemPeriodWrapper periodWrap : volTrackItemPeriodList){
                    for(Integer i=0 ; i < periodWrap.volTrackerPeriods.size(); i++){

                        Date startDate = volTrackItemPeriodList[0].volTrackerPeriods[i].EUR_CRM_Start_Date__c;
                        Date endDate = volTrackItemPeriodList[0].volTrackerPeriods[i].EUR_CRM_End_Date__c;

                        /*periodWrap.volTrackerPeriods[i].EUR_CRM_Volume_Tracker_Line_Item__c = periodWrap.volumeTrackerItem.Id;
                        periodWrap.volTrackerPeriods[i].EUR_CRM_Start_Date__c = startDate;
                        periodWrap.volTrackerPeriods[i].EUR_CRM_End_Date__c = endDate;

                        upsertTrackerPeriod.add(periodWrap.volTrackerPeriods[i]);*/

                        if(startDate != null && endDate != null){
                            /*periodWrap.volTrackerPeriods[i].EUR_CRM_Volume_Tracker_Line_Item__c = periodWrap.volumeTrackerItem.Id;
                            periodWrap.volTrackerPeriods[i].EUR_CRM_Start_Date__c = startDate;
                            periodWrap.volTrackerPeriods[i].EUR_CRM_End_Date__c = endDate;

                            upsertTrackerPeriod.add(periodWrap.volTrackerPeriods[i]);*/
                            System.debug('##START-END: '+startDate+' : '+endDate);
                            if(endDate >= startDate){
                                if(periodWrap.volTrackerPeriods[i].EUR_CRM_Volume_Tracker_EU__c == null){
                                    periodWrap.volTrackerPeriods[i].EUR_CRM_Volume_Tracker_EU__c = volTrackerId;
                                }                                
                                periodWrap.volTrackerPeriods[i].EUR_CRM_Volume_Tracker_Line_Item__c = periodWrap.volumeTrackerItem.Id;
                                periodWrap.volTrackerPeriods[i].EUR_CRM_Start_Date__c = startDate;
                                periodWrap.volTrackerPeriods[i].EUR_CRM_End_Date__c = endDate;

                                upsertTrackerPeriod.add(periodWrap.volTrackerPeriods[i]);
                            }else{
                                isError = 1;
                            }

                            if(i > 0){
                                if(startDate <= volTrackItemPeriodList[0].volTrackerPeriods[i-1].EUR_CRM_End_Date__c){
                                    isError = 2;
                                }
                            }
                            //contractObj.EUR_CRM_Start_Date__c, contractObj.EUR_CRM_End_Date__c
                            if(endDate > contractObj.EUR_CRM_End_Date__c){
                                isError = 3;
                            }
                            if(startDate < contractObj.EUR_CRM_Start_Date__c){
                                isError = 4;
                            }
                        } 
                    }
                }
                if(isError>0 && isError<5){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,MAPTRACKERPERIODERRORS.get(isError));
                    ApexPages.addMessage(myMsg);                    
                    return null;
                } else{
                    upsert upsertTrackerPeriod;
                }
                /*if(isError2 == true){
                    if (contractClassObject != null){
                        //initVolumeTracker(contractClassObject);
                    }
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Overlap of time periods. Please modify.');
                    ApexPages.addMessage(myMsg);
                    return null;
                } else{
                    upsert upsertTrackerPeriod;
                }*/
                

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
            public Decimal indexPercent {get;set;}
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
                Decimal volumeByBottles = 0;
                for(EUR_CRM_Volume_Tracker_Period__c trackerPeriod : volTrackerPeriods){
                    volumeByBottles = (trackerPeriod.EUR_CRM_Volume_by_Bottles__c == null) ? 0 : trackerPeriod.EUR_CRM_Volume_by_Bottles__c;
                    totalActual = totalActual + volumeByBottles;
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

                    /*System.debug('**1: '+daysBetweenContract);
                    System.debug('**2: '+daysBetweenContractActual);
                    System.debug('**3: '+calculateContractActual);
                    System.debug('**4: '+totalActual);*/
                    //forecast = (totalActual / (calculateContractActual * 100)) * calculateContractActual + totalActual;
                    //forecast = forecast.setScale(0);

                    //distanceToGo = volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c - totalActual;
                    distanceToGo = totalActual - volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c;

                    contractFromIndex = calculateContractActual * 100;
                    System.debug('**Contract FROM INDEX1: '+contractFromIndex);
                    contractFromIndex = contractFromIndex.setScale(0);

                    contractToIndex = 100 - contractFromIndex;
                    
                    //forecast = (totalActual / contractFromIndex) * ((1-calculateContractActual) * 100) + totalActual;
                    forecast = (totalActual / (calculateContractActual * 100)) * ((1-calculateContractActual) * 100) + totalActual;
                    forecast = forecast.setScale(0);
                    
                    indexPercent = (forecast / volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c) * 100;
                    //indexPercent = (totalActual / contractFromIndex);
                    //indexPercent = (forecast / volumeTrackerItem.EUR_CRM_Initial_Contract_Volume__c);
                    indexPercent = indexPercent.setScale(0);
                    
                    System.debug('**TOTAL ACTUAL: '+totalActual);
                    System.debug('**Contract FROM INDEX: '+contractFromIndex);
                    System.debug('**Contract FROM INDEX22: '+((1-calculateContractActual) * 100));
                }

            }
        }

    }