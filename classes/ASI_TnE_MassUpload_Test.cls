@isTest(SeeAllData=true)
public class ASI_TnE_MassUpload_Test {
        public testMethod static void testMassUpload(){
        ASI_JP_TnE_Due_Date_Mapping__c a = new ASI_JP_TnE_Due_Date_Mapping__c(name='test');
        insert a;        
        
        test.startTest();
        ASI_TnE_MassUploadController controller = new ASI_TnE_MassUploadController();
        controller.ObjAPIName = 'ASI_JP_TnE_Due_Date_Mapping__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.recordtypeName = 'ASI_JP_TnE_Due_Date_Mapping';
        controller.fields = 'ASI_JP_TnE_Closing_Date__c,ASI_JP_TnE_Department_Category_Code__c';
        controller.fieldsLabel = 'Closing Date,Department Category Code';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_TnE_DueDateMappingTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'ASI_JP_TnE_Closing_Date__c:2013-01-01';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('ASI_JP_TnE_Closing_Date__c,ASI_JP_TnE_Department_Category_Code__c\rTest,2013-08-01');
        controller.uploadcsv();        
        
        //Test inLineVF is false;
        controller.inlineVF = false;
        controller.uploadcsv();
        
        //Test negative case - Wrong field name mapping
        controller.ObjAPIName = 'ASI_JP_TnE_Due_Date_Mapping__c';        
        controller.recordtypeName = 'ASI_JP_TnE_Due_Date_Mapping';
        controller.fields = 'ASI_JP_TnE_Closing_Date__c,ASI_JP_TnE_Department_Category_Code__c';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.lookupEXID = 'account/ParentId_Error:ParentId-par';
        controller.template = 'ASI_TnE_DueDateMappingTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('name_Error,NumberOfEmployees_Error,AnnualRevenue_Error\rJohn,Error,Error,Test_TooManyFields');
        controller.uploadcsv();
        
        //Test negative case - Wrong data
        controller.ObjAPIName = 'ASI_JP_TnE_Due_Date_Mapping__c';
        controller.recordtypeName = 'ASI_JP_TnE_Due_Date_Mapping';
        controller.fields = 'ASI_JP_TnE_Closing_Date__c,ASI_JP_TnE_Department_Category_Code__c';
        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
        controller.template = 'ASI_TnE_DueDateMappingTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,YN,201X-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        controller.uploadcsv();
        
        //Test negative case - File size exceed limit
        controller.filesize = 150000;
        controller.ObjAPIName = 'ASI_JP_TnE_Due_Date_Mapping__c';
        controller.recordtypeName = 'ASI_JP_TnE_Due_Date_Mapping';
        controller.fields = 'ASI_JP_TnE_Closing_Date__c,ASI_JP_TnE_Department_Category_Code__c';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.template = 'ASI_TnE_DueDateMappingTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('name,NumberOfEmployees,AnnualRevenue\rJohn,1,3');
        controller.uploadcsv();
        test.stopTest();
    }
}