/*
*  s - plural
*  CAI, CAIs - Contract Activity Item, Contract Activity Items
*  CPI, CPIs - Contract Product Item, Contract Product Items
*  MT, MTs - Mechanic Type, Mechanic Types
*  B, Bs - Brand, Brands
*  BQ, BQs - Brand Quality, Brand Qualities
*  BQS, BQSs - Brand Quality Size, Brand Quality Sizes
*  SKU, SKUs - SKU, SKUs
*  WS - WineSpirit
*
* */

public without sharing class EUR_CRM_FI_ContractBuilderController extends EUR_CRM_PageControllerBase {

    private ApexPages.StandardController standardController {get;set;}
    private transient List<String> contractFields = new List<String>{
        'EUR_CRM_Include_VAT__c'
        , 'EUR_CRM_Contact__c'
        , 'EUR_CRM_Account__c'
        , 'EUR_CRM_Account__r.ownerid'
        , 'EUR_CRM_Account__r.owner'
        , 'EUR_CRM_Is_this_contract_material__c'
        , 'EUR_CRM_Is_this_contract_profitable__c'
        , 'RecordType.DeveloperName'
        , 'EUR_CRM_Country_Code__c'
    };
    public final String POURING_REFUND_SPIRITS = 'Pouring Refund Spirits';
    public final String POURING_REFUND_WINES = 'Pouring Refund Wines';
    public final String SELECTION_BRANDS_SPIRITS = 'Selection Brands Spirits';
    public final String SELECTION_BRANDS_WINES = 'Selection Brands Wines';
    public final String MARKETING_ACTIVITY_SPIRITS= 'Marketing Activity Spirits';
    public final String MARKETING_ACTIVITY_WINES = 'Marketing Activity Wines';
    public final String TRIPS = 'Trips';
    public final String EDUCATION = 'Education';
    public final String FREE_STOCK = 'Free stock';
    public final String PROFITABILTY = 'EUR_CRM_Profitability';
    public final String CONTRACT_MATERIAL = 'EUR_CRM_ContractMaterial';

    public EUR_CRM_Contract__c contractObj {get; set;}
    public Map<String, MechanicTypeWrapper> mechanicTypeWrapperMap{get;set;}
    private transient  Map<String, EUR_CRM_Mechanic_Type__c> MTbyEnglishName;
    private Map<id, EUR_CRM_Contract_Activity_Item__c > CAIsByMTid;
    private transient  Map<id, List<EUR_CRM_Contract_Product_Item__c>> CPIsByMTid;
    private Map<String, List<EUR_CRM_Brand__c>> allBsByWSname;
    private Map<String, List<EUR_CRM_Quality__c>> allBQsByWSname;
    private Map<String, List<EUR_CRM_Size__c>> allBQSsByWSname;
    private Map<String, List<EUR_CRM_SKU__c>> allSKUsByWSname;
    public String thousandSep {get;set;}
    public String decimalSep {get;set;}
    private List<EUR_CRM_Apex_Configuration__c> profitabilityThreshold;
    private List<EUR_CRM_Apex_Configuration__c> contractMaterialThreshold;

    // String to store product name. Used in the page's actionfunction in order for it to be able to pass
    // argument to a javascript function.

    public String productName {get; set;}

//    private Map<String, String> productFieldByMTname = new Map<String, String>{
//            POURING_REFUND_SPIRITS => 'EUR_CRM_Brand_Quality_Size__c'
//        ,   POURING_REFUND_WINES => 'EUR_CRM_SKU__c'
//        ,   SELECTION_BRANDS_SPIRITS => 'EUR_CRM_Brand_Quality_Size__c'
//        ,   SELECTION_BRANDS_WINES => 'EUR_CRM_Brand__c'
//        ,   MARKETING_ACTIVITY_SPIRITS => 'EUR_CRM_Brand__c'
//        ,   MARKETING_ACTIVITY_WINES => 'EUR_CRM_Brand__c'
//        ,   TRIPS => 'EUR_CRM_Brand__c'
//        ,   EDUCATION => 'EUR_CRM_Brand__c'
//        ,   FREE_STOCK => 'EUR_CRM_Brand_Quality__c'
//    };
    
    private Map<String,String> productFieldByProductLevel = new Map<String,String>{
           'EUR_CRM_Brand__c' =>'EUR_CRM_Brand__c'
        ,  'EUR_CRM_Quality__c' =>'EUR_CRM_Brand_Quality__c'
        ,  'EUR_CRM_Size__c' => 'EUR_CRM_Brand_Quality_Size__c'
        ,  'EUR_CRM_SKU__c' =>'EUR_CRM_SKU__c'
    };

    @TestVisible
    private static List<EUR_CRM_CTM_Contract_setting__mdt> testContractSettings;
	@TestVisible
	private static List<EUR_CRM_CTM_Contract_Display_Setting__mdt> testDisplaySettings;
    private Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingByMTExtId {
        set;
        get{
            if(contractSettingByMTExtId == null) {
                contractSettingByMTExtId = this.getContractSettingByMTExtId('FI');
            }
            return contractSettingByMTExtId;
        }
    }

    private Map<String, String> wineSpiritByMTExtId {
        set;
        get{
            if(wineSpiritByMTExtId == null) {
                wineSpiritByMTExtId = this.getWineSpiritByMTExtId('FI');
            }
            return wineSpiritByMTExtId;
        }
    }

    public EUR_CRM_FI_ContractBuilderController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if(!test.isRunningTest())
            this.standardController.addFields(this.contractFields);
        if (String.isEmpty(this.standardController.getId())){
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        }else{
            contractObj = (EUR_CRM_Contract__c )standardController.getRecord();
            initContractContent();
        }
        thousandSep = EUR_CRM_FI_UtilClass.getThousandSep();
        decimalSep = EUR_CRM_FI_UtilClass.getDecimalSep();
        initThresholds();
    }

    void initThresholds(){
        profitabilityThreshold = new List<EUR_CRM_Apex_Configuration__c>();
        contractMaterialThreshold = new List<EUR_CRM_Apex_Configuration__c>();
        for(EUR_CRM_Apex_Configuration__c config: [select EUR_CRM_Sub_Module__c, EUR_CRM_Text_Value__c, EUR_CRM_Decimal_Value__c from EUR_CRM_Apex_Configuration__c where
        EUR_CRM_Module__c = 'EUR_CRM_FI_ContractBuilder'
        order by EUR_CRM_Sequence__c asc]){
            if(config.EUR_CRM_Sub_Module__c == PROFITABILTY)
                profitabilityThreshold.add(config);
            if(config.EUR_CRM_Sub_Module__c == CONTRACT_MATERIAL)
                contractMaterialThreshold.add(config);
        }
    }
    public String getContractMaterialColor(){
        Decimal cm = contractObj.EUR_CRM_Is_this_contract_material__c;
        String color = '#FF3333';
        //handle first element, value is < element element
        if(contractMaterialThreshold == null || contractMaterialThreshold.size() == 0)
            return color;
        EUR_CRM_Apex_Configuration__c config = contractMaterialThreshold.get(0);
        if(cm == null || cm < config.EUR_CRM_Decimal_Value__c)
            return config.EUR_CRM_Text_Value__c;
        //handle 2nd to last element, value is >= element
         //default
        for(Integer i = 1; i < contractMaterialThreshold.size(); i++){
            config = contractMaterialThreshold.get(i);
            if(cm >= config.EUR_CRM_Decimal_Value__c)
                color = config.EUR_CRM_Text_Value__c;
        }
        return color;
    }
    public String getProfitColor(){
        Decimal profit = contractObj.EUR_CRM_Is_this_contract_profitable__c;
        /*
        if(profit == null || profit < 20){
            return '#FF3333';
        }else if(profit < 40){
            return  '#FFFF75';
        }else
            return '#00FF33';
        */

        //Decimal profit = contractObj.EUR_CRM_Is_this_contract_material__c;
        String color = '#FF3333';
        //handle first element, value is < element element
        if(profitabilityThreshold == null || profitabilityThreshold.size() == 0)
            return color;
        EUR_CRM_Apex_Configuration__c config = profitabilityThreshold.get(0);
        if(profit == null || profit < config.EUR_CRM_Decimal_Value__c)
            return config.EUR_CRM_Text_Value__c;
        //handle 2nd to last element, value is >= element
         //default
        for(Integer i = 1; i < profitabilityThreshold.size(); i++){
            config = profitabilityThreshold.get(i);
            if(profit >= config.EUR_CRM_Decimal_Value__c)
                color = config.EUR_CRM_Text_Value__c;
        }
        return color;
    }

    public Boolean getIsCurrentUserApprover(){
        Set<Id> approvers = new Set<Id>();

        for(ProcessInstanceStep pStep : [select  OriginalActorId from ProcessInstanceStep where stepStatus not in ('Started', 'Submitted')
            AND ProcessInstanceId in (select id from ProcessInstance where TargetObjectId = :contractObj.id)]){
            approvers.add(pStep.OriginalActorId);
        }
        return approvers.contains(UserInfo.getUserId());
    }
    public void initContractContent(){
        this.MTbyEnglishName = this.getMTbyEnglishName();
        this.CAIsByMTid = this.getCAIbyMTid();
        this.CPIsByMTid = this.getCPIsByMTid();
        this.allBsByWSname = this.getBrandsByWineSpiritName();
        this.allBQsByWSname = this.getBrandQualitiesByWineSpiritName();
        this.allBQSsByWSname = this.getBrandQualitySizesByWineSpiritName();
        this.allSKUsByWSname = this.getSKUsByWineSpiritName();

        this.mechanicTypeWrapperMap = new Map<String, MechanicTypeWrapper>();

        for(EUR_CRM_Mechanic_Type__c mType: this.MTbyEnglishName.values()){
            String key = mType.EUR_CRM_Mechanic_Type_Name_English__c;
            String productLevel = this.contractSettingByMTExtId.containsKey(mType.EUR_CRM_External_ID__c) ?
                this.contractSettingByMTExtId.get(mType.EUR_CRM_External_ID__c).EUR_CRM_Product_level__c : '';
            String productObject = this.productFieldByProductLevel.get(productLevel);

            String wsName = this.wineSpiritByMTExtId.get(mType.EUR_CRM_External_ID__c);
            MechanicTypeWrapper mTypeWrapper = new MechanicTypeWrapper(this,mType, CAIsByMTid.get(mType.id), CPIsByMTid.get(mType.id),
             productObject, wsName );
            this.mechanicTypeWrapperMap.put(key,mTypeWrapper);

        }
        System.debug('\n mechanicTypeWrapperMap.size() => ' + this.mechanicTypeWrapperMap.size() + '\n');
        System.debug('\n mechanicTypeWrapperMap => ' + this.mechanicTypeWrapperMap + '\n');
    }

    /**from Contract Class */

    private Map<String, EUR_CRM_CTM_Contract_setting__mdt> getContractSettingByMTExtId(String countryCode) {
        List<EUR_CRM_CTM_Contract_setting__mdt> contractSettings = this.selectContractSettingsWhereCountryCode(countryCode);
        if (contractSettings.isEmpty()) { return new Map<String, EUR_CRM_CTM_Contract_setting__mdt>(); }

        Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingCMTByMechanicTypeExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();
        for (EUR_CRM_CTM_Contract_setting__mdt cs : contractSettings) {
            contractSettingCMTByMechanicTypeExtId.put(cs.EUR_CRM_Mechanic_ExtID__c, cs);
        }
        return contractSettingCMTByMechanicTypeExtId;
    }

    private Map<String, String> getWineSpiritByMTExtId(String countryCode) {
        List<EUR_CRM_CTM_Contract_Display_Setting__mdt> contractDisplaySettings = this.selectContractDisplaySettingsWhereCountryCode(countryCode);
        if (contractDisplaySettings.isEmpty()) { return new Map<String, String>(); }

        Map<String, String> wineSpiritByMTextId = new Map<String, String>();
        for (EUR_CRM_CTM_Contract_Display_Setting__mdt cds : contractDisplaySettings) {
            if (String.isBlank(cds.EUR_CRM_Mechanic_type_ext_IDs__c)) { continue; }
            this.populateWineSpiritByMTextIdMap(wineSpiritByMTextId, cds);
        }
        System.debug('\n wineSpiritByMTextId.size() => ' + wineSpiritByMTextId.size() + '\n');
        System.debug('\n wineSpiritByMTextId => ' + JSON.serializePretty(wineSpiritByMTextId) + '\n');
        return wineSpiritByMTextId;
    }

    private void populateWineSpiritByMTextIdMap(Map<String, String> wineSpiritByMTextId, EUR_CRM_CTM_Contract_Display_Setting__mdt cds) {
        List<String> mtExtIds = cds.EUR_CRM_Mechanic_type_ext_IDs__c.split(',|;');
        for (String mtExtId : mtExtIds) {
            wineSpiritByMTextId.put(mtExtId, cds.EUR_CRM_Wine_Spirits__c);
        }
    }

    private Map<String, EUR_CRM_Mechanic_Type__c> getMTbyEnglishName(){
        List<EUR_CRM_Mechanic_Type__c> MTs = this.selectMTsWhereCountryCode(this.contractObj.EUR_CRM_Country_Code__c);
        if (MTs.isEmpty()) { return new Map<String, EUR_CRM_Mechanic_Type__c>(); }
        
        Map<String, EUR_CRM_Mechanic_Type__c> mtByEnglishName = new  Map<String, EUR_CRM_Mechanic_Type__c>();
        for (EUR_CRM_Mechanic_Type__c mt : MTs) {
            if (String.isBlank(mt.EUR_CRM_Mechanic_Type_Name_English__c)) { continue; }
            mtByEnglishName.put(mt.EUR_CRM_Mechanic_Type_Name_English__c, mt);
        }
        System.debug('\n mtByEnglishName.size() => ' + mtByEnglishName.size() + '\n');
        System.debug('\n mtByEnglishName => ' + JSON.serializePretty(mtByEnglishName) + '\n');
        return mtByEnglishName;
    }

    private Map<Id, EUR_CRM_Contract_Activity_Item__c > getCAIbyMTid() {
        List<EUR_CRM_Contract_Activity_Item__c> CAIs = this.selectCAIsWhereContractId(this.contractObj.Id);
        if (CAIs.isEmpty()) { return new Map<Id, EUR_CRM_Contract_Activity_Item__c>(); }
        
        Map<Id, EUR_CRM_Contract_Activity_Item__c > CAIbyMTid = new  Map<Id, EUR_CRM_Contract_Activity_Item__c >();
        for (EUR_CRM_Contract_Activity_Item__c cai : CAIs) {
            CAIbyMTid.put(cai.EUR_CRM_Mechanic_Type__c, cai);
        }
        System.debug('\n CAIbyMTid.size() => ' + CAIbyMTid.size() + '\n');
        System.debug('\n CAIbyMTid => ' + JSON.serializePretty(CAIbyMTid) + '\n');
        return CAIbyMTid;
    }

    private Map<Id, List<EUR_CRM_Contract_Product_Item__c>> getCPIsByMTid() {
        List<EUR_CRM_Contract_Product_Item__c> CPIs = this.selectCPIsWhereContractId(this.contractObj.Id);
        if (CPIs.isEmpty()) { return new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>(); }


        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> CPIsByMTid = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();
        for (EUR_CRM_Contract_Product_Item__c cpi : CPIs){
            String mtKey = cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c;
            if (CPIsByMTid.containsKey(mtKey)) {
                CPIsByMTid.get(mtKey).add(cpi);
            } else {
                CPIsByMTid.put(mtKey, new List<EUR_CRM_Contract_Product_Item__c>{ cpi });
            }
        }
        System.debug('\n CPIsByMT.size() => ' + CPIsByMTid.size() + '\n');
        System.debug('\n CPIsByMT => ' + JSON.serializePretty(CPIsByMTid) + '\n');
        return CPIsByMTid;
    }

    private Map<String, List<EUR_CRM_Brand__c>> getBrandsByWineSpiritName() {
        List<EUR_CRM_Brand__c> Bs = this.selectBrandsWhereCountryCode(this.contractObj.EUR_CRM_Country_Code__c);
        System.debug('\n Bs.size() => ' + Bs.size() + '\n');
        System.debug('\n Bs => ' + JSON.serializePretty(Bs) + '\n');
        if (Bs.isEmpty()) { return new Map<String, List<EUR_CRM_Brand__c>>(); }

        Map<String, List<EUR_CRM_Brand__c>> BsByWSname = new Map<String, List<EUR_CRM_Brand__c>>();
        for (EUR_CRM_Brand__c b : Bs) {
            String wsName = b.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c;
            if (String.isBlank(wsName)) { continue; }

            if (BsByWSname.containsKey(wsName)) {
                BsByWSname.get(wsName).add(b);
            } else {
                BsByWSname.put(wsName, new List<EUR_CRM_Brand__c>{ b });
            }
        }
        System.debug('\n BsByWSname.size() => ' + BsByWSname.size() + '\n');
        System.debug('\n BsByWSname => ' + JSON.serializePretty(BsByWSname) + '\n');
        return BsByWSname;
    }

    private Map<String, List<EUR_CRM_Quality__c>> getBrandQualitiesByWineSpiritName() {
        List<EUR_CRM_Quality__c> BQs = this.selectBrandQualitiesWhereCountryCode(this.contractObj.EUR_CRM_Country_Code__c);
        System.debug('\n BQs.size() => ' + BQs.size() + '\n');
        System.debug('\n BQs => ' + JSON.serializePretty(BQs) + '\n');
        if (BQs.isEmpty()) { return new Map<String, List<EUR_CRM_Quality__c>>(); }

        Map<String, List<EUR_CRM_Quality__c>> BQsByWSname = new Map<String, List<EUR_CRM_Quality__c>>();
        for (EUR_CRM_Quality__c bq : BQs) {
            String wsName = bq.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c;
            if (String.isBlank(wsName)) { continue; }

            if (BQsByWSname.containsKey(wsName)) {
                BQsByWSname.get(wsName).add(bq);
            } else {
                BQsByWSname.put(wsName, new List<EUR_CRM_Quality__c>{ bq });
            }
        }
        System.debug('\n BQsByWSname.size() => ' + BQsByWSname.size() + '\n');
        System.debug('\n BQsByWSname => ' + JSON.serializePretty(BQsByWSname) + '\n');
        return BQsByWSname;
    }

    private Map<String, List<EUR_CRM_Size__c>> getBrandQualitySizesByWineSpiritName() {
        List<EUR_CRM_Size__c> BQSs = this.selectBrandQualitySizesWhereCountryCode(this.contractObj.EUR_CRM_Country_Code__c);
        System.debug('\n BQSs.size() => ' + BQSs.size() + '\n');
        System.debug('\n BQSs => ' + JSON.serializePretty(BQSs) + '\n');
        if (BQSs.isEmpty()) { return new Map<String, List<EUR_CRM_Size__c>>(); }

        Map<String, List<EUR_CRM_Size__c>> BQSsByWSname = new Map<String, List<EUR_CRM_Size__c>>();
        for (EUR_CRM_Size__c bqs : BQSs) {
            String wsName = bqs.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c;
            if (String.isBlank(wsName)) { continue; }

            if (BQSsByWSname.containsKey(wsName)) {
                BQSsByWSname.get(wsName).add(bqs);
            } else {
                BQSsByWSname.put(wsName, new List<EUR_CRM_Size__c>{ bqs });
            }
        }
        System.debug('\n BQSsByWSname.size() => ' + BQSsByWSname.size() + '\n');
        System.debug('\n BQSsByWSname => ' + JSON.serializePretty(BQSsByWSname) + '\n');
        return BQSsByWSname;
    }

    private Map<String, List<EUR_CRM_SKU__c>> getSKUsByWineSpiritName() {
        List<EUR_CRM_SKU__c> SKUs = this.selectSKUsWhereCountryCode(this.contractObj.EUR_CRM_Country_Code__c);
        System.debug('\n SKUs.size() => ' + SKUs.size() + '\n');
        System.debug('\n SKUs => ' + JSON.serializePretty(SKUs) + '\n');
        if (SKUs.isEmpty()) { return new Map<String, List<EUR_CRM_SKU__c>>(); }

        Map<String, List<EUR_CRM_SKU__c>> SKUsByWSname = new Map<String, List<EUR_CRM_SKU__c>>();
        for (EUR_CRM_SKU__c sku : SKUs) {
            String wsName = sku.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c;
            if (String.isBlank(wsName)) { continue; }

            if (SKUsByWSname.containsKey(wsName)) {
                SKUsByWSname.get(wsName).add(sku);
            } else {
                SKUsByWSname.put(wsName, new List<EUR_CRM_SKU__c>{ sku });
            }
        }
        System.debug('\n SKUsByWSname.size() => ' + SKUsByWSname.size() + '\n');
        System.debug('\n SKUsByWSname => ' + JSON.serializePretty(SKUsByWSname) + '\n');
        return SKUsByWSname;
    }

        private List<EUR_CRM_CTM_Contract_setting__mdt> selectContractSettingsWhereCountryCode(String countryCode) {
            if (Test.isRunningTest()) { return testContractSettings; }
            return [
            SELECT Id
                , EUR_CRM_Product_level__c
                , EUR_CRM_Setting_Type__c
                , EUR_CRM_Mechanic_ExtID__c
            FROM EUR_CRM_CTM_Contract_setting__mdt
            WHERE EUR_CRM_Country_Code__c = :countryCode
        ];
    }

    private List<EUR_CRM_CTM_Contract_Display_Setting__mdt> selectContractDisplaySettingsWhereCountryCode(String countryCode) {
		if (Test.isRunningTest()) { return testDisplaySettings; }
        return [
            SELECT DeveloperName
                , EUR_CRM_Mechanic_type_ext_IDs__c
                , EUR_CRM_Wine_Spirits__c
            FROM EUR_CRM_CTM_Contract_Display_Setting__mdt
            WHERE EUR_CRM_Country__c = :countryCode
            AND EUR_CRM_Parent_Tab_ID__c != null
            AND EUR_CRM_Mechanic_type_ext_IDs__c != null
        ];
    }

    private List<EUR_CRM_Mechanic_Type__c> selectMTsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Country_Code__c
                , EUR_CRM_Mechanic_Type_Name_English__c
                , EUR_CRM_External_ID__c
            FROM EUR_CRM_Mechanic_Type__c
            WHERE EUR_CRM_Country_Code__c = :countryCode
        ];
    }

    private List<EUR_CRM_Brand__c> selectBrandsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Brand_Code__c
                , EUR_CRM_Country_Code__c
                , EUR_CRM_Is_Competitor__c
                , EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c
            FROM EUR_CRM_Brand__c
            WHERE EUR_CRM_Country_Code__c = :countryCode
            AND EUR_CRM_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            AND EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c != null
        ];
    }

    private List<EUR_CRM_Quality__c> selectBrandQualitiesWhereCountryCode(String countryCode) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Quality_Code__c
                , EUR_CRM_Brand__c
                , EUR_CRM_Brand__r.Name
                , EUR_CRM_Quality_Description__c
                , EUR_CRM_Country_Code__c
                , EUR_CRM_Quality_Is_Competitor__c
                , EUR_CRM_Brand__r.EUR_CRM_Category__c
                , EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c
            FROM EUR_CRM_Quality__c
            WHERE EUR_CRM_Country_Code__c = :countryCode
            AND EUR_CRM_Quality_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            AND EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c != null
        ];
    }

    private List<EUR_CRM_Size__c> selectBrandQualitySizesWhereCountryCode(String countryCode) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c
            FROM EUR_CRM_Size__c
            WHERE EUR_CRM_Country__c = :countryCode
            AND EUR_CRM_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            AND EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c != null
        ];
    }

    private List<EUR_CRM_SKU__c> selectSKUsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Category_Name__c
                , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits_Name__c
            FROM EUR_CRM_SKU__c
            WHERE EUR_CRM_Country__c = :countryCode
            AND EUR_CRM_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            AND EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__c != null
        ];
    }

    private List<EUR_CRM_Contract_Activity_Item__c> selectCAIsWhereContractId(Id contractId) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Amount__c
                , EUR_CRM_Contract__c
                , EUR_CRM_Name__c
                , EUR_CRM_Product_Items_Total__c
                , EUR_CRM_Contract_Activity_Total__c
                , EUR_CRM_Product_Qty_Total__c
                , EUR_CRM_Lumpsum_Value__c
                , EUR_CRM_Mechanic_Type__c
                , EUR_CRM_Mechanic_Type__r.Name
                , EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c
                , EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
                , EUR_CRM_Total_Gross_Sales__c
                , EUR_CRM_Total_Retro_FI__c
                , EUR_CRM_Contract_Profit_per_Activity__c
                , (
                SELECT Id
                    , EUR_CRM_Gross_SalesBtl__c
                    , EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
                    , EUR_CRM_Profit__c
                    , EUR_CRM_Marketing_Amount__c
                FROM Contract_Product_Items__r)
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c = :contractId
        ];
    }

    private List<EUR_CRM_Contract_Product_Item__c> selectCPIsWhereContractId(Id contractId) {
        return [
            SELECT Id
                , Name
                , EUR_CRM_Quantity__c
                , EUR_CRM_Volume_Btl__c
                , EUR_CRM_Amount_Spent__c
                , EUR_CRM_Marketing_Amount__c
                , EUR_CRM_Name_Reference__c
                , EUR_CRM_Amount__c
                , EUR_CRM_Contract_Event__r.Name
                , EUR_CRM_Contract_Event__c
                , EUR_CRM_No_of_People__c
                , EUR_CRM_Contract_Activity_Item__c
                , EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c
                , EUR_CRM_Brand__c
                , EUR_CRM_Brand__r.Name
                , EUR_CRM_Brand_Quality__c
                , EUR_CRM_Brand_Quality__r.Name
                , EUR_CRM_Brand_Quality_Size__c
                , EUR_CRM_Brand_Quality_Size__r.Name
                , EUR_CRM_SKU__c
                , EUR_CRM_SKU__r.Name
                , EUR_CRM_AnP__c
                , EUR_CRM_Gross_SalesBtl__c
            FROM EUR_CRM_Contract_Product_Item__c
            WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c = :contractId
        ];
    }

//    private transient Map<Id,List<SObject>> selectableProductsByMechanicType;

    public void addContractLineItem(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        Id param_productId = (Id) params.get('PARAM_PRODUCT_ID');
        MechanicTypeWrapper mtWrap =  mechanicTypeWrapperMap.get(param_mechanicTypeName);
        mtWrap.addProduct(param_productId);
    }

    public void removeContractLineItem(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        Integer row_Index = Integer.valueOf(params.get('PARAM_ROW_NUMBER'));
        Id param_productId = (Id) params.get('PARAM_PRODUCT_ID');
        MechanicTypeWrapper mtWrap =  mechanicTypeWrapperMap.get(param_mechanicTypeName);
        mtWrap.removeProduct(param_productId, row_Index);
    }

    private Boolean validateInputs(){
        Set<String> pouring = new Set<String>{'Pouring Refund Spirits','Pouring Refund Wines'};
        Set<String> selection = new Set<String>{'Selection Brands Spirits','Selection Brands Wines'};
        Set<String> marketingAct = new Set<String>{'Marketing Activity Spirits','Marketing Activity Wines'};
//        Set<String> marketingMisc = new Set<String>{'Trips','Education','Free Stock'};
        for(MechanicTypeWrapper mType : mechanicTypeWrapperMap.values()){
            String mechName = mType.mechanicTypeEnglishName;
            if(pouring.contains(mechName)){
                 system.debug('@@@ mechName: ' + mechName);
                if(mType.getContractProductItems() != null && mType.getContractProductItems().size() > 0){
                    system.debug('@@@ allContractProductItems: ' + mType.getContractProductItems());
                    for(EUR_CRM_Contract_Product_Item__c prod : mType.getContractProductItems()){
                        if(prod.EUR_CRM_Volume_Btl__c == null || prod.EUR_CRM_Amount__c == null){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_Missing_Values );
                            break;
                        }
                        if(prod.EUR_CRM_Volume_Btl__c <= 0  ){
                            addMessage(ApexPages.Severity.WARNING, mType.mechanicTypeName +': ' +  (Label.EUR_CRM_Invalid_Field_Value).replace(':','')  );
                            break;
                        }
                        else if(prod.EUR_CRM_Amount__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );
                            break;
                        }
                    }
                }
            }else if(selection.contains(mechName)){
                if(mType.allContractProductItems != null && mType.allContractProductItems.size() > 0){
                    for(EUR_CRM_Contract_Product_Item__c prod : mType.allContractProductItems){
                        if(prod.EUR_CRM_Volume_Btl__c == null || prod.EUR_CRM_Amount__c == null){
                            addMessage(ApexPages.Severity.WARNING, mType.mechanicTypeName +': ' +  (Label.EUR_CRM_Missing_Values).replace(':','')  );
                            break;
                        }
                        if(prod.EUR_CRM_Volume_Btl__c <= 0  ){
                            addMessage(ApexPages.Severity.WARNING, mType.mechanicTypeName +': ' +  (Label.EUR_CRM_Invalid_Field_Value).replace(':','')  );
                            break;
                        }
                        else if(prod.EUR_CRM_Amount__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );
                            break;
                        }
                    }
                }
            }else if(marketingAct.contains(mechName)){
                    if(mType.allContractProductItems != null && mType.allContractProductItems.size() > 0){
                        for(EUR_CRM_Contract_Product_Item__c prod : mType.allContractProductItems){
                            if(prod.EUR_CRM_Marketing_Amount__c == null){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_Missing_Values );
                                break;
                            }
                        else if(prod.EUR_CRM_Marketing_Amount__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );
                            break;
                        }
                        }
                    }
                    if(mType.contractActivityItem != null && mType.contractActivityItem.EUR_CRM_Lumpsum_Value__c != null && mType.contractActivityItem.EUR_CRM_Lumpsum_Value__c < 0){
                           addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );

                    }
            }else if('Trips' == mechName){
                if(mType.allContractProductItems != null && mType.allContractProductItems.size() > 0){
                    for(EUR_CRM_Contract_Product_Item__c prod : mType.allContractProductItems){
                        if(prod.EUR_CRM_Marketing_Amount__c == null || prod.EUR_CRM_No_of_People__c == null){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_Missing_Values );
                            break;
                        }
                        if(prod.EUR_CRM_No_of_People__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + (Label.EUR_CRM_Invalid_Field_Value).replace(':','') );
                                break;
                            }
                        else if(prod.EUR_CRM_Marketing_Amount__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );
                            break;
                        }
                    }
                }
            }else if('Education' == mechName){
                if(mType.allContractProductItems != null && mType.allContractProductItems.size() > 0){
                    for(EUR_CRM_Contract_Product_Item__c prod : mType.allContractProductItems){
                        if(prod.EUR_CRM_Marketing_Amount__c == null){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_Missing_Values );
                            break;
                        }
                        else if(prod.EUR_CRM_Marketing_Amount__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );
                            break;
                        }
                    }
                }
            }else if('Free Stock' == mechName){
                if(mType.allContractProductItems != null && mType.allContractProductItems.size() > 0){
                    for(EUR_CRM_Contract_Product_Item__c prod : mType.allContractProductItems){
                        if(prod.EUR_CRM_Marketing_Amount__c == null ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_Missing_Values );
                            break;
                        }
                        else if(prod.EUR_CRM_Marketing_Amount__c < 0 ){
                            addMessage(ApexPages.Severity.WARNING,  mType.mechanicTypeName + ': ' + Label.EUR_CRM_NegativeCurrency );
                            break;
                        }
                    }
                }
            }
        }
        if (Test.isRunningTest()) { return true; }
        return !ApexPages.hasMessages();
    }
    public PageReference save(){
        this.quickSave();
        if( ! this.isValid){ return null; }

        PageReference p = new PageReference('/' + this.contractObj.Id);
        p.setRedirect(true);
        return p; //standardController.view();
    }

    private Boolean isValid = false;
    public void quickSave(){
        System.debug('\n quickSave => \n');
        try{
            List<EUR_CRM_Contract_Product_Item__c> upsertContractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
            List<EUR_CRM_Contract_Product_Item__c> deleteContractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
            List<EUR_CRM_Contract_Activity_Item__c> upsertContractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
            List<EUR_CRM_Contract_Activity_Item__c> deleteContractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
            List<MechanicTypeWrapper> mtWrappersToUpdateCAI = new List<MechanicTypeWrapper>();
            //EUR_CRM_Missing_Values
            //insert contract activity item first
            this.isValid = validateInputs();
            if( ! this.isValid) { return; }

            Set<Id> noValue = new Set<Id>();
            for(MechanicTypeWrapper mType : this.mechanicTypeWrapperMap.values()){
                System.debug('\n mType.contractActivityItem => ' + JSON.serializePretty(mType.contractActivityItem) + '\n');
//                if(!mType.hasValue()){
//                    if(mType.contractActivityItem != null && mType.contractActivityItem.id != null){
//                        deleteContractActivityItems.add(mType.contractActivityItem );
//                        noValue.add(mType.mechanicTypeId);
//                    }
//                    continue;
//                }
//                if(mType.contractActivityItem != null)
//                    upsertContractActivityItems.add(mType.contractActivityItem);
//                    mtWrappersToUpdateCAI.add(mType);
                if (mType.contractActivityItem.Id == null) {
                    upsertContractActivityItems.add(mType.contractActivityItem);
                }

            }
//            this.fillCAIitemTypeAndProductLevel(mtWrappersToUpdateCAI);
            System.debug('\n upsertContractActivityItems.size() => ' + upsertContractActivityItems.size() + '\n');
            System.debug('\n upsertContractActivityItems => ' + JSON.serializePretty(upsertContractActivityItems) + '\n');

            delete deleteContractActivityItems;
            upsert upsertContractActivityItems;
            //update the contract product items with contract activity items
            for(MechanicTypeWrapper mType : this.mechanicTypeWrapperMap.values()){
                if(mType.contractActivityItem == null)
                    continue;
                if(mType.allContractProductItems != null && mType.allContractProductItems.size() > 0){
                    for(EUR_CRM_Contract_Product_Item__c p : mType.allContractProductItems){
                        if(p.EUR_CRM_Contract_Activity_Item__c == null){
                            p.EUR_CRM_Contract_Activity_Item__c = mType.contractActivityItem.id;
                        }
                    }
                    upsertContractProductItems.addAll(mType.allContractProductItems);
                }
                if(!noValue.contains(mType.mechanicTypeId) && mType.deleteProducts != null && mType.deleteProducts.size() > 0){
                    deleteContractProductItems.addAll(mType.deleteProducts);
                }
            }
            delete deleteContractProductItems;
            System.debug('\n upsertContractProductItems.size() => ' + upsertContractProductItems.size() + '\n');
            System.debug('\n upsertContractProductItems => ' + JSON.serializePretty(upsertContractProductItems) + '\n');
            upsert upsertContractProductItems;
            system.debug('@@@ upsertContractProductItems: ' +  upsertContractProductItems);
            calculateProfit();
            //contractObj.EUR_CRM_Is_Calculate_Profit__c = true;
            List<EUR_CRM_Contract_Activity_Item__c> caisToUpdateContractRollUp = this.selectCAIsWhereContractId(this.contractObj.Id);
            this.updateCaisTotalGrossSales(caisToUpdateContractRollUp);

            update caisToUpdateContractRollUp;

            this.updateContractRollUpFields(caisToUpdateContractRollUp);

            update this.contractObj;
            system.debug('@@@ contractObj: ' +  JSON.serializePretty(this.contractObj));

            for(MechanicTypeWrapper mType : this.mechanicTypeWrapperMap.values()){
                if(!noValue.contains(mType.mechanicTypeId) && mType.deleteProducts != null && mType.deleteProducts.size() > 0){
                     mType.deleteProducts.clear();
                }
            }
        }catch(Exception e){
             addMessage(ApexPages.Severity.Error,  Label.EUR_CRM_SaveError + ' : ' + e.getMessage() + ' , cause: ' + e.getCause());
             system.debug('@@@ EUR_CRM_SaveError: ' + e);
             this.isValid = false;
        }
    }

    private void updateCaisTotalGrossSales(List<EUR_CRM_Contract_Activity_Item__c> cais) {

        for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
            Decimal caiTotalGrossSales = 0;
            for (EUR_CRM_Contract_Product_Item__c cpi : cai.Contract_Product_Items__r) {
                caiTotalGrossSales += cpi.EUR_CRM_Gross_SalesBtl__c;
            }
            cai.EUR_CRM_Total_Gross_Sales__c = caiTotalGrossSales;
        }
    }

    private void updateContractRollUpFields(List<EUR_CRM_Contract_Activity_Item__c> cais) {
        Decimal contractProfit = 0;
        Decimal generalGrossSales = 0;
        Decimal totalRetroFi = 0;
        Decimal totalRetroEducation = 0;
        for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
            System.debug('\n cai => ' + JSON.serializePretty(cai) + '\n');
            for (EUR_CRM_Contract_Product_Item__c cpi : cai.Contract_Product_Items__r) {
                contractProfit += EUR_CRM_FI_ProfitCalculatorExt.calculateTotalCMByRow(cpi);
            }
            generalGrossSales = this.summarizeValue(generalGrossSales, cai.EUR_CRM_Total_Gross_Sales__c);
            totalRetroFi = this.summarizeValue(totalRetroFi, cai.EUR_CRM_Total_Retro_FI__c);
            if (cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c == EDUCATION) {
                totalRetroEducation = this.summarizeValue(totalRetroEducation, cai.EUR_CRM_Total_Retro_FI__c);
            }
        }
        this.contractObj.EUR_CRM_Contract_Profit__c = contractProfit;
        this.contractObj.EUR_CRM_General_Gross_Sales__c = generalGrossSales;
        this.contractObj.EUR_CRM_Total_Retro_FI__c = totalRetroFi;
        this.contractObj.EUR_CRM_Total_Retro_ex_Education_FI__c = totalRetroFi - totalRetroEducation;
    }

//    private Decimal summarizeContractProfit(Decimal contractProfit, EUR_CRM_Contract_Activity_Item__c cai) {
//        if (cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == 'EUR_FI_Education') { return contractProfit; }
//        return  this.summarizeValue(contractProfit, cai.EUR_CRM_Contract_Profit_per_Activity__c);
//    }

    private Decimal summarizeValue(Decimal total, Decimal val) {
        return val != null ? (total + val) : total;
    }



    private void calculateProfit(){
        Set<String> PROFIT_GROUP = new Set<String>{POURING_REFUND_SPIRITS,POURING_REFUND_WINES,SELECTION_BRANDS_SPIRITS,SELECTION_BRANDS_WINES};
        Set<String> MARKETING_GROUP = new Set<String>{MARKETING_ACTIVITY_SPIRITS,MARKETING_ACTIVITY_WINES,TRIPS,FREE_STOCK  };

        system.debug('@@@ calculateProfit: ' );
        Map<Id,Decimal> productCM = new Map<Id,Decimal>();
        Decimal totalCM = 0;
        Decimal totalCMRetro = 0;
        Decimal totalLumpSum = 0;
        Set<id> skuCm = new Set<id>();
        Set<id> brandCm = new Set<id>();
        Set<id> bqsCm = new Set<id>();

        for(String key : mechanicTypeWrapperMap.keySet()){
            MechanicTypeWrapper mechType = mechanicTypeWrapperMap.get(key);
            if(PROFIT_GROUP.contains(key)){
                if(mechType.allContractProductItems != null){
                        if(key == POURING_REFUND_SPIRITS || key == SELECTION_BRANDS_SPIRITS){
                            bqsCm.addAll(mechType.existingProductLevelIds);
                        }else if(key == POURING_REFUND_WINES){
                            skuCm.addAll(mechType.existingProductLevelIds);
                        }else if(key == SELECTION_BRANDS_WINES){
                            brandCm.addAll(mechType.existingProductLevelIds);
                        }
                }
            }else if(MARKETING_GROUP.contains(key)){
                 system.debug('@@@ MARKETING_GROUP: ' );
              EUR_CRM_Contract_Activity_Item__c contractActivityItem = mechType.contractActivityItem;
                 system.debug('@@@ contractActivityItem: ' + contractActivityItem);
              if(contractActivityItem != null && contractActivityItem.EUR_CRM_Lumpsum_Value__c != null){
                    totalLumpSum += contractActivityItem.EUR_CRM_Lumpsum_Value__c;
              }
              if(mechType.allContractProductItems != null ){
                for(EUR_CRM_Contract_Product_Item__c prod: mechType.allContractProductItems){
                    totalLumpSum += prod.EUR_CRM_Marketing_Amount__c == null ? 0 : prod.EUR_CRM_Marketing_Amount__c;
                }
              }
            }
        }
        if(skuCm.size() >0)
        for(EUR_CRM_SKU__c prod : [select id,EUR_CRM_Contributive_Margin_SKU__c from EUR_CRM_SKU__c where id in: skuCm]){
            productCM.put(prod.id, prod.EUR_CRM_Contributive_Margin_SKU__c);
        }
        if(brandCm.size() >0)
        for(EUR_CRM_Brand__c prod : [select id,EUR_CRM_Contributive_Margin_Brand__c from EUR_CRM_Brand__c where id in: brandCm]){
            productCM.put(prod.id, prod.EUR_CRM_Contributive_Margin_Brand__c);
        }
        if(bqsCm.size() >0)
        for(EUR_CRM_Size__c prod : [select id,EUR_CRM_Contributive_Margin_BQS__c from EUR_CRM_Size__c where id in: bqsCm]){
            productCM.put(prod.id, prod.EUR_CRM_Contributive_Margin_BQS__c);
        }
        //
        system.debug('### bqsCm: ' + bqsCm);
        system.debug('### brandCm: ' + brandCm);
        system.debug('### skuCm: ' + skuCm);
        system.debug('### productCM: ' + productCM);
        for(String key : this.mechanicTypeWrapperMap.keySet()){
            MechanicTypeWrapper mechType = this.mechanicTypeWrapperMap.get(key);
            if(PROFIT_GROUP.contains(key)){
                if(mechType.allContractProductItems != null){
                    for(EUR_CRM_Contract_Product_Item__c prod: mechType.allContractProductItems){
                        Id productId = (id) prod.get(mechType.productAPIName);
                        system.debug('### productId: ' + productId);
                        Decimal cm = productCM.get(productId) == null ? 0 : productCM.get(productId);
                        cm = cm.setScale(2);
                        Decimal volume = prod.EUR_CRM_Quantity__c == null ? 0 : prod.EUR_CRM_Quantity__c;
                        Decimal retro = prod.EUR_CRM_Amount__c == null ? 0 : prod.EUR_CRM_Amount__c;
                        totalCM += (cm * volume);
                        totalCMRetro += (retro * volume);
                    }
                }
            }
        }

        //
        system.debug('### totalCM: ' + totalCM);
        system.debug('### totalCMRetro: ' + totalCMRetro);
        system.debug('### totalLumpSum: ' + totalLumpSum);
        Decimal contractMaterial = totalCM - (totalLumpSum + totalCMRetro);
        this.contractObj.EUR_CRM_Is_this_contract_material__c = contractMaterial;
        this.contractObj.EUR_CRM_Is_this_contract_profitable__c = totalCM == 0 ? 0 : (contractMaterial/totalCM) * 100;

    }
    
    private void fillCAIitemTypeAndProductLevel(List<MechanicTypeWrapper> mtWrappersToUpdateCAI) {
        for (MechanicTypeWrapper mtWrap : mtWrappersToUpdateCAI) {
            if (contractSettingByMTExtId.containsKey(mtWrap.mechanicType.EUR_CRM_External_ID__c)) {
                EUR_CRM_CTM_Contract_setting__mdt cs = contractSettingByMTExtId.get(mtWrap.mechanicType.EUR_CRM_External_ID__c);
                mtWrap.contractActivityItem.EUR_CRM_Item_Type__c = String.isBlank(cs.EUR_CRM_Setting_Type__c) ? '' : cs.EUR_CRM_Setting_Type__c;
                mtWrap.contractActivityItem.EUR_CRM_Product_Level__c = String.isBlank(cs.EUR_CRM_Product_level__c) ? '' : cs.EUR_CRM_Product_level__c;
            }
        }
    }

    /*
    public PageReference resetMarketingPackageHandling(){
       system.debug('### reset. Flag 1');
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
       system.debug('### reset. Flag 2: ' + param_mechanicTypeName);
        MechanicTypeWrapper mtWrap =  mechanicTypeWrapperMap.get(param_mechanicTypeName);
       system.debug('### reset. Flag 2: mtWrap ' + mtWrap);
        if(mtWrap == null || mtWrap.contractActivityItem == null)
                return null;
        mtWrap.contractActivityItem.EUR_CRM_Lumpsum_Value__c = null;
       system.debug('### reset. Flag 2');
        if(mtWrap.allContractProductItems != null){
            for(EUR_CRM_Contract_Product_Item__c prod:mtWrap.allContractProductItems){
                if(prod.id != null){
                    if(mtWrap.deleteProducts == null)
                        mtWrap.deleteProducts = new List<EUR_CRM_Contract_Product_Item__c>();
                    mtWrap.deleteProducts.add(prod);
                }
            }
            mtWrap.allContractProductItems.clear();
        }
        mtWrap.existingProducts.clear();
        return null;
     }
*/

//    public class EduTripProductWrapper{
//        Id productId;
//        Id mechanicTypeId;
//        String productAPIName;
//        public List<EUR_CRM_Contract_Event__c> contractEvents {get;set;}
//        public EduTripProductWrapper(Id productId,Id mechanicTypeId,
//            String productAPIName, List<EUR_CRM_Contract_Event__c> contractEvents){
//            this.productId = productId;
//            this.mechanicTypeId = mechanicTypeId;
//            this.productAPIName = productAPIName;
//            this.contractEvents = contractEvents;
//        }
//        public List<SelectOption> getContractEventOptions(){
//            List<SelectOption> s = new List<SelectOption>();
//            if(contractEvents == null)
//                contractEvents = retrieveContractEvents();
//            for(EUR_CRM_Contract_Event__c cEvent: contractEvents){
//                s.add(new SelectOption(cEvent.id,cEvent.name));
//            }
//            return s;
//        }

//        private List<EUR_CRM_Contract_Event__c> retrieveContractEvents(){
//                List<EUR_CRM_Contract_Event__c> cEvents = new List<EUR_CRM_Contract_Event__c>();
//                String productId = (String) this.productId;
//                String mechTypeId = this.mechanicTypeId;
//                String query = 'select id from EUR_CRM_Contract_Mechanic__c where ';
//                query +=  productAPIName + ' =: productId';
//                query += ' AND EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c =:mechTypeId';
//
//                String query2 = 'select EUR_CRM_Contract_Event__c, EUR_CRM_Contract_Event__r.Name, EUR_CRM_Contract_Event__r.id from EUR_CRM_Contract_Event_To_Prod_Mapping__c ';
//                        query2 += ' where EUR_CRM_Contract_Mechanic__c in (' + query + ') order by EUR_CRM_Contract_Event__r.Name asc';
//               // List<EUR_CRM_Contract_Mechanic__c> contractMechanics = (List<EUR_CRM_Contract_Mechanic__c>) Database.query(query);
//                List<EUR_CRM_Contract_Event_To_Prod_Mapping__c> cEventProdMapping = (List<EUR_CRM_Contract_Event_To_Prod_Mapping__c>) Database.query(query2);
//                system.debug('@@ cEventProdMapping: ' + cEventProdMapping);
//                for(EUR_CRM_Contract_Event_To_Prod_Mapping__c mapping : cEventProdMapping){
//                    cEvents.add((EUR_CRM_Contract_Event__c) mapping.getSObject('EUR_CRM_Contract_Event__r'));
//                }
//               // select EUR_CRM_Contract_Event__c, EUR_CRM_Contract_Event__r.Name, EUR_CRM_Contract_Event__r.id from EUR_CRM_Contract_Event_To_Prod_Mapping__c
//                return cEvents;
//        }
//    }

//    public Component.Apex.Repeat getRepeat() {
//        Component.Apex.PageBlockSection pbs = new Component.Apex.PageBlockSection();
//        pbs.title = '{!$Label.EUR_CRM_Select_Products}';
//        pbs.columns = 1;
//        Component.Apex.Repeat repeat = new Component.Apex.Repeat();
//        Component.Apex.CommandLink commandLink = new Component.Apex.CommandLink();
//        commandLink.value = '{!$Label.EUR_CRM_Add}';
//        commandLink.action = '{!addContractLineItem}';
//        commandLink.rerender = 'pageBlock_PouringRefundSpirits';
//        commandLink.onComplete = 'console.log (\'Test onComplete - ADD\'); ' +
//            'addProduct(\'{!productName}\'); preventReturnKeyPress(); setPouringRefundSpirits(); reCalculateProductList(\'pouringRefundSpiritsTable\')';
//        commandLink.immediate = 'true';
//        commandLink.status = 'loading';
//
//        Component.Apex.Param mtName = new Component.Apex.Param();
//        mtName.name = 'PARAM_MECHANIC_TYPE_NAME';
//        mtName.value = this.mechanicTypeEnglishName;
//
//        Component.Apex.Param productId = new Component.Apex.Param();
//        productId.name = 'PARAM_PRODUCT_ID';
//
//        Component.Apex.OutputText trOpen = new Component.Apex.OutputText();
//        trOpen.escape = false;
//        trOpen.value = '<tr><td>';
//        Component.Apex.OutputText trMiddle = new Component.Apex.OutputText();
//        trMiddle.escape = false;
//        trMiddle.value = '</td><td>';
//        Component.Apex.OutputText trClose = new Component.Apex.OutputText();
//        trClose.escape = false;
//        trClose.value = '</td></tr>';
//
//        Component.Apex.OutputField outputField = new Component.Apex.OutputField();
//
//        if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand__c')) {
//            repeat.value = this.BbyId;
//
//        }
//        if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality__c')) {
//
//        }
//        if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality_Size__c')) {
//            repeat.value = this.BQSbyId;
//        }
//        if (this.productAPIName.equalsIgnoreCase('EUR_CRM_SKU__c')) {
//
//        }
//
//        repeat.var = 'key';
//
//        productId.value = repeat.value[repeat.var].Id;
//        outputField.value = repeat.value[repeat.var].Name;
//
//        commandLink.childComponents.add(mtName);
//        commandLink.childComponents.add(productId);
//        repeat.childComponents.add(trOpen);
//        repeat.childComponents.add(commandLink);
//        repeat.childComponents.add(trMiddle);
//        repeat.childComponents.add(outputField);
//        repeat.childComponent.add(trClose);
//
//        return repeat;
//    }

    /*
    inner wrapper class
    */

 //###############################################################################
    private void addMessage(ApexPages.Severity severity, String message){
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
    public class MechanicTypeWrapper{

        public EUR_CRM_Mechanic_Type__c mechanicType{get;set;}
        public String mechanicTypeName {get;set;}
        public String mechanicTypeEnglishName {get;set;}
        public Id mechanicTypeId {get;set;}

        public EUR_CRM_Contract_Activity_Item__c contractActivityItem {get;set;}
        public List<EUR_CRM_Contract_Product_Item__c> allContractProductItems {get;set;}
        private EUR_CRM_FI_ContractBuilderController controller;
        private Set<Id> existingProductLevelIds;
        public List<EUR_CRM_Contract_Product_Item__c> deleteProducts {get;set;}
        private String productObject; //quality, size, sku?
        public String productAPIName {get;set;}
        private String wineSpiritName;
        public Map<Id, EUR_CRM_Brand__c> BbyId {get; set;}
        public Map<Id, EUR_CRM_Quality__c> BQbyId {get; set;}
        public Map<Id, EUR_CRM_Size__c> BQSbyId {get; set;}
        public Map<Id,EUR_CRM_SKU__c> SKUbyId {get; set;}
        private Map<Id, EUR_CRM_Brand__c> bufferedBbyId {get; set;}
        private Map<Id, EUR_CRM_Quality__c> bufferedBQbyId {get; set;}
        private Map<Id, EUR_CRM_Size__c> bufferedBQSbyId {get; set;}
        private Map<Id,EUR_CRM_SKU__c> bufferedSKUbyId {get; set;}
        public List<EUR_CRM_Size__c> BQSs {get; set;}

        public MechanicTypeWrapper(EUR_CRM_FI_ContractBuilderController controller, EUR_CRM_Mechanic_Type__c mt,EUR_CRM_Contract_Activity_Item__c cai, List<EUR_CRM_Contract_Product_Item__c> cpis,
            String productAPIName, String wineSpiritName ){
            this.mechanicType = mt;
            this.mechanicTypeName = mt.Name;
            this.mechanicTypeId = mt.Id;
            this.mechanicTypeEnglishName = mt.EUR_CRM_Mechanic_Type_Name_English__c;
            this.allContractProductItems = cpis;
            this.productAPIName = productAPIName == null ? 'EUR_CRM_Brand_Quality__c' : productAPIName;
            this.controller = controller;
            this.productObject = productObject;
            this.wineSpiritName = wineSpiritName;
            this.existingProductLevelIds = this.getExistingProductLevelIds();
            this.contractActivityItem = cai == null ? this.makeCAI() : cai;

            this.sortContractProductItems(controller, this.mechanicType.EUR_CRM_External_ID__c);
            this.BbyId = new Map<Id, EUR_CRM_Brand__c>();
            this.bufferedBbyId = new Map<Id, EUR_CRM_Brand__c>();
            this.BQbyId = new Map<Id, EUR_CRM_Quality__c>();
            this.bufferedBQbyId = new Map<Id, EUR_CRM_Quality__c>();
            this.BQSbyId = new Map<Id, EUR_CRM_Size__c>();
            this.bufferedBQSbyId = new Map<Id, EUR_CRM_Size__c>();
            this.SKUbyId = new Map<Id,EUR_CRM_SKU__c >();
            this.bufferedSKUbyId = new Map<Id, EUR_CRM_SKU__c>();

            this.populateProductLevels();
            System.debug('\n productAPIName => ' + JSON.serializePretty(productAPIName) + '\n');
            System.debug('\n this.mechanicTypeEnglishName => ' + this.mechanicTypeEnglishName + '\n');
            System.debug('\n this.BbyId.size() => ' + this.BbyId.size() + '\n');
            System.debug('\n this.bufferedBbyId.size() => ' + this.bufferedBbyId.size() + '\n');
            System.debug('\n this.BQbyId.size() => ' + this.BQbyId.size() + '\n');
            System.debug('\n this.bufferedBQbyId.size() => ' + this.bufferedBQbyId.size() + '\n');
            System.debug('\n this.BQSbyId.size() => ' + this.BQSbyId.size() + '\n');
            System.debug('\n this.bufferedBQSbyId.size() => ' + this.bufferedBQSbyId.size() + '\n');
            System.debug('\n this.SKUbyId.size() => ' + this.SKUbyId.size() + '\n');
            System.debug('\n this.bufferedSKUbyId.size() => ' + this.bufferedSKUbyId.size() + '\n');

        }

        private Set<Id> getExistingProductLevelIds() {
            Set<Id> existingProductLevelIds = new Set<Id>();
            if(this.allContractProductItems == null) { return new Set<Id>(); }
            for(EUR_CRM_Contract_Product_Item__c p : this.allContractProductItems){
                Id prodLevelId = (Id) p.get(this.productAPIName);
                if (prodLevelId == null) { continue; }
                existingProductLevelIds.add(prodLevelId);
            }
            return existingProductLevelIds;
        }

        private void populateProductLevels() {
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand__c')) {
                this.BbyId = new Map<Id, EUR_CRM_Brand__c>(
                    (List<EUR_CRM_Brand__c>) this.getProductLevelsWhereWineSpiritName(this.controller.allBsByWSname)
                );
                this.bufferedBbyId = new Map<Id, EUR_CRM_Brand__c>((List<EUR_CRM_Brand__c>) this.bufferProductLevels(this.BbyId));
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality__c')) {
                this.BQbyId = new Map<Id, EUR_CRM_Quality__c>(
                    (List<EUR_CRM_Quality__c>) this.getProductLevelsWhereWineSpiritName(this.controller.allBQsByWSname)
                );
                this.bufferedBQbyId = new Map<Id, EUR_CRM_Quality__c>((List<EUR_CRM_Quality__c>) this.bufferProductLevels(this.BQbyId));
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality_Size__c')) {
                this.BQSbyId = new Map<Id, EUR_CRM_Size__c>(
                    (List<EUR_CRM_Size__c>) this.getProductLevelsWhereWineSpiritName(this.controller.allBQSsByWSname)
                );
                this.bufferedBQSbyId = new Map<Id, EUR_CRM_Size__c>((List<EUR_CRM_Size__c>) this.bufferProductLevels(this.BQSbyId));
                this.BQSs = this.BQSbyId.values();
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_SKU__c')) {
                this.SKUbyId = new Map<Id, EUR_CRM_SKU__c>(
                    (List<EUR_CRM_SKU__c>) this.getProductLevelsWhereWineSpiritName(this.controller.allSKUsByWSname)
                );
                this.bufferedSKUbyId = new Map<Id, EUR_CRM_SKU__c>((List<EUR_CRM_SKU__c>) this.bufferProductLevels(this.SKUbyId));
            }
        }

        private List<SObject> bufferProductLevels(Map<Id, SObject> prodLevById) {
            if (prodLevById.isEmpty()) { return new List<SObject>(); }

            List<SObject> bufferedProdLevels = new List<SObject>();
            for (Id existProdId : this.existingProductLevelIds) {
                if ( ! prodLevById.containsKey(existProdId)) { continue; }
                bufferedProdLevels.add(prodLevById.get(existProdId));
                prodLevById.remove(existProdId);
            }
            return bufferedProdLevels;
        }

        private List<SObject> getProductLevelsWhereWineSpiritName(Map<String, List<SObject>> allProductLevelsByWineSpiritName) {
            if ( ! allProductLevelsByWineSpiritName.containsKey(this.wineSpiritName)) {
                return this.getAllProductLevelById(allProductLevelsByWineSpiritName).values();
            }
            return allProductLevelsByWineSpiritName.get(this.wineSpiritName);
        }

        private Map<Id, SObject> getAllProductLevelById(Map<String, List<SObject>> productLevelsByWineSpiritName) {
            List<SObject> allProductLevels = new List<SObject>();
            for (List<SObject> productLevels : productLevelsByWineSpiritName.values()) {
                allProductLevels.addAll(productLevels);
            }
            return new Map<Id, SObject>( allProductLevels );
        }

        private EUR_CRM_Contract_Activity_Item__c makeCAI() {
            String itemType = '';
            String productLevel = '';
            if (controller.contractSettingByMTExtId.containsKey(this.mechanicType.EUR_CRM_External_ID__c)) {
                EUR_CRM_CTM_Contract_setting__mdt cs = controller.contractSettingByMTExtId.get(this.mechanicType.EUR_CRM_External_ID__c);
                itemType = String.isBlank(cs.EUR_CRM_Setting_Type__c) ? '' : cs.EUR_CRM_Setting_Type__c;
                productLevel = String.isBlank(cs.EUR_CRM_Product_level__c) ? '' : cs.EUR_CRM_Product_level__c;
            }
            return new EUR_CRM_Contract_Activity_Item__c(
                EUR_CRM_Contract__c = this.controller.contractObj.Id
            ,   EUR_CRM_Mechanic_Type__c = this.mechanicTypeId
            ,   EUR_CRM_Item_Type__c = itemType
            ,   EUR_CRM_Product_Level__c = productLevel
            );
        }

        private void sortContractProductItems(EUR_CRM_FI_ContractBuilderController controller, String mtExternalId) {
            // sort allContractProductItems based on the label names alphabetically
            EUR_CRM_CTM_Contract_setting__mdt cs = controller.contractSettingByMTExtId.get(mtExternalId);
            if ( ! this.isCPIsNeedToSort(controller, cs)) { return; }

            if ( ! controller.productFieldByProductLevel.containsKey(cs.EUR_CRM_Product_level__c)) { return; }
            String productField = controller.productFieldByProductLevel.get(cs.EUR_CRM_Product_level__c);
            this.sortList(this.allContractProductItems, productField.replace('__c', '__r'), 'asc');

            List<EUR_CRM_Contract_Product_Item__c> sortedProductItemsWithRetro = new List<EUR_CRM_Contract_Product_Item__c>();
            List<EUR_CRM_Contract_Product_Item__c> sortedProductItemsWithoutRetro =  new List<EUR_CRM_Contract_Product_Item__c>();

            // For each product item, check if they have retro or not
            for(EUR_CRM_Contract_Product_Item__c cpi: this.allContractProductItems) {
                if(cpi.EUR_CRM_Amount__c != 0.00) {
                    // For product items with retro, put it in the items with retro list
                    sortedProductItemsWithRetro.add(cpi);
                } else {
                    // For product items without retro, put it in the items without retro list
                    sortedProductItemsWithoutRetro.add(cpi);
                }
            }

            // Concatenate those 2 lists to get the final sorted list
            this.allContractProductItems = sortedProductItemsWithRetro;
            this.allContractProductItems.addAll(sortedProductItemsWithoutRetro);
        }

        private Boolean isCPIsNeedToSort(EUR_CRM_FI_ContractBuilderController controller, EUR_CRM_CTM_Contract_setting__mdt cs) {
            return this.isValidMTenglishName(controller)
                && ( ! this.isAllCPIsBlank())
                && cs != null
            ;
        }

        private Boolean isValidMTenglishName(EUR_CRM_FI_ContractBuilderController controller) {
            return this.mechanicTypeEnglishName == controller.POURING_REFUND_SPIRITS
                || this.mechanicTypeEnglishName == controller.SELECTION_BRANDS_SPIRITS
                || this.mechanicTypeEnglishName == controller.POURING_REFUND_WINES
                || this.mechanicTypeEnglishName == controller.SELECTION_BRANDS_WINES
            ;
        }

        private Boolean isAllCPIsBlank() {
            return this.allContractProductItems == null || this.allContractProductItems.isEmpty();
        }
        public void sortList(List<EUR_CRM_Contract_Product_Item__c> CPIs, String productField, String order) {
            List<EUR_CRM_Contract_Product_Item__c> resultList = new List<EUR_CRM_Contract_Product_Item__c>();

            //Create a map that can be used for sorting
            Map<Object, List<EUR_CRM_Contract_Product_Item__c>> objectMap = new Map<Object, List<EUR_CRM_Contract_Product_Item__c>>();

            for(EUR_CRM_Contract_Product_Item__c cpi : CPIs){
                if(cpi.getSObject(productField) == null) { continue; }

                if(objectMap.get(cpi.getSObject(productField).get('Name')) == null) {
                    objectMap.put(cpi.getSObject(productField).get('Name'), new List<EUR_CRM_Contract_Product_Item__c>());
                }
                objectMap.get(cpi.getSObject(productField).get('Name')).add(cpi);
            }

            //Sort the keys
            List<Object> keys = new List<Object>(objectMap.keySet());
            keys.sort();

            for(object key : keys){
                resultList.addAll(objectMap.get(key));
            }

            //Apply the sorted values to the source list
            CPIs.clear();
            if(order.toLowerCase() == 'asc'){
                for(EUR_CRM_Contract_Product_Item__c ob : resultList){
                    CPIs.add(ob);
                }
            }else if(order.toLowerCase() == 'desc'){
                for(integer i = resultList.size()-1; i >= 0; i--){
                    CPIs.add(resultList[i]);
                }
            }
        }

        public String getProductName(){
            if( String.isEmpty( productAPIName))
                return '';
            Integer l = productAPIName.length() - 3;
            return productAPIName.substring(0,l) + '__r.Name';
        }

        public List<EUR_CRM_Contract_Product_Item__c> getContractProductItems(){
            return allContractProductItems;
        }

        public void addProduct(Id productId){
            this.existingProductLevelIds.add(productId);
            if(this.allContractProductItems == null) { this.allContractProductItems = new List<EUR_CRM_Contract_Product_Item__c>(); }
            EUR_CRM_Contract_Product_Item__c prodItem = new EUR_CRM_Contract_Product_Item__c();
            prodItem.put(this.productAPIName,productId);
            System.debug('\n addProduct before allContractProductItems.size() => ' + allContractProductItems.size() + '\n');
            this.allContractProductItems.add(prodItem);
            System.debug('\n addProduct after allContractProductItems.size() => ' + allContractProductItems.size() + '\n');
            System.debug('\n addProduct productAPIName => ' + productAPIName + '\n');
            System.debug('\n addProduct productId => ' + productId + '\n');
            SObject removedSObj = this.removeProductLevelById(productId);
            System.debug('\n removedSObj => ' + JSON.serializePretty(removedSObj) + '\n');
        }

        private SObject removeProductLevelById(Id prodLevId) {
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand__c')) {
                return this.removeProductLevelFromMainMap(prodLevId, this.BbyId, this.bufferedBbyId);
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality__c')) {
                return this.removeProductLevelFromMainMap(prodLevId, this.BQbyId, this.bufferedBQbyId);
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality_Size__c')) {
                return this.removeProductLevelFromMainMap(prodLevId, this.BQSbyId, this.bufferedBQSbyId);
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_SKU__c')) {
                return this.removeProductLevelFromMainMap(prodLevId, this.SKUbyId, this.bufferedSKUbyId);
            }
            return null;
        }

        private SObject removeProductLevelFromMainMap(Id prodLevId, Map<Id, SObject> mainProdLevById, Map<Id, SObject> bufferedProdLevById) {
            if ( ! mainProdLevById.containsKey(prodLevId)) { return null; }
            SObject removedSObj = mainProdLevById.remove(prodLevId);
            bufferedProdLevById.put(prodLevId, removedSObj);
            return removedSObj;
        }

        public void removeProduct(Id productId, Integer index){
            Boolean bool = this.existingProductLevelIds.remove(productId);
            System.debug('\n removeProduct productId => ' + productId + '\n');
            System.debug('\n removeProduct index => ' + index + '\n');
            System.debug('\n removeProduct bool => ' + bool + '\n');
            System.debug('\n removeProduct before allContractProductItems.size() => ' + allContractProductItems.size() + '\n');
            SObject addedSobj = this.addProductLevelById(productId);
            System.debug('\n addedSobj => ' + JSON.serializePretty(addedSobj) + '\n');
            if (this.allContractProductItems == null) { return; }
            EUR_CRM_Contract_Product_Item__c product = this.allContractProductItems.remove(index);
            System.debug('\n product => ' + JSON.serializePretty(product) + '\n');
            System.debug('\n removeProduct after allContractProductItems.size() => ' + allContractProductItems.size() + '\n');
            if (product.id == null) { return; }
            if (this.deleteProducts == null) { this.deleteProducts = new List<EUR_CRM_Contract_Product_Item__c>(); }
            this.deleteProducts.add(product);

        }

        private SObject addProductLevelById(Id prodLevId) {
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand__c')) {
                return this.addProductLevelToMainMap(prodLevId, this.BbyId, this.bufferedBbyId);
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality__c')) {
                return this.addProductLevelToMainMap(prodLevId, this.BQbyId, this.bufferedBQbyId);
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_Brand_Quality_Size__c')) {
                return this.addProductLevelToMainMap(prodLevId, this.BQSbyId, this.bufferedBQSbyId);
            }
            if (this.productAPIName.equalsIgnoreCase('EUR_CRM_SKU__c')) {
                return this.addProductLevelToMainMap(prodLevId, this.SKUbyId, this.bufferedSKUbyId);
            }
            return null;
        }

        private SObject addProductLevelToMainMap(Id prodLevId, Map<Id, SObject> mainProdLevById, Map<Id, SObject> bufferedProdLevById) {
            if ( ! bufferedProdLevById.containsKey(prodLevId)) { return null; }
            SObject addedSObj = bufferedProdLevById.remove(prodLevId);
            mainProdLevById.put(prodLevId, addedSObj);
            return addedSObj;
        }

        //determine if the mechanic has products or lumpsum value.
        public Boolean hasValue(){
            return (allContractProductItems != null && allContractProductItems.size() > 0) ||
                (contractActivityItem != null && contractActivityItem.EUR_CRM_Lumpsum_Value__c !=null
                    && contractActivityItem.EUR_CRM_Lumpsum_Value__c > 0);
        }
        public Boolean getHasValue(){
            return hasValue();
        }
        public Boolean getHasLumpSumValue(){
            return  (contractActivityItem != null && contractActivityItem.EUR_CRM_Lumpsum_Value__c !=null);
        }

        public Boolean getHasVolumeValue(){
            Boolean hasVolume = false;
            if(allContractProductItems == null)
                return hasVolume;
            for(EUR_CRM_Contract_Product_Item__c prod:allContractProductItems){
                if(prod.EUR_CRM_Quantity__c != null && prod.EUR_CRM_Quantity__c > 0){
                    hasVolume = true;
                    break;
                }
            }
            return hasVolume;
        }

//        private void retrieveExistingContractEvents(){
//                List<EUR_CRM_Contract_Event__c> cEvents = new List<EUR_CRM_Contract_Event__c>();
//                Set<Id> products = this.existingProductLevelIds;
//                String mechTypeId = this.mechanicTypeId;
//                String query = 'select id from EUR_CRM_Contract_Mechanic__c where ';
//                query +=  this.productAPIName + ' in: products';
//                query += ' AND EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c =:mechTypeId';
//
//                String query2 = 'select EUR_CRM_Contract_Mechanic__r.'+productAPIName + ', EUR_CRM_Contract_Event__c, EUR_CRM_Contract_Event__r.Name, EUR_CRM_Contract_Event__r.id from EUR_CRM_Contract_Event_To_Prod_Mapping__c ';
//                        query2 += ' where EUR_CRM_Contract_Mechanic__c in (' + query + ') order by EUR_CRM_Contract_Event__r.Name asc';
//                 List<EUR_CRM_Contract_Event_To_Prod_Mapping__c> cEventProdMapping = (List<EUR_CRM_Contract_Event_To_Prod_Mapping__c>) Database.query(query2);
//                system.debug('@@ cEventProdMapping: ' + cEventProdMapping);
//                for(EUR_CRM_Contract_Event_To_Prod_Mapping__c mapping : cEventProdMapping){
//                    cEvents.add((EUR_CRM_Contract_Event__c) mapping.getSObject('EUR_CRM_Contract_Event__r'));
//
//                    if(productContractEventMap == null)
//                        productContractEventMap = new Map<String, EduTripProductWrapper>();
//                    EUR_CRM_Contract_Mechanic__c cm = (EUR_CRM_Contract_Mechanic__c) mapping.getSObject('EUR_CRM_Contract_Mechanic__r');
//                    String prodId = (String) cm.get(productAPIName);
//                    EduTripProductWrapper wrapper = productContractEventMap.get(prodId);
//                    if(wrapper == null){
//                        wrapper =  new EduTripProductWrapper(prodId,mechanicTypeId, productAPIName, new List<EUR_CRM_Contract_Event__c>());
//                        productContractEventMap.put(prodId,wrapper);
//                    }
//                    wrapper.contractEvents.add((EUR_CRM_Contract_Event__c) mapping.getSObject('EUR_CRM_Contract_Event__r'));
//                }
//        }

//        public String getProductActiveFlag(){
//            if( String.isEmpty( productAPIName))
//                return '';
//            Integer l = productAPIName.length() - 3;
//            return productAPIName.substring(0,l) + '__r.EUR_CRM_Active__c';
//        }
//        public List<SOBject> getSelectableProducts(){
//            List<SOBject> sProducts = new List<SOBject>();
//            String countryCode = controller.contractObj.EUR_CRM_Country_Code__c;
//            Set<Id> existingProducts = this.existingProductLevelIds;
//            Id mechanicTypeId = this.mechanicTypeId;
//            String activeFlag  = getProductActiveFlag();
//            String query = 'select EUR_CRM_Brand__c,  EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, EUR_CRM_SKU__c';
//             if(activeFlag != '')
//                query +=   ' , ' + activeFlag;
//                query +=' from EUR_CRM_Contract_Mechanic__c where EUR_CRM_Country_Code__c =: countryCode';
//                query += ' AND '+productAPIName + ' NOT IN : existingProducts';
//                query += ' AND EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c =:mechanicTypeId';
//            if(activeFlag != '')
//                query += ' AND '+activeFlag + ' = true';
//
//            return Database.query(query);
//        }

    }

 }