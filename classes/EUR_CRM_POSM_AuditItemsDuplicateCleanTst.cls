/**
 * Created by Ilarion Tokarskyi on 28.05.2020.
 */

@IsTest
private class EUR_CRM_POSM_AuditItemsDuplicateCleanTst {

    private static final String MOBILE_ID_1 = 'Mobile_Id_1';
    private static final String MOBILE_ID_2 = 'Mobile_Id_2';

    //Acc RTs
    private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM';

    //PA RTs
    private static final String EUR_RU_ON_TRADE_POSM_AUDIT = 'EUR_RU_On_Trade_POSM_Audit';

    //PAI RTs
    private static final String EUR_RU_ON_TRADE_POSM_AUDIT_ITEM = 'EUR_RU_On_Trade_POSM_Audit_Item';

    private static final String BAD_RECORD_TYPE_DEV_NAME = 'Bad_Record_Type_Dev_Name';

    //Schedule tests
    @IsTest
    private static void scheduleCleanSAIsWhereRtDevNameAndDates_Test() {
        Test.startTest();
        String cronExpr = '0 0 1 * * ?';
        Set<String> rtDevName = new Set<String>{
                EUR_RU_ON_TRADE_POSM_AUDIT
        };
        String cronJobId = EUR_CRM_POSM_AuditItemsDuplicateClean.scheduleCleanRecordsWhereRtDevNameAndDates(cronExpr, rtDevName, null, null, 200);
        Test.stopTest();


        List<CronTrigger> cronTriggers = selectCronTriggers(cronJobId);
        System.assertEquals(1, selectCronTriggers(cronJobId).size());

        System.assertEquals('0 0 1 * * ?', cronTriggers[0].CronExpression);
        System.assertEquals(1, cronTriggers[0].NextFireTime.hour());
        System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
        System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase(EUR_CRM_POSM_AuditItemsDuplicateClean.EUR_CRM_POSM_AUDIT_ITEMS_DUPLICATE_CLEAN));

        EUR_CRM_POSM_AuditItemsDuplicateClean.removeSchedules();
        System.assertEquals(0, selectCronTriggers(cronJobId).size());
    }

    @IsTest
    private static void buildPaisQuery_NoRtParameter() {
        Set<String> rtDevNames = new Set<String>();
        String query = new EUR_CRM_POSM_AuditItemsDuplicateClean().buildPaisQuery(null, null, null);
        System.assert( ! query.contains('RecordType.DeveloperName IN :rtDevNames'));
        System.assert( ! query.contains('CreatedDate >= :startDatetime'));
        System.assert( ! query.contains('CreatedDate < :endDatetime'));
    }

    @IsTest
    private static void buildPaisQuery_OneParameter() {
        Set<String> rtDevNames = new Set<String>{
                EUR_RU_ON_TRADE_POSM_AUDIT
        };
        String query = new EUR_CRM_POSM_AuditItemsDuplicateClean().buildPaisQuery(rtDevNames, null, null);
        System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
        System.assert( ! query.contains('CreatedDate >= :startDatetime'));
        System.assert( ! query.contains('CreatedDate < :endDatetime'));
    }

    @IsTest
    private static void buildPaisQuery_TwoParameters() {
        Set<String> rtDevNames = new Set<String>{
                EUR_RU_ON_TRADE_POSM_AUDIT
        };
        Datetime startDt = Datetime.newInstance(2020, 01, 01);
        String query = new EUR_CRM_POSM_AuditItemsDuplicateClean().buildPaisQuery(rtDevNames, startDt, null);
        System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
        System.assert(query.contains('CreatedDate >= :startDatetime'));
        System.assert( ! query.contains('CreatedDate < :endDatetime'));
    }

    @IsTest
    private static void buildPaisQuery_ThreeParameters() {
        Set<String> rtDevNames = new Set<String>{
                EUR_RU_ON_TRADE_POSM_AUDIT
        };
        Datetime startDt = Datetime.newInstance(2020, 01, 01);
        Datetime endDt = Datetime.newInstance(2020, 03, 01);
        String query = new EUR_CRM_POSM_AuditItemsDuplicateClean().buildPaisQuery(rtDevNames, startDt, endDt);
        System.assert(query.contains('RecordType.DeveloperName IN :rtDevNames'));
        System.assert(query.contains('CreatedDate >= :startDatetime'));
        System.assert(query.contains('CreatedDate < :endDatetime'));
    }


    //Integration tests
    @IsTest
    private static void cleanPAIsWhereRtDevName_onePAwithSeveraPAIsDuplicates_Positive() {
        EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
        insert account;

        EUR_CRM_POSM_Audit__c pa = makePOSM_Audit(EUR_RU_ON_TRADE_POSM_AUDIT, account.Id);
        insert pa;

        EUR_CRM_POSM_Audit_Item__c pai1 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        EUR_CRM_POSM_Audit_Item__c pai2 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        EUR_CRM_POSM_Audit_Item__c pai3 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        EUR_CRM_POSM_Audit_Item__c pai4 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        pai1.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai2.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai3.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai4.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        insert new List<EUR_CRM_POSM_Audit_Item__c>{ pai1, pai2, pai3, pai4 };

        //Assertion before
        List<EUR_CRM_POSM_Audit_Item__c> paisBefore = selectPais();
        System.assertEquals(4, paisBefore.size());

        Test.startTest();
        EUR_CRM_POSM_AuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{
                EUR_RU_ON_TRADE_POSM_AUDIT
        });
        Test.stopTest();

        //Assertion after
        List<EUR_CRM_POSM_Audit_Item__c> paisAfter = selectPais();
        System.assertEquals(2, paisAfter.size());
        System.assertEquals(MOBILE_ID_1, paisAfter[0].EUR_CRM_Mobile_Id__c);
        System.assertEquals(MOBILE_ID_2, paisAfter[1].EUR_CRM_Mobile_Id__c);
    }

    @IsTest
    private static void cleanPAIsWhereRtDevName_onePAwithSeveralPAIsDuplicates_Negative() {
        EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
        insert account;

        EUR_CRM_POSM_Audit__c pa = makePOSM_Audit(EUR_RU_ON_TRADE_POSM_AUDIT, account.Id);
        insert pa;

        EUR_CRM_POSM_Audit_Item__c pai1 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        EUR_CRM_POSM_Audit_Item__c pai2 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        EUR_CRM_POSM_Audit_Item__c pai3 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        EUR_CRM_POSM_Audit_Item__c pai4 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa.Id);
        pai1.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai2.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai3.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai4.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        insert new List<EUR_CRM_POSM_Audit_Item__c>{ pai1, pai2, pai3, pai4 };

        //Assertion before
        List<EUR_CRM_POSM_Audit_Item__c> paisBefore = selectPais();
        System.assertEquals(4, paisBefore.size());

        Test.startTest();
        EUR_CRM_POSM_AuditItemsDuplicateClean.cleanRecordsWhereRtDevName(new Set<String>{ }, 200);
        Test.stopTest();

        //Assertion after
        List<EUR_CRM_POSM_Audit_Item__c> paisAfter = selectPais();
        System.assertEquals(4, paisAfter.size());
    }

    @IsTest
    private static void cleanPAIsWhereRtDevNameAndDates_twoPAwithSeveralPAIsDuplicates_Positive() {
        EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
        insert account;

        EUR_CRM_POSM_Audit__c pa1 = makePOSM_Audit(EUR_RU_ON_TRADE_POSM_AUDIT, account.Id);
        EUR_CRM_POSM_Audit__c pa2 = makePOSM_Audit(EUR_RU_ON_TRADE_POSM_AUDIT, account.Id);
        insert new List<EUR_CRM_POSM_Audit__c>{ pa1, pa2 };

        EUR_CRM_POSM_Audit_Item__c pai11 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        EUR_CRM_POSM_Audit_Item__c pai12 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        EUR_CRM_POSM_Audit_Item__c pai13 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        EUR_CRM_POSM_Audit_Item__c pai14 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        pai11.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai12.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai13.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai14.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;

        EUR_CRM_POSM_Audit_Item__c pai21 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        EUR_CRM_POSM_Audit_Item__c pai22 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        EUR_CRM_POSM_Audit_Item__c pai23 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        EUR_CRM_POSM_Audit_Item__c pai24 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        pai21.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai22.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai23.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai24.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;


        insert new List<EUR_CRM_POSM_Audit_Item__c>{ pai11, pai12, pai13, pai14, pai21, pai22, pai23, pai24 };

        //Assertion before
        List<EUR_CRM_POSM_Audit_Item__c> paisBefore = selectPais();
        System.assertEquals(8, paisBefore.size());

        Test.startTest();
        Datetime startDt = Datetime.now().addMinutes(-1);
        Datetime endDt = Datetime.now().addMinutes(1);
        EUR_CRM_POSM_AuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
                new Set<String>{
                        EUR_RU_ON_TRADE_POSM_AUDIT
                }, startDt, endDt
        );
        Test.stopTest();

        List<EUR_CRM_POSM_Audit__c> pas = selectPas();
        System.debug('\n pas.size() => ' + pas.size() + '\n');
        System.debug('\n pas => ' + JSON.serializePretty(pas) + '\n');
        System.assertEquals(2, pas.size());
        for (EUR_CRM_POSM_Audit__c pa : pas) {
            System.assertEquals(2, pa.POSM_Audit_Item_EU__r.size());
            System.assertEquals(MOBILE_ID_1, pa.POSM_Audit_Item_EU__r[0].EUR_CRM_Mobile_Id__c);
            System.assertEquals(MOBILE_ID_2, pa.POSM_Audit_Item_EU__r[1].EUR_CRM_Mobile_Id__c);
        }
    }

    @IsTest
    private static void cleanPAIsWhereRtDevNameAndDates_twoPAwithSeveralPAIsDuplicates_Negative() {
        EUR_CRM_Account__c account = makeAccount(EUR_GB_FS_RTM);
        insert account;

        EUR_CRM_POSM_Audit__c pa1 = makePOSM_Audit(EUR_RU_ON_TRADE_POSM_AUDIT, account.Id);
        EUR_CRM_POSM_Audit__c pa2 = makePOSM_Audit(EUR_RU_ON_TRADE_POSM_AUDIT, account.Id);
        insert new List<EUR_CRM_POSM_Audit__c>{ pa1, pa2 };

        EUR_CRM_POSM_Audit_Item__c pai11 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        EUR_CRM_POSM_Audit_Item__c pai12 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        EUR_CRM_POSM_Audit_Item__c pai13 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        EUR_CRM_POSM_Audit_Item__c pai14 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa1.Id);
        pai11.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai12.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai13.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai14.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;

        EUR_CRM_POSM_Audit_Item__c pai21 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        EUR_CRM_POSM_Audit_Item__c pai22 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        EUR_CRM_POSM_Audit_Item__c pai23 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        EUR_CRM_POSM_Audit_Item__c pai24 = makePOSM_AuditItem(EUR_RU_ON_TRADE_POSM_AUDIT_ITEM, pa2.Id);
        pai21.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai22.EUR_CRM_Mobile_Id__c = MOBILE_ID_1;
        pai23.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;
        pai24.EUR_CRM_Mobile_Id__c = MOBILE_ID_2;


        insert new List<EUR_CRM_POSM_Audit_Item__c>{ pai11, pai12, pai13, pai14, pai21, pai22, pai23, pai24 };

        //Assertion before
        List<EUR_CRM_POSM_Audit_Item__c> paisBefore = selectPais();
        System.assertEquals(8, paisBefore.size());

        Test.startTest();
        Datetime startDt = Datetime.now().addMinutes(-1);
        Datetime endDt = Datetime.now().addMinutes(1);
        EUR_CRM_POSM_AuditItemsDuplicateClean.cleanRecordsWhereRtDevNameAndDates(
                new Set<String>{ BAD_RECORD_TYPE_DEV_NAME }, startDt, endDt, 200
        );
        Test.stopTest();

        List<EUR_CRM_POSM_Audit__c> pas = selectPas();
        System.debug('\n pas.size() => ' + pas.size() + '\n');
        System.debug('\n pas => ' + JSON.serializePretty(pas) + '\n');
        System.assertEquals(2, pas.size());
        for (EUR_CRM_POSM_Audit__c pa : pas) {
            System.assertEquals(4, pa.POSM_Audit_Item_EU__r.size());
        }
    }



    //Makers
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                Name = 'Test Name'
                ,   EUR_CRM_Postal_Code__c = '1122'
                ,   RecordTypeId = rtId
        );
    }

    private static EUR_CRM_POSM_Audit__c makePOSM_Audit(String rt, Id accId) {
        Id rtId = SObjectType.EUR_CRM_POSM_Audit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_POSM_Audit__c(
                RecordTypeId = rtId
                , EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_POSM_Audit_Item__c makePOSM_AuditItem(String rt, Id paId) {
        Id rtId = SObjectType.EUR_CRM_POSM_Audit_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_POSM_Audit_Item__c(
                RecordTypeId = rtId
                , EUR_CRM_POSM_Audit__c = paId
        );
    }


    //Selectors
    private static List<CronTrigger> selectCronTriggers(String cronJobId) {
        return [
                SELECT Id
                        ,   CronJobDetail.Name
                        ,   CronExpression
                        ,   NextFireTime
                FROM CronTrigger
                WHERE Id = :cronJobId
        ];
    }

    private static List<EUR_CRM_POSM_Audit_Item__c> selectPais() {
        return [
                SELECT Id
                        ,   EUR_CRM_Mobile_Id__c
                FROM EUR_CRM_POSM_Audit_Item__c
        ];
    }

    private static List<EUR_CRM_POSM_Audit__c> selectPas() {
        return [
                SELECT Id
                        ,   (
                        SELECT Id
                                ,   EUR_CRM_Mobile_Id__c
                        FROM POSM_Audit_Item_EU__r
                        ORDER BY EUR_CRM_Mobile_Id__c ASC
                )
                FROM EUR_CRM_POSM_Audit__c
        ];
    }
}