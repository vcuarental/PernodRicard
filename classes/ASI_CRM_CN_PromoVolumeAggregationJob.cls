/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromoVolumeAggregationJob
 * Description: Batch Job Class to generate Aggregated Sub-brand Volume
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-06-28       Keith Yip	            Created
 ****************************************************************************************************************************/

global class ASI_CRM_CN_PromoVolumeAggregationJob implements Database.Batchable<sObject>{
    //Field Map
    private final static List<String> RECORD_TYPE_LIST_AGGREGATION = new List<String> {
            'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume',
            'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume',
            'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume',
            'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data',
            'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data'
    };

    private final static List<String> SUBBRAND_FIELD_TO_RETRIEVE = new List<String> {
            'ASI_CRM_Year__c',
            'ASI_CRM_Month__c',
            'ASI_CRM_End_Date__c',
            'ASI_CRM_CN_Contract__c',
            'ASI_CRM_Account__c',
            'ASI_CRM_End_Date__c',
            'ASI_CRM_CN_Region__c',
            'ASI_CRM_CN_Product_Category__c',
            'ASI_CRM_CN_Product_Category_Agg__c',
            'ASI_CRM_Subbrand__c',
            'ASI_CRM_Subbrand__r.ASI_MFM_Brand__c',
            'ASI_CRM_CN_No_Month__c',
            'ASI_CRM_CN_Original_Contract_Start_Date__c'
    };

    private final static List<String> SUBBRAND_FIELD_TO_AGGREGATE_SUM = new List<String> {
            'ASI_CRM_Intake_9L__c',
            'ASI_CRM_Intake_Btl__c',
            'ASI_CRM_Intake_CR12__c',
            'ASI_CRM_CN_Intake_GS_T1_Price__c',
            'ASI_CRM_Intake_Std_Billing__c',
            'ASI_CRM_Intake_Std_Btl__c',
            'ASI_CRM_Offtake_CR12__c',
            'ASI_CRM_Offtake_GS__c',
            'ASI_CRM_Offtake_Std_Billing__c',
            'ASI_CRM_Offtake_Std__c',
            'ASI_CRM_POS_CR12__c',
            'ASI_CRM_POS_GS__c',
            'ASI_CRM_POS_Std_Billing__c',
            'ASI_CRM_PR_Direct__c',
            'ASI_CRM_PR_Direct_CR12__c',
            'ASI_CRM_PR_Direct_STD_Billing__c',
            'ASI_CRM_PR_Direct_STD__c',
            'ASI_CRM_T1_Depletion__c',
            'ASI_CRM_T1_Depletion_CR12__c',
            'ASI_CRM_T1_Depletion_STD_Billing__c',
            'ASI_CRM_T1_Depletion_STD__c',
            'ASI_CRM_T2_Depletion__c',
            'ASI_CRM_T2_Depletion_CR12__c',
            'ASI_CRM_T2_Depletion_STD_Billing__c',
            'ASI_CRM_T2_Depletion_STD__c'
    };

    private final static List<String> SUBBRAND_FIELD_TO_AGGREGATE_NON_SUMMABLE = new List<String> {
            'ASI_CRM_Year__c',
            'ASI_CRM_Month__c',
            'ASI_CRM_End_Date__c'
    };

    global Map<Id, List<ContractInfo>> outletContractMap {get;set;} {outletContractMap = new Map<Id, List<ContractInfo>>();}
    global List<ASI_TH_CRM_Contract__c> targetContract {get;set;} {targetContract = new List<ASI_TH_CRM_Contract__c>();}
    global String query {get;set;}
    global Date startDate {get;set;}

    global Date endDate {get;set;}
    global set<Id> allOutletIdSet {get;set;} {allOutletIdSet = new set<Id>();}

    public class ContractInfo {
        public Id contractId {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public Id outlet {get;set;}

        public ContractInfo (Id contractIdInput, Date startDateInput, Date endDateInput, ASI_CRM_AccountsAdditionalField__c outletInput){
            this.contractId = contractIdInput;
            this.startDate = startDateInput;
            this.endDate = endDateInput;
            this.outlet = outletInput.Id;
        }

        public ContractInfo (Id contractIdInput, Date startDateInput, Date endDateInput, Id outletInput){
            this.contractId = contractIdInput;
            this.startDate = startDateInput;
            this.endDate = endDateInput;
            this.outlet = outletInput;
        }
    }

    //Scope: All existing ongoing Contract which is TOT/MOT
    global ASI_CRM_CN_PromoVolumeAggregationJob(boolean deleteOldSummary){
        Set<Id> contractIdSet = new Map<Id, ASI_TH_CRM_Contract__c>([SELECT ID
        FROM ASI_TH_CRM_Contract__c
        WHERE ASI_CRM_CN_PO_Start_Date__c <= TODAY
        AND ASI_CRM_CN_PO_End_Date__c >= TODAY
        AND ASI_TH_CRM_Promotion_Type__c in('Outlet Promotion', 'Consumer Promotion', 'Wholesaler Promotion')]).KeySet();
        this.targetContract = [SELECT ID, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c
        FROM ASI_TH_CRM_Contract__c
        WHERE ASI_TH_CRM_Promotion_Type__c in('Outlet Promotion', 'Consumer Promotion', 'Wholesaler Promotion')
        AND Id in :contractIdSet
        ORDER BY Id ASC];
        if (deleteOldSummary){
            Set<Id> contractIdDeleteSet = new Set<Id>();
            for (ASI_TH_CRM_Contract__c contract : this.targetContract){
                contractIdDeleteSet.add(contract.Id);
            }
            delete [SELECT ID
            FROM ASI_CRM_Subbrand_Volume__c
            WHERE ASI_CRM_CN_Contract__c in :contractIdDeleteSet
            AND RecordType.DeveloperName in :RECORD_TYPE_LIST_AGGREGATION];
        }
        //Use Contract ID to find all Customer and Covered Outlet
        Set<Id> contractId = new Set<Id>();
        List<ContractInfo> ContractInfoList = new List<ContractInfo>();

        for (ASI_TH_CRM_Contract__c contract : targetContract){
            ContractInfo contractVol = new ContractInfo(contract.Id, contract.ASI_CRM_CN_PO_Start_Date__c, contract.ASI_CRM_CN_PO_End_Date__c, contract.ASI_CRM_CN_Outlet_WS__c);
            ContractInfoList.add(contractVol);

            List<ContractInfo> contractValues = outletContractMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
            if (contractValues == null){
                contractValues = new List<ContractInfo>();
            }
            contractValues.add(contractVol);
            outletContractMap.put(contract.ASI_CRM_CN_Outlet_WS__c, contractValues);

            //Used for search covered outlet
            contractId.add(contract.Id);
        }

        Map<Id, List<ASI_CRM_CN_Covered_Outlet__c>> contractOutletMap = new Map<Id, List<ASI_CRM_CN_Covered_Outlet__c>>();

        List<ASI_CRM_CN_Covered_Outlet__c> allCoveredOutletList = [SELECT Id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Outlet__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_End_Date__c
        FROM ASI_CRM_CN_Covered_Outlet__c
        WHERE ASI_CRM_CN_Contract__c in :contractId
        AND ASI_CRM_CN_Outlet__r.RecordType.DeveloperName ='ASI_CRM_Outlet_CN'
        ORDER BY ASI_CRM_CN_Contract__c ASC];


        //Covered Outlet
        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : allCoveredOutletList){
            ContractInfo contractVol = new ContractInfo(coveredOutlet.ASI_CRM_CN_Contract__c,
                    coveredOutlet.ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Start_Date__c,
                    coveredOutlet.ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                    coveredOutlet.ASI_CRM_CN_Outlet__c);
            ContractInfoList.add(contractVol);

            List<ContractInfo> contractValues = outletContractMap.get(coveredOutlet.ASI_CRM_CN_Outlet__c);
            if (contractValues == null){
                contractValues = new List<ContractInfo>();
            }
            contractValues.add(contractVol);
            outletContractMap.put(coveredOutlet.ASI_CRM_CN_Outlet__c, contractValues);

            if(contractOutletMap.containsKey(coveredOutlet.ASI_CRM_CN_Contract__c)){
                contractOutletMap.get(coveredOutlet.ASI_CRM_CN_Contract__c).add(coveredOutlet);
            }else{
                List<ASI_CRM_CN_Covered_Outlet__c> tempList  = new  List<ASI_CRM_CN_Covered_Outlet__c>();
                tempList.add(coveredOutlet);
                contractOutletMap.put(coveredOutlet.ASI_CRM_CN_Contract__c,tempList);
            }

        }
        //Get all Subbrand Volume Data
        Set<String> allQueryField = new Set<String>();
        allQueryField.addAll(SUBBRAND_FIELD_TO_RETRIEVE);
        allQueryField.addAll(SUBBRAND_FIELD_TO_AGGREGATE_SUM);

        //TODO: Put RECORD_TYPE_LIST_AGGREGATION into Custom Setting to avoid deployment if any update of record type
        String query = 'SELECT ' + String.join(new List<String>(allQueryField), ',') + ' ' +
                'FROM ASI_CRM_Subbrand_Volume__c ' +
                'WHERE ASI_CRM_CN_Competitor_Sub_brand__c = FALSE ' +
                'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE ' +
                'AND RecordType.DeveloperName NOT in :RECORD_TYPE_LIST_AGGREGATION AND (';

        List<string> queryContractInfo = new List<String>();
        for (ContractInfo ContractInfo : ContractInfoList){
            if(contractOutletMap.containsKey(ContractInfo.contractId)){
                for(ASI_CRM_CN_Covered_Outlet__c outlet : contractOutletMap.get(ContractInfo.contractId)) {
                    //queryContractInfo.add('(ASI_CRM_End_Date__c > ' + dateToString(ContractInfo.startDate) + ' AND ASI_CRM_End_Date__c <= ' + dateToString(ContractInfo.endDate) + ' AND ASI_CRM_Account__c = \'' + ContractInfo.outlet + '\')');
                    queryContractInfo.add('(ASI_CRM_End_Date__c > ' + dateToString(ContractInfo.startDate) + ' AND ASI_CRM_End_Date__c <= ' + dateToString(ContractInfo.endDate) + ' AND ASI_CRM_Account__c = \'' + outlet.ASI_CRM_CN_Outlet__c + '\')');
                }
            }
        }
        query += String.join(queryContractInfo, ' OR ') + ')';

        this.query = query;

    }

    global ASI_CRM_CN_PromoVolumeAggregationJob(boolean deleteOldSummary, Set<Id> contractIdSet){
        this.targetContract = [SELECT ID, ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c
        FROM ASI_TH_CRM_Contract__c
        WHERE ASI_TH_CRM_Promotion_Type__c in('Outlet Promotion', 'Consumer Promotion', 'Wholesaler Promotion')
        AND Id in :contractIdSet
        ORDER BY Id ASC];
        if (deleteOldSummary){
            Set<Id> contractIdDeleteSet = new Set<Id>();
            for (ASI_TH_CRM_Contract__c contract : this.targetContract){
                contractIdDeleteSet.add(contract.Id);
            }
            delete [SELECT ID
            FROM ASI_CRM_Subbrand_Volume__c
            WHERE ASI_CRM_CN_Contract__c in :contractIdDeleteSet
            AND RecordType.DeveloperName in :RECORD_TYPE_LIST_AGGREGATION];
        }
        //Use Contract ID to find all Customer and Covered Outlet
        Set<Id> contractId = new Set<Id>();
        List<ContractInfo> ContractInfoList = new List<ContractInfo>();

        for (ASI_TH_CRM_Contract__c contract : targetContract){
            ContractInfo contractVol = new ContractInfo(contract.Id, contract.ASI_CRM_CN_PO_Start_Date__c, contract.ASI_CRM_CN_PO_End_Date__c, contract.ASI_CRM_CN_Outlet_WS__c);
            ContractInfoList.add(contractVol);

            List<ContractInfo> contractValues = outletContractMap.get(contract.ASI_CRM_CN_Outlet_WS__c);
            if (contractValues == null){
                contractValues = new List<ContractInfo>();
            }
            contractValues.add(contractVol);
            outletContractMap.put(contract.ASI_CRM_CN_Outlet_WS__c, contractValues);

            //Used for search covered outlet
            contractId.add(contract.Id);

            if(startDate == null || startDate >= contract.ASI_CRM_CN_PO_Start_Date__c){
                startDate = contract.ASI_CRM_CN_PO_Start_Date__c;
            }

            if(endDate == null || endDate >= contract.ASI_CRM_CN_PO_End_Date__c){
                endDate = contract.ASI_CRM_CN_PO_End_Date__c;
            }
        }

        List<ASI_CRM_CN_Covered_Outlet__c> allCoveredOutletList = [SELECT Id, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Outlet__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Start_Date__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_End_Date__c
        FROM ASI_CRM_CN_Covered_Outlet__c
        WHERE ASI_CRM_CN_Contract__c in :contractId
        AND ASI_CRM_CN_Outlet__r.RecordType.DeveloperName ='ASI_CRM_Outlet_CN'
        ORDER BY ASI_CRM_CN_Contract__c ASC];


        Map<Id, List<ASI_CRM_CN_Covered_Outlet__c>> contractOutletMap = new Map<Id, List<ASI_CRM_CN_Covered_Outlet__c>>();

        //Covered Outlet
        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : allCoveredOutletList){
            ContractInfo contractVol = new ContractInfo(coveredOutlet.ASI_CRM_CN_Contract__c,
                    coveredOutlet.ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Start_Date__c,
                    coveredOutlet.ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_End_Date__c,
                    coveredOutlet.ASI_CRM_CN_Outlet__c);
            ContractInfoList.add(contractVol);

            List<ContractInfo> contractValues = outletContractMap.get(coveredOutlet.ASI_CRM_CN_Outlet__c);
            if (contractValues == null){
                contractValues = new List<ContractInfo>();
            }
            contractValues.add(contractVol);
            outletContractMap.put(coveredOutlet.ASI_CRM_CN_Outlet__c, contractValues);

            if(contractOutletMap.containsKey(coveredOutlet.ASI_CRM_CN_Contract__c)){
                contractOutletMap.get(coveredOutlet.ASI_CRM_CN_Contract__c).add(coveredOutlet);
            }else{
                List<ASI_CRM_CN_Covered_Outlet__c> tempList  = new  List<ASI_CRM_CN_Covered_Outlet__c>();
                tempList.add(coveredOutlet);
                contractOutletMap.put(coveredOutlet.ASI_CRM_CN_Contract__c,tempList);
            }

            allOutletIdSet.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
        }
        //Get all Subbrand Volume Data
        Set<String> allQueryField = new Set<String>();
        allQueryField.addAll(SUBBRAND_FIELD_TO_RETRIEVE);
        allQueryField.addAll(SUBBRAND_FIELD_TO_AGGREGATE_SUM);

        String query = 'SELECT ' + String.join(new List<String>(allQueryField), ',') + ' ' +
                'FROM ASI_CRM_Subbrand_Volume__c ' +
                'WHERE ASI_CRM_CN_Competitor_Sub_brand__c = FALSE ' +
                'AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = FALSE ' +
                'AND RecordType.Name NOT in :RECORD_TYPE_LIST_AGGREGATION ';
        List<string> queryContractInfo = new List<String>();

        String queryInfo = ' AND ASI_CRM_End_Date__c > ' + dateToString(startDate) +
                           ' AND ASI_CRM_End_Date__c <= ' + dateToString(endDate) +
                           ' AND ASI_CRM_Account__c in :allOutletIdSet ';

        /*if(ContractInfoList.size()>0){
            query += 'AND (';
            for (ContractInfo ContractInfo : ContractInfoList){
                if(contractOutletMap.containsKey(ContractInfo.contractId)) {
                    for (ASI_CRM_CN_Covered_Outlet__c outlet : contractOutletMap.get(ContractInfo.contractId)) {
                        //queryContractInfo.add('(ASI_CRM_End_Date__c > ' + dateToString(ContractInfo.startDate) + ' AND ASI_CRM_End_Date__c <= ' + dateToString(ContractInfo.endDate) + ' AND ASI_CRM_Account__c = \'' + ContractInfo.outlet + '\')');
                        queryContractInfo.add('(ASI_CRM_End_Date__c > ' + dateToString(ContractInfo.startDate) + ' AND ASI_CRM_End_Date__c <= ' + dateToString(ContractInfo.endDate) + ' AND ASI_CRM_Account__c = \'' + outlet.ASI_CRM_CN_Outlet__c + '\')');
                    }
                }
            }
            query += String.join(queryContractInfo, ' OR ') + ')';
        }*/
        this.query = query + queryInfo;
    }

    global database.querylocator start(Database.BatchableContext BC){
        system.debug('Canter+sql:' + query);
        return Database.getQueryLocator(query);
    }

    /*	Create Map of Aggregated Sub-brand Volume (Summary) by respective key
    	Refresh Contract ID for each Sub-brand Volume
    	Looping all the Non-Aggregated Sub-brand Volume (Data)
    		If Not created, create and add into the Summary
    		Else, add into Summary
    	Upsert the Summary */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_CRM_Subbrand_Volume__c> dataList = scope;
        Set<Id> contractIDSet = new Set<Id>();
        for (ASI_CRM_Subbrand_Volume__c datarow:dataList){
            List<ContractInfo> contractInfoList = outletContractMap.get(datarow.ASI_CRM_Account__c);
            if(contractInfoList != null){
                for (contractInfo contractInfoLine : contractInfoList){
                    contractIDSet.add(contractInfoLine.contractId);
                }
            }

        }

        Set<String> allQueryField = new Set<String>();
        allQueryField.addAll(SUBBRAND_FIELD_TO_RETRIEVE);
        allQueryField.addAll(SUBBRAND_FIELD_TO_AGGREGATE_SUM);

        List<ASI_CRM_Subbrand_Volume__c> existingSummaryList = Database.query('SELECT Id, ' + String.join(new List<String>(allQueryField), ',') + ' ' +
                ',RecordType.DeveloperName, ASI_CRM_CN_Brand_Agg__c ' +
                'FROM ASI_CRM_Subbrand_Volume__c ' +
                'WHERE ASI_CRM_CN_Contract__c in :contractIDSet ' +
                'AND RecordType.DeveloperName in :RECORD_TYPE_LIST_AGGREGATION');

        List<ASI_TH_CRM_Contract__c> contractList = Database.query('SELECT Id, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c ' +
                'FROM ASI_TH_CRM_Contract__c ' +
                'WHERE id in :contractIDSet');

        Map<Id, ASI_TH_CRM_Contract__c> contractMap = new Map<Id, ASI_TH_CRM_Contract__c>();
        for (ASI_TH_CRM_Contract__c contract : contractList){
            contractMap.put(contract.Id, contract);
        }



        //BrandSummary use Year;Month;Contract Id;Brand as Key
        //RegionVolumeSummary use Year;Month;Contract Id;Region as Key
        //CategorySummary use Year;Month;Contract Id;category as Key
        //MonthlyDataSummaryMap use Year;Month;ContractId;subBrand as Key
        Map<String, ASI_CRM_Subbrand_Volume__c> brandSummaryMap = new Map<String, ASI_CRM_Subbrand_Volume__c>();
        Map<String, ASI_CRM_Subbrand_Volume__c> regionVolumeSummaryMap = new Map<String, ASI_CRM_Subbrand_Volume__c>();
        Map<String, ASI_CRM_Subbrand_Volume__c> categorySummaryMap = new Map<String, ASI_CRM_Subbrand_Volume__c>();
        Map<String, ASI_CRM_Subbrand_Volume__c> monthlyDataSummaryMap = new Map<String, ASI_CRM_Subbrand_Volume__c>();

        //CTDDataSummary use nthMonth;subBrand;ContractId as Key
        Map<String, ASI_CRM_Subbrand_Volume__c> CTDDataSummaryMap = new Map<String, ASI_CRM_Subbrand_Volume__c>();

        for (ASI_CRM_Subbrand_Volume__c existingSummary : existingSummaryList){
            String commonKey = existingSummary.ASI_CRM_Year__c+';'+existingSummary.ASI_CRM_Month__c+';'+existingSummary.ASI_CRM_CN_Contract__c+';';
            if (existingSummary.RecordType.DeveloperName == 'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume'){
                String brandKey = commonKey + existingSummary.ASI_CRM_CN_Brand_Agg__c;
                brandSummaryMap.put(brandKey, existingSummary);
            } else if (existingSummary.RecordType.DeveloperName == 'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume'){
                String regionKey = commonKey + existingSummary.ASI_CRM_CN_Region__c;
                regionVolumeSummaryMap.put(regionKey, existingSummary);
            } else if (existingSummary.RecordType.DeveloperName == 'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume'){
                String categoryKey = commonKey + existingSummary.ASI_CRM_CN_Product_Category_Agg__c;
                categorySummaryMap.put(categoryKey, existingSummary);
            } else if (existingSummary.RecordType.DeveloperName == 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data'){
                String monthlyDataKey = commonKey + existingSummary.ASI_CRM_Subbrand__c;
                //monthlyDataSummaryMap.put(commonKey + existingSummary.ASI_CRM_CN_Contract__c, existingSummary);
                monthlyDataSummaryMap.put(monthlyDataKey, existingSummary);
            } else if (existingSummary.RecordType.DeveloperName == 'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data'){
                Integer nthMonth = ASI_CRM_CN_HeavyContractUtilitiesClass.MonthDiff(contractMap.get(existingSummary.ASI_CRM_CN_Contract__c).ASI_CRM_CN_PO_Start_Date__c, Date.newInstance(Integer.valueOf(existingSummary.ASI_CRM_Year__c),Integer.valueOf(existingSummary.ASI_CRM_Month__c),1))+1;
                String CTDKey = nthMonth+';'+existingSummary.ASI_CRM_Subbrand__c+';'+existingSummary.ASI_CRM_CN_Contract__c;
                CTDDataSummaryMap.put(CTDKey, existingSummary);
            }
        }

        for (ASI_CRM_Subbrand_Volume__c datarow : dataList){
            System.debug('datarow.ASI_CRM_End_Date__c ' + datarow.ASI_CRM_End_Date__c);
            //Calculate Contract ID
            Id contractId;
            List<ContractInfo> contractValues = outletContractMap.get(datarow.ASI_CRM_Account__c);
            if(contractValues != null){
                for (ContractInfo contractValue : contractValues){
                    System.debug('contractValue.startDate ' + contractValue.startDate);
                    System.debug('datarow.contractValue.endDate ' + contractValue.endDate);

                    if (datarow.ASI_CRM_End_Date__c > contractValue.startDate && datarow.ASI_CRM_End_Date__c <= contractValue.endDate){
                        contractId = contractValue.contractId;
                    }
                }
            }
            System.debug('after that contractId: ' + contractId);
            String commonKey = datarow.ASI_CRM_Year__c+';'+datarow.ASI_CRM_Month__c+';'+contractId+';';

            //Put data into SummaryMap
            //If not exist, create new one

            //BrandSummary
            Id brandId = datarow.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c;
            ASI_CRM_Subbrand_Volume__c brandSummary = brandSummaryMap.get(commonKey + brandId);
            if (brandSummary == null){
                brandSummary = new ASI_CRM_Subbrand_Volume__c();
                brandSummary.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Brand_Monthly_Volume');
                brandSummary.ASI_CRM_CN_Contract__c = contractId;
                brandSummary.ASI_CRM_CN_Brand_Agg__c = brandId;

                createSummary(brandSummary, datarow);
            } else {
                addToSummary(brandSummary, datarow);
            }
            String brandKey = commonKey + brandSummary.ASI_CRM_CN_Brand_Agg__c;
            brandSummaryMap.put(brandKey, brandSummary);

            //RegionVolumeSummary (ASI_CRM_CN_Region__c)
            ASI_CRM_Subbrand_Volume__c regionVolumeSummary = regionVolumeSummaryMap.get(commonKey + datarow.ASI_CRM_CN_Region__c);
            if (regionVolumeSummary == null){
                regionVolumeSummary = new ASI_CRM_Subbrand_Volume__c();
                regionVolumeSummary.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Region_Monthly_Volume');
                regionVolumeSummary.ASI_CRM_CN_Contract__c = contractId;
                regionVolumeSummary.ASI_CRM_CN_Region__c = datarow.ASI_CRM_CN_Region__c;


                createSummary(regionVolumeSummary, datarow);
            } else {
                addToSummary(regionVolumeSummary, datarow);
            }
            String regionKey = commonKey + regionVolumeSummary.ASI_CRM_CN_Region__c;
            regionVolumeSummaryMap.put(regionKey, regionVolumeSummary);

            //CategorySummary (ASI_CRM_CN_Product_Category__c)
            ASI_CRM_Subbrand_Volume__c categorySummary = categorySummaryMap.get(commonKey + datarow.ASI_CRM_CN_Product_Category__c);
            if (categorySummary == null){
                categorySummary = new ASI_CRM_Subbrand_Volume__c();
                categorySummary.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Category_Monthly_Volume');
                categorySummary.ASI_CRM_CN_Contract__c = contractId;
                categorySummary.ASI_CRM_CN_Product_Category_Agg__c = datarow.ASI_CRM_CN_Product_Category__c;

                createSummary(categorySummary, datarow);
            } else {
                addToSummary(categorySummary, datarow);
            }
            String categoryKey = commonKey + categorySummary.ASI_CRM_CN_Product_Category_Agg__c;
            categorySummaryMap.put(categoryKey, categorySummary);

            //MonthlyDataSummaryMap (ASI_CRM_Subbrand__c)
            ASI_CRM_Subbrand_Volume__c monthlyDataSummary = monthlyDataSummaryMap.get(commonKey + datarow.ASI_CRM_Subbrand__c);
            if (monthlyDataSummary == null){
                monthlyDataSummary = new ASI_CRM_Subbrand_Volume__c();
                monthlyDataSummary.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_Monthly_Sub_Brand_Data');
                monthlyDataSummary.ASI_CRM_CN_Contract__c = contractId;
                monthlyDataSummary.ASI_CRM_Subbrand__c = datarow.ASI_CRM_Subbrand__c;

                createSummary(monthlyDataSummary, datarow);
            } else {
                addToSummary(monthlyDataSummary, datarow);
            }
            String monthlyDataKey = commonKey + monthlyDataSummary.ASI_CRM_Subbrand__c;
            monthlyDataSummaryMap.put(monthlyDataKey, monthlyDataSummary);

            if(contractId != null){
                //CTDDataSummary
                Date endDate = contractMap.get(contractId).ASI_CRM_CN_PO_End_Date__c > Date.today() ? Date.today():contractMap.get(contractId).ASI_CRM_CN_PO_End_Date__c;
                Integer nthMonth = ASI_CRM_DateUtilClass.monthDiff(contractMap.get(contractId).ASI_CRM_CN_PO_Start_Date__c, Date.newInstance(Integer.valueOf(datarow.ASI_CRM_Year__c),Integer.valueOf(datarow.ASI_CRM_Month__c),1));
                Integer endMonth = ASI_CRM_DateUtilClass.monthDiff(Date.newInstance(Integer.valueOf(datarow.ASI_CRM_Year__c),Integer.valueOf(datarow.ASI_CRM_Month__c),1), endDate);
                for (Integer i = nthMonth; i <= endMonth; i++){
                    String CTDKey = i +';'+datarow.ASI_CRM_Subbrand__c+';'+contractId;

                    ASI_CRM_Subbrand_Volume__c CTDDataSummary = CTDDataSummaryMap.get(CTDKey);
                    if (CTDDataSummary == null){
                        CTDDataSummary = new ASI_CRM_Subbrand_Volume__c();
                        CTDDataSummary.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Subbrand_Volume__c' + 'ASI_CRM_CN_WS_Outlet_CTD_Sub_Brand_Data');
                        CTDDataSummary.ASI_CRM_CN_Contract__c = contractId;
                        CTDDataSummary.ASI_CRM_Subbrand__c = datarow.ASI_CRM_Subbrand__c;
                        CTDDataSummary.ASI_CRM_CN_Original_Contract_Start_Date__c = contractMap.get(contractId).ASI_CRM_CN_PO_Start_Date__c;

                        createSummary(CTDDataSummary, datarow);

                        //Overwrite the Year and Month with earliest month in data
                        Date monthEndDate = contractMap.get(contractId).ASI_CRM_CN_PO_Start_Date__c.addMonths(i-1);
                        CTDDataSummary.ASI_CRM_Year__c = String.valueOf(monthEndDate.year());
                        CTDDataSummary.ASI_CRM_Month__c = String.valueOf(monthEndDate.month());
                        CTDDataSummary.ASI_CRM_End_Date__c = ASI_CRM_DateUtilClass.getEndOfMonth(monthEndDate);
                    } else {
                        addToSummary(CTDDataSummary, datarow);
                    }

                    CTDDataSummaryMap.put(CTDKey, CTDDataSummary);
                }
            }
        }

        system.debug('brandSummaryMap:' + brandSummaryMap);
        system.debug('regionVolumeSummaryMap:' + regionVolumeSummaryMap);
        system.debug('categorySummaryMap:' + categorySummaryMap);
        system.debug('monthlyDataSummaryMap:' + monthlyDataSummaryMap);
        system.debug('CTDDataSummaryMap:' + CTDDataSummaryMap);

        upsert brandSummaryMap.values();
        upsert regionVolumeSummaryMap.values();
        upsert categorySummaryMap.values();
        upsert monthlyDataSummaryMap.values();
        upsert CTDDataSummaryMap.values();
    }

    global void finish(Database.BatchableContext BC){

    }

    // Tools function
    private static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private ASI_CRM_Subbrand_Volume__c createSummary(ASI_CRM_Subbrand_Volume__c summary, ASI_CRM_Subbrand_Volume__c datarow){
        for (string fieldName : SUBBRAND_FIELD_TO_AGGREGATE_NON_SUMMABLE){
            summary.put(fieldName, datarow.get(fieldName));
        }
        for (string fieldName : SUBBRAND_FIELD_TO_AGGREGATE_SUM){
            summary.put(fieldName, datarow.get(fieldName));
        }
        return summary;
    }

    private ASI_CRM_Subbrand_Volume__c addToSummary(ASI_CRM_Subbrand_Volume__c summary, ASI_CRM_Subbrand_Volume__c datarow){
        for (string fieldName : SUBBRAND_FIELD_TO_AGGREGATE_SUM){
            Object summaryValue = summary.get(fieldName) != null ? summary.get(fieldName) : 0;
            Object dataRowValue = datarow.get(fieldName) != null ? datarow.get(fieldName) : 0;
            summary.put(fieldName, summaryValue == null? Double.valueOf(dataRowValue) : Double.valueOf(summaryValue) + Double.valueOf(dataRowValue));
        }
        return summary;
    }

    public static String dateToString(Date dt){
        return DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd');
    }

}