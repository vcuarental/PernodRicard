@IsTest
private class EUR_CRM_ProsToPrsMigratingBatchTest {

    @IsTest
    private static void prosToPrsMigratingBatchTest() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;
        EUR_CRM_Group_Outlet_Type__c prosgot = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_External_ID__c = 'DE_REST');
        insert prosgot;

        EUR_CRM_PRS_Group_Outlet_Type__c prsgot = new EUR_CRM_PRS_Group_Outlet_Type__c(EUR_CRM_External_ID__c = 'DE_GOT_RST');
        insert prsgot;

        EUR_CRM_Pros_Segmentation__c prosSegmentation = new EUR_CRM_Pros_Segmentation__c(EUR_CRM_Group_Outlet_Type__c = prosgot.Id, EUR_CRM_Account__c = acc.Id);
        insert prosSegmentation;

        String counrtyCode = 'DE';
        Map<String, String> channelToRecordTypeMapping = new Map<String, String>{
                'OFF TRADE'  => 'EUR_PRS_Segmentation_Off_Trade',
                'ON TRADE'  => 'EUR_PRS_Segmentation_On_Trade',
                null  => 'EUR_PRS_Segmentation_On_Trade'
        };
        List<EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping> migratingMapping = new List<EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping>();
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Group_Outlet_Type__c', 'EUR_CRM_Group_Outlet_Type__c', 'EUR_CRM_PRS_Group_Outlet_Type__c', 'EUR_CRM_PRS_Group_Outlet_Type__c', new Map<String, String> {
                'DE_REST' => 'DE_GOT_RST',
                'DE_HEB' => 'DE_GOT_HEB',
                'DE_LEB' => 'DE_GOT_LEB',
                'DE_NC' => 'DE_GOT_NCL'
        }));
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Outlet_Type__c', 'EUR_CRM_Outlet_Type__c', 'EUR_CRM_PRS_Outlet_Type__c', 'EUR_CRM_PRS_Outlet_Type__c',new Map<String, String> {
                'DE_HEB_Beachclub' => 'DE_GOT_HEB_Beachclub',
                'DE_HEB_Cocktail_Bar' => 'DE_GOT_HEB_Cocktail_bar',
                'DE_HEB_Hotelbar' => 'DE_GOT_HEB_Hotel_bar',
                'DE_HEB_Pub' => 'DE_GOT_HEB_Pub',
                'DE_LEB_Beachclub' => 'DE_GOT_LEB_Beach_Club',
                'DE_LEB_Cafe_Bar' => 'DE_GOT_LEB_Cafe_Bar',
                'DE_LEB_Cocktail_Bar' => 'DE_GOT_LEB_Cocktail_bar',
                'DE_LEB_Hotelbar' => 'DE_GOT_LEB_Hotel_bar',
                'DE_LEB_Pub' => 'DE_GOT_LEB_Pub',
                'DE_NC_Club' => 'DE_GOT_NCL_Club',
                'DE_NC_Disco' => 'DE_GOT_NCL_Disco',
                'DE_NC_Großraum-Disco' => 'DE_GOT_NCL_Großraum-Disco',
                'DE_REST_Italiener' => 'DE_GOT_RST_Italiener',
                'DE_REST_Lieblingsitaliener' => 'DE_GOT_RST_Lieblingsitaliener',
                'DE_REST_Restaurant' => 'DE_GOT_RST_Restaurant',
                'DE_REST_Sterne Restaurant' => 'DE_GOT_RST_Sterne_Restaurant'
        }));
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Image_Level__c', 'EUR_CRM_Image_Level__c', 'EUR_CRM_Image_Level__c', 'EUR_CRM_PRS_Seg_Aspect__c', new Map<String, String> {
                'DE_Lead' => 'DE_IL_Leading',
                'DE_Icon' => 'DE_IL_Iconic',
                'DE_Main' => 'DE_IL_Mainstream',
                'DE_Prem' => 'DE_IL_Premium'
        }));
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Volume_Potential__c', 'EUR_CRM_Volume_Potential__c', 'EUR_CRM_Volume_Potential__c', 'EUR_CRM_PRS_Seg_Aspect__c', new Map<String, String> {
                'DE_High' => 'DE_VP_High',
                'DE_Med' => 'DE_VP_Medium',
                'DE_Low' => 'DE_VP_Low'
        }));


        Test.startTest();
            Database.executeBatch(new EUR_CRM_ProsToPrsMigratingBatch(counrtyCode, migratingMapping, channelToRecordTypeMapping));
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> prsSegmentations = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :acc.Id AND EUR_CRM_PRS_Group_Outlet_Type__c = :prsgot.Id];
        System.assertEquals(1, prsSegmentations.size());
    }

    @IsTest
    private static void prosToPrsMigratingBatch_2_Test() {
        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
            Name = 'Test Name',
            EUR_CRM_Channel__c = 'ON TRADE',
            EUR_CRM_Postal_Code__c = '02568',
            RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;
        EUR_CRM_Group_Outlet_Type__c prosgot = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_External_ID__c = 'DE_REST');
        insert prosgot;

        EUR_CRM_PRS_Group_Outlet_Type__c prsgot = new EUR_CRM_PRS_Group_Outlet_Type__c(EUR_CRM_External_ID__c = 'DE_GOT_RST');
        insert prsgot;

        EUR_CRM_Pros_Segmentation__c prosSegmentation = new EUR_CRM_Pros_Segmentation__c(EUR_CRM_Group_Outlet_Type__c = prosgot.Id, EUR_CRM_Account__c = acc.Id);
        insert prosSegmentation;

        String counrtyCode = 'DE';
        Map<String, String> channelToRecordTypeMapping = new Map<String, String>{
            'OFF TRADE'  => 'EUR_PRS_Segmentation_Off_Trade',
            'ON TRADE'  => 'EUR_PRS_Segmentation_On_Trade',
            null  => 'EUR_PRS_Segmentation_On_Trade'
        };
        List<EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping> migratingMapping = new List<EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping>();
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Group_Outlet_Type__c', 'EUR_CRM_Group_Outlet_Type__c', 'EUR_CRM_PRS_Group_Outlet_Type__c', 'EUR_CRM_PRS_Group_Outlet_Type__c', new Map<String, String> {
            'DE_REST' => 'DE_GOT_RST',
            'DE_HEB' => 'DE_GOT_HEB',
            'DE_LEB' => 'DE_GOT_LEB',
            'DE_NC' => 'DE_GOT_NCL'
        }));
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Outlet_Type__c', 'EUR_CRM_Outlet_Type__c', 'EUR_CRM_PRS_Outlet_Type__c', 'EUR_CRM_PRS_Outlet_Type__c',new Map<String, String> {
            'DE_HEB_Beachclub' => 'DE_GOT_HEB_Beachclub',
            'DE_HEB_Cocktail_Bar' => 'DE_GOT_HEB_Cocktail_bar',
            'DE_HEB_Hotelbar' => 'DE_GOT_HEB_Hotel_bar',
            'DE_HEB_Pub' => 'DE_GOT_HEB_Pub',
            'DE_LEB_Beachclub' => 'DE_GOT_LEB_Beach_Club',
            'DE_LEB_Cafe_Bar' => 'DE_GOT_LEB_Cafe_Bar',
            'DE_LEB_Cocktail_Bar' => 'DE_GOT_LEB_Cocktail_bar',
            'DE_LEB_Hotelbar' => 'DE_GOT_LEB_Hotel_bar',
            'DE_LEB_Pub' => 'DE_GOT_LEB_Pub',
            'DE_NC_Club' => 'DE_GOT_NCL_Club',
            'DE_NC_Disco' => 'DE_GOT_NCL_Disco',
            'DE_NC_Großraum-Disco' => 'DE_GOT_NCL_Großraum-Disco',
            'DE_REST_Italiener' => 'DE_GOT_RST_Italiener',
            'DE_REST_Lieblingsitaliener' => 'DE_GOT_RST_Lieblingsitaliener',
            'DE_REST_Restaurant' => 'DE_GOT_RST_Restaurant',
            'DE_REST_Sterne Restaurant' => 'DE_GOT_RST_Sterne_Restaurant'
        }));
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Image_Level__c', 'EUR_CRM_Image_Level__c', 'EUR_CRM_Image_Level__c', 'EUR_CRM_PRS_Seg_Aspect__c', new Map<String, String> {
            'DE_Lead' => 'DE_IL_Leading',
            'DE_Icon' => 'DE_IL_Iconic',
            'DE_Main' => 'DE_IL_Mainstream',
            'DE_Prem' => 'DE_IL_Premium'
        }));
        migratingMapping.add(new EUR_CRM_ProsToPrsMigratingBatch.SegmentMapping('EUR_CRM_Volume_Potential__c', 'EUR_CRM_Volume_Potential__c', 'EUR_CRM_Volume_Potential__c', 'EUR_CRM_PRS_Seg_Aspect__c', new Map<String, String> {
            'DE_High' => 'DE_VP_High',
            'DE_Med' => 'DE_VP_Medium',
            'DE_Low' => 'DE_VP_Low'
        }));


        Test.startTest();
        Database.executeBatch(new EUR_CRM_ProsToPrsMigratingBatch(counrtyCode, migratingMapping, channelToRecordTypeMapping, acc.Id));
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> prsSegmentations = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :acc.Id AND EUR_CRM_PRS_Group_Outlet_Type__c = :prsgot.Id];
        System.assertEquals(1, prsSegmentations.size());
    }

}