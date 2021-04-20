@isTest
private class EUR_CRM_Account_PRSegPageSectionTest {

    static testMethod void unitTest1() {
        EUR_CRM_PRS_TestClassUtilityHelper.initRecordType();
        EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA = EUR_CRM_PRS_TestClassUtilityHelper.createUser(EUR_CRM_PRS_TestClassUtilityHelper.PROFILE_NAME_ADMIN,EUR_CRM_PRS_TestClassUtilityHelper.ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BG');
//        EUR_CRM_PRS_TestClassUtilityHelper.BG_UserB = EUR_CRM_PRS_TestClassUtilityHelper.createUser(EUR_CRM_PRS_TestClassUtilityHelper.PROFILE_NAME_ADMIN,EUR_CRM_PRS_TestClassUtilityHelper.ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BG');

        System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA)
        {
            EUR_CRM_PRS_TestClassUtilityHelper.BG_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_VISIT_FREQUENCY);
            insert EUR_CRM_PRS_TestClassUtilityHelper.BG_VisitFeq_List;

            //CREATE Region
            EUR_CRM_PRS_TestClassUtilityHelper.BG_Region = EUR_CRM_PRS_TestClassUtilityHelper.createRegion('Test Region' ,EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA.Id , EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_REGION);
            //BG_Region = createRegion('BG_Region' ,BG_User.Id , 'EUR_BG_Region');
            //CREATE Territory
            EUR_CRM_PRS_TestClassUtilityHelper.BG_Territory = EUR_CRM_PRS_TestClassUtilityHelper.createTerritory('Test Territory',EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA.Id ,EUR_CRM_PRS_TestClassUtilityHelper.BG_Region.Id ,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_TERRITORY);
            //BG_Territory = createTerritory('BG Territory',BG_User.Id ,BG_Region.ID ,'EUR_BG_Territory');

            //CREATE Customer Taxonomy
            //BG_Customer_Tax = createCustomerTaxonomy('Test Cust Tax',BG_UserA.Id,RECORD_TYPE_BG_CUST_TAX);
            EUR_CRM_PRS_TestClassUtilityHelper.BG_Customer_Tax = EUR_CRM_PRS_TestClassUtilityHelper.createBGCustomerTaxonomy();
            //BG_Customer_Tax = createCustomerTaxonomy('BG_Cust_Tax',BG_User.Id,'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy');


            //Create PRS Segmentation Aspect (EU)
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();

            string ValueLow = 'Low';
            string ValueHigh = 'High';

            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BP_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_A_BP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BP_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_A_BP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW  = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BBP_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_A_BBP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_HI   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BBP_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_A_BBP));

            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_VP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_VP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_IL));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_IL));

            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_LOW);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_HI);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_HI);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_HI);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_HI);

            insert PRS_SAList;

            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BP',
                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BBP',
                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_PRS_Q_BBP));
            QuestionSetList.add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BP);
            QuestionSetList.add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP);

            insert QuestionSetList;

            EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            //(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName)
            EUR_CRM_PRS_Group_Outlet_Type__c BG_GROUP_OT1 = EUR_CRM_PRS_TestClassUtilityHelper.createBGOffGOutletType(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP.Id, EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BP.Id,
                'BG_GOT_HYSUM', 'Hyper/Supermarket','BG Hyper/Supermarket',''  );

            EUR_CRM_PRS_Group_Outlet_Type__c BG_GROUP_OT2 = EUR_CRM_PRS_TestClassUtilityHelper.createBGOffGOutletType(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP.Id, EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BP.Id,
                'BG_GOT_CON', 'Convenience','BG Convenience',''  );
            EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List.add(BG_GROUP_OT1);
            EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List.add(BG_GROUP_OT2);

            insert EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List);

            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT1_1 = EUR_CRM_PRS_TestClassUtilityHelper.createBGOffOutletType('Hypermarket',EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List[0].id,'BG_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT1_2 = EUR_CRM_PRS_TestClassUtilityHelper.createBGOffOutletType('Supermarket',EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List[0].id,'BG_OT_Supermarket');

            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT2_1 = EUR_CRM_PRS_TestClassUtilityHelper.createBGOffOutletType('Convenience',EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List[1].id,'BG_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BG_GROUP_OT2_2 = EUR_CRM_PRS_TestClassUtilityHelper.createBGOffOutletType('Gas stations',EUR_CRM_PRS_TestClassUtilityHelper.BG_GroupOutlet_List[1].id,'BG_OT_Gas_stations');

            OutletTypeList.add(BG_GROUP_OT1_1);
            OutletTypeList.add(BG_GROUP_OT1_2);
            OutletTypeList.add(BG_GROUP_OT2_1);
            OutletTypeList.add(BG_GROUP_OT2_2);

            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);

            EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BG_GROUP_OT1.id,
                EUR_CRM_BrandBuildPotQuestionSet__c = BG_GROUP_OT1.EUR_CRM_BrandBuildPotQuestionSet__c,
                EUR_CRM_BusinessPotentialQuestionSet__c = BG_GROUP_OT1.EUR_CRM_BusinessPotentialQuestionSet__c,
                EUR_CRM_External_ID__c = BG_GROUP_OT1.EUR_CRM_External_ID__c,
                EUR_CRM_Group_Outlet_Type_Name__c = BG_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                EUR_CRM_Name__c = BG_GROUP_OT1.EUR_CRM_Name__c,
                EUR_CRM_PRS_Group_Outlet_Name__c = BG_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);


            Test.startTest();
            //System.Debug('####Testing Account 1:' + BE_On_Account);
            EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account  = EUR_CRM_PRS_TestClassUtilityHelper.createBGAccount('Test Off Trade Account', '00000',  EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BG_ACC_OFF, EUR_CRM_PRS_TestClassUtilityHelper.BG_Customer_Tax.Id);

            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.Id Limit 1];
            PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id;
            update PRS_Seg;
            Test.stopTest();

            System.Debug('####Testing Account 1:' + EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account);

            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
            Id rtSACBBP = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_BBP);
            Id rtSACBP = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_BP);
            Id rtSACIL = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_IL);
            Id rtSACVP = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_VP);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC1 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACBBP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Brand_Building_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW.Id,  // Brand Building Potential
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC1);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC2 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACBBP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Brand_Building_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_HI.Id,  // Brand Building Potential
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC2);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC3 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACBP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Business_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_LOW.Id,  // Brand Building Potential
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC3);
            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC4 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACBP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Business_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_HI.Id,  // Brand Building Potential
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC4);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC5 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACIL,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Image_Level__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW.Id, 	 // Image Level
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC5);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC6 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACIL,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 50,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Image_Level__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_HI.Id, 	 // Image Level
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC6);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC7 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACVP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Volume_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW.Id,
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC7);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC8 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACVP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 50,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Volume_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_HI.Id,
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC8);


            Insert ListSAC;

            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
            aspCriteria.RecordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_BP);
            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BG_GROUP_OT.Id;
            aspCriteria.EUR_CRM_Minimum_Weight__c = 73;
            aspCriteria.EUR_CRM_Business_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_LOW.Id;
            insert aspCriteria;

            EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.EUR_CRM_Brand_Building_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW.Id;
            EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.EUR_CRM_Business_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_LOW.Id;
            update EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account;


        }


        EUR_CRM_Account__c acc = [
            SELECT Id
            FROM EUR_CRM_Account__c
            LIMIT 1
        ];
        ApexPages.StandardController standardController = new ApexPages.StandardController(acc);

        EUR_CRM_Account_PRSegPageSectionCntrl controller = new EUR_CRM_Account_PRSegPageSectionCntrl(standardController);
        controller.setPRSUrl();
    }

    static testMethod void unitTest2() {
        EUR_CRM_PRS_TestClassUtilityHelper.initRecordType();

        //FIND or CREATE User
        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
        if (userA.size() == 0){
            EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA = EUR_CRM_PRS_TestClassUtilityHelper.createUser(EUR_CRM_PRS_TestClassUtilityHelper.PROFILE_NAME_ADMIN,EUR_CRM_PRS_TestClassUtilityHelper.ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        } else {
            EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA = userA[0];
        }

        System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA)
        {
            EUR_CRM_PRS_TestClassUtilityHelper.BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_VISIT_FREQUENCY);
            insert EUR_CRM_PRS_TestClassUtilityHelper.BE_VisitFeq_List;

            //CREATE Region
            EUR_CRM_PRS_TestClassUtilityHelper.BE_Region = EUR_CRM_PRS_TestClassUtilityHelper.createRegion('Test Region' ,EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA.Id , EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_REGION);

            //CREATE Territory
            EUR_CRM_PRS_TestClassUtilityHelper.BE_Territory = EUR_CRM_PRS_TestClassUtilityHelper.createTerritory('Test Territory',EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA.Id ,EUR_CRM_PRS_TestClassUtilityHelper.BE_Region.Id ,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_TERRITORY);

            //CREATE Customer Taxonomy
            EUR_CRM_PRS_TestClassUtilityHelper.BE_Customer_Tax = EUR_CRM_PRS_TestClassUtilityHelper.createCustomerTaxonomy('Test Cust Tax',EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA.Id,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_CUST_TAX);

            Test.startTest();
            //Setup Account
            EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account     = EUR_CRM_PRS_TestClassUtilityHelper.createBEAccount('BE On Trade Account', '00000', EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_ACC_ON, EUR_CRM_PRS_TestClassUtilityHelper.BE_Customer_Tax.Id);
            System.Debug('####Testing Account 1:' + EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account);


            /*System.Debug('@@@Account PRS Check:' + [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: BE_Off_Account.Id]);*/

            //Create PRS Segmentation Aspect (EU)
            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_VP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_VP));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Leading',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_IL));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_IL));

            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_HI);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW);
            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_HI);

            insert PRS_SAList;
            Test.stopTest();

            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
            //Create Set
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_IL = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_IL',
                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_Q_IL));
            EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_VP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_VP',
                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_Q_VP));
            QuestionSetList.add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_IL);
            QuestionSetList.add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_VP);

            insert QuestionSetList;

            //Create Group Outlet List
            EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT1 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOnGOutletType(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_IL.Id, EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_VP.Id,
                'BE_GOT_HYSUM', 'Hyper/Supermarket','BE Hyper/Supermarket',''  );

            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT2 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOnGOutletType(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_IL.Id, EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_VP.Id,
                'BE_GOT_CON', 'Convenience','BE Convenience',''  );
            EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List.add(BE_GROUP_OT1);
            EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List.add(BE_GROUP_OT2);

            insert EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List;
            System.Debug('@@Init Group Outlet Type:' + EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List);

            //Create Outlet Type List
            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_1 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Hypermarket',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[0].id,'BE_OT_Hypermarket');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_2 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Supermarket',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[0].id,'BE_OT_Supermarket');

            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_1 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Convenience',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[1].id,'BE_OT_Convenience');
            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_2 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Gas stations',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[1].id,'BE_OT_Gas_stations');

            OutletTypeList.add(BE_GROUP_OT1_1);
            OutletTypeList.add(BE_GROUP_OT1_2);
            OutletTypeList.add(BE_GROUP_OT2_1);
            OutletTypeList.add(BE_GROUP_OT2_2);

            insert OutletTypeList;
            System.Debug('@@Init Outlet Type:' + OutletTypeList);

            EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BE_GROUP_OT1.id,
                EUR_CRM_Image_Level_Question_Set__c = BE_GROUP_OT1.EUR_CRM_Image_Level_Question_Set__c,
                EUR_CRM_Volume_Potential_Question_Set__c = BE_GROUP_OT1.EUR_CRM_Volume_Potential_Question_Set__c,
                EUR_CRM_External_ID__c = BE_GROUP_OT1.EUR_CRM_External_ID__c,
                EUR_CRM_Group_Outlet_Type_Name__c = BE_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
                EUR_CRM_Name__c = BE_GROUP_OT1.EUR_CRM_Name__c,
                EUR_CRM_PRS_Group_Outlet_Name__c = BE_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);



            //Create Segmentation
            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account.Id Limit 1];
            PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id;
            update PRS_Seg;

            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
            Id rtSACIL = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_IL);
            Id rtSACVP = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_VP);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC5 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACIL,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id,     	 // Group Outlet Type
                EUR_CRM_Image_Level__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW.Id, 				 // Image Level
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC5);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC6 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACIL,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Image_Level__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_HI.Id, 	 // Image Level
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC6);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC7 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACVP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Volume_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW.Id,
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC7);

            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC8 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
                RecordTypeId = rtSACVP,                         // Record Type
                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id,     // Group Outlet Type
                EUR_CRM_Volume_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_HI.Id,
                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
            );
            ListSAC.add(SAC8);
            insert ListSAC;

            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
            aspCriteria.RecordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_IL);
            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id;
            aspCriteria.EUR_CRM_Minimum_Weight__c = 50;
            aspCriteria.EUR_CRM_Image_Level__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW.Id;
            insert aspCriteria;

            EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account.EUR_CRM_PRS_Image_Level__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_IL_LOW.Id;
            EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account.EUR_CRM_PRS_Volume_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_VP_LOW.Id;
            update EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account;
        }

        EUR_CRM_Account__c acc = [
            SELECT Id
            FROM EUR_CRM_Account__c
            LIMIT 1
        ];
        ApexPages.StandardController standardController = new ApexPages.StandardController(acc);

        EUR_CRM_Account_PRSegPageSectionCntrl controller = new EUR_CRM_Account_PRSegPageSectionCntrl(standardController);
        controller.setPRSUrl();
    }

//    static testMethod void unitTest3() {
//        EUR_CRM_PRS_TestClassUtilityHelper.initRecordType();
//
//        //CREATE User
//        //FIND or CREATE User
//        User[] userA = [SELECT id from User where Email = 'test.userA@mail.com' LIMIT 1];
//        if (userA.size() == 0){
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA = EUR_CRM_PRS_TestClassUtilityHelper.createUser(EUR_CRM_PRS_TestClassUtilityHelper.PROFILE_NAME_ADMIN,EUR_CRM_PRS_TestClassUtilityHelper.ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
//        } else {
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA = userA[0];
//        }
//
//
//        User[] userB = [SELECT id from User where Email = 'test.userB@mail.com' LIMIT 1];
//        if (userB.size() == 0){
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_UserB = EUR_CRM_PRS_TestClassUtilityHelper.createUser(EUR_CRM_PRS_TestClassUtilityHelper.PROFILE_NAME_ADMIN,EUR_CRM_PRS_TestClassUtilityHelper.ROLE_NAME_EMEA,'test.userB@mail.com','test.userB@mail.com','BE');
//        } else {
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_UserB = userB[0];
//        }
//        //BE_User = createUser(PROFILE_NAME_ADMIN,ROLE_NAME_EMEA,'BE.user@mail.com','BE User','BE');
//
//        System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA)
//        {
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_VISIT_FREQUENCY);
//            insert EUR_CRM_PRS_TestClassUtilityHelper.BE_VisitFeq_List;
//
//            //CREATE Region
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_Region = EUR_CRM_PRS_TestClassUtilityHelper.createRegion('Test Region' ,EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA.Id , EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_REGION);
//            //CREATE Territory
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_Territory = EUR_CRM_PRS_TestClassUtilityHelper.createTerritory('Test Territory',EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA.Id ,EUR_CRM_PRS_TestClassUtilityHelper.BE_Region.Id ,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_TERRITORY);
//            //CREATE Customer Taxonomy
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_Customer_Tax = EUR_CRM_PRS_TestClassUtilityHelper.createCustomerTaxonomy('Test Cust Tax',EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA.Id,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_CUST_TAX);
//
//
//            List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
//
//            string ValueLow = 'Low';
//            string ValueHigh = 'High';
//
//            //PRS_SA_BP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BP_LO', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_BP));
//            //PRS_SA_BP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BP_HI', recordTypeId = rtMap.get(RECORD_TYPE_BE_PRS_A_BP));
//            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW   = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueLow,EUR_CRM_External_ID__c = 'TEST_BBP_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_BBP));
//            EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_HI    = New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_BBP_Aspect_Name__c = ValueHigh,EUR_CRM_External_ID__c = 'TEST_BBP_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_BBP));
//
//            //PRS_SAList.Add(PRS_SA_BP_LOW);
//            //PRS_SAList.Add(PRS_SA_BP_HI);
//            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW);
//            PRS_SAList.Add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_HI);
//
//            insert PRS_SAList;
//
//            List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
//            //Create Set
//            /*PRS_QSet_BP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BP',
//                                                          EUR_CRM_Last_Mass_Update_Date__c = System.now(),
//                                                          recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',RECORD_TYPE_BE_PRS_Q_BP));*/
//            EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP = New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_BBP',
//                EUR_CRM_Last_Mass_Update_Date__c = System.now(),
//                recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_Q_BBP));
//            //QuestionSetList.add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BP);
//            QuestionSetList.add(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP);
//
//            insert QuestionSetList;
//
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
//            //(Id BBPQSId, Id BPQSId, String ExtId, String GOTName, String Name, String GOName)
//            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT1 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOffGOutletType(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP.Id, null,
//                'BE_GOT_HYSUM', 'Hyper/Supermarket','BE Hyper/Supermarket',''  );
//
//            EUR_CRM_PRS_Group_Outlet_Type__c BE_GROUP_OT2 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOffGOutletType(EUR_CRM_PRS_TestClassUtilityHelper.PRS_QSet_BBP.Id, null,
//                'BE_GOT_CON', 'Convenience','BE Convenience',''  );
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List.add(BE_GROUP_OT1);
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List.add(BE_GROUP_OT2);
//
//            insert EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List;
//            System.Debug('@@Init Group Outlet Type:' + EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List);
//
//            List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
//            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_1 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOffOutletType('Hypermarket',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[0].id,'BE_OT_Hypermarket');
//            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT1_2 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOffOutletType('Supermarket',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[0].id,'BE_OT_Supermarket');
//
//            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_1 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOffOutletType('Convenience',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[1].id,'BE_OT_Convenience');
//            EUR_CRM_PRS_Outlet_Type__c BE_GROUP_OT2_2 = EUR_CRM_PRS_TestClassUtilityHelper.createBEOffOutletType('Gas stations',EUR_CRM_PRS_TestClassUtilityHelper.BE_GroupOutlet_List[1].id,'BE_OT_Gas_stations');
//
//            OutletTypeList.add(BE_GROUP_OT1_1);
//            OutletTypeList.add(BE_GROUP_OT1_2);
//            OutletTypeList.add(BE_GROUP_OT2_1);
//            OutletTypeList.add(BE_GROUP_OT2_2);
//
//            insert OutletTypeList;
//            System.Debug('@@Init Outlet Type:' + OutletTypeList);
//
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT = new EUR_CRM_PRS_Group_Outlet_Type__c(id = BE_GROUP_OT1.id,
//                EUR_CRM_BrandBuildPotQuestionSet__c = BE_GROUP_OT1.EUR_CRM_BrandBuildPotQuestionSet__c,
//                EUR_CRM_BusinessPotentialQuestionSet__c = BE_GROUP_OT1.EUR_CRM_BusinessPotentialQuestionSet__c,
//                EUR_CRM_External_ID__c = BE_GROUP_OT1.EUR_CRM_External_ID__c,
//                EUR_CRM_Group_Outlet_Type_Name__c = BE_GROUP_OT1.EUR_CRM_Group_Outlet_Type_Name__c,
//                EUR_CRM_Name__c = BE_GROUP_OT1.EUR_CRM_Name__c,
//                EUR_CRM_PRS_Group_Outlet_Name__c = BE_GROUP_OT1.EUR_CRM_PRS_Group_Outlet_Name__c);
//
//
//            Test.startTest();
//            EUR_CRM_PRS_TestClassUtilityHelper.BE_Off_Account  = EUR_CRM_PRS_TestClassUtilityHelper.createBEAccount('Test Off Trade Account', '00000',  EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_ACC_OFF, EUR_CRM_PRS_TestClassUtilityHelper.BE_Customer_Tax.Id);
//
//            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =: EUR_CRM_PRS_TestClassUtilityHelper.BE_Off_Account.Id Limit 1];
//            PRS_Seg.EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id;
//            update PRS_Seg;
//            Test.stopTest();
//
//            System.Debug('####Testing Account 1:' + EUR_CRM_PRS_TestClassUtilityHelper.BE_Off_Account);
//
//            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> ListSAC = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
//            Id rtSACBBP = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_BBP);
//            Id rtSACBP = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_BP);
//            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC1 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
//                RecordTypeId = rtSACBBP,                         // Record Type
//                EUR_CRM_Minimum_Weight__c = 0,                            // Minimum Weight
//                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id,     // Group Outlet Type
//                EUR_CRM_Brand_Building_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW.Id,  // Brand Building Potential
//                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
//            );
//            ListSAC.add(SAC1);
//            EUR_CRM_PRS_Seg_Aspect_Criteria__c SAC2 = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
//                RecordTypeId = rtSACBBP,                         // Record Type
//                EUR_CRM_Minimum_Weight__c = 0.5,                            // Minimum Weight
//                EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id,     // Group Outlet Type
//                EUR_CRM_Brand_Building_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_HI.Id,  // Brand Building Potential
//                EUR_CRM_Is_Weight_Changed__c = false                     // Is Weight Changed
//            );
//            ListSAC.add(SAC2);
//            Insert ListSAC;
//
//
////            EUR_CRM_PRS_Seg_Aspect_Criteria__c aspCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c();
////            aspCriteria.RecordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_PRS_AC_BBP);
////            aspCriteria.EUR_CRM_PRS_Group_Outlet_Type__c = EUR_CRM_PRS_TestClassUtilityHelper.BE_GROUP_OT.Id;
////            aspCriteria.EUR_CRM_Minimum_Weight__c = 73;
////            aspCriteria.EUR_CRM_Business_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW.Id;
////            insert aspCriteria;
//
////            EUR_CRM_PRS_TestClassUtilityHelper.BE_Off_Account.EUR_CRM_Brand_Building_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BBP_LOW.Id;
////            //BE_Off_Account.EUR_CRM_Business_Potential__c = EUR_CRM_PRS_TestClassUtilityHelper.PRS_SA_BP_LOW.Id;
////            update EUR_CRM_PRS_TestClassUtilityHelper.BE_Off_Account;
//        }
//
//
//        EUR_CRM_Account__c acc = [
//            SELECT Id
//            FROM EUR_CRM_Account__c
//            LIMIT 1
//        ];
//        ApexPages.StandardController standardController = new ApexPages.StandardController(acc);
//
//        EUR_CRM_Account_PRSegPageSectionCntrl controller = new EUR_CRM_Account_PRSegPageSectionCntrl(standardController);
//        controller.setPRSUrl();
//    }

}