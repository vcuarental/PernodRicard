@IsTest
private class EUR_CRM_Test_PRS_GroupOutletTypeSheet {

    @IsTest
    private static void testInstantiation1() {
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segment = [SELECT Id, EUR_CRM_Country_Code__c, EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Country_Code__c, (SELECT Id FROM EUR_CRM_PRS_Answer__r) FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(segment);
        EUR_CRM_PRS_GroupOutletTypeSheetCntrl ctrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(sc);
        ctrl.getChildOptions();

        PageReference pageRef = Page.EUR_CRM_PRS_GroupOutletTypeSheet;
        pageRef.getParameters().put('id', String.valueOf(segment.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    private static void testInstantiation2() {
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segment = [SELECT Id, EUR_CRM_Country_Code__c FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(segment);
        EUR_CRM_PRS_GroupOutletTypeSheetCntrl ctrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(sc);
        ctrl.getChildOptions();

        PageReference pageRef = Page.EUR_CRM_PRS_GroupOutletTypeSheet;
        pageRef.getParameters().put('id', String.valueOf(segment.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }
    @IsTest
    private static void testInstantiation3() {
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segment = [SELECT Id, EUR_CRM_Country_Code__c FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(segment);
        EUR_CRM_PRS_GroupOutletTypeSheetCntrl ctrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(sc);
        ctrl.getChildOptions();

        PageReference pageRef = Page.EUR_CRM_PRS_GroupOutletTypeSheet;
        pageRef.getParameters().put('id', String.valueOf(segment.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    private static void testClearPRSegmentationValues() {
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segment = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(segment);
        EUR_CRM_PRS_GroupOutletTypeSheetCntrl ctrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(sc);
        ctrl.clearPRSegmentationValues();
        Test.stopTest();
    }

    @IsTest
    private static void testStandardActions() {
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c segment = [SELECT Id, EUR_CRM_Account__c, RecordTypeId, EUR_CRM_PRS_Group_Outlet_Type__c FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(segment);
        EUR_CRM_PRS_GroupOutletTypeSheetCntrl ctrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(sc);
        ctrl.parentValue = EUR_CRM_TestDataFactory.getGeneratedId('EUR_CRM_PRS_Group_Outlet_Type__c');
        ctrl.childValue = null;
        ctrl.save();

        segment.Id = null;
        ctrl.parentValue = segment.Id;
        ctrl.save();

        ctrl.cancel();
        Test.stopTest();

        Set<Id> moscowAndStPetersRegionIds = EUR_CRM_PRS_GroupOutletTypeSheetCntrl.moscowAndStPetersRegionIds;
    }

    @IsTest
    private static void EUR_CRM_PRS_AssignAspectFromCustomerTax_test() {
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_AssignAspectFromCustomerTax assignAspectFromCustomerTax = new EUR_CRM_PRS_AssignAspectFromCustomerTax();
        Test.stopTest();
    }


    private static EUR_CRM_Account__c makeAccount(String name) {
        return new EUR_CRM_Account__c(
                Name = name
        , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_NL_On_Trade')
        , EUR_CRM_Postal_Code__c = '11111'
        );
    }
}