/***************************************************************************************************************************
 * Name:        ASI_CRM_DateUtilClassTest
 * Description: Test class for ASI_CRM_DateUtilClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-05       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_DateUtilClassTest {
    @IsTest static void isStartOfMonthTest() {
        System.assert(ASI_CRM_DateUtilClass.isStartOfMonth(Date.newInstance(2019,1,1)));
        System.assert(!ASI_CRM_DateUtilClass.isStartOfMonth(Date.newInstance(2019,1,2)));
    }
    @IsTest static void isEndOfMonthTest() {
        System.assert(ASI_CRM_DateUtilClass.isEndOfMonth(Date.newInstance(2019,1,31)));
        System.assert(!ASI_CRM_DateUtilClass.isEndOfMonth(Date.newInstance(2019,1,2)));
    }
    @IsTest static void getEndOfMonthTest() {
        System.assertEquals(Date.newInstance(2019,1,31), ASI_CRM_DateUtilClass.getEndOfMonth(Date.newInstance(2019,1,15)));
    }
    @IsTest static void isCrossingFiscalYearTest() {
        ASI_CRM_DateUtilClass.getFiscalYearEndDate(Date.today());
        ASI_CRM_DateUtilClass.getFiscalYearMonthMap(Date.today().addYears(-1), Date.today());
        System.assert(ASI_CRM_DateUtilClass.isCrossingFiscalYear(Date.today().addYears(-1), Date.today()));
        System.assert(!ASI_CRM_DateUtilClass.isCrossingFiscalYear(Date.today(), Date.today().addYears(1)));
    }
    @IsTest static void toDMYTest() {
        System.assertEquals('31/1/2019', ASI_CRM_DateUtilClass.toDMY(Date.newInstance(2019,1,31)));
    }
    @IsTest static void monthDiffTest() {
        System.assertEquals(12, ASI_CRM_DateUtilClass.monthDiff(Date.newInstance(2019,1,1),Date.newInstance(2019,12,31)));
    }
    @IsTest static void getCutOffDateTest() {
        ASI_CRM_DateUtilClass.getCutOffDate();
    }
    @IsTest static void findMinMaxDateTest() {
        System.assertEquals(Date.newInstance(2019,1,1), ASI_CRM_DateUtilClass.findMinMaxDate(Date.newInstance(2019,1,1),Date.newInstance(2019,1,31),'MIN'));
        System.assertEquals(Date.newInstance(2019,1,31), ASI_CRM_DateUtilClass.findMinMaxDate(Date.newInstance(2019,1,1),Date.newInstance(2019,1,31),'MAX'));
    }
}