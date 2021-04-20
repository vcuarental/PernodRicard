/**
 * Created by illia on 03.09.18.
 */

@IsTest
private class EUR_CRM_PRSegmentationPageControllerTest {

//    @TestSetup
//    public static void setup() {
//        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG_2nd();
//    }

    @IsTest
    static void unitTest2() {
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(
                Name = 'Acc'
                ,   EUR_CRM_Postal_Code__c = '112233'
                ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_On_Trade').getRecordTypeId()
            );
            insert account;

            EUR_CRM_PRS_Question_Set__c questionSet = new EUR_CRM_PRS_Question_Set__c();
            insert questionSet;

        //        EUR_CRM_PRS_Question__c question = new EUR_CRM_PRS_Question__c(EUR_CRM_PRS_Question_Set__c = questionSet.Id);
        //        insert question;
        //
        //        EUR_CRM_PRS_Question_Criteria__c questionCriteria = new EUR_CRM_PRS_Question_Criteria__c(EUR_CRM_PRS_Question__c = question.Id);
        //        insert questionCriteria;

            EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c(
                EUR_CRM_BrandBuildPotQuestionSet__c = questionSet.Id
            );
            insert groupOutletType;
			
        	EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.Id];
        	segmentation.RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Off_Trade').getRecordTypeId();
            segmentation.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id;
        	update segmentation;
        /*
            EUR_CRM_PRS_Segmentation__c segmentation = new EUR_CRM_PRS_Segmentation__c(
                EUR_CRM_Account__c = account.Id
                ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Off_Trade').getRecordTypeId()
                ,   EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id
            );
            insert segmentation;*/

            EUR_CRM_PRS_Answer__c answer = new EUR_CRM_PRS_Answer__c(
                EUR_CRM_PRS_Segmentation__c = segmentation.Id
            );
            insert answer;

        EUR_CRM_PRS_Segmentation__c PRS_Seg = [
                SELECT Id, RecordTypeId,RecordType.DeveloperName,EUR_CRM_Account__c
                FROM EUR_CRM_PRS_Segmentation__c
//                WHERE EUR_CRM_Account__c = :EUR_CRM_PRS_TestClassUtilityHelper.BG_Off_Account_2nd.id
                LIMIT 1
        ];
        System.Debug('PRS_Seg:' + PRS_Seg);
        Test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(PRS_Seg);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRSegmentationPage');
        rf.getParameters().put('id', PRS_Seg.id);
        Test.setCurrentPage(rf);

        EUR_CRM_PRSegmentationPageController controller = new EUR_CRM_PRSegmentationPageController(standardController);

        PageReference rf2 = new Pagereference('/apex/EUR_CRM_PRS_GroupOutletTypeSheet');
        rf2.getParameters().put('id', PRS_Seg.id);
        Test.setCurrentPage(rf2);

        EUR_CRM_PRS_GroupOutletTypeSheetCntrl GOTCtrl = new EUR_CRM_PRS_GroupOutletTypeSheetCntrl(standardController);
//            GOTCtrl.parentValue = GOTCtrl.parentOptions[0].getValue();
//            GOTCtrl.childValue = GOTCtrl.getChildOptions()[0].getValue();
        GOTCtrl.Save();
        GOTCtrl.cancel();


        PageReference rf3 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf3.getParameters().put('id', PRS_Seg.id);
        rf3.getParameters().put('type', '1');
        Test.setCurrentPage(rf3);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl1 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        //QSCtrl1.getCustomForm();
        for (String key : QSCtrl1.answerSheet.keySet()) {
            QSCtrl1.answerSheet.put(key, 'TRUE');
        }


        QSCtrl1.saveCriteriaSheet();
        try {
            QSCtrl1.getCustomForm();
        } catch (Exception e) {
        }

        PageReference rf4 = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf4.getParameters().put('id', PRS_Seg.id);
        rf4.getParameters().put('type', '2');
        Test.setCurrentPage(rf4);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl2 = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        QSCtrl2.saveCriteriaSheet();
        Test.stopTest();

        EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
        EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
        EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{
                'BE'
        });
        EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{
                'BE'
        });
        EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{
                'BE'
        });
        EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{
                'BE'
        });
        EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{
                'BE'
        });
        EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{
                'BE'
        });
        EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria('Testing', 'BE');
        EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria('Testing', 'BE');
        EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria('Testing', 'BE');
        try {
            EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(null, null, null);
        } catch (Exception e) {
        }
        try {
            EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(null, null, null);
        } catch (Exception e) {
        }
        try {
            EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(null, null, null);
        } catch (Exception e) {
        }

        try {
            controller.gotoGroupOutletTypeSheet();
        } catch (Exception e) {
        }
        try {
            controller.gotoBBPSheet();
        } catch (Exception e) {
        }
        try {
            controller.gotoBPSheet();
        } catch (Exception e) {
        }
        try {
            controller.gotoILSheet();
        } catch (Exception e) {
        }
        try {
            controller.gotoVPSheet();
        } catch (Exception e) {

        }
    }

}