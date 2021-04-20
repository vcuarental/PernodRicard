@isTest
public class ASI_GnH_KR_UploadRecipientCtrlTest{
    
    @testSetUp static void initData(){
        List<User> userList = ASI_GnH_KR_TestClassHelper.createTestUser();
        
    }
    
    
    static testMethod void testMassUpload(){
        
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c testRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                                ASI_GnH_Applicant__c = appliciant.Id,
                                                                ASI_GnH_Amount_per_Recipient__c = 25000,
                                                                ASI_GnH_PAX__c = 1,
                                                                ASI_GnH_Type__c = 'Gifts',
                                                                ASI_GnH_Recipient_Type__c = 'Others');
        insert testRequest;
        
        Test.startTest();
        system.runAs(appliciant){
            ASI_GnH_KR_UploadRecipientController tmpClass = new ASI_GnH_KR_UploadRecipientController();
            
            String[] myArray = new List<String>();
            
            tmpClass.ObjAPIName = 'ASI_GnH_Request_Recipient__c';
            tmpClass.fields = 'ASI_GnH_Sys_Name__c,ASI_GnH_Sys_Title__c,ASI_GnH_Sys_Organization__c,ASI_GnH_Sys_Company_Address__c,ASI_GnH_Sys_Mobile__c,ASI_GnH_Sys_Email__c';
            tmpClass.fieldsLabel = 'Name,Title,Organisation,Company Address,Mobile,Email';
            tmpClass.parentField = 'ASI_GnH_Request__c';
            tmpClass.parentID = testRequest.Id;
            tmpClass.template = 'ASI_GnH_KR_MassUpload_Recipient_Template';
            tmpClass.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
            tmpClass.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
            tmpClass.recEXID = 'Id';
            tmpClass.recEXIDcol = 'Id';
            tmpClass.upsertMode = true;
            tmpClass.batchMode = true;
            tmpClass.report = '';
            tmpClass.lookupEXID = '';
            tmpClass.DefaultValues = '';
            tmpClass.opt_allOrNone = true;
            tmpClass.currentPageURL = '';
            tmpClass.inlineVF = true;
            tmpClass.emailNotification = true;
            tmpClass.namefile = 'test.csv';
            tmpClass.filesize = 2000;
            tmpClass.reloadNeeded = false;
            tmpClass.currentPageURLOutput = '';
            tmpClass.objName = '';
            tmpClass.hasError = false;
            tmpClass.msgGenerateTnEEmail = '';
            tmpClass.contentFile = blob.valueOf('Name,Title,Organisation,Company Address,Mobile,Email\Test Name,Staff,Test Org,Test Address,12345678,testing@test.com');
            
            tmpClass.uploadCSVByBatch();
            tmpClass.getItems();
            
            for(String a : tmpClass.StatusMsgs){
                myArray.add(a);
            }
            
            Test.stopTest();
        }
        
    }
    
    static testMethod void testMassUploadErrorFileSize(){
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c testRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                                ASI_GnH_Applicant__c = appliciant.Id,
                                                                ASI_GnH_Amount_per_Recipient__c = 25000,
                                                                ASI_GnH_PAX__c = 1,
                                                                ASI_GnH_Type__c = 'Gifts',
                                                                ASI_GnH_Recipient_Type__c = 'Others');
        insert testRequest;
        
        Test.startTest();
        
        ASI_GnH_KR_UploadRecipientController tmpClass = new ASI_GnH_KR_UploadRecipientController();
        
        String[] myArray = new List<String>();
        
        tmpClass.ObjAPIName = 'ASI_GnH_Request_Recipient__c';
        tmpClass.fields = 'ASI_GnH_Sys_Name__c,ASI_GnH_Sys_Title__c,ASI_GnH_Sys_Organization__c,ASI_GnH_Sys_Company_Address__c,ASI_GnH_Sys_Mobile__c,ASI_GnH_Sys_Email__c';
        tmpClass.fieldsLabel = 'Name,Title,Organisation,Company Address,Mobile,Email';
        tmpClass.parentField = 'ASI_GnH_Request__c';
        tmpClass.parentID = testRequest.Id;
        tmpClass.template = 'ASI_GnH_KR_MassUpload_Recipient_Template';
        tmpClass.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
        tmpClass.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
        tmpClass.recEXID = 'Id';
        tmpClass.recEXIDcol = 'Id';
        tmpClass.upsertMode = true;
        tmpClass.batchMode = true;
        tmpClass.report = '';
        tmpClass.lookupEXID = '';
        tmpClass.DefaultValues = '';
        tmpClass.opt_allOrNone = true;
        tmpClass.currentPageURL = '';
        tmpClass.inlineVF = true;
        tmpClass.emailNotification = true;
        tmpClass.namefile = 'test.csv';
        tmpClass.filesize = 6242880;
        tmpClass.contentFile = blob.valueOf('Name,Title,Organisation,Company Address,Mobile,Email\Test Name,Staff,Test Org,Test Address,12345678,testing@test.com');
        
        tmpClass.uploadCSVByBatch();
        
        Test.stopTest();
        
        
    }
    static testMethod void testMassUploadErrorFileType(){
        User appliciant = [select id from user where CompanyName = 'Test Company' and ASI_GnH_Department__c = 'Kyunggi WS'];
        Id routeTypeDetailRtId = Global_RecordTypeCache.getRtId('ASI_GnH_Request__c' + 'ASI_GnH_KR_Offer_Request');
        ASI_GnH_Request__c testRequest = new ASI_GnH_Request__c(recordTypeId = routeTypeDetailRtId,
                                                                ASI_GnH_Applicant__c = appliciant.Id,
                                                                ASI_GnH_Amount_per_Recipient__c = 25000,
                                                                ASI_GnH_PAX__c = 1,
                                                                ASI_GnH_Type__c = 'Gifts',
                                                                ASI_GnH_Recipient_Type__c = 'Others');
        insert testRequest;
        
        Test.startTest();
        
        ASI_GnH_KR_UploadRecipientController tmpClass = new ASI_GnH_KR_UploadRecipientController();
        
        String[] myArray = new List<String>();
        
        tmpClass.ObjAPIName = 'ASI_GnH_Request_Recipient__c';
        tmpClass.fields = 'ASI_GnH_Sys_Name__c,ASI_GnH_Sys_Title__c,ASI_GnH_Sys_Organization__c,ASI_GnH_Sys_Company_Address__c,ASI_GnH_Sys_Mobile__c,ASI_GnH_Sys_Email__c';
        tmpClass.fieldsLabel = 'Name,Title,Organisation,Company Address,Mobile,Email';
        tmpClass.parentField = 'ASI_GnH_Request__c';
        tmpClass.parentID = testRequest.Id;
        tmpClass.template = 'ASI_GnH_KR_MassUpload_Recipient_Template';
        tmpClass.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
        tmpClass.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
        tmpClass.recEXID = 'Id';
        tmpClass.recEXIDcol = 'Id';
        tmpClass.upsertMode = true;
        tmpClass.batchMode = true;
        tmpClass.report = '';
        tmpClass.lookupEXID = '';
        tmpClass.DefaultValues = '';
        tmpClass.opt_allOrNone = true;
        tmpClass.currentPageURL = '';
        tmpClass.inlineVF = true;
        tmpClass.emailNotification = true;
        tmpClass.namefile = 'test.excel';
        tmpClass.filesize = 42880;
        tmpClass.contentFile = blob.valueOf('Name,Title,Organisation,Company Address,Mobile,Email\Test Name,Staff,Test Org,Test Address,12345678,testing@test.com');
        
        tmpClass.uploadCSVByBatch();
        
        Test.stopTest();
        
    }
}