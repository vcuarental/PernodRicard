/*********************************************************************************
    * Name: EUR_CRM_MassUpload_Test
    * Description: Test Class to cover the Mass Upload Controller and Mass Upload Batch classes
    *
    * Version History
    * 2015-09-22        Conrad Pantua Laputa      Create
*********************************************************************************/ 
@isTest
private without sharing class EUR_CRM_MassUpload_Test {
	
    static User eurSysUser;
    static EUR_CRM_Size__c bqs;
    
    static void setUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name= 'System Administrator'];
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    
	static testMethod void testMassUpload(){      
        
        setUser();
        System.runAs(eurSysUser) {
            Id ZAOnTradeAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND DeveloperName = 'EUR_ZA_On_Trade_Direct'].Id;
            Id ZAOnObjPromoRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ObjPromo__c' AND DeveloperName = 'EUR_ZA_On_Trade_Promotion'].Id;
            
            Id bqsRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c', 'EUR_ZA_Size');
            bqs = new EUR_CRM_Size__c(recordTypeId = bqsRecordTypeId, name= 'TestBQS');
            insert bqs;
            
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_ON_ALT_Promo', 'ZA O/P Action List Template');
            
            EUR_CRM_Account__c accEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_ZA_On_Trade_Direct').get(0);
            
            accEU.EUR_CRM_External_ID__c = 'EUR_ZA_Demo_Direct_1';
            insert accEU;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordTypeId = ZAOnObjPromoRecordTypeId,
                Name = 'Test OP',
                EUR_CRM_Active_End_Date__c = System.today(),
                EUR_CRM_Active_Start_Date__c = System.today(),
                EUR_CRM_Status__c = 'Draft'
            );
            insert op;
            
            // Set Targets
            Id opTargetObjProductRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_CRM_Objective_Product');
            EUR_CRM_ObjPromo_Target__c opTargetObjProduct = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetObjProductRecordTypeId,
                EUR_CRM_ObjPromo__c = op.Id
            );
            insert opTargetObjProduct;
            
            EUR_CRM_ObjPromo_Account_Mapping__c objOpAccMapping = new EUR_CRM_ObjPromo_Account_Mapping__c();
            objOpAccMapping.EUR_CRM_Account__c = accEU.Id;
            objOpAccMapping.EUR_CRM_ObjPromo__c = op.Id;
            insert objOpAccMapping;        
        
	        test.startTest();

            PageReference rf = new Pagereference('/apex/EUR_CRM_ZA_ObjectivePromoPage');
            rf.getParameters().put('ObjPromoId', op.Id);
            Test.setCurrentPage(rf);


	        EUR_CRM_MassUploadController controller = new EUR_CRM_MassUploadController();
	        controller.ObjAPIName = 'EUR_CRM_ObjPromo_Account_Mapping__c';
	        controller.recordtypeName = 'EUR_ZA_OP_Account_Mapping';
	        controller.fields = 'EUR_CRM_Account__c,EUR_CRM_Evaluation_Required__c';
	        controller.fieldsLabel = 'Account (EU)/External ID,Evaluation Required';
	        controller.template = 'EUR_CRM_AccountMappingTemplate';
	        controller.currentPageURL = String.valueof(op.id);
	        controller.inlineVF = false;
	        controller.DefaultValues = '';
	        controller.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';
            controller.parentObjectAPIName   = 'EUR_CRM_MassUploadLog__c';
	        
	        controller.filesize = 2000;
	        controller.namefile = 'test.csv';
	        controller.contentFile = blob.valueOf('Account (EU)/External ID,Evaluation Required\r' + accEU.EUR_CRM_External_ID__c + ',TRUE');
	        controller.objPromoHeaderStatus = op.EUR_CRM_Status__c;
	        
	        controller.uploadCSVByBatch();        
	        
	        controller.inlineVF = false;
	        controller.uploadCSVByBatch();
	        
	        controller.publishOpAccount();
	        controller.refreshPage2();
	        String[] testString = controller.StatusMsgs;

            controller.getIsUploadDisabled();
            controller.isPublishReady = true;
	        controller.objPromoHeaderStatus = 'Activate';
            String[] testString2 = controller.StatusMsgs;
            controller.refreshPage();

            // Attachment related Errors
            controller.filesize = 5300000;
            controller.uploadCSVByBatch();

            controller.namefile = 'test.exe';
            controller.uploadCSVByBatch();

	        //controller.ObjAPIName = 'EUR_CRM_ObjPromo_Account_Mapping__c';        
	        //controller.recordtypeName = 'EUR_ZA_OP_Account_Mapping';
	        //controller.fields = 'EUR_CRM_Account__c,EUR_CRM_Evaluation_Required__c';
	        //controller.fieldsLabel = 'Account (EU)/External ID,Evaluation Required';
	        //controller.lookupEXID = '';
	        //controller.template = 'EUR_CRM_AccountMappingTemplate';
	        //controller.currentPageURL = String.valueof(op.id);
	        //controller.inlineVF = false;
	        //controller.DefaultValues = '';
	        //controller.contentFile = blob.valueOf('name_Error,NumberOfEmployees_Error,AnnualRevenue_Error\rJohn,Error,Error,Test_TooManyFields');
	        //controller.uploadCSVByBatch();
	        
	        //controller.ObjAPIName = 'EUR_CRM_ObjPromo_Account_Mapping__c';
	        //controller.recordtypeName = 'EUR_ZA_OP_Account_Mapping';
	        //controller.fields = 'EUR_CRM_Account__c,EUR_CRM_Evaluation_Required__c';
            controller.fields = 'Name,LastModifiedDate';
	        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
	        controller.template = 'ASI_TnE_DueDateMappingTemplate';
	        controller.currentPageURL = null;
	        controller.inlineVF = true;
            controller.emailNotification = false;
	        controller.DefaultValues = 'birthdate:2013-01-01';
            controller.filesize = 2000;
	        controller.namefile = 'test.csv';
	        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,YN,201X-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
	        controller.uploadCSVByBatch();
	        

            // Empty values
            controller.fieldsLabel = 'Name,LastModifiedDate';
            controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test');
            controller.uploadCSVByBatch();

	        test.stopTest();
        }
    }

	static testMethod void testMassUploadNegativeEnded(){      
        
        setUser();
        System.runAs(eurSysUser) {
            Id ZAOnTradeAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND DeveloperName = 'EUR_ZA_On_Trade_Direct'].Id;
            Id ZAOnObjPromoRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ObjPromo__c' AND DeveloperName = 'EUR_ZA_On_Trade_Promotion'].Id;
            
            Id bqsRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c', 'EUR_ZA_Size');
            bqs = new EUR_CRM_Size__c(recordTypeId = bqsRecordTypeId, name= 'TestBQS');
            insert bqs;
            
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_ON_ALT_Promo', 'ZA O/P Action List Template');
            
            EUR_CRM_Account__c accEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_ZA_On_Trade_Direct').get(0);
            accEU.EUR_CRM_External_ID__c = 'EUR_ZA_Demo_Direct_1';
            insert accEU;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordTypeId = ZAOnObjPromoRecordTypeId,
                Name = 'Test OP',
                EUR_CRM_Active_End_Date__c = System.today(),
                EUR_CRM_Active_Start_Date__c = (date.today() - 1),
                EUR_CRM_Evaluation_Period_End_Date__c = (date.today() - 3),
                EUR_CRM_Status__c = 'Ended'
            );
            insert op;
            
            // Set Targets
            Id opTargetObjProductRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_CRM_Objective_Product');
            EUR_CRM_ObjPromo_Target__c opTargetObjProduct = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetObjProductRecordTypeId,
                EUR_CRM_ObjPromo__c = op.Id
            );
            insert opTargetObjProduct;
            
        
	        test.startTest();
	        EUR_CRM_MassUploadController controller = new EUR_CRM_MassUploadController();
	        controller.ObjAPIName = 'EUR_CRM_ObjPromo_Account_Mapping__c';
	        controller.recordtypeName = 'EUR_ZA_OP_Account_Mapping';
	        controller.fields = 'EUR_CRM_Account__c,EUR_CRM_Do_Not_Reactivate__c';
	        controller.fieldsLabel = 'Account (EU),Do Not Reactivate';
	        controller.template = 'EUR_CRM_Reactivation_Template';
	        controller.currentPageURL = String.valueof(op.id);
	        controller.inlineVF = false;
	        controller.DefaultValues = '';
	        controller.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';
            controller.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
	        
	        controller.filesize = 2000;
	        controller.namefile = 'test.csv';
	        controller.contentFile = blob.valueOf('Account (EU),Do Not Reactivate\r' + accEU.EUR_CRM_External_ID__c + ',FALSE');
	        controller.objPromoHeader = op;
	        controller.objPromoHeaderStatus = op.EUR_CRM_Status__c;
	        
	        controller.uploadCSVByBatch();        
	        
	        controller.inlineVF = false;
	        controller.uploadCSVByBatch();
	        test.stopTest();
	        controller.publishOpAccount();
        }
    }

	static testMethod void testMassUploadPositiveEnded(){      
        
        setUser();
        System.runAs(eurSysUser) {
            Id ZAOnTradeAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND DeveloperName = 'EUR_ZA_On_Trade_Direct'].Id;
            Id ZAOnObjPromoRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ObjPromo__c' AND DeveloperName = 'EUR_ZA_On_Trade_Promotion'].Id;
            
            Id bqsRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c', 'EUR_ZA_Size');
            bqs = new EUR_CRM_Size__c(recordTypeId = bqsRecordTypeId, name= 'TestBQS');
            insert bqs;
            
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_ON_ALT_Promo', 'ZA O/P Action List Template');
            
            EUR_CRM_Account__c accEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_ZA_On_Trade_Direct').get(0);
            accEU.EUR_CRM_External_ID__c = 'EUR_ZA_Demo_Direct_1';
            insert accEU;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordTypeId = ZAOnObjPromoRecordTypeId,
                Name = 'Test OP',
                EUR_CRM_Active_End_Date__c = (System.today() + 2),
                EUR_CRM_Active_Start_Date__c = (date.today() + 1),
                EUR_CRM_Evaluation_Period_End_Date__c = (date.today() + 3),
                EUR_CRM_Status__c = 'Ended'
            );
            insert op;
            
            // Set Targets
            Id opTargetObjProductRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_CRM_Objective_Product');
            EUR_CRM_ObjPromo_Target__c opTargetObjProduct = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetObjProductRecordTypeId,
                EUR_CRM_ObjPromo__c = op.Id
            );
            insert opTargetObjProduct;
            
        
	        test.startTest();
	        EUR_CRM_MassUploadController controller = new EUR_CRM_MassUploadController();
	        
	        controller.report = '';
	        controller.batchMode = true;
	        controller.objName = '';
	        controller.hasError = false;
	        controller.country = '';
	        controller.currencyStr = '';
	        
	        controller.ObjAPIName = 'EUR_CRM_ObjPromo_Account_Mapping__c';
	        controller.recordtypeName = 'EUR_ZA_OP_Account_Mapping';
	        controller.fields = 'EUR_CRM_Account__c,EUR_CRM_Do_Not_Reactivate__c';
	        controller.fieldsLabel = 'Account (EU),Do Not Reactivate';
	        controller.template = 'EUR_CRM_Reactivation_Template';
	        controller.currentPageURL = String.valueof(op.id);
	        controller.inlineVF = false;
	        controller.DefaultValues = '';
	        controller.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';
            controller.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
	        
	        controller.filesize = 2000;
	        controller.namefile = 'test.csv';
	        controller.contentFile = blob.valueOf('Account (EU),Do Not Reactivate\r' + accEU.EUR_CRM_External_ID__c + ',FALSE');
	        controller.objPromoHeader = op;
	        controller.objPromoHeaderStatus = op.EUR_CRM_Status__c;
	        
	        controller.uploadCSVByBatch();        
	        
	        //controller.inlineVF = false;
	        //controller.uploadCSVByBatch();
	        test.stopTest();
            List<EUR_CRM_ObjPromo_Account_Mapping__c> objList = [select Id from EUR_CRM_ObjPromo_Account_Mapping__c];
	        System.debug('======== objList ' + objList);	
	        controller.publishOpAccount();        
        }
    }
    
    static testMethod void testMassUploadEndDateError(){      
        
        setUser();
        System.runAs(eurSysUser) {
            Id ZAOnTradeAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND DeveloperName = 'EUR_ZA_On_Trade_Direct'].Id;
            Id ZAOnObjPromoRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ObjPromo__c' AND DeveloperName = 'EUR_ZA_On_Trade_Promotion'].Id;
            
            Id bqsRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c', 'EUR_ZA_Size');
            bqs = new EUR_CRM_Size__c(recordTypeId = bqsRecordTypeId, name= 'TestBQS');
            insert bqs;
            
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('Test O/P Action List Template', 'ZA_ON_ALT_Promo', 'ZA O/P Action List Template');
            
            EUR_CRM_Account__c accEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_ZA_On_Trade_Direct').get(0);
            accEU.EUR_CRM_External_ID__c = 'EUR_ZA_Demo_Direct_1';
            insert accEU;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordTypeId = ZAOnObjPromoRecordTypeId,
                Name = 'Test OP',
                EUR_CRM_Active_End_Date__c = (System.today() + 1),
                EUR_CRM_Active_Start_Date__c = (date.today() + 2),
                EUR_CRM_Evaluation_Period_End_Date__c = (date.today() + 3),
                EUR_CRM_Status__c = 'Ended'
            );
            insert op;
            
            // Set Targets
            Id opTargetObjProductRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', 'EUR_CRM_Objective_Product');
            EUR_CRM_ObjPromo_Target__c opTargetObjProduct = new EUR_CRM_ObjPromo_Target__c(
                recordTypeId = opTargetObjProductRecordTypeId,
                EUR_CRM_ObjPromo__c = op.Id
            );
            insert opTargetObjProduct;
            
        
	        test.startTest();
	        EUR_CRM_MassUploadController controller = new EUR_CRM_MassUploadController();
	        
	        controller.report = '';
	        controller.batchMode = true;
	        controller.objName = '';
	        controller.hasError = false;
	        controller.country = '';
	        controller.currencyStr = '';
	        
	        controller.ObjAPIName = 'EUR_CRM_ObjPromo_Account_Mapping__c';
	        controller.recordtypeName = 'EUR_ZA_OP_Account_Mapping';
	        controller.fields = 'EUR_CRM_Account__c,EUR_CRM_Do_Not_Reactivate__c';
	        controller.fieldsLabel = 'Account (EU),Do Not Reactivate';
	        controller.template = 'EUR_CRM_Reactivation_Template';
	        controller.currentPageURL = String.valueof(op.id);
	        controller.inlineVF = false;
	        controller.DefaultValues = '';
	        controller.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';
            controller.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
	        
	        controller.filesize = 2000;
	        controller.namefile = 'test.csv';
	        controller.contentFile = blob.valueOf('Account (EU),Do Not Reactivate\r' + accEU.EUR_CRM_External_ID__c + ',FALSE');
	        controller.objPromoHeader = op;
	        controller.objPromoHeaderStatus = op.EUR_CRM_Status__c;
	        
	        controller.uploadCSVByBatch();        
	        
	        //controller.inlineVF = false;
	        //controller.uploadCSVByBatch();
	        test.stopTest();
            List<EUR_CRM_ObjPromo_Account_Mapping__c> objList = [select Id from EUR_CRM_ObjPromo_Account_Mapping__c];
	        System.debug('======== objList ' + objList);	
	        controller.publishOpAccount();        
        }
    }
}