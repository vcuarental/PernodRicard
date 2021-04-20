public with sharing class EUR_CRM_FI_ProfitCalculatorExt {
    public final String EDUCATION = 'Education';

    public EUR_CRM_Contract__c contractObj{get; set;}

    private ApexPages.StandardController standardController {get;set;}
    private Id contractId {
        get{if (this.standardController!=null){
                return this.standardController.getId();                                 
        }   
        return null;
    }}

    public EUR_CRM_ContractClass contractClassObject {get; private set;}

    public Map<Id,EUR_CRM_Mechanic_Type__c> mechanicTypeMap = new Map<Id,EUR_CRM_Mechanic_Type__c>();

    public Map<String,  List<EUR_CRM_Contract_Product_Item__c>> contractActivityItemsMap {get;set;}

    private static Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingByMtExtId {
        get{
            if (contractSettingByMtExtId == null) {
                contractSettingByMtExtId = getContractSettingsByMtExtId();
            }
            return contractSettingByMtExtId;
        }
        set;
    }

    public List<ProfitCalculatorWrapper2> profCalculatorWrapList2 {get;set;}
    public String thousandSep {get;set;}
    public String decimalSep {get;set;}

    public EUR_CRM_FI_ProfitCalculatorExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.contractObj = (EUR_CRM_Contract__c )standardController.getRecord();

        //Init Contract
        this.contractClassObject = new EUR_CRM_ContractClass(contractId);

        //Init MechanicTypeMap
        retrieveMechanicTypes();

        //Init Wrapper
        buildProfitCalculatorWrapper(contractId);
        Decimal value = 1000.10;
        String formattedValue = value.format();
        this.thousandSep = formattedValue.substring(1,2);
        this.decimalSep = formattedValue.substring(5,6);

        
    }

    public void buildProfitCalculatorWrapper(Id contractId){
        contractActivityItemsMap = new Map<String,  List<EUR_CRM_Contract_Product_Item__c>>();
        profCalculatorWrapList2 = new List<ProfitCalculatorWrapper2>();
        Map<Id,  List<EUR_CRM_Contract_Product_Item__c>> cpisByMechTypeId = new Map<Id,  List<EUR_CRM_Contract_Product_Item__c>>();

        cpisByMechTypeId = EUR_CRM_FI_UtilClass.retrieveContractProductLineItems(contractId);

        System.debug('FLAG - ITEMS: '+ cpisByMechTypeId);

        List<EUR_CRM_Contract_Activity_Item__c> cais = this.selectCAIsWhereContractId(contractId);
        for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
            System.debug('&&KEY: '+ cai.Id);
            System.debug('&&KEY2: '+ cpisByMechTypeId.containskey(cai.EUR_CRM_Mechanic_Type__c));
            if(cpisByMechTypeId.containskey(cai.EUR_CRM_Mechanic_Type__c)){
                for(EUR_CRM_Contract_Product_Item__c cpi : cpisByMechTypeId.get(cai.EUR_CRM_Mechanic_Type__c)){
                    profCalculatorWrapList2.add(new ProfitCalculatorWrapper2(cpi));
                }
            }
        }
        
    }

    private List<EUR_CRM_Contract_Activity_Item__c> selectCAIsWhereContractId(Id contractId) {
        return [
            SELECT Id
                , EUR_CRM_Mechanic_Type__c
                , EUR_CRM_Mechanic_Type__r.Name
                , EUR_CRM_Lumpsum_Value__c
                , EUR_CRM_Mktg_Package_Mechanic_Handling__c
                , EUR_CRM_Total_Retro_FI__c
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c = :contractId
            AND EUR_CRM_Mechanic_Type__r.Name <> :EDUCATION
            ORDER BY EUR_CRM_Mechanic_Type__r.EUR_CRM_Display_Order__c
        ];
    }

    private void retrieveMechanicTypes() {
        mechanicTypeMap = new  Map<Id, EUR_CRM_Mechanic_Type__c>();        
        for (EUR_CRM_Mechanic_Type__c mechanic: [SELECT Id, Name, EUR_CRM_Grouping_Name__c, 
                                                EUR_CRM_Mechanic_Process_Type__c, EUR_CRM_Country_Code__c, 
                                                EUR_CRM_Has_Lump_Sum__c, EUR_CRM_Has_Per_BQ__c,
                                                EUR_CRM_Mechanic_Type_Name_English__c
                                                FROM EUR_CRM_Mechanic_Type__c
                                                WHERE EUR_CRM_Country_Code__c =: contractClassObject.contractDetails.EUR_CRM_Country_Code__c
                                             
                                                LIMIT 49999]){
            mechanicTypeMap.put(mechanic.Id, mechanic);
        }
        
        System.debug('Flag - Retrieve mechanicTypeMap:' + mechanicTypeMap); 
    } 

    public class ProfitCalculatorWrapper2{

        public final String POURING_REFUND_SPIRITS = 'Pouring Refund Spirits';
        public final String POURING_REFUND_WINES = 'Pouring Refund Wines';
        public final String SELECTION_BRANDS_SPIRITS = 'Selection Brands Spirits';
        public final String SELECTION_BRANDS_WINES = 'Selection Brands Wines';
        public final String MARKETING_ACTIVITY_SPIRITS= 'Marketing Activity Spirits';
        public final String MARKETING_ACTIVITY_WINES = 'Marketing Activity Wines';
        public final String TRIPS = 'Trips';
        public final String EDUCATION = 'Education';
        public final String FREE_STOCK = 'Free stock';
        public final Set<String> MARKETING_GROUP_NAME = new Set<String>{MARKETING_ACTIVITY_SPIRITS,MARKETING_ACTIVITY_WINES,TRIPS,EDUCATION,FREE_STOCK};

        public String sourceName {get;set;}
        public String itemName {get;set;}
        public Decimal volBottles {get;set;}
        public Decimal totalGrossSales {get;set;}
        public Decimal grossSalesBottles {get;set;}
        public Decimal cMargin {get;set;}
        public Decimal totalVolperCMargin {get;set;}
        public Decimal retroBottles {get;set;}
        public Decimal totalRetroBottles {get;set;}
        public Decimal netSalesBottles {get;set;}
        public Decimal totalRetroperCMargin {get;set;}
        public Decimal totalCM {get;set;}
        public Decimal lumpSum {get;set;}
        public Decimal totalCMByRow {get;set;}
        public Decimal CM_NS_Percents {get;set;}

        public ProfitCalculatorWrapper2(EUR_CRM_Contract_Product_Item__c productItem) {

            System.debug('\n productItem => ' + JSON.serializePretty(productItem) + '\n');
            sourceName = productItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name;
            if (sourceName == POURING_REFUND_SPIRITS) {
                itemName = productItem.EUR_CRM_Brand_Quality_Size__r.Name;
                if (productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c != null) {
                    cMargin = productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == POURING_REFUND_WINES) {
                itemName = productItem.EUR_CRM_SKU__r.Name;
                if (productItem.EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c != null) {
                    cMargin = productItem.EUR_CRM_SKU__r.EUR_CRM_Contributive_Margin_SKU__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_SKU__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == SELECTION_BRANDS_SPIRITS) {
                itemName = productItem.EUR_CRM_Brand_Quality_Size__r.Name;
                if (productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c != null) {
                    cMargin = productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == SELECTION_BRANDS_WINES) {
                itemName = productItem.EUR_CRM_Brand__r.Name;
                if (productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c != null) {
                    cMargin = productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == MARKETING_ACTIVITY_SPIRITS) {
                itemName = productItem.EUR_CRM_Brand__r.Name;
                if (productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c != null) {
                    cMargin = productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == MARKETING_ACTIVITY_WINES) {
                itemName = productItem.EUR_CRM_Brand__r.Name;
                if (productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c != null) {
                    cMargin = productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == TRIPS) {
                itemName = productItem.EUR_CRM_Brand__r.Name;
                if (productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c != null) {
                    cMargin = productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == EDUCATION) {
                itemName = productItem.EUR_CRM_Brand__r.Name;
                if (productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c != null) {
                    cMargin = productItem.EUR_CRM_Brand__r.EUR_CRM_Contributive_Margin_Brand__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand__r.EUR_CRM_Gross_sales_Btl__c;
            }
            if (sourceName == FREE_STOCK) {
                itemName = productItem.EUR_CRM_Brand_Quality__r.Name;
                if (productItem.EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c != null) {
                    cMargin = productItem.EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c;
                }
                this.grossSalesBottles = productItem.EUR_CRM_Brand_Quality__r.EUR_CRM_Gross_Sales_per_Liters__c;
            }

            if (cMargin != null) {
                //cMargin = cMargin.setScale(2);
                if (!MARKETING_GROUP_NAME.contains(sourceName)) {
//                        cMargin = cMargin.setScale(2);
                } else {
                    cMargin = null;
                }
            }

            if (productItem.EUR_CRM_Volume_Btl__c == 0) {
                volBottles = null;
            } else {
                volBottles = productItem.EUR_CRM_Volume_Btl__c;
            }

            if (productItem.EUR_CRM_Gross_SalesBtl__c == 0) {
                this.totalGrossSales = null;
            } else {
                totalGrossSales = productItem.EUR_CRM_Gross_SalesBtl__c;
            }

            if (cMargin != null && volBottles != null) {
                totalVolperCMargin = volBottles * cMargin;
            }
            retroBottles = productItem.EUR_CRM_Amount__c;
            if (MARKETING_GROUP_NAME.contains(sourceName)) {
                retroBottles = null;
            }

            if (this.volBottles != null && this.retroBottles != null) {
                this.totalRetroBottles = this.volBottles * this.retroBottles;
            }

            if (this.isBlank(productItem.EUR_CRM_Amount__c)) {
                this.totalRetroBottles = productItem.EUR_CRM_Marketing_Amount__c == null ? 0 : productItem.EUR_CRM_Marketing_Amount__c;
            }

            if (this.grossSalesBottles != null && this.retroBottles != null) {
                this.netSalesBottles = this.grossSalesBottles - this.retroBottles;
            }

            this.totalRetroperCMargin = productItem.EUR_CRM_Profit_Btl__c;


            if (totalRetroperCMargin != null && volBottles != null) {
                totalCM = totalRetroperCMargin * volBottles;
            }

            if (MARKETING_GROUP_NAME.contains(sourceName)) {
                if (productItem.EUR_CRM_Marketing_Amount__c != 0) {
                    lumpSum = productItem.EUR_CRM_Marketing_Amount__c;
                }
            }

            if (productItem != null) {
                this.totalCMByRow = calculateTotalCMByRow(productItem);
                this.CM_NS_Percents = productItem.EUR_CRM_CM_NS__c == null ? 0 : productItem.EUR_CRM_CM_NS__c;
            }
        }

        private Boolean isBlank(Decimal dec) {
            return dec == null || dec == 0;
        }
    }

    public static Decimal calculateTotalCMByRow(EUR_CRM_Contract_Product_Item__c productItem) {
        Decimal totalCMByRow = 0;
        String caiMtExtId = productItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
        if (!contractSettingByMtExtId.containsKey(caiMtExtId) || caiMtExtId == 'EUR_FI_Education') { return 0; }

        EUR_CRM_CTM_Contract_setting__mdt cs = contractSettingByMtExtId.get(caiMtExtId);
        if (cs.EUR_CRM_Is_profitable__c) {
            totalCMByRow = productItem.EUR_CRM_Profit__c == null ? 0 : productItem.EUR_CRM_Profit__c;
        } else {
            totalCMByRow = productItem.EUR_CRM_Marketing_Amount__c == null ? 0 : (-productItem.EUR_CRM_Marketing_Amount__c);
        }
        return totalCMByRow;
    }

    private static Map<String, EUR_CRM_CTM_Contract_setting__mdt> getContractSettingsByMtExtId() {
        List<EUR_CRM_CTM_Contract_setting__mdt> contractSettings = selectContractSettings();
        if (contractSettings.isEmpty()) { return new Map<String, EUR_CRM_CTM_Contract_setting__mdt>(); }

        Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingByMtExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();
        for (EUR_CRM_CTM_Contract_setting__mdt cs : contractSettings) {
            contractSettingByMtExtId.put(cs.EUR_CRM_Mechanic_ExtID__c, cs);
        }
        return contractSettingByMtExtId;
    }

    private static List<EUR_CRM_CTM_Contract_setting__mdt> selectContractSettings() {
        return [
            SELECT EUR_CRM_Country_Code__c
            ,   EUR_CRM_Is_profitable__c
            ,   EUR_CRM_Mechanic_ExtID__c
            FROM EUR_CRM_CTM_Contract_setting__mdt
            WHERE EUR_CRM_Country_Code__c = 'FI'
            ORDER BY DeveloperName

        ];
    }

   
}