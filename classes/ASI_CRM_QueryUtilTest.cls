@isTest
public class ASI_CRM_QueryUtilTest {

    @isTest
    static void testGetSelectAllFieldsQueryStringWithNullCriteria() {
        final SObjectType objectType = ASI_CRM_QueryUtil.getSObjectTypeByName('Lead');
        ASI_CRM_QueryUtil.getSelectAllFieldsQueryString(objectType, null);
    }
    
    @isTest
    static void testGetSelectAllFieldsQueryStringWithCriteria() {
        final SObjectType objectType = ASI_CRM_QueryUtil.getSObjectTypeByName('Lead');
        ASI_CRM_QueryUtil.getSelectAllFieldsQueryString(objectType, 'Id');
    }
    
    @isTest
    static void testGetSObjectFieldsForQuery() {
        final SObjectType objectType = ASI_CRM_QueryUtil.getSObjectTypeByName('Lead');
        ASI_CRM_QueryUtil.getSObjectFieldsForQuery(objectType);
    }
    
    @isTest
    static void testGetListStringForQuery1() {
        List<String> strList = new List<String>();
        String a = 'a';
        String b = 'b';
        String c = 'c';
        strList.add(a);
        strList.add(b);
        strList.add(c);
        ASI_CRM_QueryUtil.getListStringForQuery(strList);
    }
    
    @isTest
    static void testGetListStringForQuery2() {
		Id userId = UserInfo.getUserId();
        Set<Id> idSet = new Set<Id>();
        idSet.add(userId);
        ASI_CRM_QueryUtil.getListStringForQuery(idSet);
    }
    
    @isTest
    static void testGetListStringForQuery3() {
		Set<String> strSet = new Set<String>();
        String a = 'a';
        String b = 'b';
        String c = 'c';
        strSet.add(a);
        strSet.add(b);
        strSet.add(c);
        ASI_CRM_QueryUtil.getListStringForQuery(strSet);
    }
    
    @isTest
    static void testGetListStringForQuery4() {
		Id userId = UserInfo.getUserId();
        List<Id> idList = new List<Id>();
        idList.add(userId);
        ASI_CRM_QueryUtil.getListStringForQuery(idList);
    }
    
    @isTest
    static void testEncloseWithQuotesWithNull() {
        String test = '';
        ASI_CRM_QueryUtil.encloseWithQuotes(test);
    }
    
    @isTest
    static void testEncloseWithQuotes() {
        String test = 'test';
        ASI_CRM_QueryUtil.encloseWithQuotes(test);
    }
    
    @isTest
    static void testGetDateForQuery() {
        DateTime now = DateTime.now();
        ASI_CRM_QueryUtil.getDateForQuery(now);
    }
}