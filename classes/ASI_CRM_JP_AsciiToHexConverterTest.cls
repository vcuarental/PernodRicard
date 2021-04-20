/**********************************************************************************
 * Name : ASI_CRM_JP_AsciiToHexConverterTest
 * Created : DC @04/18/2016
 * Revision History:
 * 1. 04/18/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_AsciiToHexConverterTest {
    
    private static String testString;

    static testMethod void testConverter() {

        testString = 'ABCD';
        Test.startTest(); // Starts the scope of test
            ASI_CRM_JP_AsciiToHexConverter converter = new ASI_CRM_JP_AsciiToHexConverter(testString);
            List<String> convertedHexValues = converter.convert();
        Test.stopTest(); // Ends the scope of test
    }
    
    static testMethod void testConverterWithBlankString() {

        testString = '';
        Test.startTest(); // Starts the scope of test
            ASI_CRM_JP_AsciiToHexConverter converter = new ASI_CRM_JP_AsciiToHexConverter(testString);
            List<String> str = converter.convert();
        Test.stopTest(); // Ends the scope of test
    }

    static testMethod void testConverterWithNullString() {

        Test.startTest(); // Starts the scope of test
            ASI_CRM_JP_AsciiToHexConverter converter = new ASI_CRM_JP_AsciiToHexConverter(testString);
            List<String> str = converter.convert();
        Test.stopTest(); // Ends the scope of test
    }
}