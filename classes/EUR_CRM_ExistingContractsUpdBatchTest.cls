@IsTest
private class EUR_CRM_ExistingContractsUpdBatchTest {

    @IsTest
    private static void existingContractsUpdatingBatchTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
            Name = 'Test Name',
            EUR_CRM_Channel__c = 'ON TRADE',
            EUR_CRM_Postal_Code__c = '02568',
            RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId()
            ,   EUR_CRM_Account__c = acc.Id
            ,   EUR_CRM_Status__c = 'Activated'
        );
        insert contract;

        EUR_CRM_Mechanic_Type__c mechanicType = new EUR_CRM_Mechanic_Type__c(
                EUR_CRM_External_ID__c = 'EUR_DE_Listing',
                EUR_CRM_Is_marketing_investment__c = true,
                Name = 'Listing'
        );
        insert mechanicType;

        EUR_CRM_Contract_Activity_Item__c cai1 = new EUR_CRM_Contract_Activity_Item__c(
                EUR_CRM_Contract__c = contract.Id,
                EUR_CRM_Mechanic_Type__c = mechanicType.Id,
                EUR_CRM_Amount_Year_1__c = 10
        );
        EUR_CRM_Contract_Activity_Item__c cai2 = new EUR_CRM_Contract_Activity_Item__c(
                EUR_CRM_Contract__c = contract.Id,
                EUR_CRM_Mechanic_Type__c = mechanicType.Id,
                EUR_CRM_Amount_Year_1__c = 10
        );
        insert new List<EUR_CRM_Contract_Activity_Item__c> {cai1, cai2};

        EUR_CRM_Quality__c quality = new EUR_CRM_Quality__c(
                RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Quality').getRecordTypeId(),
                EUR_CRM_Contributive_Margin_BQ__c = 1,
                EUR_CRM_Gross_Sales_per_Liters__c = 2
        );
        insert quality;

        EUR_CRM_Contract_Product_Item__c cpi1 = new EUR_CRM_Contract_Product_Item__c(
                EUR_CRM_Contract_Activity_Item__c = cai1.Id,
                EUR_CRM_Volume_lt__c = 5,
                EUR_CRM_Brand_Quality__c = quality.Id
        );
        EUR_CRM_Contract_Product_Item__c cpi2 = new EUR_CRM_Contract_Product_Item__c(
                EUR_CRM_Contract_Activity_Item__c = cai1.Id,
                EUR_CRM_Volume_lt__c = 5,
                EUR_CRM_Brand_Quality__c = quality.Id
        );
        insert new List<EUR_CRM_Contract_Product_Item__c> {cpi1, cpi2};

        Test.startTest();
        String soqlWhereCondition = 'EUR_CRM_Account__r.EUR_CRM_Country_Code__c = \'DE\' AND CreatedDate >= 2016-01-01T00:00:00.000Z';
        Database.executeBatch(new EUR_CRM_ExistingContractsUpdatingBatch(soqlWhereCondition));
        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> cai = [SELECT EUR_CRM_Item_Type__c, EUR_CRM_Product_level__c FROM EUR_CRM_Contract_Activity_Item__c WHERE Id = :cai1.Id];
        System.assertEquals('Listing', cai[0].EUR_CRM_Item_Type__c);
        System.assertEquals('EUR_CRM_Quality__c', cai[0].EUR_CRM_Product_level__c);

        List<EUR_CRM_Contract__c> contracts = [SELECT EUR_CRM_Total_Contributive_Margin__c, EUR_CRM_Total_Gross_Sales__c, EUR_CRM_Total_Non_Marketing_Year_1__c FROM EUR_CRM_Contract__c WHERE Id = :contract.Id];
        System.assertEquals(10, contracts[0].EUR_CRM_Total_Contributive_Margin__c);
        System.assertEquals(20, contracts[0].EUR_CRM_Total_Gross_Sales__c);
        System.assertEquals(20, contracts[0].EUR_CRM_Total_Non_Marketing_Year_1__c);
    }

}