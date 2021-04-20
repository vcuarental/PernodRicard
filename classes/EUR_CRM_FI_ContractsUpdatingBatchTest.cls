@IsTest(IsParallel = true)
private class EUR_CRM_FI_ContractsUpdatingBatchTest {
    @IsTest
    private static void existingContractsUpdatingBatchTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_FI_Direct_On_Trade').getRecordTypeId()
        );
        insert acc;

        Contact contact = new Contact(
            LastName = 'test',
            EUR_CRM_Account__c = acc.Id
        );
        insert contact;

            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
                RecordTypeId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_FI_Independent_Contract').getRecordTypeId()
                ,   EUR_CRM_Account__c = acc.Id
                ,   EUR_CRM_Status__c = 'Activated'
                ,   EUR_cRM_Contact__c = contact.Id
        );
        insert contract;

        EUR_CRM_Mechanic_Type__c mechanicType = new EUR_CRM_Mechanic_Type__c(
                EUR_CRM_External_ID__c = 'EUR_FI_Pouring_Refund_Wines',
                EUR_CRM_Is_marketing_investment__c = true,
                Name = 'Pouring Refund Wines'
        );
        insert mechanicType;

        Test.startTest();

        EUR_CRM_Contract_Activity_Item__c cai1 = new EUR_CRM_Contract_Activity_Item__c(
            EUR_CRM_Contract__c = contract.Id,
            EUR_CRM_Mechanic_Type__c = mechanicType.Id,
            EUR_CRM_Profit__c = 150
//            EUR_CRM_Total_Gross_Sales__c = 200

        );
        insert new List<EUR_CRM_Contract_Activity_Item__c> {cai1};

        EUR_CRM_Brand__c b = new EUR_CRM_Brand__c(
            EUR_CRM_Gross_sales_Btl__c = 10
        );
        insert b;

        EUR_CRM_Contract_Product_Item__c cpi1 = new EUR_CRM_Contract_Product_Item__c(
                EUR_CRM_Contract_Activity_Item__c = cai1.Id,
                EUR_CRM_Quantity__c = 5,
                EUR_CRM_Marketing_Amount__c = 50,
                EUR_CRM_Amount__c = 70,
                EUR_CRM_Volume_Btl__c = 70,
                EUR_CRM_Brand__c = b.Id
        );

        insert new List<EUR_CRM_Contract_Product_Item__c> {cpi1};
        List<EUR_CRM_Contract_Product_Item__c> cpisInserted = selectCPIs();
        List<EUR_CRM_Contract_Activity_Item__c> caiInserted = selectCAIs();
        System.debug('\n caiInserted.size() => ' + caiInserted.size() + '\n');
        System.debug('\n caiInserted => ' + JSON.serializePretty(caiInserted) + '\n');
        System.debug('\n cpisInserted.size() => ' + cpisInserted.size() + '\n');
        System.debug('\n cpisInserted => ' + JSON.serializePretty(cpisInserted) + '\n');

        Database.executeBatch(new EUR_CRM_FI_ContractsUpdatingBatch());

        Test.stopTest();

        List<EUR_CRM_Contract_Activity_Item__c> cai = selectCAIs();
        System.debug('\n cai.size() => ' + cai.size() + '\n');
        System.debug('\n cai => ' + JSON.serializePretty(cai) + '\n');

        System.assertEquals('Listing', cai[0].EUR_CRM_Item_Type__c);
        System.assertEquals('EUR_CRM_SKU__c', cai[0].EUR_CRM_Product_level__c);
        System.assertEquals('EUR_FI_Contract_Activity_Item', cai[0].RecordType.DeveloperName);
        System.assertEquals(700, cai[0].EUR_CRM_Total_Gross_Sales__c);
        System.assertEquals(-4900, cai[0].EUR_CRM_Contract__r.EUR_CRM_Contract_Profit__c);
        System.assertEquals(700, cai[0].EUR_CRM_Contract__r.EUR_CRM_General_Gross_Sales__c);
        System.assertEquals(50, cai[0].EUR_CRM_Contract__r.EUR_CRM_Total_Retro_FI__c);
        System.assertEquals(50, cai[0].EUR_CRM_Contract__r.EUR_CRM_Total_Retro_ex_Education_FI__c);

        List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
        System.debug('\n cpis.size() => ' + cpis.size() + '\n');
        System.debug('\n cpis => ' + JSON.serializePretty(cpis) + '\n');
        System.assertEquals(70, cpis[0].EUR_CRM_Volume_Btl__c);
        System.assertEquals('EUR_FI_Contract_Product_Item', cpis[0].RecordType.DeveloperName);
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
        return [
            SELECT EUR_CRM_Item_Type__c
            ,   EUR_CRM_Product_level__c
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Contract_Profit_per_Activity__c
            ,   EUR_CRM_Total_Gross_Sales__c
            ,   EUR_CRM_Total_Retro_FI__c
            ,   EUR_CRM_Contract__r.EUR_CRM_Contract_Profit__c
            ,   EUR_CRM_Contract__r.EUR_CRM_General_Gross_Sales__c
            ,   EUR_CRM_Contract__r.EUR_CRM_Total_Retro_FI__c
            ,   EUR_CRM_Contract__r.EUR_CRM_Total_Retro_ex_Education_FI__c
            FROM EUR_CRM_Contract_Activity_Item__c
        ];
    }

    private static List<EUR_CRM_Contract_Product_Item__c> selectCPIs() {
        return [
            SELECT EUR_CRM_Volume_Btl__c
                ,   RecordType.DeveloperName
                ,   EUR_CRM_Profit__c
                ,   EUR_CRM_Profit_Btl__c
                ,   EUR_CRM_Margin_Btl__c
                ,   EUR_CRM_Amount__c
                ,   EUR_CRM_Gross_SalesBtl__c
            FROM EUR_CRM_Contract_Product_Item__c
        ];
    }
}