@isTest
public class EUR_CRM_PRS_GroupOutletTypeSheetTest {
    @TestSetup
    static void setup() {
        insert new EUR_CRM_Region__c(RecordTypeId = '012D00000007S88IAE', EUR_CRM_External_ID__c = 'RU_Reg_MO');
        insert makePrsGOT('EUR BE PRS On Trade Group Outlet Type');
    }

    @IsTest
    private static void EUR_CRM_PRS_GroupOutletTypeSheetCntrlTest() {
        Set<Id> testSet =  EUR_CRM_PRS_GroupOutletTypeSheetCntrl.moscowAndStPetersRegionIds;
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c prsSeg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        ApexPages.StandardController standardController = new ApexPages.StandardController(prsSeg);

        EUR_CRM_PRS_GroupOutletTypeSheetCntrl controller = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(standardController);
//        System.assert(ApexPages.getMessages().isEmpty());

        List<SelectOption> childOpts = controller.getChildOptions();
//        System.assert(!childOpts.isEmpty());

//        controller.childValue = childOpts[1].getValue();
        System.runAs(new User(Id=UserInfo.getUserId())){
            controller.save();
        }
//        System.assert(ApexPages.getMessages().isEmpty());

        controller.cancel();
        Test.stopTest();
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makePrsGOT(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByName().get(rt).getRecordTypeId();

        return new EUR_CRM_PRS_Group_Outlet_Type__c(
                RecordTypeId = rtId,
                EUR_CRM_PRS_Group_Outlet_Name__c = 'Restaurant'
        );
    }
}