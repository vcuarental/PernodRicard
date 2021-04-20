@IsTest /*(IsParallel = true)*/
private class EUR_CRM_PRS_QuestionsSheetControllerTest {


    @IsTest
    static void simpleTest() {
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

        EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.id];
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

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(segmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf.getParameters().put('id', segmentation.id);
        rf.getParameters().put('type', '1');
        Test.setCurrentPage(rf);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        for (String key : QSCtrl.answerSheet.keySet()) {
            QSCtrl.answerSheet.put(key, '0');
        }
        QSCtrl.saveCriteriaSheet();
        QSCtrl.initQuestionAnswerMap();
        QSCtrl.initAnswerSheet();
//        QSCtrl.savePotentialLevels(questionCriteria.Id);
        QSCtrl.assignBusinessPotential(1, 'got');
        QSCtrl.assignImageLevel(1, 'got');
        QSCtrl.assignVolumePotential(1, 'got');
        QSCtrl.assignPriorityMatrix();
        QSCtrl.getBPFinalResultsCriteria('', '');
        QSCtrl.getILFinalResultsCriteria('', '');
        QSCtrl.getVPFinalResultsCriteria('', '');
        QSCtrl.getPriorityLevelMatrices('');
        QSCtrl.createKey('A', 'B');
        QSCtrl.addPageErrorMessage('Message');
        try {
            QSCtrl.getCustomForm();
        } catch (Exception e) {

        }
    }

    @IsTest
    static void assignBrandBuildingPotentialTest() {
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
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()
        );
        insert groupOutletType;

        EUR_CRM_PRS_Seg_Aspect__c segAspect = new EUR_CRM_PRS_Seg_Aspect__c();
        insert segAspect;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id
        ,   EUR_CRM_Minimum_Weight__c = 1
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect_Criteria__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Aspect_Criteria_BBP').getRecordTypeId()
        );
        insert segAspectCriteria;
		
        EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.id];
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

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(segmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf.getParameters().put('id', segmentation.id);
        rf.getParameters().put('type', '1');
        Test.setCurrentPage(rf);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        for (String key : QSCtrl.answerSheet.keySet()) {
            QSCtrl.answerSheet.put(key, '0');
        }
        String gotName = [SELECT Id, Name FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE Id =: groupOutletType.Id LIMIT 1][0].Name;
        System.debug('\n\n gotName => ' + JSON.serializePretty(gotName) + '\n');
        QSCtrl.saveCriteriaSheet();
//        QSCtrl.initQuestionAnswerMap();
//        QSCtrl.initAnswerSheet();
        QSCtrl.assignBrandBuildingPotential(1, groupOutletType.Id);
//        QSCtrl.assignBusinessPotential(1, gotName);
//        QSCtrl.assignImageLevel(1, gotName);
//        QSCtrl.assignVolumePotential(1, gotName);
//        QSCtrl.assignPriorityMatrix();
//        QSCtrl.getBPFinalResultsCriteria('', '');
//        QSCtrl.getILFinalResultsCriteria('', '');
//        QSCtrl.getVPFinalResultsCriteria('', '');
//        QSCtrl.getPriorityLevelMatrices('');
//        QSCtrl.createKey('A', 'B');
//        QSCtrl.addPageErrorMessage('Message');
        try {
            QSCtrl.getCustomForm();
        } catch (Exception e) {

        }
    }

    @IsTest
    static void assignBusinessPotentialTest() {
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
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()
        );
        insert groupOutletType;

        EUR_CRM_PRS_Seg_Aspect__c segAspect = new EUR_CRM_PRS_Seg_Aspect__c();
        insert segAspect;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id
        ,   EUR_CRM_Minimum_Weight__c = 1
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect_Criteria__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Aspect_Criteria_BP').getRecordTypeId()
        );
        insert segAspectCriteria;
	
        EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.id];
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

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(segmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf.getParameters().put('id', segmentation.id);
        rf.getParameters().put('type', '2');
        Test.setCurrentPage(rf);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        for (String key : QSCtrl.answerSheet.keySet()) {
            QSCtrl.answerSheet.put(key, '0');
        }
        String gotName = [SELECT Id, Name FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE Id =: groupOutletType.Id LIMIT 1][0].Name;
        System.debug('\n\n gotName => ' + JSON.serializePretty(gotName) + '\n');
        QSCtrl.saveCriteriaSheet();
//        QSCtrl.initQuestionAnswerMap();
//        QSCtrl.initAnswerSheet();
        QSCtrl.assignBusinessPotential(1, gotName);
//        QSCtrl.assignImageLevel(1, gotName);
//        QSCtrl.assignVolumePotential(1, gotName);
//        QSCtrl.assignPriorityMatrix();
//        QSCtrl.getBPFinalResultsCriteria('', '');
//        QSCtrl.getILFinalResultsCriteria('', '');
//        QSCtrl.getVPFinalResultsCriteria('', '');
//        QSCtrl.getPriorityLevelMatrices('');
//        QSCtrl.createKey('A', 'B');
//        QSCtrl.addPageErrorMessage('Message');
        try {
            QSCtrl.getCustomForm();
        } catch (Exception e) {

        }
    }

    @IsTest
    static void assignImageLevelTest() {
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
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()
        );
        insert groupOutletType;

        EUR_CRM_PRS_Seg_Aspect__c segAspect = new EUR_CRM_PRS_Seg_Aspect__c();
        insert segAspect;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id
        ,   EUR_CRM_Minimum_Weight__c = 1
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect_Criteria__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Aspect_Criteria_Image_Level').getRecordTypeId()
        );
        insert segAspectCriteria;

        EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.id];
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

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(segmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf.getParameters().put('id', segmentation.id);
        rf.getParameters().put('type', '3');
        Test.setCurrentPage(rf);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        for (String key : QSCtrl.answerSheet.keySet()) {
            QSCtrl.answerSheet.put(key, '0');
        }
        String gotName = [SELECT Id, Name FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE Id =: groupOutletType.Id LIMIT 1][0].Name;
        System.debug('\n\n gotName => ' + JSON.serializePretty(gotName) + '\n');
        QSCtrl.saveCriteriaSheet();
//        QSCtrl.initQuestionAnswerMap();
//        QSCtrl.initAnswerSheet();
//        QSCtrl.assignBusinessPotential(1, gotName);
        QSCtrl.assignImageLevel(1, gotName);
//        QSCtrl.assignVolumePotential(1, gotName);
//        QSCtrl.assignPriorityMatrix();
//        QSCtrl.getBPFinalResultsCriteria('', '');
//        QSCtrl.getILFinalResultsCriteria('', '');
//        QSCtrl.getVPFinalResultsCriteria('', '');
//        QSCtrl.getPriorityLevelMatrices('');
//        QSCtrl.createKey('A', 'B');
//        QSCtrl.addPageErrorMessage('Message');
        try {
            QSCtrl.getCustomForm();
        } catch (Exception e) {

        }
    }

    @IsTest
    static void assignVolumePotentialTest() {
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
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()
        );
        insert groupOutletType;

        EUR_CRM_PRS_Seg_Aspect__c segAspect = new EUR_CRM_PRS_Seg_Aspect__c();
        insert segAspect;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id
        ,   EUR_CRM_Minimum_Weight__c = 1
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect_Criteria__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential').getRecordTypeId()
        );
        insert segAspectCriteria;
	
        EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.id];
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

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(segmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf.getParameters().put('id', segmentation.id);
        rf.getParameters().put('type', '4');
        Test.setCurrentPage(rf);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        for (String key : QSCtrl.answerSheet.keySet()) {
            QSCtrl.answerSheet.put(key, '0');
        }
        String gotName = [SELECT Id, Name FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE Id =: groupOutletType.Id LIMIT 1][0].Name;
        System.debug('\n\n gotName => ' + JSON.serializePretty(gotName) + '\n');
        QSCtrl.saveCriteriaSheet();
//        QSCtrl.initQuestionAnswerMap();
//        QSCtrl.initAnswerSheet();
//        QSCtrl.assignBusinessPotential(1, gotName);
//        QSCtrl.assignImageLevel(1, gotName);
        QSCtrl.assignVolumePotential(1, gotName);
//        QSCtrl.assignPriorityMatrix();
//        QSCtrl.getBPFinalResultsCriteria('', '');
//        QSCtrl.getILFinalResultsCriteria('', '');
//        QSCtrl.getVPFinalResultsCriteria('', '');
//        QSCtrl.getPriorityLevelMatrices('');
//        QSCtrl.createKey('A', 'B');
//        QSCtrl.addPageErrorMessage('Message');
        try {
            QSCtrl.getCustomForm();
        } catch (Exception e) {

        }
    }

    @IsTest
    private static void savePotentialLevelsTest() {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(
            Name = 'Acc'
        ,   EUR_CRM_Postal_Code__c = '112233'
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_On_Trade').getRecordTypeId()
        );
        insert account;

        EUR_CRM_PRS_Question_Set__c questionSet = new EUR_CRM_PRS_Question_Set__c();
        insert questionSet;

        EUR_CRM_PRS_Question__c question = new EUR_CRM_PRS_Question__c(EUR_CRM_PRS_Question_Set__c = questionSet.Id);
        insert question;

        EUR_CRM_PRS_Question_Criteria__c questionCriteria = new EUR_CRM_PRS_Question_Criteria__c(EUR_CRM_PRS_Question__c = question.Id);
        insert questionCriteria;

        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c(
            EUR_CRM_BrandBuildPotQuestionSet__c = questionSet.Id
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_On_Trade_Group_Outlet_Type').getRecordTypeId()
        );
        insert groupOutletType;

        EUR_CRM_PRS_Seg_Aspect__c segAspect = new EUR_CRM_PRS_Seg_Aspect__c();
        insert segAspect;

        EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria = new EUR_CRM_PRS_Seg_Aspect_Criteria__c(
            EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletType.Id
        ,   EUR_CRM_Minimum_Weight__c = 1
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect_Criteria__c.getRecordTypeInfosByDeveloperName().get('EUR_PRS_Segmentation_Aspect_Criteria_BBP').getRecordTypeId()
        );
        insert segAspectCriteria;
	
        EUR_CRM_PRS_Segmentation__c segmentation = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :account.id];
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

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(segmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_PRS_QuestionsSheet');
        rf.getParameters().put('id', segmentation.id);
        rf.getParameters().put('type', '1');
        Test.setCurrentPage(rf);

        EUR_CRM_PRS_QuestionsSheetController QSCtrl = new EUR_CRM_PRS_QuestionsSheetController(standardController);
        for (String key : QSCtrl.answerSheet.keySet()) {
            QSCtrl.answerSheet.put(key, '0');
        }
        String gotName = [SELECT Id, Name FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE Id =: groupOutletType.Id LIMIT 1][0].Name;
        System.debug('\n\n gotName => ' + JSON.serializePretty(gotName) + '\n');
        QSCtrl.saveCriteriaSheet();
        QSCtrl.savePotentialLevels(questionCriteria.Id);
//        QSCtrl.initQuestionAnswerMap();
//        QSCtrl.initAnswerSheet();
//        QSCtrl.assignBusinessPotential(1, gotName);
//        QSCtrl.assignImageLevel(1, gotName);
//        QSCtrl.assignVolumePotential(1, gotName);
//        QSCtrl.assignPriorityMatrix();
//        QSCtrl.getBPFinalResultsCriteria('', '');
//        QSCtrl.getILFinalResultsCriteria('', '');
//        QSCtrl.getVPFinalResultsCriteria('', '');
//        QSCtrl.getPriorityLevelMatrices('');
//        QSCtrl.createKey('A', 'B');
//        QSCtrl.addPageErrorMessage('Message');
        try {
            QSCtrl.getCustomForm();
        } catch (Exception e) {

        }
    }


}