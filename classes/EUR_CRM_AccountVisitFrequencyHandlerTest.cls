@isTest(IsParallel = true)
private class EUR_CRM_AccountVisitFrequencyHandlerTest {

    private static final String CLASS_NAME = 'EUR_CRM_AccountVisitFrequencyHandler';
    private static final Set<String> ACC_RT_TO_ASSIGN_VF = new Set<String>{
    	'EUR_GB_FS_Indirect',
    	'EUR_BG_Modern_Off_Trade',
    	'EUR_BG_Wholesaler',
    	'EUR_BE_Off_Trade'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'ACC_RT_TO_ASSIGN_VF', ACC_RT_TO_ASSIGN_VF));
    }


    /* ========================================================= */
    /*      On before insert tests
    /* ========================================================= */
    @IsTest
    private static void beforeInsert_assignVisitFreqViaPROS_positiveTest() {
        initCMT();

        EUR_CRM_Group_Outlet_Type__c prosGOT = makeGOT('Restaurant');
        insert prosGOT;

        EUR_CRM_Outlet_Type__c prosOT = makeOT(prosGOT.Id, 'Resaurant');
        insert prosOT;

        EUR_CRM_Image_Level__c prosIL = makeIL('Leading');
        insert prosIL;

        EUR_CRM_Volume_Potential__c prosVP = makeVP('High');
        insert prosVP;

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC('EUR_GB_Visit_Frequency_Criteria', vf.Id, prosGOT.Id, prosOT.Id, prosIL.Id, prosVP.Id);
        insert vfc;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_CRM_Group_Outlet_Type__c = prosGOT.Id;
        account.EUR_CRM_Outlet_Type__c = prosOT.Id;
        account.EUR_CRM_Image_Level__c = prosIL.Id;
        account.EUR_CRM_Volume_Potential__c = prosVP.Id;
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(vf.Id, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaPROS_negativeTest() {
        initCMT();

        EUR_CRM_Group_Outlet_Type__c prosGOT = makeGOT('Restaurant');
        insert prosGOT;

        EUR_CRM_Outlet_Type__c prosOT = makeOT(prosGOT.Id, 'Restaurant');
        insert prosOT;

        EUR_CRM_Image_Level__c prosIL = makeIL('Leading');
        insert prosIL;

        EUR_CRM_Volume_Potential__c prosVP = makeVP('High');
        insert prosVP;

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC('EUR_GB_Visit_Frequency_Criteria', vf.Id, prosGOT.Id, prosOT.Id, prosIL.Id, prosVP.Id);
        insert vfc;

        EUR_CRM_Account__c account = makeAccount('EUR_GB_FS_Indirect');
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaPRS_positiveTest() {
        initCMT();

        EUR_CRM_PRS_Group_Outlet_Type__c prsGOT = makePrsGOT('Restaurant');
        insert prsGOT;

        EUR_CRM_PRS_Outlet_Type__c prsOT = makePrsOT(prsGOT.Id, 'Restaurant');
        insert prsOT;

        EUR_CRM_PRS_Seg_Aspect__c prsIL = makePrsSA('Leading');
        EUR_CRM_PRS_Seg_Aspect__c prsVP = makePrsSA('High');
        insert new List<EUR_CRM_PRS_Seg_Aspect__c> { prsIL, prsVP };

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC(vf.Id, prsGOT.Id, prsOT.Id, prsIL.Id, prsVP.Id);
        insert vfc;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_CRM_PRS_Group_Outlet_Type__c = prsGOT.Id;
        account.EUR_CRM_PRS_Outlet_Type__c = prsOT.Id;
        account.EUR_CRM_PRS_Image_Level__c = prsIL.Id;
        account.EUR_CRM_PRS_Volume_Potential__c = prsVP.Id;
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(vf.Id, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaPRS_negativeTest() {
        initCMT();

        EUR_CRM_PRS_Group_Outlet_Type__c prsGOT = makePrsGOT('Restaurant');
        insert prsGOT;

        EUR_CRM_PRS_Outlet_Type__c prsOT = makePrsOT(prsGOT.Id, 'Restaurant');
        insert prsOT;

        EUR_CRM_PRS_Seg_Aspect__c prsIL = makePrsSA('Leading');
        EUR_CRM_PRS_Seg_Aspect__c prsVP = makePrsSA('High');
        insert new List<EUR_CRM_PRS_Seg_Aspect__c> { prsIL, prsVP };

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC(vf.Id, prsGOT.Id, prsOT.Id, prsIL.Id, prsVP.Id);
        insert vfc;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_CRM_PRS_Group_Outlet_Type__c = prsGOT.Id;
        account.EUR_CRM_PRS_Outlet_Type__c = prsOT.Id;
        account.EUR_CRM_PRS_Image_Level__c = prsIL.Id;
        account.EUR_CRM_PRS_Volume_Potential__c = null;
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaTaxonomy_positiveTest() {
        initCMT();

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Customer_Taxonomy__c ct = makeCT();
        ct.EUR_CRM_Visit_Frequency__c = vf.Id;
        insert ct;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_JB_Customer_Taxonomy__c = ct.Id;
        account.EUR_CRM_Status__c = 'Active';
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals('BG', insertedAccounts[0].EUR_CRM_Country_Code__c);
        System.assertEquals(vf.Id, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaTaxonomy_negativeTest() {
        initCMT();

        EUR_CRM_Group_Outlet_Type__c prosGOT = makeGOT('Restaurant');
        insert prosGOT;

        EUR_CRM_Outlet_Type__c prosOT = makeOT(prosGOT.Id, 'Restaurant');
        insert prosOT;

        EUR_CRM_Image_Level__c prosIL = makeIL('Leading');
        insert prosIL;

        EUR_CRM_Volume_Potential__c prosVP = makeVP('High');
        insert prosVP;

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        vf.Name = 'Once every 1 month';
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC('EUR_GB_Visit_Frequency_Criteria', vf.Id, prosGOT.Id, prosOT.Id, prosIL.Id, prosVP.Id);
        insert vfc;

        EUR_CRM_Customer_Taxonomy__c ct = makeCT();
        insert ct;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        account.EUR_JB_Customer_Taxonomy__c = ct.Id;
        account.EUR_CRM_Status__c = 'Prospect';
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaDeliveryType_positiveTest() {
        initCMT();

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        vf.Name = 'Once every 2 weeks';
        insert vf;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        account.EUR_CRM_Delivery_Type__c = 'Indirect';
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(vf.Id, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeInsert_assignVisitFreqViaDeliveryType_negativeTest() {
        initCMT();

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        vf.Name = 'Once every 2 weeks';
        insert vf;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
        account.EUR_CRM_Delivery_Type__c = 'Direct';
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    /* ========================================================= */
    /*      On before update tests
    /* ========================================================= */
    @IsTest
    private static void beforeUpdate_assignVisitFreqViaPROS_positiveTest() {
        initCMT();

        EUR_CRM_Group_Outlet_Type__c prosGOT = makeGOT('Restaurant');
        insert prosGOT;

        EUR_CRM_Outlet_Type__c prosOT = makeOT(prosGOT.Id, 'Resaurant');
        insert prosOT;

        EUR_CRM_Image_Level__c prosIL = makeIL('Leading');
        insert prosIL;

        EUR_CRM_Volume_Potential__c prosVP = makeVP('High');
        insert prosVP;

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC('EUR_GB_Visit_Frequency_Criteria', vf.Id, prosGOT.Id, prosOT.Id, prosIL.Id, prosVP.Id);
        insert vfc;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
        account.EUR_CRM_Group_Outlet_Type__c = prosGOT.Id;
        account.EUR_CRM_Outlet_Type__c = prosOT.Id;
        account.EUR_CRM_Image_Level__c = prosIL.Id;
        account.EUR_CRM_Volume_Potential__c = null;
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        insertedAccounts[0].EUR_CRM_Volume_Potential__c = prosVP.Id;
        update insertedAccounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(vf.Id, updatedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeUpdate_assignVisitFreqViaPRS_positiveTest() {
        initCMT();

        EUR_CRM_PRS_Group_Outlet_Type__c prsGOT = makePrsGOT('Restaurant');
        insert prsGOT;

        EUR_CRM_PRS_Outlet_Type__c prsOT = makePrsOT(prsGOT.Id, 'Restaurant');
        insert prsOT;

        EUR_CRM_PRS_Seg_Aspect__c prsIL = makePrsSA('Leading');
        EUR_CRM_PRS_Seg_Aspect__c prsVP = makePrsSA('High');
        insert new List<EUR_CRM_PRS_Seg_Aspect__c> { prsIL, prsVP };

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Visit_Frequency_Criteria__c vfc = makeVFC(vf.Id, prsGOT.Id, prsOT.Id, prsIL.Id, prsVP.Id);
        insert vfc;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
//        account.EUR_CRM_PRS_Group_Outlet_Type__c = prsGOT.Id;
//        account.EUR_CRM_PRS_Outlet_Type__c = prsOT.Id;
//        account.EUR_CRM_PRS_Image_Level__c = prsIL.Id;
//        account.EUR_CRM_PRS_Volume_Potential__c = null;
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        insertedAccounts[0].EUR_CRM_PRS_Group_Outlet_Type__c = prsGOT.Id;
        insertedAccounts[0].EUR_CRM_PRS_Outlet_Type__c = prsOT.Id;
        insertedAccounts[0].EUR_CRM_PRS_Image_Level__c = prsIL.Id;
        insertedAccounts[0].EUR_CRM_PRS_Volume_Potential__c = prsVP.Id;
        update insertedAccounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(vf.Id, updatedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeUpdate_assignVisitFreqViaTaxonomy_positiveTest() {
        initCMT();

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        insert vf;

        EUR_CRM_Customer_Taxonomy__c ct = makeCT();
        ct.EUR_CRM_Visit_Frequency__c = vf.Id;
        insert ct;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Modern_Off_Trade');
//        account.EUR_JB_Customer_Taxonomy__c = ct.Id;
        account.EUR_CRM_Status__c = 'Active';
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals('BG', insertedAccounts[0].EUR_CRM_Country_Code__c);
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        insertedAccounts[0].EUR_JB_Customer_Taxonomy__c = ct.Id;
        update insertedAccounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(vf.Id, updatedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }

    @IsTest
    private static void beforeUpdate_assignVisitFreqViaDeliveryType_positiveTest() {
        initCMT();

        EUR_CRM_Visit_Frequency__c vf = makeVF('EUR_BG_Visit_Frequency');
        vf.Name = 'Once every 2 weeks';
        insert vf;

        EUR_CRM_Account__c account = makeAccount('EUR_BG_Wholesaler');
//        account.EUR_CRM_Delivery_Type__c = 'Indirect';
        insert account;

        List<EUR_CRM_Account__c> insertedAccounts = selectAccounts();
        System.assertEquals(1, insertedAccounts.size());
        System.assertEquals(null, insertedAccounts[0].EUR_CRM_Visit_Frequency__c);

        Test.startTest();
        insertedAccounts[0].EUR_CRM_Delivery_Type__c = 'Indirect';
        update insertedAccounts;
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(vf.Id, updatedAccounts[0].EUR_CRM_Visit_Frequency__c);
    }


    /* ========================================================= */
    /*      Makers
	/* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '12345'
        ,   RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Visit_Frequency__c makeVF(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Visit_Frequency__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Visit_Frequency__c(
            RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Visit_Frequency_Criteria__c makeVFC(String rt, Id vfId, Id gotId, Id otId, Id ilId, Id vpId) {
        Id rtId = Schema.SObjectType.EUR_CRM_Visit_Frequency_Criteria__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Visit_Frequency_Criteria__c(
                RecordTypeId = rtId
            ,	EUR_CRM_Visit_Frequency__c = vfId
            ,   EUR_CRM_Group_Outlet_Type__c = gotId
            ,	EUR_CRM_Outlet_Type__c = otId
            ,   EUR_CRM_Image_Level__c = ilId
            ,   EUR_CRM_Volume_Potential__c = vpId
        );
    }

    private static EUR_CRM_Visit_Frequency_Criteria__c makeVFC(Id vfId, Id prsGOTid, Id prsOTid, Id prsILid, Id prsVPid) {
//        Id rtId = Schema.SObjectType.EUR_CRM_Visit_Frequency_Criteria__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Visit_Frequency_Criteria__c(
//            RecordTypeId = rtId
            	EUR_CRM_Visit_Frequency__c = vfId
            ,   EUR_CRM_PRS_Group_Outlet_Type_EU__c= prsGOTid
            ,	EUR_CRM_PRS_Outlet_Type_EU__c = prsOTid
            ,   EUR_CRM_PRS_IL_Segmentation_Aspect_EU__c= prsILid
            ,   EUR_CRM_PRS_VP_Segmentation_Aspect_EU__c = prsVPid
        );
    }

    private static EUR_CRM_Group_Outlet_Type__c makeGOT(String extId) {
        return new EUR_CRM_Group_Outlet_Type__c(
            EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_Outlet_Type__c makeOT(Id gotId, String extId) {
        return new EUR_CRM_Outlet_Type__c(
            EUR_CRM_Group_Outlet_Type__c = gotId
            ,   EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_Image_Level__c makeIL(String extID) {
        return new EUR_CRM_Image_Level__c(
            EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_Volume_Potential__c makeVP(String extId) {
        return new EUR_CRM_Volume_Potential__c(
            EUR_CRM_External_ID__c = extId

        );
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makePrsGOT(String extId) {
        return new EUR_CRM_PRS_Group_Outlet_Type__c(
            EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_PRS_Outlet_Type__c makePrsOT(Id gotId, String extId) {
        return new EUR_CRM_PRS_Outlet_Type__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = gotId
            ,	EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makePrsSA(String extId) {
        return new EUR_CRM_PRS_Seg_Aspect__c(
            EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_Customer_Taxonomy__c makeCT() {
        return new EUR_CRM_Customer_Taxonomy__c(

        );
    }


    /* ========================================================= */
    /*      SOQL Selectors
	/* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
                ,   EUR_CRM_Group_Outlet_Type__c
                ,   EUR_CRM_Outlet_Type__c
                ,   EUR_CRM_Image_Level__c
                ,   EUR_CRM_Volume_Potential__c
                ,   EUR_CRM_Visit_Frequency__c
                ,   EUR_CRM_Country_Code__c
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_Visit_Frequency__c> selectVFs() {
        return [
            SELECT Id
            FROM EUR_CRM_Visit_Frequency__c
        ];
    }

    private static List<EUR_CRM_Visit_Frequency_Criteria__c> selectVFCs() {
        return [
            SELECT Id
                ,	RecordType.DeveloperName
                ,	EUR_CRM_Group_Outlet_Type__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_Outlet_Type__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_Image_Level__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_Volume_Potential__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_PRS_Group_Outlet_Type_EU__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_PRS_Outlet_Type_EU__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_PRS_IL_Segmentation_Aspect_EU__r.EUR_CRM_External_ID__c
                ,	EUR_CRM_PRS_VP_Segmentation_Aspect_EU__r.EUR_CRM_External_ID__c
            FROM EUR_CRM_Visit_Frequency_Criteria__c
        ];
    }
}