/*
@Company:     Laputa Technologies
@Description: Test Class for Account_TriggerHandler.
@Author:      Laputa
@History:     MAR.4.2015 - Created
              JUL.3.2017 - Modification LCS-159
*/
@isTest(SeeAllData = false) 
private class PRH_IconicBriefcaseMappingControllerTest{
    public static USA_Survey__c sur;
    private static User u;
    private static User u2;

    static void setUpData() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        	u = PRH_TestClass_Utilities.createUser('France', 'System Administrator GDT');
        }
        
        System.runAs ( thisUser ) {
        	u2 = PRH_TestClass_Utilities.createUser('France', 'System Administrator GDT');
        }

        // Briefcase Mapping
        List<PRH_Iconic_Briefcase_Mapping__c> listBM = new List<PRH_Iconic_Briefcase_Mapping__c>();
        PRH_Iconic_Briefcase_Mapping__c bm1 = new PRH_Iconic_Briefcase_Mapping__c(
            Name = 'Absolut Elyx',
            PRH_Iconic_Brands__c = 'Absolut Elyx',
            PRH_US_Brands__c = 'Absolut Elyx'
        );
        listBM.add(bm1);
        
        PRH_Iconic_Briefcase_Mapping__c bm2 = new PRH_Iconic_Briefcase_Mapping__c(
            Name = 'Glenlivet 18YO',
            PRH_Iconic_Brands__c = 'The Glenlivet 18 and above',
            PRH_US_Brands__c = 'Glenlivet 18YO'
        );
        listBM.add(bm2);
        
        PRH_Iconic_Briefcase_Mapping__c bm3 = new PRH_Iconic_Briefcase_Mapping__c(
            Name = 'Glenlivet 21YO',
            PRH_Iconic_Brands__c = 'The Glenlivet 18 and above',
            PRH_US_Brands__c = 'Glenlivet 21YO'
        );
        listBM.add(bm3);
        system.runAs(u) {
            insert listBM;
        }
        
        //Iconic Brands
        List<PRH_Brand_Luxury_Brand__c> listNewBrand = new List<PRH_Brand_Luxury_Brand__c>();
        PRH_Brand_Luxury_Brand__c lBrand1 = new PRH_Brand_Luxury_Brand__c(
            Name = 'Absolut Elyx',
            PRH_Sequence__c = 'LCEB9991',
            PRH_PIM_ID__c = 'PIMC9991',
            PRH_Active__c = true,
            PRH_COMPETITOR_BRAND__C = False
        );
        lBrand1.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
        listNewBrand.add(lBrand1);
        
        PRH_Brand_Luxury_Brand__c lBrand2 = new PRH_Brand_Luxury_Brand__c(
            Name = 'The Glenlivet 18 and above',
            PRH_Sequence__c = 'LCEB1002',
            PRH_PIM_ID__c = 'PIM1002',
            PRH_Active__c = true,
            PRH_COMPETITOR_BRAND__C=False
        );
        lBrand2.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Pernod').getRecordTypeId();
        listNewBrand.add(lBrand2);
        
        PRH_Brand_Luxury_Brand__c lBrand3 = new PRH_Brand_Luxury_Brand__c(
            Name = 'The Glenlivet 18 and above',
            PRH_Sequence__c = 'COMP1003',
            PRH_PIM_ID__c = 'PIMC1003',
            PRH_Active__c = true,
            PRH_Competitor_Brand__c = true
        );
        lBrand3.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
        listNewBrand.add(lBrand3);
        
        PRH_Brand_Luxury_Brand__c lBrand4 = new PRH_Brand_Luxury_Brand__c(
            Name = 'The Glenlivet 18 and above',
            PRH_Sequence__c = 'COMP1004',
            PRH_PIM_ID__c = 'PIMC1004',
            PRH_Active__c = true,
            PRH_Competitor_Brand__c = true
        );
        lBrand4.recordTypeId = Schema.SObjectType.PRH_Brand_Luxury_Brand__c.getRecordTypeInfosByName().get('Luxury Account - Competitor').getRecordTypeId();
        listNewBrand.add(lBrand4);
        
        system.runAs(u) {
           insert listNewBrand;
        }
        
        //Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('USA Account').getRecordTypeId();
        Account acc = new Account(
            RecordTypeId = accRecordTypeId,
            Name = 'Iconic sync Test',
            PRH_Iconic_Account__c = true
        );
        
        system.runAs(u) {
            insert acc;
        }
        
        //Survey
        sur = new USA_Survey__c(
            Name = 'test survey'
        );
        system.runAs(u) {
            insert sur;
        }
        
        //SurveyResponse
        USA_Survey_Response__c res = new USA_Survey_Response__c(
            Name = 'Test response',
            USA_Account__c = acc.Id,
            USA_Survey__c = sur.Id
        );
        system.runAs(u) {
            insert res;
        }
        
        //Survey Question
        List<USA_Survey_Question__c> listQuestion = new List<USA_Survey_Question__c>();
        USA_Survey_Question__c sQuestion1 = new USA_Survey_Question__c(
            Name = 'test question',
            USA_Question_Category__c = 'Adjacency',
            USA_Question_Header__c = 'Activation',
            USA_Question_Label__c = 'Absolut Elyx',
            USA_Question_Type__c = 'Picklist'
        );
        listQuestion.add(sQuestion1);

        USA_Survey_Question__c sQuestion2 = new USA_Survey_Question__c(
            Name = 'test question',
            USA_Question_Category__c = 'Adjacency',
            USA_Question_Header__c = 'Menu',
            USA_Question_Label__c = 'Glenlivet 18YO',
            USA_Question_Type__c = 'Picklist'
        );
        listQuestion.add(sQuestion2);
        
        USA_Survey_Question__c sQuestion3 = new USA_Survey_Question__c(
            Name = 'test question',
            USA_Question_Category__c = 'Adjacency',
            USA_Question_Header__c = 'Distribution',
            USA_Question_Label__c = 'Glenlivet 21YO',
            USA_Question_Type__c = 'Picklist'
        );
        listQuestion.add(sQuestion3);
        
        USA_Survey_Question__c sQuestion4 = new USA_Survey_Question__c(
            Name = 'test question4',
            USA_Question_Category__c = 'Adjacency',
            USA_Question_Header__c = 'POS',  //Activation
            USA_Question_Label__c = 'Glenlivet 21YO',
            USA_Question_Type__c = 'Picklist'
        );
        listQuestion.add(sQuestion4);
        system.runAs(u) {
            insert listQuestion;
        }
        
        //Survey Answer
        USA_Survey_Answer__c ans1 = new USA_Survey_Answer__c(
            USA_Briefcase_Survey_Question__c = sQuestion1.Id,
            USA_Survey_Response__c = res.Id,
            USA_Answer__c = 'Yes',
            USA_Survey__c = sur.Id
        );
        
        system.runAs(u) {
            insert ans1;
        }
        USA_Survey_Answer__c ans2 = new USA_Survey_Answer__c(
            USA_Briefcase_Survey_Question__c = sQuestion2.Id,
            USA_Survey_Response__c = res.Id,
            USA_Answer__c = 'Yes',
            USA_Survey__c = sur.Id
        );
        system.runAs(u) {
            insert ans2;
        }
        USA_Survey_Answer__c ans3 = new USA_Survey_Answer__c(
            USA_Briefcase_Survey_Question__c = sQuestion3.Id,
            USA_Survey_Response__c = res.Id,
            USA_Answer__c = 'Yes',
            USA_Survey__c = sur.Id
        );
        system.runAs(u) {
            insert ans3;
        }
        USA_Survey_Answer__c ans4 = new USA_Survey_Answer__c(
            USA_Briefcase_Survey_Question__c = sQuestion4.Id,
            USA_Survey_Response__c = res.Id,
            USA_Answer__c = 'Yes',
            USA_Survey__c = sur.Id
        );
        system.runAs(u) {
            insert ans4;
        }
        
        //Iconic Account
        PRH_Luxury_Accounts__c lux = new PRH_Luxury_Accounts__c(
            Name = 'Test Lux',
            PRH_Account_Type__c = 'Restaurant',
            PRH_Account_Region__c = 'PR LATAM',
            PRH_Account_Market_Company__c = 'PR Brazil',
            PRH_Account_Country__c = 'Brazil',
            PRH_City__c = 'Rio de Janeiro',
            PRH_Existing_Account__c = acc.Id,
            PRH_Owner_2__c = u2.id
        );
        system.runAs(u) {
            insert lux;
        }
        PRH_Luxury_Accounts__c idIconicAccount = [SELECT Id FROM PRH_Luxury_Accounts__c WHERE (name = 'Test Lux') LIMIT 1];
        //Start Creation Collect
        PRH_Collect__c testColl = new PRH_Collect__c();
        testColl.PRH_Active__c=true; 
        //testColl.PRH_Full_Active_Le_Cercle_Portfolio__c=False;
        testColl.PRH_Number_of_Pernod_Ricard_products__c=0;
        testColl.PRH_Period_Start__c= date.newInstance(2016, 03, 01);
        testColl.PRH_Period_End__c= date.newInstance(2016, 06, 29);
        testColl.PRH_Iconic_Account__c=idIconicAccount.id;
        //End Creation Collect
        system.runAs(u) {
            insert testColl;
        }
        
        //Le Cercle Brands
        PRH_Brand_Criteria__c brand1 = new PRH_Brand_Criteria__c(
            PRH_Collect__c = testColl.Id,
            // PRH_Account_Name__c = acc.Id,
            PRH_Brand__c = lBrand1.Id
        );
        system.runAs(u) {
            insert brand1;
        }
        
        PRH_Brand_Criteria__c brand2 = new PRH_Brand_Criteria__c(
            PRH_Collect__c = testColl.Id,
            // PRH_Account_Name__c = acc.Id,
            PRH_Brand__c = lBrand2.Id
        );
        system.runAs(u) {
            insert brand2;
        }
        PRH_Brand_Criteria__c brand3 = new PRH_Brand_Criteria__c(
            PRH_Collect__c = testColl.Id,
            //PRH_Account_Name__c = acc.Id,
            PRH_Brand__c = lBrand2.Id
        );
        system.runAs(u) {
            insert brand3;
        }
        
        //Competitor Brands
        PRH_Competitor_Brands__c compBrand1 = new PRH_Competitor_Brands__c(
            PRH_Collect__c = testColl.Id,
            PRH_Iconic_Brand__c = lBrand3.Id
        );
        system.runAs(u) {
            insert compBrand1;
        }
        
        PRH_Competitor_Brands__c compBrand2 = new PRH_Competitor_Brands__c(
            PRH_Collect__c = testColl.Id,
            PRH_Iconic_Brand__c = lBrand4.Id
        );
        system.runAs(u) {
            insert compBrand2;
        }
    }
    
    public static testmethod void test_Briefcase1(){
        setUpData();
        Test.StartTest();
        
        List<USA_Survey_Answer__c> listans = [Select id, USA_Survey__c from USA_Survey_Answer__c LIMIT 1];
        system.debug('***test_Briefcase1() listans='+listans);            
             
        System.runAs(u){
            //Test1
            PRH_IconicBriefcaseMappingController cls = new PRH_IconicBriefcaseMappingController();
            cls.getIconicBrands();
            cls.brandName = 'The Glenlivet 18 and above';
            cls.emailAdd = '';
            cls.surveyAnswer= listans[0];
            system.debug('***listans[0]='+listans[0]); 
            system.debug('***cls.surveyName='+cls.surveyAnswer); 
            cls.callBriefcaseSync_BatchJob();
        
            PRH_IconicBriefcaseMappingBatch clsBatch = new PRH_IconicBriefcaseMappingBatch('The Glenlivet 18 and above', sur.Id, '');
            ID batchprocessid1;   
            Database.executeBatch(clsBatch);
       
            //Test2
            PRH_IconicBriefcaseMappingController cls2 = new PRH_IconicBriefcaseMappingController();
            cls2.getIconicBrands();
            cls2.brandName = 'All';
            cls2.emailAdd = 'testEmailAdd@gymail.com';
            cls2.surveyName = sur.Id;
            
            cls2.callBriefcaseSync_BatchJob();
            
            PRH_IconicBriefcaseMappingBatch clsBatch2 = new PRH_IconicBriefcaseMappingBatch('All', sur.Id, 'testEmailAdd@gymail.com');
            ID batchprocessid2 = Database.executeBatch(clsBatch2); 
        }
        
        Test.StopTest();
    }
}