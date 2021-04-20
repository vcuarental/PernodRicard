/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_QueryListMappingTest {

    @isTest
    public static void itShouldBeMethodGetValue() {
        LAT_QueryListMapping listMapping = new LAT_QueryListMapping('d');
        listMapping.value = '[1,2,3]';
        List<String> jsonBody = listMapping.getValues();
    }

    @isTest
    public static void itShouldBeMethodSetValues() {
        LAT_QueryListMapping listMapping = new LAT_QueryListMapping('d');
        listMapping.setValues(new List<String> {'1', '2', '3'});
    }
}