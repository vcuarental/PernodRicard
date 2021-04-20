global without sharing class EUR_CRM_FI_ContractsUpdatingBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {

    private static final Map<String, String> ITEM_TYPE_BY_MT_EXT_ID = new  Map<String, String> {
        'EUR_FI_Education' => 'Marketing',
        'EUR_FI_Free_Stock' => 'Marketing',
        'EUR_FI_Mktg_Activity_Spirits' => 'Marketing',
        'EUR_FI_Mktg_Activity_Wines' => 'Marketing',
        'EUR_FI_Pouring_Refund_Spirits' => 'Listing',
        'EUR_FI_Pouring_Refund_Wines' => 'Listing',
        'EUR_FI_Selection_Brands_Spirits' => 'Listing',
        'EUR_FI_Selection_Brands_Wines' => 'Listing',
        'EUR_FI_Trips' => 'Marketing'
    };

    private static final Map<String, String> PRODUCT_LEVEL_BY_MT_EXT_ID = new  Map<String, String> {
        'EUR_FI_Education' => 'EUR_CRM_Brand__c',
        'EUR_FI_Free_Stock' => 'EUR_CRM_Quality__c',
        'EUR_FI_Mktg_Activity_Spirits' => 'EUR_CRM_Brand__c',
        'EUR_FI_Mktg_Activity_Wines' => 'EUR_CRM_Brand__c',
        'EUR_FI_Pouring_Refund_Spirits' => 'EUR_CRM_Size__c',
        'EUR_FI_Pouring_Refund_Wines' => 'EUR_CRM_SKU__c',
        'EUR_FI_Selection_Brands_Spirits' => 'EUR_CRM_Size__c',
        'EUR_FI_Selection_Brands_Wines' => 'EUR_CRM_Brand__c',
        'EUR_FI_Trips' => 'EUR_CRM_Brand__c'
    };
    private static final Map<String, RecordTypeInfo> CAI_RT_INFO_BY_DEV_NAME = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName();
    private static final Map<String, RecordTypeInfo> CPI_RT_INFO_BY_DEV_NAME = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName();

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id
            ,   EUR_CRM_Item_Type__c
            ,   EUR_CRM_Product_level__c
            ,   EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
            ,   EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c
            ,   EUR_CRM_Total_Gross_Sales__c
            ,   EUR_CRM_Total_Retro_FI__c
            ,   EUR_CRM_Contract__c
            ,   (
                SELECT Id
                ,   EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
                ,   EUR_CRM_Profit__c
                ,   EUR_CRM_Marketing_Amount__c
                ,   EUR_CRM_Quantity__c
                ,   EUR_CRM_Volume_Btl__c
                ,   EUR_CRM_Gross_SalesBtl__c
                FROM Contract_Product_Items__r
            )
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__r.EUR_CRM_Country_Code__c = 'FI'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<EUR_CRM_Contract_Activity_Item__c> scope){
        Map<Id, EUR_CRM_Contract_Activity_Item__c> caiById = new Map<Id, EUR_CRM_Contract_Activity_Item__c>(scope);
        System.debug('\n caiById.size() => ' + caiById.size() + '\n');
        Map<Id, EUR_CRM_Contract_Activity_Item__c> caisToUpdate = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();

        RecordTypeInfo caiRtInfo = CAI_RT_INFO_BY_DEV_NAME.get('EUR_FI_Contract_Activity_Item');
        RecordTypeInfo cpiRtInfo = CPI_RT_INFO_BY_DEV_NAME.get('EUR_FI_Contract_Product_Item');
        Map<Id, EUR_CRM_Contract_Product_Item__c> cpisToUpdateById = this.updateCpis(caiById, cpiRtInfo);
        System.debug('\n cpisToUpdateById.size() => ' + cpisToUpdateById.size() + '\n');
        System.debug('\n cpisToUpdateById => ' + JSON.serializePretty(cpisToUpdateById) + '\n');
        this.upsertRecords(cpisToUpdateById.values());

        Map<Id, EUR_CRM_Contract_Activity_Item__c> caisToUpdateById = this.updateCais(caiById, caiRtInfo);
        System.debug('\n caisToUpdateById.size() => ' + caisToUpdateById.size() + '\n');
        System.debug('\n caisToUpdateById => ' + JSON.serializePretty(caisToUpdateById) + '\n');
        this.upsertRecords(caisToUpdateById.values());

        Map<Id, EUR_CRM_Contract_Activity_Item__c> updatedCaiById = new Map<Id, EUR_CRM_Contract_Activity_Item__c>(this.selectCaisWhereIds(caiById.values()));
        List<EUR_CRM_Contract__c> contractToUpdate = this.updateContractsWhereIds(updatedCaiById);
        System.debug('\n contractToUpdate.size() => ' + contractToUpdate.size() + '\n');
        System.debug('\n contractToUpdate => ' + JSON.serializePretty(contractToUpdate) + '\n');
        this.upsertRecords(contractToUpdate);
    }

    global override void finish(Database.BatchableContext bc) {
        super.finish(bc);
    }


    /* ========================================================= */
    /*      High Level Helpers
    /* ========================================================= */
    private Map<Id, EUR_CRM_Contract_Product_Item__c> updateCpis(Map<Id, EUR_CRM_Contract_Activity_Item__c> caiById, RecordTypeInfo cpiRtInfo) {
        Map<Id, EUR_CRM_Contract_Product_Item__c> cpisToUpdate = new Map<Id, EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Contract_Product_Item__c cpi : this.selectCPIsWhereCAIs(caiById.values())) {
            System.debug('\n cpi => ' + JSON.serializePretty(cpi) + '\n');
            if (cpiRtInfo != null) {
                cpi.RecordTypeId = cpiRtInfo.getRecordTypeId();
                cpisToUpdate.put(cpi.Id, cpi);
            }
            if (cpi.EUR_CRM_Volume_Btl__c == null || cpi.EUR_CRM_Volume_Btl__c == 0) {
                cpi.EUR_CRM_Volume_Btl__c = cpi.EUR_CRM_Quantity__c;
                cpisToUpdate.put(cpi.Id, cpi);
            }
        }
        return cpisToUpdate;
    }

    private Map<Id, EUR_CRM_Contract_Activity_Item__c> updateCais(Map<Id, EUR_CRM_Contract_Activity_Item__c> caiById, RecordTypeInfo caiRtInfo) {
        Map<Id, EUR_CRM_Contract_Activity_Item__c> caisToUpdate = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
        Map<Id, EUR_CRM_Contract_Activity_Item__c> caiWithUpdatedCpiById = new Map<Id, EUR_CRM_Contract_Activity_Item__c>(this.selectCaisWhereIds(caiById.values()));
        for (EUR_CRM_Contract_Activity_Item__c cai : caiWithUpdatedCpiById.values()) {
            if (caiRtInfo != null) {
                cai.RecordTypeId = caiRtInfo.getRecordTypeId();
                caisToUpdate.put(cai.Id, cai);
            }
            String itemType = ITEM_TYPE_BY_MT_EXT_ID.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
            if (itemType != null && cai.EUR_CRM_Item_Type__c != itemType) {
                cai.EUR_CRM_Item_Type__c = itemType;
                caisToUpdate.put(cai.Id, cai);
            }
            String productLevel = PRODUCT_LEVEL_BY_MT_EXT_ID.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
            if (productLevel != null && cai.EUR_CRM_Product_level__c != productLevel) {
                cai.EUR_CRM_Product_level__c = productLevel;
                caisToUpdate.put(cai.Id, cai);
            }
            Decimal totalGrossSales = this.updateCaisTotalGrossSales(cai);
            if (cai.EUR_CRM_Total_Gross_Sales__c != totalGrossSales) {
                cai.EUR_CRM_Total_Gross_Sales__c = totalGrossSales;
                caisToUpdate.put(cai.Id, cai);
            }
        }
        return caisToUpdate;
    }

    private List<EUR_CRM_Contract__c> updateContractsWhereIds(Map<Id, EUR_CRM_Contract_Activity_Item__c> updatedCaiById) {
        List<EUR_CRM_Contract__c> contracts = this.selectContractsWhereCAIs(updatedCaiById.values());
        List<EUR_CRM_Contract__c> contractToUpdate = new List<EUR_CRM_Contract__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            Decimal contractProfit = 0;
            Decimal generalGrossSales = 0;
            Decimal totalRetroFi = 0;
            Decimal totalRetroEducation = 0;
            for (EUR_CRM_Contract_Activity_Item__c cai : contract.EUR_CRM_Contract_Activity_Items__r) {
                System.debug('\n cai => ' + JSON.serializePretty(cai) + '\n');
                if ( ! updatedCaiById.containsKey(cai.Id)) { continue; }
                EUR_CRM_Contract_Activity_Item__c updatedCai = updatedCaiById.get(cai.Id);
                for (EUR_CRM_Contract_Product_Item__c cpi : updatedCai.Contract_Product_Items__r) {
                    contractProfit += EUR_CRM_FI_ProfitCalculatorExt.calculateTotalCMByRow(cpi);
                }
                generalGrossSales = this.summarizeValue(generalGrossSales, updatedCai.EUR_CRM_Total_Gross_Sales__c);
                totalRetroFi = this.summarizeValue(totalRetroFi, cai.EUR_CRM_Total_Retro_FI__c);
                if (updatedCai.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c == 'Education') {
                    totalRetroEducation = this.summarizeValue(totalRetroEducation, updatedCai.EUR_CRM_Total_Retro_FI__c);
                }
            }
            contract.EUR_CRM_Contract_Profit__c = contractProfit;
            contract.EUR_CRM_General_Gross_Sales__c = generalGrossSales;
            contract.EUR_CRM_Total_Retro_FI__c = totalRetroFi;
            contract.EUR_CRM_Total_Retro_ex_Education_FI__c = totalRetroFi - totalRetroEducation;
            contractToUpdate.add(contract);
        }
        return contractToUpdate;
    }


    /* ========================================================= */
    /*      Middle Level Helpers
    /* ========================================================= */
    private Decimal updateCaisTotalGrossSales(EUR_CRM_Contract_Activity_Item__c cai) {
        Decimal caiTotalGrossSales = 0;
        for (EUR_CRM_Contract_Product_Item__c cpi : cai.Contract_Product_Items__r) {
            caiTotalGrossSales += cpi.EUR_CRM_Gross_SalesBtl__c;
        }
        return caiTotalGrossSales;
    }


    /* ========================================================= */
    /*      Low Level Helpers
    /* ========================================================= */
    private Decimal summarizeValue(Decimal total, Decimal val) {
        return val != null ? (total + val) : total;
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Contract__c> selectContractsWhereCAIs(List<EUR_CRM_Contract_Activity_Item__c> cais) {
        return [
            SELECT Id
            ,   EUR_CRM_Contract_Profit__c
            ,   EUR_CRM_General_Gross_Sales__c
            ,   EUR_CRM_Total_Retro_FI__c
            ,   (
                SELECT Id
                ,   EUR_CRM_Contract_Profit_per_Activity__c
                ,   EUR_CRM_Total_Gross_Sales__c
                ,   EUR_CRM_Total_Retro_FI__c
                ,   EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
                FROM EUR_CRM_Contract_Activity_Items__r)
            FROM EUR_CRM_Contract__c
            WHERE Id IN (
                SELECT EUR_CRM_Contract__c
                FROM EUR_CRM_Contract_Activity_Item__c
                WHERE Id IN :cais
            )
            AND EUR_CRM_Status__c != 'Cancelled'
//            AND EUR_CRM_Contact__r.EUR_CRM_Account__c != NULL
            FOR UPDATE
        ];
    }

    private List<EUR_CRM_Contract_Product_Item__c> selectCPIsWhereCAIs(List<EUR_CRM_Contract_Activity_Item__c> cais) {
        return [
            SELECT Id
            ,   EUR_CRM_Contract_Activity_Item__c
            ,   EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c
            ,   EUR_CRM_Profit__c
            ,   EUR_CRM_Marketing_Amount__c
            ,   EUR_CRM_Quantity__c
            ,   EUR_CRM_Volume_Btl__c
            FROM EUR_CRM_Contract_Product_Item__c
            WHERE
            EUR_CRM_Contract_Activity_Item__c IN :cais
        ];
    }

    private List<EUR_CRM_Contract_Activity_Item__c> selectCaisWhereIds(List<EUR_CRM_Contract_Activity_Item__c> cais) {
        return [
            SELECT Id
                ,   EUR_CRM_Item_Type__c
                ,   EUR_CRM_Product_level__c
                ,   EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
                ,   EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c
                ,   EUR_CRM_Total_Gross_Sales__c
                ,   EUR_CRM_Total_Retro_FI__c
                ,   EUR_CRM_Contract__c
                ,   (
                SELECT Id
                    ,   EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
                    ,   EUR_CRM_Profit__c
                    ,   EUR_CRM_Marketing_Amount__c
                    ,   EUR_CRM_Quantity__c
                    ,   EUR_CRM_Volume_Btl__c
                    ,   EUR_CRM_Gross_SalesBtl__c
                FROM Contract_Product_Items__r
            )
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE Id IN :cais
        ];
    }
}