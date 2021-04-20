@isTest(seealldata=false)
public with sharing class EUR_CRM_PRSegmentationTest {

//    static testMethod void unitTest1(){
//        test.startTest();
//        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();
//        test.stopTest();
//        //System.Debug('>>>Check Point:1');
//        //EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id, RecordTypeId,RecordType.DeveloperName,EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_PRS_Group_Outlet_Type__c <> null LIMIT 1];
//        //Id rtidAcc = [SELECT Id FROM recordType where DeveloperName = 'EUR_BG_Modern_Off_Trade' LIMIT 1 ].Id;
//        //EUR_CRM_Account__c accobj = new EUR_CRM_Account__c(
//        //RecordTypeId = rtidAcc ,                  // Record Type
//        //EUR_CRM_Channel__c = 'OFF TRADE',                  // Channel
//        //Name = 'BG Account Test',                    // Account Name
//        //EUR_CRM_Sub_Channel__c = 'Modern Off-Trade',       // Sub Channel
//        //EUR_CRM_Business_Type__c = 'Head Office',          // Business Type
//        //EUR_CRM_Status__c = 'Active',                      // Status
//        //EUR_CRM_Delivery_Type__c = 'Direct',               // Delivery Type
//        //EUR_CRM_Country__c = 'Bulgaria',                   // Country
//        //EUR_CRM_Force_GOT_OT_by_CT__c = false             // Force GroupOutletType/OutletType by CT
//        //);
//        //Test.startTest();
//        //insert accobj;
//        //Test.stopTest();
//
//        //EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id, RecordTypeId,RecordType.DeveloperName,EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =:accobj.Id  LIMIT 1];
//
//        EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id, RecordTypeId, RecordType.DeveloperName,
//                                               EUR_CRM_Account__c, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_PRS_Outlet_Type__c
//                                               FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c =:EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account.id  LIMIT 1];
//        System.Debug('PRS_Seg:' + PRS_Seg);
//        System.Debug([SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c
//                      FROM EUR_CRM_PRS_Group_Outlet_Type__c
//                      WHERE RecordType.DeveloperName LIKE '%PRS_Off_Trade_Group_Outlet_Type']);
//
//        //System.Debug('>>>Check Point:2');
//        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(PRS_Seg);
//        PageReference rf = new Pagereference('/apex/EUR_CRM_PRSegmentationPage');
//        rf.getParameters().put('id', PRS_Seg.id);
//        Test.setCurrentPage(rf);
//
//        EUR_CRM_PRSegmentationPageController controller = new EUR_CRM_PRSegmentationPageController(standardController);
//        //System.Debug('>>>Check Point:3');
//        PageReference rf2 = new Pagereference('/apex/EUR_CRM_PRS_GroupOutletTypeSheet');
//        rf2.getParameters().put('id', PRS_Seg.id);
//        Test.setCurrentPage(rf2);
//        //System.Debug('>>>Check Point:4');
//        EUR_CRM_PRS_GroupOutletTypeSheetCntrl GOTCtrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(standardController);
//        GOTCtrl.parentValue = GOTCtrl.parentOptions[0].getValue();
//        GOTCtrl.childValue = GOTCtrl.getChildOptions()[0].getValue();
//        GOTCtrl.Save();
//        GOTCtrl.exit();
//        GOTCtrl.clearPRSegmentationValues();
//        //System.Debug('>>>Check Point:5');
//        //Test.StopTest();
//
//        PageReference rf3 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//        rf3.getParameters().put('id', PRS_Seg.id);
//        rf3.getParameters().put('type', '1');
//        Test.setCurrentPage(rf3);
//
//        EUR_CRM_PRS_QuestionsSheetController QSCtrl1 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//        //QSCtrl1.getCustomForm();
//        for (String key : QSCtrl1.answerSheet.keySet()){
//            QSCtrl1.answerSheet.put(key,'TRUE');
//        }
//        QSCtrl1.saveCriteriaSheet();
//        try{
//            QSCtrl1.getCustomForm();
//        } catch(Exception e) {
//        }
//        //System.Debug('>>>Check Point:6');
//
//        PageReference rf4 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//        rf4.getParameters().put('id', PRS_Seg.id);
//        rf4.getParameters().put('type', '2');
//        Test.setCurrentPage(rf4);
//
//        EUR_CRM_PRS_QuestionsSheetController QSCtrl2 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//        QSCtrl2.saveCriteriaSheet();
//        //System.Debug('>>>Check Point:7');
//
//        EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
//        EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
//        EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{'BG'});
//        EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{'BG'});
//        EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{'BG'});
//        EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{'BG'});
//        EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{'BG'});
//        EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{'BG'});
//        EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria('Testing', 'BG');
//        EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria('Testing', 'BG');
//        EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria('Testing', 'BG');
//
//        //System.Debug('>>>Check Point:8');
//        try{EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(null);} catch(Exception e) {}
//        try{EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(null);} catch(Exception e) {}
//        try{EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(null);} catch(Exception e) {}
//        //System.Debug('>>>Check Point:9');
//        try{controller.gotoGroupOutletTypeSheet();}catch(Exception e) {}
//        try{controller.gotoBBPSheet();}catch(Exception e) {}
//        try{controller.gotoBPSheet();}catch(Exception e) {}
//        try{controller.gotoILSheet();}catch(Exception e) {}
//        try{controller.gotoVPSheet();}catch(Exception e) {}
//        //System.Debug('>>>Check Point:10');
//
//
//        Try{
//            System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
//                EUR_CRM_Account__c account = [SELECT Id,Name,
//                                              EUR_CRM_Is_PRS_Dimensions_Forced__c,EUR_CRM_Force_PRS_Image_Level__c,
//                                              EUR_CRM_Force_PRS_Volume_Potential__c,EUR_CRM_Force_Group_Outlet_Type__c,EUR_CRM_Force_Outlet_Type__c,EUR_CRM_Force_GOT_OT_by_CT__c,
//                                              EUR_CRM_Force_Brand_Building_Potential__c,EUR_CRM_Force_Business_potential__c
//                                              FROM EUR_CRM_Account__c
//                                              Where Id = :PRS_Seg.EUR_CRM_Account__c];
//                System.Debug('PRS Account Before Update:' + account);
//                //account.EUR_CRM_Is_PRS_Dimensions_Forced__c = true;
//                account.EUR_CRM_Force_Business_potential__c = 'High';
//                account.EUR_CRM_Force_Brand_Building_Potential__c = 'High';
//                account.EUR_CRM_Force_GOT_OT_by_CT__c = True;
//                //account.EUR_CRM_Force_Group_Outlet_Type__c = 'Hyper/Supermarket';
//                //account.EUR_CRM_Force_Outlet_Type__c = 'Hypermarket';
//
//                Update account;
//                System.Debug('PRS Account After Update:' + account);
//            }
//
//
//            System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
//                EUR_CRM_Account__c account = [SELECT Id,Name,
//                                              EUR_CRM_Is_PRS_Dimensions_Forced__c,EUR_CRM_Force_PRS_Image_Level__c,
//                                              EUR_CRM_Force_PRS_Volume_Potential__c,EUR_CRM_Force_Group_Outlet_Type__c,EUR_CRM_Force_Outlet_Type__c,EUR_CRM_Force_GOT_OT_by_CT__c,
//                                              EUR_CRM_Force_Brand_Building_Potential__c,EUR_CRM_Force_Business_potential__c
//                                              FROM EUR_CRM_Account__c
//                                              Where Id = :PRS_Seg.EUR_CRM_Account__c];
//                System.Debug('PRS Account Before Update:' + account);
//                //account.EUR_CRM_Is_PRS_Dimensions_Forced__c = true;
//                account.EUR_CRM_Force_Business_potential__c = 'Low';
//                account.EUR_CRM_Force_Brand_Building_Potential__c = 'Low';
//                //account.EUR_CRM_Force_GOT_OT_by_CT__c = True;
//                account.EUR_CRM_Force_Group_Outlet_Type__c = 'Hyper/Supermarket';
//                account.EUR_CRM_Force_Outlet_Type__c = 'Hypermarket';
//
//                Update account;
//                System.Debug('PRS Account After Update:' + account);
//            }
//
//        }Catch (Exception e){
//            System.Debug(e.getMessage());
//            System.Debug(e.getStackTraceString());
//        }
//
//    }
//    static testMethod void unitTest2(){
//        test.startTest();
//        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG_2nd();
//        test.stopTest();
//        EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id, RecordTypeId,RecordType.DeveloperName,EUR_CRM_Account__c
//                                               FROM EUR_CRM_PRS_Segmentation__c
//                                               WHERE EUR_CRM_Account__c =:EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account_2nd.id  LIMIT 1];
//        System.Debug('PRS_Seg:' + PRS_Seg);
//        System.Debug([SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c
//                      FROM EUR_CRM_PRS_Group_Outlet_Type__c
//                      WHERE RecordType.DeveloperName LIKE '%PRS_Off_Trade_Group_Outlet_Type']);
//
//        system.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserB)
//        {
//
//            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(PRS_Seg);
//            PageReference rf = new Pagereference('/apex/EUR_CRM_PRSegmentationPage');
//            rf.getParameters().put('id', PRS_Seg.id);
//            Test.setCurrentPage(rf);
//
//            EUR_CRM_PRSegmentationPageController controller = new EUR_CRM_PRSegmentationPageController(standardController);
//
//            PageReference rf2 = new Pagereference('/apex/EUR_CRM_PRS_GroupOutletTypeSheet');
//            rf2.getParameters().put('id', PRS_Seg.id);
//            Test.setCurrentPage(rf2);
//
//            EUR_CRM_PRS_GroupOutletTypeSheetCntrl GOTCtrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(standardController);
//            GOTCtrl.parentValue = GOTCtrl.parentOptions[0].getValue();
//            GOTCtrl.childValue = GOTCtrl.getChildOptions()[0].getValue();
//            GOTCtrl.Save();
//            GOTCtrl.exit();
//
//            PageReference rf3 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//            rf3.getParameters().put('id', PRS_Seg.id);
//            rf3.getParameters().put('type', '1');
//            Test.setCurrentPage(rf3);
//
//            EUR_CRM_PRS_QuestionsSheetController QSCtrl1 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//            //QSCtrl1.getCustomForm();
//            for (String key : QSCtrl1.answerSheet.keySet()){
//                QSCtrl1.answerSheet.put(key,'TRUE');
//            }
//            QSCtrl1.saveCriteriaSheet();
//            try{
//                QSCtrl1.getCustomForm();
//            } catch(Exception e) {
//            }
//
//            PageReference rf4 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//            rf4.getParameters().put('id', PRS_Seg.id);
//            rf4.getParameters().put('type', '2');
//            Test.setCurrentPage(rf4);
//
//            EUR_CRM_PRS_QuestionsSheetController QSCtrl2 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//            QSCtrl2.saveCriteriaSheet();
//
//            EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
//            EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
//            EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria('Testing', 'BE');
//            EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria('Testing', 'BE');
//            EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria('Testing', 'BE');
//            try{
//                EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(null);
//            } catch(Exception e) {
//            }
//            try {
//                EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(null);
//            } catch(Exception e) {
//            }
//            try {
//                EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(null);
//            } catch(Exception e) {
//            }
//
//            try{controller.gotoGroupOutletTypeSheet();}catch(Exception e) {}
//            try{controller.gotoBBPSheet();}catch(Exception e) {}
//            try{controller.gotoBPSheet();}catch(Exception e) {}
//            try{controller.gotoILSheet();}catch(Exception e) {}
//            try{controller.gotoVPSheet();}catch(Exception e) {}
//        }
//    }
//    static testMethod void unitTest3(){
//        //Test.startTest();
//        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OffTrade();
//        //Test.stopTest();
//
//        EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id, RecordTypeId,RecordType.DeveloperName,EUR_CRM_Account__c
//                                               FROM EUR_CRM_PRS_Segmentation__c
//                                               WHERE EUR_CRM_Account__c =:EUR_CRM_PRS_TestClassUtilityHelper.BE_Off_Account.id  LIMIT 1];
//        System.Debug('PRS_Seg:' + PRS_Seg);
//        System.Debug([SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c
//                      FROM EUR_CRM_PRS_Group_Outlet_Type__c
//                      WHERE RecordType.DeveloperName LIKE '%PRS_Off_Trade_Group_Outlet_Type']);
//
//
//        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(PRS_Seg);
//        PageReference rf = new Pagereference('/apex/EUR_CRM_PRSegmentationPage');
//        rf.getParameters().put('id', PRS_Seg.id);
//        Test.setCurrentPage(rf);
//
//        EUR_CRM_PRSegmentationPageController controller = new EUR_CRM_PRSegmentationPageController(standardController);
//
//        PageReference rf2 = new Pagereference('/apex/EUR_CRM_PRS_GroupOutletTypeSheet');
//        rf2.getParameters().put('id', PRS_Seg.id);
//        Test.setCurrentPage(rf2);
//
//        EUR_CRM_PRS_GroupOutletTypeSheetCntrl GOTCtrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(standardController);
//        GOTCtrl.parentValue = GOTCtrl.parentOptions[0].getValue();
//        GOTCtrl.childValue = GOTCtrl.getChildOptions()[0].getValue();
//        GOTCtrl.Save();
//        GOTCtrl.exit();
//
//        PageReference rf3 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//        rf3.getParameters().put('id', PRS_Seg.id);
//        rf3.getParameters().put('type', '1');
//        Test.setCurrentPage(rf3);
//
//        EUR_CRM_PRS_QuestionsSheetController QSCtrl1 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//        //QSCtrl1.getCustomForm();
//        for (String key : QSCtrl1.answerSheet.keySet()){
//            QSCtrl1.answerSheet.put(key,'TRUE');
//        }
//        QSCtrl1.saveCriteriaSheet();
//        try{
//            QSCtrl1.getCustomForm();
//        } catch(Exception e) {
//        }
//
//        PageReference rf4 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//        rf4.getParameters().put('id', PRS_Seg.id);
//        rf4.getParameters().put('type', '2');
//        Test.setCurrentPage(rf4);
//
//        EUR_CRM_PRS_QuestionsSheetController QSCtrl2 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//        QSCtrl2.saveCriteriaSheet();
//
//        EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
//        EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
//        EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{'BE'});
//        //EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{'BE'});
//        EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{'BE'});
//        EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{'BE'});
//        EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{'BE'});
//        EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{'BE'});
//        //EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria('Testing', 'BE');
//        EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria('Testing', 'BE');
//        EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria('Testing', 'BE');
//        try{
//            EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(null);
//        } catch(Exception e) {
//        }
//        try {
//            EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(null);
//        } catch(Exception e) {
//        }
//        try {
//            EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(null);
//        } catch(Exception e) {
//        }
//
//        try{controller.gotoGroupOutletTypeSheet();}catch(Exception e) {}
//        try{controller.gotoBBPSheet();}catch(Exception e) {}
//        //try{controller.gotoBPSheet();}catch(Exception e) {}
//        try{controller.gotoILSheet();}catch(Exception e) {}
//        try{controller.gotoVPSheet();}catch(Exception e) {}
//        try{
//            System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA){
//                Id batchJobId = Database.executeBatch(new EUR_CRM_BE_PRS_SetReperformFlag(), 200);
//            }
//        }catch(Exception e){}
//    }
//    static testMethod void unitTest4(){
//        test.startTest();
//        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTrade();
//        test.stopTest();
//
//        system.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BE_UserB)
//        {
//            EUR_CRM_PRS_Segmentation__c PRS_Seg = [SELECT Id, RecordTypeId,RecordType.DeveloperName,EUR_CRM_Account__c
//                                                   FROM EUR_CRM_PRS_Segmentation__c
//                                                   WHERE EUR_CRM_Account__c =:EUR_CRM_PRS_TestClassUtilityHelper.BE_On_Account.id  LIMIT 1];
//
//
//            //System.Debug('PRS_Seg:' + PRS_Seg);
//            //System.Debug([SELECT Id, RecordType.DeveloperName, EUR_CRM_Group_Outlet_Type_Name__c
//            //FROM EUR_CRM_PRS_Group_Outlet_Type__c
//            //WHERE RecordType.DeveloperName LIKE '%PRS_On_Trade_Group_Outlet_Type']);
//
//            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(PRS_Seg);
//            PageReference rf = new Pagereference('/apex/EUR_CRM_PRSegmentationPage');
//            rf.getParameters().put('id', PRS_Seg.id);
//            Test.setCurrentPage(rf);
//
//            EUR_CRM_PRSegmentationPageController controller = new EUR_CRM_PRSegmentationPageController(standardController);
//
//            PageReference rf2 = new Pagereference('/apex/EUR_CRM_PRS_GroupOutletTypeSheet');
//            rf2.getParameters().put('id', PRS_Seg.id);
//            Test.setCurrentPage(rf2);
//
//            EUR_CRM_PRS_GroupOutletTypeSheetCntrl GOTCtrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(standardController);
//            GOTCtrl.parentValue = GOTCtrl.parentOptions[0].getValue();
//            GOTCtrl.childValue = GOTCtrl.getChildOptions()[0].getValue();
//            GOTCtrl.Save();
//            GOTCtrl.exit();
//
//            PageReference rf3 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//            rf3.getParameters().put('id', PRS_Seg.id);
//            rf3.getParameters().put('type', '3');
//            Test.setCurrentPage(rf3);
//
//            EUR_CRM_PRS_QuestionsSheetController QSCtrl1 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//            //QSCtrl1.getCustomForm();
//            for (String key : QSCtrl1.answerSheet.keySet()){
//                QSCtrl1.answerSheet.put(key,'TRUE');
//            }
//            QSCtrl1.saveCriteriaSheet();
//            try{
//                QSCtrl1.getCustomForm();
//            } catch(Exception e) {}
//
//            PageReference rf4 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
//            rf4.getParameters().put('id', PRS_Seg.id);
//            rf4.getParameters().put('type', '4');
//            Test.setCurrentPage(rf4);
//
//            EUR_CRM_PRS_QuestionsSheetController QSCtrl2 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
//            for (String key : QSCtrl2.answerSheet.keySet()){
//                QSCtrl2.answerSheet.put(key,'TRUE');
//            }
//            QSCtrl2.saveCriteriaSheet();
//
//            EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
//            EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
//            EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{'BE'});
//            //EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{'BE'});
//            EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{'BE'});
//            //EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria('Testing', 'BE');
//            EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria('Testing', 'BE');
//            EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria('Testing', 'BE');
//            try{
//                EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(null);
//            } catch(Exception e) {
//            }
//            try {
//                EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(null);
//            } catch(Exception e) {
//            }
//            try {
//                EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(null);
//            } catch(Exception e) {
//            }
//
//            try{controller.gotoGroupOutletTypeSheet();}catch(Exception e) {}
//            try{controller.gotoBBPSheet();}catch(Exception e) {}
//            //try{controller.gotoBPSheet();}catch(Exception e) {}
//            try{controller.gotoILSheet();}catch(Exception e) {}
//            try{controller.gotoVPSheet();}catch(Exception e) {}
//            try{
//                System.runAs(EUR_CRM_PRS_TestClassUtilityHelper.BE_UserA){
//                    Id batchJobId = Database.executeBatch(new EUR_CRM_BE_PRS_SetReperformFlag(), 200);
//                }
//            }catch(Exception e){}
//        }
//    }

    @TestSetup
    private static void setupMethod() {
        Test.startTest();
//        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();

        EUR_CRM_PRS_TestClassUtilityHelper.initRecordType();

        User BE_UserA = null;

        //FIND or CREATE User
        System.runAs(new User(Id = UserInfo.getUserId())) {
            BE_UserA = EUR_CRM_PRS_TestClassUtilityHelper.createUser(EUR_CRM_PRS_TestClassUtilityHelper.PROFILE_NAME_ADMIN,EUR_CRM_PRS_TestClassUtilityHelper.ROLE_NAME_EMEA,'test.userA@mail.com','test.userA@mail.com','BE');
        }

        EUR_CRM_PRS_TestClassUtilityHelper.BE_VisitFeq_List = EUR_CRM_TestClassUtilityHelper.createVisitFrequency(1,EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_VISIT_FREQUENCY);
        insert EUR_CRM_PRS_TestClassUtilityHelper.BE_VisitFeq_List;

        //Setup Account
        EUR_CRM_Account__c BE_On_Account = EUR_CRM_PRS_TestClassUtilityHelper.createBEAccount('BE On Trade Account', '00000', EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_ACC_ON, null);
        System.Debug('####Testing Account 1:' + BE_On_Account);
        Test.stopTest();

        //Create PRS Segmentation Aspect (EU)
        List<EUR_CRM_PRS_Seg_Aspect__c> PRS_SAList = New List<EUR_CRM_PRS_Seg_Aspect__c>();
        PRS_SAList.Add(New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'Low',EUR_CRM_External_ID__c = 'TEST_VP_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_VP)));
        PRS_SAList.Add(New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_VP_Aspect_Name__c = 'High',EUR_CRM_External_ID__c = 'TEST_VP_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_VP)));
        PRS_SAList.Add(New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Mainstream',EUR_CRM_External_ID__c = 'TEST_IL_LO', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_IL)));
        PRS_SAList.Add(New EUR_CRM_PRS_Seg_Aspect__c(EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic',EUR_CRM_External_ID__c = 'TEST_IL_HI', recordTypeId = EUR_CRM_PRS_TestClassUtilityHelper.rtMap.get(EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_A_IL)));

        List<EUR_CRM_PRS_Question_Set__c> QuestionSetList = new List<EUR_CRM_PRS_Question_Set__c>();
        //Create Set
        QuestionSetList.add(New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_IL', EUR_CRM_Last_Mass_Update_Date__c = System.now(), recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_Q_IL)));
        QuestionSetList.add(New EUR_CRM_PRS_Question_Set__c(EUR_CRM_External_Id__c = 'TEST_QS_VP', EUR_CRM_Last_Mass_Update_Date__c = System.now(), recordtypeid = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_PRS_Question_Set__c',EUR_CRM_PRS_TestClassUtilityHelper.RECORD_TYPE_BE_PRS_Q_VP)));
        insert QuestionSetList;

        List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
        groupOutletTypes.add(EUR_CRM_PRS_TestClassUtilityHelper.createBEOnGOutletType(QuestionSetList[0].Id, QuestionSetList[1].Id, 'BE_GOT_HYSUM', 'Hyper/Supermarket','BE Hyper/Supermarket',''  ));
        groupOutletTypes.add(EUR_CRM_PRS_TestClassUtilityHelper.createBEOnGOutletType(QuestionSetList[0].Id, QuestionSetList[1].Id, 'BE_GOT_CON', 'Convenience','BE Convenience',''  ));
        insert groupOutletTypes;

        //Create Outlet Type List
        List<EUR_CRM_PRS_Outlet_Type__c> OutletTypeList = new List<EUR_CRM_PRS_Outlet_Type__c>();
        OutletTypeList.add(EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Hypermarket',groupOutletTypes[0].id,'BE_OT_Hypermarket'));
        OutletTypeList.add(EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Supermarket',groupOutletTypes[0].id,'BE_OT_Supermarket'));
        OutletTypeList.add(EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Convenience',groupOutletTypes[1].id,'BE_OT_Convenience'));
        OutletTypeList.add(EUR_CRM_PRS_TestClassUtilityHelper.createBEOnOutletType('Gas stations',groupOutletTypes[1].id,'BE_OT_Gas_stations'));
        insert OutletTypeList;
        System.Debug('@@Init Outlet Type:' + OutletTypeList);
    }

    static testMethod void EUR_CRM_PRSegmentationClassTest(){
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c prsSeg = [SELECT Id, EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        EUR_CRM_Account__c acc = [SELECT Id, EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c,
            EUR_CRM_Brand_Building_Potential__c, EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c,
            EUR_CRM_Business_Potential__c, EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c,
            EUR_CRM_PRS_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c
        FROM EUR_CRM_Account__c WHERE Id=:prsSeg.EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = [SELECT Id FROM EUR_CRM_PRS_Group_Outlet_Type__c LIMIT 1];

        EUR_CRM_PRS_Segmentation__c retPrsSeg = EUR_CRM_PRSegmentationClass.returnPRSegmentationViaId(prsSeg.Id);
        System.assertEquals(retPrsSeg.Id, prsSeg.Id);
        EUR_CRM_PRS_Group_Outlet_Type__c retgroupOutletType = EUR_CRM_PRSegmentationClass.returnPRSGroupOutletTypeViaId(groupOutletType.Id);
        System.assertEquals(retgroupOutletType.Id, groupOutletType.Id);

        List<String> ilLabels = EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
        System.assert(!ilLabels.isEmpty());
        List<String> vpLabels = EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
        System.assert(!vpLabels.isEmpty());
        List<EUR_CRM_PRS_Seg_Aspect__c> bbp = EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{'BE'});
        List<EUR_CRM_PRS_Seg_Aspect__c> bp = EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{'BE'});
        List<EUR_CRM_PRS_Seg_Aspect__c> il = EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{'BE'});
        List<EUR_CRM_PRS_Seg_Aspect__c> vp = EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{'BE'});
        Test.stopTest();

        EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria(groupOutletType.Id, 'BE');
        EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria(groupOutletType.Id, 'BE');
        EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria(groupOutletType.Id, 'BE');
        EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialFinalResultsCriteria(groupOutletType.Id, 'BE');
        List<String> bbpLabels = EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialLabels();
        List<String> bpLabels = EUR_CRM_PRSegmentationClass.returnBusinessPotentialLabels();
        EUR_CRM_PRSegmentationClass.returnPROFSPotentialMatrix(retPrsSeg, bbpLabels, bpLabels);
        EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(acc, bbpLabels, bpLabels);
        EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(retPrsSeg, ilLabels, vpLabels);
        EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(acc, ilLabels, vpLabels);
        EUR_CRM_PRSegmentationClass.returnPRSQuestionsAndPossibleAnswersList(null);
        EUR_CRM_PRSegmentationClass.returnPriorityLevelMatrices('BE');
        EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(retPrsSeg.EUR_CRM_Image_Level__r.RecordTypeId, 'EUR_CRM_Segmentation_IL_Aspect_Name__c');
        EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(retPrsSeg.EUR_CRM_Volume_Potential__r.RecordTypeId, 'EUR_CRM_Segmentation_VP_Aspect_Name__c');
        EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(retPrsSeg.EUR_CRM_Business_Potential__r.RecordTypeId, 'EUR_CRM_Segmentation_BP_Aspect_Name__c');
        EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(retPrsSeg.EUR_CRM_Brand_Building_Potential__r.RecordTypeId, 'EUR_CRM_Segmentation_BBP_Aspect_Name__c');

    }

    //@IsTest
    //private static void coverageTest() {
    //    Test.startTest();
    //    EUR_CRM_PRSegmentationPageController.superMethod();
    //    Test.stopTest();
    //}

}