/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_Util_DateTest
 * Description: Test class for ASI_CRM_VN_Util_Date
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-08       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_Util_DateTest {
    @IsTest static void testGetDayOfWeek() {
        String dayOfWeek = ASI_CRM_VN_Util_Date.getDayOfWeek(Date.newInstance(2018,2,8));
        System.assertEquals('Thursday', dayOfWeek);
    }

    @IsTest static void testIsWeekend() {
        System.assert(ASI_CRM_VN_Util_Date.isWeekend(Date.newInstance(2018,2,11)));
    }

    @IsTest static void testGetNumOfWorkingDays(){
        Date startDate = Date.newInstance(2018,2,1);
        Date endDate = Date.newInstance(2018,2,15);
        ASI_CRM_Holiday__c chineseNewYear = new ASI_CRM_Holiday__c(
                Name = 'Chinese New Year',
                ASI_CRM_Date_From__c = Date.newInstance(2018,2,15),
                ASI_CRM_Date_To__c = Date.newInstance(2018,2,20)
        );
        List<ASI_CRM_Holiday__c> holidays = new List<ASI_CRM_Holiday__c>{ chineseNewYear };

        Integer numOfWorkingDays = ASI_CRM_VN_Util_Date.getNumOfWorkingDays(startDate, endDate, holidays);
        System.assertEquals(10, numOfWorkingDays);


        startDate = Date.newInstance(2018,2,16);
        endDate = Date.newInstance(2018,2,28);
        numOfWorkingDays = ASI_CRM_VN_Util_Date.getNumOfWorkingDays(startDate, endDate, holidays);
        System.assertEquals(6, numOfWorkingDays);
    }

    @IsTest static void testGetVisitationPlanStartDate(){
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(
                Name = 'Test',
                ASI_HK_CRM_Year__c = '2018',
                ASI_HK_CRM_Month__c = 'February',
                ASI_CRM_VN_Period__c = 'First Half',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan')
        );
        insert visitationPlan;

        visitationPlan = [SELECT Id, ASI_CRM_VN_Period__c, ASI_CRM_TH_Month_Start_Date__c FROM ASI_HK_CRM_Visitation_Plan__c LIMIT 1];

        Date startDate = ASI_CRM_VN_Util_Date.getVisitationPlanStartDate(visitationPlan);
        System.assertEquals(Date.newInstance(2018,2,1), startDate);

        visitationPlan.ASI_CRM_VN_Period__c = 'Second Half';
        startDate = ASI_CRM_VN_Util_Date.getVisitationPlanStartDate(visitationPlan);
        System.assertEquals(Date.newInstance(2018,2,16), startDate);
    }

    @IsTest static void testGetVisitationPlanEndDate(){
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(
                Name = 'Test',
                ASI_HK_CRM_Year__c = '2018',
                ASI_HK_CRM_Month__c = 'February',
                ASI_CRM_VN_Period__c = 'First Half',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan')
        );
        insert visitationPlan;

        visitationPlan = [SELECT Id, ASI_CRM_VN_Period__c, ASI_CRM_TH_Month_End_Date__c FROM ASI_HK_CRM_Visitation_Plan__c LIMIT 1];

        Date endDate = ASI_CRM_VN_Util_Date.getVisitationPlanEndDate(visitationPlan);
        System.assertEquals(Date.newInstance(2018,2,15), endDate);

        visitationPlan.ASI_CRM_VN_Period__c = 'Second Half';
        endDate = ASI_CRM_VN_Util_Date.getVisitationPlanEndDate(visitationPlan);
        System.assertEquals(Date.newInstance(2018,2,28), endDate);
    }
}