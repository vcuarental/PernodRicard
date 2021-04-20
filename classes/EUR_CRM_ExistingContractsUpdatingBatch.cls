global without sharing class EUR_CRM_ExistingContractsUpdatingBatch implements Database.Batchable<sObject> {

    private String soqlWhereCondition;

    private static final Map<String, String> ITEM_TYPE_BY_MECHANICTYPE_ID = new  Map<String, String> {
            'EUR_DE_Drinks_Menu' => 'Marketing',
            'EUR_DE_Events' => 'Marketing',
            'EUR_DE_Napkins' => 'Marketing',
            'EUR_DE_Others' => 'Marketing',
            'EUR_DE_POS_WKZ' => 'Marketing',
            'EUR_DE_POS_Material' => 'Marketing',
            'EUR_DE_Training' => 'Marketing',
            'EUR_DE_Visibility_Branding' => 'Marketing',
            'EUR_DE_WKZ_Fix_Amount' => 'Marketing',
            'EUR_DE_House_Pouring' => 'Listing',
            'EUR_DE_Listing' => 'Listing',
            'EUR_DE_Pouring_Refund' => 'Pouring Refund',
            'DE_Drinks_Menu' => 'Marketing',
            'DE_Events' => 'Marketing',
            'DE_Napkins' => 'Marketing',
            'DE_Others' => 'Marketing',
            'DE_POS_WKZ' => 'Marketing',
            'DE_POS_Material' => 'Marketing',
            'DE_Training' => 'Marketing',
            'DE_Visibility_Branding' => 'Marketing',
            'DE_WKZ_Fix_Amount' => 'Marketing',
            'DE_Pouring_Refund' => 'Pouring Refund'
    };

    private static final Map<String, String> PRODUCT_LEVEL_BY_MECHANICTYPE_ID = new  Map<String, String> {
            'EUR_DE_Drinks_Menu' => 'EUR_CRM_Brand__c',
            'EUR_DE_Events' => 'EUR_CRM_Brand__c',
            'EUR_DE_Napkins' => 'EUR_CRM_Brand__c',
            'EUR_DE_Others' => 'EUR_CRM_Brand__c',
            'EUR_DE_POS_WKZ' => 'EUR_CRM_Brand__c',
            'EUR_DE_POS_Material' => 'EUR_CRM_Brand__c',
            'EUR_DE_Training' => 'EUR_CRM_Brand__c',
            'EUR_DE_Visibility_Branding' => 'EUR_CRM_Brand__c',
            'EUR_DE_WKZ_Fix_Amount' => 'EUR_CRM_Brand__c',
            'EUR_DE_House_Pouring' => 'EUR_CRM_Quality__c',
            'EUR_DE_Listing' => 'EUR_CRM_Quality__c',
            'EUR_DE_Pouring_Refund' => 'EUR_CRM_Quality__c',
            'DE_Drinks_Menu' => 'EUR_CRM_Brand__c',
            'DE_Events' => 'EUR_CRM_Brand__c',
            'DE_Napkins' => 'EUR_CRM_Brand__c',
            'DE_Others' => 'EUR_CRM_Brand__c',
            'DE_POS_WKZ' => 'EUR_CRM_Brand__c',
            'DE_POS_Material' => 'EUR_CRM_Brand__c',
            'DE_Training' => 'EUR_CRM_Brand__c',
            'DE_Visibility_Branding' => 'EUR_CRM_Brand__c',
            'DE_WKZ_Fix_Amount' => 'EUR_CRM_Brand__c',
            'DE_Pouring_Refund' => 'EUR_CRM_Quality__c'
    };

    public EUR_CRM_ExistingContractsUpdatingBatch(String soqlWhereCondition) {
        this.soqlWhereCondition = soqlWhereCondition;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query =
                'SELECT Id, EUR_CRM_Total_Contributive_Margin__c, EUR_CRM_Total_Gross_Sales__c, EUR_CRM_Total_Non_Marketing_Year_1__c ' +
                        'FROM EUR_CRM_Contract__c ' +
                        'WHERE ' + '('+ soqlWhereCondition +')';

        System.debug('EUR_CRM_ExistingContractsUpdatingBatch start query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id, EUR_CRM_Contract__c> contracts = new Map<Id, EUR_CRM_Contract__c>((List<EUR_CRM_Contract__c>)scope);
        Map<Id, EUR_CRM_Contract__c> contractsForUpdate = new Map<Id, EUR_CRM_Contract__c>();
        Map<Id, EUR_CRM_Contract_Activity_Item__c> activityItemForUpdate = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();

        for(EUR_CRM_Contract_Activity_Item__c cai :[
                SELECT Id, EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c, EUR_CRM_Item_Type__c, EUR_CRM_Product_level__c
                FROM EUR_CRM_Contract_Activity_Item__c
                WHERE EUR_CRM_Contract__c IN :contracts.keySet()
        ]) {
            String itemType = ITEM_TYPE_BY_MECHANICTYPE_ID.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
            if(cai.EUR_CRM_Item_Type__c !=  itemType) {
                cai.EUR_CRM_Item_Type__c =  itemType;
                activityItemForUpdate.put(cai.Id, cai);
            }
            String productLevel = PRODUCT_LEVEL_BY_MECHANICTYPE_ID.get(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
            if(cai.EUR_CRM_Product_level__c !=  productLevel) {
                cai.EUR_CRM_Product_level__c =  productLevel;
                activityItemForUpdate.put(cai.Id, cai);
            }
        }
        update activityItemForUpdate.values();

        for(AggregateResult ar : [
                SELECT EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c,
                        SUM(EUR_CRM_Contributive_Margin__c) Contributive_Margin,
                        SUM(EUR_CRM_Gross_Sales__c) Gross_Sales
                FROM EUR_CRM_Contract_Product_Item__c
                WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c IN :contracts.keySet()
                GROUP BY EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c
        ]) {
            EUR_CRM_Contract__c contract = contracts.get((Id)ar.get('EUR_CRM_Contract__c'));
            Decimal contributiveMarginSum = (Decimal) ar.get('Contributive_Margin');
            if(contract.EUR_CRM_Total_Contributive_Margin__c != contributiveMarginSum) {
                contract.EUR_CRM_Total_Contributive_Margin__c = contributiveMarginSum;
                contractsForUpdate.put(contract.Id, contract);
            }
            Decimal grossSalesSum = (Decimal) ar.get('Gross_Sales');
            if(contract.EUR_CRM_Total_Gross_Sales__c != grossSalesSum) {
                contract.EUR_CRM_Total_Gross_Sales__c = grossSalesSum;
                contractsForUpdate.put(contract.Id, contract);
            }
        }
        for(AggregateResult ar : [
                SELECT EUR_CRM_Contract__c,
                        SUM(EUR_CRM_Non_Marketing_Year_1__c) Non_Marketing_Year_SUM
                FROM EUR_CRM_Contract_Activity_Item__c
                WHERE EUR_CRM_Contract__c IN :contracts.keySet()
                GROUP BY EUR_CRM_Contract__c
        ]) {
            EUR_CRM_Contract__c contract = contracts.get((Id)ar.get('EUR_CRM_Contract__c'));
            Decimal nonMarketingYearSUM = (Decimal) ar.get('Non_Marketing_Year_SUM');
            if(contract.EUR_CRM_Total_Non_Marketing_Year_1__c != nonMarketingYearSUM) {
                contract.EUR_CRM_Total_Non_Marketing_Year_1__c = nonMarketingYearSUM;
                contractsForUpdate.put(contract.Id, contract);
            }
        }
        update contractsForUpdate.values();
    }

    global void finish(Database.BatchableContext BC){

    }
}