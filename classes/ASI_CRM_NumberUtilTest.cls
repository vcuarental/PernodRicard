@isTest
public class ASI_CRM_NumberUtilTest {

    @isTest
    static void testGetIntegerValue() {
        System.assertEquals(1, ASI_CRM_NumberUtil.getIntegerValue('1'));

        try {
            System.assertEquals(1, ASI_CRM_NumberUtil.getIntegerValue('abc'));
        } catch (Exception e) {
            System.assert(e.getTypeName().contains('ParseException'));
        }
    }

    @isTest
    static void testGetCurrencyFormattedValue() {
        ASI_CRM_NumberUtil.getCurrencyFormattedValue(123123.12);
        ASI_CRM_NumberUtil.getCurrencyFormattedValue(123123.12, 'HKD ');
        //System.assertEquals('123 123,12', ASI_CRM_NumberUtil.getCurrencyFormattedValue(123123.12));
        //System.assertEquals('HKD 123 123,12', ASI_CRM_NumberUtil.getCurrencyFormattedValue(123123.12, 'HKD '));
    }

}