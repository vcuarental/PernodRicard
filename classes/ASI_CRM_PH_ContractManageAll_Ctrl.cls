/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_ContractManageAll_Ctrl
 * Description: controller for ASI_CRM_PH_ContractManageAll_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-08-24       Kaiden/Mikesh (LAPUTA)  Created/Updated
 ****************************************************************************************************************************/
public class ASI_CRM_PH_ContractManageAll_Ctrl {
    
    //Inner class for storing the exception
    private class ExceptionWrapper {
        private Integer lineNumber {
            get;
            set;
        }
        private String errorMessage {
            get;
            set;
        }
        private List < String > fieldAPINameList {
            get;
            set;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage) {
            this.lineNumber = lineNumber;
            this.errorMessage = errorMessage;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage, List < String > fieldAPINameList) {
            this(lineNumber, errorMessage);
            this.fieldAPINameList = fieldAPINameList;
        }
    }
    
    //Object Record Type Developer Name
    private final static String SKU_DUTY_FREE_RECORD_TYPE      = 'ASI_CRM_PH_DF_SKU';
    private final static String SKU_DUTY_PAID_RECORD_TYPE      = 'ASI_CRM_PH_DP_SKU';
    private final static String SKU_OUTLETSELLINGPRICE_RECORD_TYPE      = 'ASI_CRM_PH_Outlet_Selling_Price';
    private final static String CONTRACT_TARGET_PH_RECORD_TYPE = 'ASI_CRM_PH_Contract_Target';
    private final static String CONTRACT_FUND_SCHEME_RECORD_TYPE = 'ASI_CRM_PH_Contract_Fund';
    private final static String PURCHASE_INCENTIVE_SCHEME_RECORD_TYPE = 'ASI_CRM_PH_Purchase_Incentive';
    
    
    //Page Parameters Key
    private final static String IS_QUICK_SAVE = 'isQuickSave';
    private final static String UPDATE_CONTRACT_TARGET_LIST_JSON = 'updateContractTargetListJson';
    private final static String DELETE_CONTRACT_TARGET_LIST_JSON = 'deleteContractTargetListJson';
    private final static String UPDATE_SUPPORT_MAP_JSON = 'updateSupportMapJson';
    private final static String UPDATE_CONTRACT_FUND_SCHEME_LIST_JSON = 'updateContractFundSchemeListJson';
    private final static String DELETE_CONTRACT_FUND_SCHEME_LIST_JSON = 'deleteContractFundSchemeListJson';
    private final static String UPDATE_PURCHASE_INCENTIVE_SCHEME_LIST_JSON = 'updatePurchaseIncentiveSchemeListJson';
    private final static String DELETE_PURCHASE_INCENTIVE_SCHEME_LIST_JSON = 'deletePurchaseIncentiveSchemeListJson';
    private final static String UPDATE_CONTRACT_TARGET_MONTHLY_LIST_JSON = 'updateContractTargetMonthlyListJson';
    
    //Public Data Storage Parameters
    public ASI_TH_CRM_Contract__c contract {get; set;}
    
    //Private Data Storage Parameters
    private List < ASI_CRM_ContractTarget__c > contractTargetList;
    private List < ASI_CRM_Payment_Schedule__c > contractFundSchemeList;
    private List < ASI_CRM_Payment_Schedule__c > purchaseIncentiveSchemeList;
    private List < ASI_CRM_SG_AdhocOther__c > contractTargetMonthlyList;
    
    private ASI_TH_CRM_Actual_Offtake__c actualOfftake {get; set;}
    //Page variables
    public Boolean isReadOnly {get; set;}
    public Boolean hasError {get; set;}
    public List < ExceptionWrapper > exceptionList {get; set;}

    //Private Data Storage Parameters
    private Map<String, ASI_MFM_SKU_Code__c> SKUMap;
    
    //Auto Complete Value Map => JSON String for VF Page
    public String SKUListJson {get {return toJsonString(SKUMap.keySet());}}
    
    public String SKUMapJson {get {return toJsonString(SKUMap);}}
    
    //Field Map
    private final static Map < String, Schema.SObjectField > CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
    private final static Map < String, Schema.SObjectField > CONTRACT_TARGET_FIELD_MAP = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
    private final static Map < String, Schema.SObjectField > PAYMENT_SCHEDULE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();
    private final static Map < String, Schema.SObjectField > CONTRACT_TARGET_ADHOC_FIELD_MAP = Schema.SObjectType.ASI_CRM_SG_AdhocOther__c.fields.getMap();
    
    //JSON String for VF Page
    public String contractJson {
        get {
            return toJsonString(contract);
        }
    }
    public String contractTargetListJson {
        get {
            return toJsonString(contractTargetList);
        }
    }
    public String contractTargetMonthlyListJson {
        get {
            return toJsonString(contractTargetMonthlyList);
        }
    }
    public String contractFundSchemeListJson {
        get {
            return toJsonString(contractFundSchemeList);
        }
    }
    public String purchaseIncentiveSchemeListJson {
        get {
            return toJsonString(purchaseIncentiveSchemeList);
        }
    }
    public String exceptionListJson {
        get {
            return toJsonString(exceptionList);
        }
    }
    public String actualOfftakeJson {
        get {
            return toJsonString(actualOfftake);
        }
    }
    
    // Record Type Ids
    public String contractTargetRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target');
        }
    }
    
    public String contractTargetMonthlyRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_SG_AdhocOther__cASI_CRM_PH_AdhocOther');
        }
    }
    
    public String contractFundSchemeRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Contract_Fund');
        }
    }
    
    public String purchaseIncentiveSchemeRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Purchase_Incentive');
        }
    }
    
    private final static String RTID_OUTLETSELLINGPRICE = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price');
    private final static String RTID_LISTPRICE = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price');
    private final static String RTID_DUTY = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax');
    private final static String RTID_HANDLING = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost');
    private final static String RTID_COGS = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS');
    private final static String RTID_STANDARD = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost');
    
    public String contractId {
        get;
        set;
    }
    
    public String contractFundType{
        get;
        set;
    }
    
    public String customerType{
        get;
        set;
    }
    
    public ASI_CRM_PH_ContractManageAll_Ctrl(ApexPages.StandardController standardController) {
        contractId = String.valueOf(standardController.getRecord().get('Id'));
        Map < String, String > pageParameters = ApexPages.currentPage().getParameters();
        isReadOnly = Boolean.valueOf(pageParameters.containsKey('isReadOnly') ? pageParameters.get('isReadOnly') : 'true');
        
        init(contractId);
    }
    
    public void init(String contractId) {
        contract = retrieveContract(contractId);
        SKUMap = new Map<String, ASI_MFM_SKU_Code__c>();
        
        ASI_CRM_AccountsAdditionalField__c customerRecord = retrieveCustomerRecord(contract.ASI_CRM_CN_Outlet_WS__c);
        //Boolean isDutyFree = retrieveIsDutyFree(contract.ASI_CRM_CN_Outlet_WS__c);
        Boolean isDutyFree = customerRecord.ASI_CRM_Duty_Free__c;
        String recordType = isDutyFree? SKU_DUTY_FREE_RECORD_TYPE : SKU_DUTY_PAID_RECORD_TYPE;
        
        customerType = customerRecord.ASI_CRM_Customer_Type__c;
        
        for(ASI_MFM_SKU_Code__c sku : retrieveSKUList(recordType)) {
            SKUMap.put(sku.Name, sku);
        }
        
        contractTargetList = retrieveContractTargetList(contractId);
        contractTargetMonthlyList = retrieveContractTargetMonthlyList(contractId);
        contractFundSchemeList = retrievePaymentScheduleList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACT_FUND_SCHEME_RECORD_TYPE + '\' ');
        purchaseIncentiveSchemeList = retrievePaymentScheduleList(contractId, 'AND RecordType.DeveloperName = \'' + PURCHASE_INCENTIVE_SCHEME_RECORD_TYPE + '\' ');
        if(!contractFundSchemeList.isEmpty()){
            contractFundType = contractFundSchemeList[0].ASI_CRM_Type__c;
        }
        
        actualOfftake = retrieveActualOfftake(contract);
    }
    
    /***************
    Data Retrievement Functions
    ***************/
    
 
    
    private ASI_CRM_AccountsAdditionalField__c retrieveCustomerRecord(String customerId){
        return [SELECT ASI_CRM_Duty_Free__c, ASI_CRM_Customer_Type__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id =: customerId];
    }
    
    // Retrieve List of SKUs for autocomplete purpose
    private List<ASI_MFM_SKU_Code__c> retrieveSKUList(String recordType) {
        Date contractStartDate = contract.ASI_TH_CRM_Start_Date__c;
        String customerId = contract.ASI_CRM_CN_Outlet_WS__c;
        
        String query = 'SELECT Id '
                     + 'FROM ASI_MFM_SKU_Code__c '
                     + 'WHERE RecordType.DeveloperName = :recordType '
                     // outlet selling price exist
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null '
                     + 'AND recordtypeId = :RTID_OUTLETSELLINGPRICE '
                     + 'AND ASI_CRM_Customer__c = :customerId '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)'
                     // list price
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null '
                     + 'AND recordtypeId = :RTID_LISTPRICE '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)';        
        List<ASI_MFM_SKU_Code__c> list_sku = (List<ASI_MFM_SKU_Code__c>) Database.query(query);
        
        query = 'SELECT Id '
                     + 'FROM ASI_MFM_SKU_Code__c '
                     + 'WHERE RecordType.DeveloperName = :recordType '
                     + 'AND Id IN :list_sku '
                     // Duty
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_DUTY '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)'
                     // Handling
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_HANDLING '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)';
        list_sku = (List<ASI_MFM_SKU_Code__c>) Database.query(query);
        
        query = 'SELECT Id, Name, ASI_MFM_Sub_brand__r.Name, ASI_MFM_SKU_Code__c '
                     + 'FROM ASI_MFM_SKU_Code__c '
                     + 'WHERE RecordType.DeveloperName = :recordType '
                     + 'AND Id IN :list_sku '
                     // COGS
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_COGS '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)'
                     // Standard
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_STANDARD '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)';
        list_sku = (List<ASI_MFM_SKU_Code__c>) Database.query(query);
        // *Howard Fei*
        String queryWithoutCus = 'SELECT Id '
            + 'FROM ASI_MFM_SKU_Code__c '
            + 'WHERE RecordType.DeveloperName = :recordType '
            //+ 'AND Id not IN :listsku_withcustomer'
            // outlet selling price exist
            + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null '
            + 'AND recordtypeId = :RTID_OUTLETSELLINGPRICE '
            + 'AND ASI_CRM_Customer__c = NULL '
            + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)'
            // list price
            + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null '
            + 'AND recordtypeId = :RTID_LISTPRICE '
            + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)';        
        List<ASI_MFM_SKU_Code__c> list_skuWithoutCus = (List<ASI_MFM_SKU_Code__c>) Database.query(queryWithoutCus);
        queryWithoutCus = 'SELECT Id '
                     + 'FROM ASI_MFM_SKU_Code__c '
                     + 'WHERE RecordType.DeveloperName = :recordType '
                     + 'AND Id IN :list_skuWithoutCus '
                     // Duty
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_DUTY '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)'
                     // Handling
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_HANDLING '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)';
        list_skuWithoutCus = (List<ASI_MFM_SKU_Code__c>) Database.query(queryWithoutCus);
        
        queryWithoutCus = 'SELECT Id, Name, ASI_MFM_Sub_brand__r.Name, ASI_MFM_SKU_Code__c '
                     + 'FROM ASI_MFM_SKU_Code__c '
                     + 'WHERE RecordType.DeveloperName = :recordType '
                     + 'AND Id IN :list_skuWithoutCus '
                     // COGS
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_COGS '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)'
                     // Standard
                     + 'AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Cost__c != null '
                     + 'AND recordtypeId = :RTID_STANDARD '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate)';
        list_skuWithoutCus = (List<ASI_MFM_SKU_Code__c>) Database.query(queryWithoutCus);
        
        List<ASI_MFM_SKU_Code__c> list_skuCombine = new List<ASI_MFM_SKU_Code__c>();
        set<String> SKUId = new set<String>();
        for(ASI_MFM_SKU_Code__c sku:list_sku){
            if(!SKUId.contains(sku.Id)){
                SKUId.add(sku.Id);
                list_skuCombine.add(sku);
            }
        }
        for(ASI_MFM_SKU_Code__c sku:list_skuWithoutCus){
            if(!SKUId.contains(sku.Id)){
                SKUId.add(sku.Id);
                list_skuCombine.add(sku);
            }
        }

        return list_skuCombine;
    }
    
    private Map<String, ASI_CRM_MY_SKUPriceCost__c> retrieveSKUPriceCost(List<String> SKUIdList) {
        Date contractStartDate = contract.ASI_TH_CRM_Start_Date__c;
        String contractCustomerId = contract.ASI_CRM_CN_Outlet_WS__c;
        
        String SKUIdQuery = String.join(SKUIdList, '\', \'');
        String query = 'SELECT ASI_CRM_SKU__c, ASI_CRM_Price__c, ASI_CRM_EffectiveDate__c '
                     + 'FROM ASI_CRM_MY_SKUPriceCost__c '
                     + 'WHERE ASI_CRM_SKU__c IN (\'' + SKUIdQuery + '\') '
                     + 'AND recordtype.developername = :SKU_OUTLETSELLINGPRICE_RECORD_TYPE '
                     + 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate '
                     //+ 'AND ASI_CRM_Customer__c = :contractCustomerId '
                     + 'ORDER BY ASI_CRM_EffectiveDate__c ';
        system.debug(query);
        List < ASI_CRM_MY_SKUPriceCost__c > priceCostList = (List < ASI_CRM_MY_SKUPriceCost__c >) Database.query(query);
        if (priceCostList.size() == 0) {
            // No prices found
            system.debug('Price Cost not found');
            return null;
        }
        
        /* commented by Calvin (Laputa)
        if (priceCostList.size() != SKUIdList.size()) {
            // Some prices cannot be obtained
            system.debug('Some prices cannot be obtained');
            return null;
        }*/
        
        // Contruct a map of SKU-PriceCost
        Map<String, ASI_CRM_MY_SKUPriceCost__c> SKUPriceCostMap = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
        for (ASI_CRM_MY_SKUPriceCost__c priceCost: priceCostList){
            
            if (SKUPriceCostMap.containsKey(priceCost.ASI_CRM_SKU__c)) {
                // Map already contains key, update key-value if the price cost is of newer date
                if (priceCost.ASI_CRM_EffectiveDate__c > SKUPriceCostMap.get(priceCost.ASI_CRM_SKU__c).ASI_CRM_EffectiveDate__c) {
                    SKUPriceCostMap.put(priceCost.ASI_CRM_SKU__c, priceCost);
                }
            } else {
                // It's a new key
                SKUPriceCostMap.put(priceCost.ASI_CRM_SKU__c, priceCost);
            }
        }
        
        return SKUPriceCostMap;
    }
    
    private ASI_TH_CRM_Contract__c retrieveContract(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) +
            ', RecordType.DeveloperName, ASI_CRM_Original_Version__r.Name, ASI_CRM_Original_Version__r.ASI_CRM_ROI__c ' +
            'FROM ASI_TH_CRM_Contract__c ' +
            'WHERE Id = :contractId ';

        List < ASI_TH_CRM_Contract__c > contractList = (List < ASI_TH_CRM_Contract__c > ) Database.query(query);
        return contractList.size() > 0 ? contractList.get(0) : null;
    }
    
    private List < ASI_CRM_ContractTarget__c > retrieveContractTargetList(Id contractId) {
        String query = 'SELECT ' + 
            'ASI_CRM_SKU__c, ' +
            'ASI_CRM_SKUCode__c, ' +
            'ASI_CRM_Target_Total_Bottle__c, ' +
            'ASI_CRM_Bottle_Rebate__c, ' +
            'ASI_CRM_Staff_Incentive__c, ' +
            'ASI_CRM_Total_Staff_Incentive__c, ' +
            //'ASI_CRM_SKU_Allocation_Percent__c, ' +
            'ASI_CRM_Contract__c, ' +
            'ASI_CRM_Approved__c, ' +
            'ASI_CRM_FOC__c, ' +
            'ASI_CRM_Till_Date_Sales_Bottle__c, ' +
            'RecordType.DeveloperName, ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SKU__r.ASI_CRM_Preset__c, ASI_CRM_SKU__r.ASI_CRM_Allow_Back_Rebates__c ' +
            'FROM ASI_CRM_ContractTarget__c ' +
            'WHERE ASI_CRM_Contract__c = :contractId ' +
            'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_PH_RECORD_TYPE + '\' ' +
            'ORDER BY ASI_CRM_Approved__c desc, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name ';
            
            List < ASI_CRM_ContractTarget__c > list_ct = Database.query(query);
            
        return list_ct;
    }
    
    private List < ASI_CRM_SG_AdhocOther__c > retrieveContractTargetMonthlyList(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_TARGET_ADHOC_FIELD_MAP) +
            ', RecordType.DeveloperName ' +
            'FROM ASI_CRM_SG_AdhocOther__c ' +
            'WHERE ASI_CRM_SG_Contract_Target__r.ASI_CRM_Contract__c = :contractId ' +
            'AND RecordTypeId = \'' + contractTargetMonthlyRecordTypeId +  '\' ' +
            'order by ASI_CRM_SG_Contract_Target__c, ASI_CRM_Month__c';

        List < ASI_CRM_SG_AdhocOther__c > contractList = (List < ASI_CRM_SG_AdhocOther__c > ) Database.query(query);
        return contractList;
    }
    
    private List < ASI_CRM_Payment_Schedule__c > retrievePaymentScheduleList(Id contractId, String whereClause) {
        String query = 'SELECT ' + 
            'ASI_CRM_Target_Achievement_Amount__c, ' +
            'ASI_CRM_Target_Start_Date__c, ' +
            'ASI_CRM_Target_End_Date__c, ' +
            'ASI_CRM_Sponsorship__c, ' +
            'ASI_CRM_Contract__c, ' +
            'ASI_CRM_Target_Purchase_Amount_From__c, ' +
            'ASI_CRM_Target_Purchase_Amount_To__c, ' +
            'ASI_CRM_Incentive_to_issue__c, ' +
            'ASI_CRM_Sys_Parent_Record__c, ' +
            'ASI_CRM_Achieved__c, ' +
            'ASI_CRM_Issuable__c, ' +
            'ASI_CRM_Type__c, ' +
            'ASI_CRM_Schedule_Date__c, ' +
            'ASI_CRM_Target_Bottle__c, ' +
            'ASI_CRM_Payout_Amount__c, ' +
            'RecordType.DeveloperName ' +
            'FROM ASI_CRM_Payment_Schedule__c ' +
            'WHERE ASI_CRM_Contract__c = :contractId ';
        if (String.isNotBlank(whereClause)) query += whereClause;
        
        //query += 'ORDER BY ASI_CRM_Schedule_Date__c asc NULLS FIRST, ASI_CRM_Percent_Achieved__c asc';
        
        return (List < ASI_CRM_Payment_Schedule__c > ) Database.query(query);
    }
    
    private static ASI_TH_CRM_Actual_Offtake__c retrieveActualOfftake(ASI_TH_CRM_Contract__c contract) {
        final List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakes = [
                SELECT Id, ASI_TH_CRM_Quantity__c, ASI_CRM_SKU__c
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_SG_Customer__c = :contract.ASI_CRM_CN_Outlet_WS__c
                AND ASI_CRM_SKU__c in (
                    select ASI_CRM_SKU__c from ASI_CRM_ContractTarget__c
                    where ASI_CRM_Contract__c = :contract.Id
                )
                AND ASI_TH_CRM_Offtake_G_L_Date__c >= :contract.ASI_TH_CRM_Start_Date__c
                AND ASI_TH_CRM_Offtake_G_L_Date__c <= :contract.ASI_TH_CRM_End_Date__c
        ];

        if (actualOfftakes.isEmpty()) {
            return new ASI_TH_CRM_Actual_Offtake__c();
        }

        return actualOfftakes.get(0);
    }
    
    /***************
    Page Functions
    ***************/
    public PageReference saveRecord() {
        //Init current page error 
        hasError = false;
        exceptionList = new List < ExceptionWrapper > ();
        
        //Collect Json String from VisualForce Page
        Map < String, String > params = ApexPages.currentPage().getParameters();
        Boolean isQuickSave = String.isBlank(params.get('IS_QUICK_SAVE')) ? false : Boolean.valueOf(params.get('IS_QUICK_SAVE'));
        String upsertContractTargetListJson = params.get(UPDATE_CONTRACT_TARGET_LIST_JSON);
        String removeContractTargetListJson = params.get(DELETE_CONTRACT_TARGET_LIST_JSON);
        String upsertSupportMapJson = params.get(UPDATE_SUPPORT_MAP_JSON);
        String upsertContractFundSchemeListJson = params.get(UPDATE_CONTRACT_FUND_SCHEME_LIST_JSON);
        String removeContractFundSchemeListJson = params.get(DELETE_CONTRACT_FUND_SCHEME_LIST_JSON);
        String upsertPurchaseIncentiveSchemeListJson = params.get(UPDATE_PURCHASE_INCENTIVE_SCHEME_LIST_JSON);
        String removePurchaseIncentiveSchemeListJson = params.get(DELETE_PURCHASE_INCENTIVE_SCHEME_LIST_JSON);
        String upsertContractTargetMonthlyListJson = params.get(UPDATE_CONTRACT_TARGET_MONTHLY_LIST_JSON);

        List < ASI_CRM_ContractTarget__c > upsertContractTargetList;
        List < String > removeContractTargetIdList;

        List < ASI_CRM_Payment_Schedule__c > upsertContractFundSchemeList;
        List < String > removeContractFundSchemeIdList;

        List < ASI_CRM_Payment_Schedule__c > upsertPurchaseIncentiveSchemeList;
        List < String > removePurchaseIncentiveSchemeIdList;
        
        //Map < String, Decimal > upsertSupportMap;
        ASI_TH_CRM_Contract__c upsertSuport;
        
        List< ASI_CRM_SG_AdhocOther__c > upsertContractTargetMonthlyList;
        
        //Convert Json String -> List<SObject>, and Json String -> Map for upsertSupportMapJson
        try {
            upsertContractTargetList = (List < ASI_CRM_ContractTarget__c > ) fromJsonString(upsertContractTargetListJson, List < ASI_CRM_ContractTarget__c > .class);
            removeContractTargetIdList = (List < String > ) fromJsonString(removeContractTargetListJson, List < String > .class);

            upsertContractFundSchemeList = (List < ASI_CRM_Payment_Schedule__c > ) fromJsonString(upsertContractFundSchemeListJson, List < ASI_CRM_Payment_Schedule__c > .class);
            removeContractFundSchemeIdList = (List < String > ) fromJsonString(removeContractFundSchemeListJson, List < String > .class);

            upsertPurchaseIncentiveSchemeList = (List < ASI_CRM_Payment_Schedule__c > ) fromJsonString(upsertPurchaseIncentiveSchemeListJson, List < ASI_CRM_Payment_Schedule__c > .class);
            removePurchaseIncentiveSchemeIdList = (List < String > ) fromJsonString(removePurchaseIncentiveSchemeListJson, List < String > .class);
            
            //upsertSupportMap = (Map < String, Decimal >) fromJsonString(upsertSupportMapJson, Map < String, Decimal > .class);
            upsertSuport = (ASI_TH_CRM_Contract__c) fromJsonString(upsertSupportMapJson, ASI_TH_CRM_Contract__c .class);
            
            upsertContractTargetMonthlyList = (List < ASI_CRM_SG_AdhocOther__c > ) fromJsonString(upsertContractTargetMonthlyListJson, List < ASI_CRM_SG_AdhocOther__c > .class);
        } catch (Exception e) {
            hasError = true;
            ExceptionWrapper exceptionWrapper = new ExceptionWrapper(0, 'Convert Json String Error, Please contact support.' + e.getMessage());
            exceptionList.add(exceptionWrapper);
            return null;
        }
        
        //Upsert data / Delete data
        System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            List < sObject > removeContractTargetList = convertIdToSObject(removeContractTargetIdList, 'ASI_CRM_ContractTarget__c');
            List < sObject > removeContractFundSchemeList = convertIdToSObject(removeContractFundSchemeIdList, 'ASI_CRM_Payment_Schedule__c');
            List < sObject > removePurchaseIncentiveSchemeList = convertIdToSObject(removePurchaseIncentiveSchemeIdList, 'ASI_CRM_Payment_Schedule__c');
            
            if (removeContractTargetList != null) Database.delete(removeContractTargetList);
            if (removeContractFundSchemeList != null) Database.delete(removeContractFundSchemeList);
            if (removePurchaseIncentiveSchemeList != null) Database.delete(removePurchaseIncentiveSchemeList);
            
            /*
            contract.ASI_CRM_Contract_Fund_Amount__c = (Decimal) upsertSupportMap.get('ASI_CRM_Contract_Fund_Amount__c');
            contract.ASI_CRM_Activation_Fund_Amount__c = (Decimal) upsertSupportMap.get('ASI_CRM_Activation_Fund_Amount__c');
            contract.ASI_CRM_Merchandise_Amount__c = (Decimal) upsertSupportMap.get('ASI_CRM_Merchandise_Amount__c');
            contract.ASI_CRM_Purchase_Incentive_Amount__c = (Decimal) upsertSupportMap.get('ASI_CRM_Purchase_Incentive_Amount__c');
            contract.ASI_CRM_Activation_Fund_A_P_Segment__c = String.valueOf(upsertSupportMap.get('ASI_CRM_Activation_Fund_A_P_Segment__c'));
            contract.ASI_CRM_Contract_Fund_A_P_Segment__c = String.valueOf(upsertSupportMap.get('ASI_CRM_Contract_Fund_A_P_Segment__c'));
            contract.ASI_CRM_Bottle_Rebate_A_P_Segment__c = String.valueOf(upsertSupportMap.get('ASI_CRM_Bottle_Rebate_A_P_Segment__c'));
            contract.ASI_CRM_Merchandise_A_P_Segment__c = String.valueOf(upsertSupportMap.get('ASI_CRM_Merchandise_A_P_Segment__c'));
            contract.ASI_CRM_Purchase_Incentive_A_P_Segment__c = String.valueOf(upsertSupportMap.get('ASI_CRM_Purchase_Incentive_A_P_Segment__c'));
            contract.ASI_CRM_Staff_Incentive_A_P_Segment__c = String.valueOf(upsertSupportMap.get('ASI_CRM_Staff_Incentive_A_P_Segment__c'));
            */
            contract.ASI_CRM_Contract_Fund_Amount__c = upsertSuport.ASI_CRM_Contract_Fund_Amount__c;
            contract.ASI_CRM_Activation_Fund_Amount__c = upsertSuport.ASI_CRM_Activation_Fund_Amount__c;
            contract.ASI_CRM_Merchandise_Amount__c = upsertSuport.ASI_CRM_Merchandise_Amount__c;
            contract.ASI_CRM_Purchase_Incentive_Amount__c = upsertSuport.ASI_CRM_Purchase_Incentive_Amount__c;
            contract.ASI_CRM_Activation_Fund_A_P_Segment__c = upsertSuport.ASI_CRM_Activation_Fund_A_P_Segment__c;
            contract.ASI_CRM_Contract_Fund_A_P_Segment__c = upsertSuport.ASI_CRM_Contract_Fund_A_P_Segment__c;
            contract.ASI_CRM_Bottle_Rebate_A_P_Segment__c = upsertSuport.ASI_CRM_Bottle_Rebate_A_P_Segment__c;
            contract.ASI_CRM_Merchandise_A_P_Segment__c = upsertSuport.ASI_CRM_Merchandise_A_P_Segment__c;
            contract.ASI_CRM_Purchase_Incentive_A_P_Segment__c = upsertSuport.ASI_CRM_Purchase_Incentive_A_P_Segment__c;
            contract.ASI_CRM_Staff_Incentive_A_P_Segment__c = upsertSuport.ASI_CRM_Staff_Incentive_A_P_Segment__c;
            contract.ASI_CRM_Marketing_Support_Fund_Amount__c = upsertSuport.ASI_CRM_Marketing_Support_Fund_Amount__c;
            contract.ASI_CRM_Marketing_Support_Fund_APSegment__c = upsertSuport.ASI_CRM_Marketing_Support_Fund_APSegment__c;
            contract.ASI_CRM_CN_Approval_Status__c = 'Draft';
            contract.ASI_CRM_Revising__c = true;
            
            update contract;
            
            if (upsertContractTargetList != null && upsertContractTargetList.size() > 0) {
                
                for (ASI_CRM_ContractTarget__c contractTarget: upsertContractTargetList) {
                    contractTarget.RecordTypeId = contractTargetRecordTypeId;
                    
                    if (contractTarget.ASI_CRM_Contract__c == null) {
                        contractTarget.ASI_CRM_Contract__c = contract.Id;
                    }
                    
                    contractTarget.ASI_CRM_SKU__r = null; 
                    
                    // Convert SKU Name to ID
                    String skuName = contractTarget.ASI_CRM_SKU__c; 
                    ASI_MFM_SKU_Code__c skuCode = SKUMap.get(skuName);
                    if(skuCode!=null) contractTarget.ASI_CRM_SKU__c = skuCode.Id;
                }
                
                //Get converted amount for each SKU, and Save the converted amount to ASI_CRM_Target_Total_Sales__c
                // uncommented by serena 10/5
                try {
                    List<String> SKUIdList = new List<String>();
                    for (ASI_CRM_ContractTarget__c contractTarget: upsertContractTargetList) {
                        // Get list of SKU Ids for 
                        SKUIdList.add(contractTarget.ASI_CRM_SKU__c);
                    }
                    system.debug('Before RetrieveSKUPriceCost');
                    Map < String, ASI_CRM_MY_SKUPriceCost__c > SKUPriceCostMap = retrieveSKUPriceCost(SKUIdList);
                    system.debug('SKUPriceCostMap: ' + SKUPriceCostMap);
                    system.debug('After RetrieveSKUPriceCost');
                    for (ASI_CRM_ContractTarget__c contractTarget: upsertContractTargetList) {
                        ASI_CRM_MY_SKUPriceCost__c priceCost = SKUPriceCostMap.get(contractTarget.ASI_CRM_SKU__c);
                        system.debug('PriceCost: ' + priceCost);
                        system.debug('Contract Target Total Bottle: ' + contractTarget.ASI_CRM_Target_Total_Bottle__c);
                        system.debug('Price Cost: ' + priceCost.ASI_CRM_Price__c);
                        contractTarget.ASI_CRM_Target_Total_Sales__c = (contractTarget.ASI_CRM_Target_Total_Bottle__c) * (priceCost.ASI_CRM_Price__c);
                    }
                    
                } catch (Exception e) {
                    System.debug(e);
                    System.debug(e.getStackTraceString());
                    hasError = true;
                    ExceptionWrapper exceptionWrapper = new ExceptionWrapper(0, 'Cannot get converted amount for SKU, Please contact support.' + e.getMessage());
                    exceptionList.add(exceptionWrapper);
                    return null;
                }
                
                Database.upsert(upsertContractTargetList);
            }
            
            map<string, string> map_skuCode_ctId = new map<string, string>();
            final Map<Id, Id> skuIdContractIdMap = new Map<Id, Id>();
            for(ASI_CRM_ContractTarget__c ct : upsertContractTargetList){
                map_skuCode_ctId.put(ct.ASI_CRM_SKUCode__c, ct.Id);
                skuIdContractIdMap.put(ct.ASI_CRM_SKU__c, ct.Id);
            }
            
            if (upsertContractFundSchemeList != null && upsertContractFundSchemeList.size() > 0) {
                for (ASI_CRM_Payment_Schedule__c contractFundScheme: upsertContractFundSchemeList) {
                    contractFundScheme.RecordTypeId = contractFundSchemeRecordTypeId;
                    
                    if (contractFundScheme.ASI_CRM_Contract__c == null) {
                        contractFundScheme.ASI_CRM_Contract__c = contract.Id;
                    }
                }
                Database.upsert(upsertContractFundSchemeList);
            }

            if (upsertPurchaseIncentiveSchemeList != null && upsertPurchaseIncentiveSchemeList.size() > 0) {
                for (ASI_CRM_Payment_Schedule__c purchaseIncentiveScheme: upsertPurchaseIncentiveSchemeList) {
                    purchaseIncentiveScheme.RecordTypeId = purchaseIncentiveSchemeRecordTypeId;
                    
                    if (purchaseIncentiveScheme.ASI_CRM_Contract__c == null) {
                        purchaseIncentiveScheme.ASI_CRM_Contract__c = contract.Id;
                    }
                }
                Database.upsert(upsertPurchaseIncentiveSchemeList);
            }
            
            if (upsertContractTargetMonthlyList != null && upsertContractTargetMonthlyList.size() > 0) {
                for (ASI_CRM_SG_AdhocOther__c ctm: upsertContractTargetMonthlyList) {
                    ctm.RecordTypeId = contractTargetMonthlyRecordTypeId;

                    if (ctm.Id == null) {
                        ctm.ASI_CRM_SG_Contract_Target__c = skuIdContractIdMap.get(ctm.ASI_CRM_SG_SKU__c);
                    }
                }
                Database.upsert(upsertContractTargetMonthlyList);
            }
            
        } catch (Exception e) {
            System.debug(e);
            System.debug(e.getStackTraceString());
            hasError = true;
            Database.rollback(databaseSavepoint);
            
            if (e.getTypeName() == 'System.DmlException') {
                DmlException dmlException = (DmlException) e;
                for (Integer i = 0; i < dmlException.getNumDml(); i++) {
                    ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
                    exceptionList.add(exceptionWrapper);
                }
            } else {
                ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
                exceptionList.add(exceptionWrapper);
            }

            return null;
        }
        
        //Refresh page / Back to contract page
        PageReference pageRef;
        if (isQuickSave) {
            init(contract.Id);
        } else {
            pageRef = new PageReference('/' + contract.Id);
            pageRef.setRedirect(true);
        }

        return pageRef;
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + contract.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /***************
    Utility Functions
    ***************/
    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }
    
    private Object fromJsonString(String jsonString, System.Type apexType) {
        if (String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
    
    private String genQueryField(Map < String, Schema.SObjectField > fieldMap) {
        String queryField = '';
        for (String fields: fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private List < sObject > convertIdToSObject(List < String > sObjIdList, String sObjType) {
        if (sObjIdList == null || sObjIdList.size() == 0) return null;

        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sObjType);

        List < sObject > removeDataList = new List < sObject > ();
        for (String sObjId: sObjIdList) {
            removeDataList.add(convertIdToSObject(sObjId, convertType));
        }
        return removeDataList;
    }

    private sObject convertIdToSObject(String sObjId, Schema.SObjectType convertType) {
        sObject sObj = convertType.newSObject();
        sObj.put('Id', sObjId);
        return sObj;
    }
}