@isTest
public class EUR_CRM_DE_TestRoutePlanningRemoteClass {

    public static EUR_CRM_Account__c offTradeAccount1;

    @IsTest
    private static void simpleTest() {
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(EUR_CRM_Region_Owner__c = UserInfo.getUserId(), Name = 'Region_1', EUR_CRM_Channel__c = 'ON TRADE');
        insert region;
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = region.Id, name = 'Territory_1', EUR_CRM_Territory_Owner__c = UserInfo.getUserId());
        insert territory;
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c(EUR_CRM_Postal_Code__c = '112233',name = 'PostalCode_1', EUR_CRM_Territory__c = territory.Id);
        postalCodeTerritoryMapping.RecordTypeId = Schema.SObjectType.EUR_CRM_Postal_Code_Territory_Mapping__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Off_Trade_Postal_Code_Territory_Mapping').getRecordTypeId();
        insert postalCodeTerritoryMapping;

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList = new List<EUR_CRM_Customer_Taxonomy__c>();

        EUR_CRM_Customer_Taxonomy__c customerTaxonomy1 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy1.name = 'customerTaxonomy1';
        customerTaxonomy1.EUR_CRM_Chain_Name__c = 'testchain1';
        customerTaxonomy1.EUR_CRM_Level_1__c = 'chain1level1';
        customerTaxonomy1.EUR_CRM_Level_2__c = 'chain1level2';
        customerTaxonomy1.EUR_CRM_Level_3__c = 'chain1level3';
        customerTaxonomy1.EUR_CRM_Level_4__c = 'chain1level4';
        customerTaxonomy1.EUR_CRM_Level_5__c = 'chain1level5';
        customerTaxonomy1.EUR_CRM_Level_6__c = 'chain1level6';
        customerTaxonomy1.EUR_CRM_Level_7__c = 'chain1level7';
        customerTaxonomy1.EUR_CRM_Level_8__c = 'chain1level8';
        customerTaxonomy1.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy1);
        insert customerTaxonomyList;


        List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();

        Id accountrecordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', EUR_CRM_DE_TestClassUtilityHelper.DE_EUACCOUNT_RECORD_TYPE);

        offTradeAccount1 = new EUR_CRM_Account__c();
        offTradeAccount1.EUR_CRM_Postal_Code__c = '112233';
        offTradeAccount1.recordtypeid = accountrecordtypeId;
        offTradeAccount1.name = 'offTradeAccount1';
        offTradeAccount1.EUR_JB_Customer_Taxonomy__c = customerTaxonomy1.id;
        offTradeAccount1.EUR_CRM_Channel__c = 'ON TRADE';
        euAccounts.add(offTradeAccount1);

        insert euAccounts;

        Id rtid = [select id from recordtype where developername = 'EUR_DE_Route_Template' and sobjecttype = 'EUR_CRM_Route_Template__c'][0].id;
//        Id rtid2 = [select id from recordtype where developername = 'EUR_DE_Visit_Frequency' and sobjecttype = 'EUR_CRM_Visit_Frequency__c'][0].id;
        EUR_CRM_Visit_Frequency__c visitFreq = new EUR_CRM_Visit_Frequency__c(name = 'test', EUR_CRM_Frequency_Span_Days__c = 14, EUR_CRM_No_of_Visits_Within_Interval__c = 1);
        insert visitFreq;

        test.startTest();
        offTradeAccount1.EUR_CRM_Visit_Frequency__c = visitFreq.id;
        offTradeAccount1.eur_crm_status_of_customer__c = 'Active';
        offTradeAccount1.ownerid = UserInfo.getUserId();
        update offTradeAccount1;
        EUR_CRM_Route_Template__c routeTemplate = new EUR_CRM_Route_Template__c(recordtypeid = rtid,
            EUR_CRM_Max_Planning_Period_Week__c = 52, EUR_CRM_Planning_Period__c = 4, EUR_CRM_Reminder_Day__c = 5);
        insert routeTemplate;
        routeTemplate = [
            select id,EUR_CRM_Max_Planning_Period_Week__c, EUR_CRM_Planning_Period__c, EUR_CRM_Reminder_Day__c,
                EUR_CRM_Country_Code__c
            from EUR_CRM_Route_Template__c
            where id = :routeTemplate.id
        ];

        EUR_CRM_Route_Template_Item__c routeTemplateItem = new EUR_CRM_Route_Template_Item__c(EUR_CRM_Account__c = offTradeAccount1.id,
            EUR_CRM_Route_Template__c = routeTemplate.id, EUR_CRM_Subject__c = 'test');
        insert routeTemplateItem ;

        EUR_CRM_Route_Template_Day__c rday = new EUR_CRM_Route_Template_Day__c(EUR_CRM_Route_Template_Item__c = routeTemplateItem.id, EUR_CRM_Day__c = 5);
        insert rday;
        Apexpages.StandardController sc = new Apexpages.standardController(routeTemplate);
        EUR_CRM_RoutePlanningRemoteClass rc = new EUR_CRM_RoutePlanningRemoteClass(sc);

        List<EUR_CRM_RoutePlanningRemoteClass.RoutePlanItem> items = EUR_CRM_RoutePlanningRemoteClass.getRoutPlanItems('1', '28', routeTemplate.id);
        EUR_CRM_RoutePlanningRemoteClass.getRoutPlanItemsByAccount(offTradeAccount1.id, routeTemplate.id);
        rc.retrieveAccounts();
        //system.assert(items, null);
        List<EUR_CRM_RoutePlanningRemoteClass.RoutePlanItem> items2 = new List<EUR_CRM_RoutePlanningRemoteClass.RoutePlanItem>();
        items2.add(items.get(0));
        EUR_CRM_RoutePlanningRemoteClass.saveRoutePlanItems(items2, '4', '8');

        List<String> accountIds = new List<String>();
        accountIds.add(offTradeAccount1.id);

        EUR_CRM_RoutePlanningRemoteClass.deleteRouteTemplateItems(accountIds);
        Integer totalPages = rc.totalPages;
        Integer accountListSize = rc.accountListSize;
//            rc.searchAccounts();
        rc.firstPage();
        rc.nextPage();
        rc.previousPage();
        rc.lastPage();
        test.StopTest();
    }

}