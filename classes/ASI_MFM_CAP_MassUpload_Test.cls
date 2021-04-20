@isTest
public class ASI_MFM_CAP_MassUpload_Test {

    public testMethod static void testMassUpload(){
        ASI_MFM_Budget__c a = ASI_MFM_CAP_TestClassHelper.createBudget();       
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Budget__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.emailNotification = true;
        controller.recordtypeName = 'CAP Budget';
        controller.fields = 'ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c';
        controller.fieldsLabel = 'P1 Amount,P2 Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'AP Recordtype:CAP AP Code;BU Recordtype:CAP BU;Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c\r220,420');
        controller.uploadcsv();        
        
        //Test inLineVF is false;
        controller.inlineVF = false;
        controller.uploadcsv();
        
        //Test negative case - Wrong field name mapping
        controller.ObjAPIName = 'ASI_MFM_Budget__c';        
        controller.recordtypeName = 'CAP Budget';
        controller.fields = 'ASI_MFM_Currency__c,ASI_MFM_Fiscal_Year__c,ASI_MFM_Type__c,ASI_MFM_AP_Code__c,ASI_MFM_BU__c,ASI_MFM_Domain__c,ASI_MFM_Type__c,ASI_MFM_Budget_Type__c,ASI_MFM_Plan__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Remarks__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c';
        controller.fieldsLabel = 'Currency,Fiscal Year,Type,AP Code,BU Code,Domain,Type,Budget Type,Plan ID,Plan Line Item,Remarks,P1 Amount,P2 Amount,P3 Amount,P4 Amount,P5 Amount,P6 Amount,P7 Amount,P8 Amount,P9 Amount,P10 Amount,P11 Amount,P12 Amount';
        controller.lookupEXID = 'account/ParentId_Error:ParentId-par';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('name_Error,NumberOfEmployees_Error,AnnualRevenue_Error\rJohn,Error,Error,Test_TooManyFields');
        controller.uploadcsv();
        
        //Test negative case - Wrong data
        controller.ObjAPIName = 'ASI_MFM_Budget__c';        
        controller.recordtypeName = 'CAP Budget';
        controller.fields = 'ASI_MFM_Currency__c,ASI_MFM_Fiscal_Year__c,ASI_MFM_Type__c,ASI_MFM_AP_Code__c,ASI_MFM_BU__c,ASI_MFM_Domain__c,ASI_MFM_Type__c,ASI_MFM_Budget_Type__c,ASI_MFM_Plan__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Remarks__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c';
        controller.fieldsLabel = 'Currency,Fiscal Year,Type,AP Code,BU Code,Domain,Type,Budget Type,Plan ID,Plan Line Item,Remarks,P1 Amount,P2 Amount,P3 Amount,P4 Amount,P5 Amount,P6 Amount,P7 Amount,P8 Amount,P9 Amount,P10 Amount,P11 Amount,P12 Amount';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,YN,201X-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        controller.uploadcsv();
        
        //Test negative case - File size exceed limit
        controller.filesize = 150000;
        controller.ObjAPIName = 'ASI_MFM_Budget__c';        
        controller.recordtypeName = 'CAP Budget';
        controller.fields = 'ASI_MFM_Currency__c,ASI_MFM_Fiscal_Year__c,ASI_MFM_Type__c,ASI_MFM_AP_Code__c,ASI_MFM_BU__c,ASI_MFM_Domain__c,ASI_MFM_Type__c,ASI_MFM_Budget_Type__c,ASI_MFM_Plan__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Remarks__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c';
        controller.fieldsLabel = 'Currency,Fiscal Year,Type,AP Code,BU Code,Domain,Type,Budget Type,Plan ID,Plan Line Item,Remarks,P1 Amount,P2 Amount,P3 Amount,P4 Amount,P5 Amount,P6 Amount,P7 Amount,P8 Amount,P9 Amount,P10 Amount,P11 Amount,P12 Amount';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.contentFile = blob.valueOf('ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c\r220,420');
        controller.uploadcsv();
        test.stopTest();
    }

    @isTest
    public static void testMassUpload2(){
        Account a = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test');
        insert c;
        
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'Contact';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'AccountID';
        controller.recordtypeName = 'contactType1';
        controller.fields = 'firstname,lastname,description,reportstoid,DoNotCall,Birthdate,reportstoid';
        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
        controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,Y,2013-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        controller.uploadcsv();
        
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'name,NumberOfEmployees,AnnualRevenue';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadcsv();
        
        
        test.stopTest();
    }

    @isTest
    public static void testMassUploadBatch(){
        Account a = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test');
        insert c;
        
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'Contact';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'AccountID';
        controller.recordtypeName = 'contactType1';
        controller.fields = 'firstname,lastname,description,reportstoid,DoNotCall,Birthdate,reportstoid';
        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
        controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,Y,2013-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        controller.uploadCSVByBatch();
        
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'name,NumberOfEmployees,AnnualRevenue';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        
        test.stopTest();
    }
    
    @isTest
    public static void testMassUploadBatch2(){
        Account a = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test');
        insert c;
        
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'Contact';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'AccountID';
        controller.recordtypeName = 'contactType1';
        controller.fields = 'firstname,lastname,description,reportstoid,DoNotCall,Birthdate,reportstoid';
        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
        controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,Y,2013-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        //controller.currentPageURL = null;
        controller.uploadCSVByBatch();
        
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'name,NumberOfEmployees,AnnualRevenue';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        String[] msgsTest = controller.StatusMsgs;
        
        test.stopTest();
    }
    
    public testMethod static void testMassUploadBatch3(){
        ASI_MFM_Budget__c a = ASI_MFM_CAP_TestClassHelper.createBudget();       
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Budget__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.emailNotification = true;
        controller.recordtypeName = 'CAP Budget';
        controller.fields = 'ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c';
        controller.fieldsLabel = 'P1 Amount,P2 Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'AP Recordtype:CAP AP Code;BU Recordtype:CAP BU;Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller.parentObjectAPIName = 'ASI_MFM_Budget__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_Remarks__c';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c\r220,420');
        controller.upsertMode = true;
        controller.uploadCSVByBatch();        
        
        test.stopTest();
    }
    
    public testMethod static void testMassUploadBatch4(){
        ASI_MFM_Plan__c a = ASI_MFM_CAP_TestClassHelper.createPlan();       
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Plan__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.emailNotification = true;
        controller.recordtypeName = 'CAP Plan';
        controller.fields = 'name,ASI_MFM_Plan_Type__c';
        controller.fieldsLabel = 'Plan ID,Plan Type';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller.parentObjectAPIName = 'ASI_MFM_Plan__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_Plan_Description__c';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('name,ASI_MFM_Plan_Type__c\rtest,CAPEX');
        controller.upsertMode = true;
        controller.uploadCSVByBatch();        
        
        test.stopTest();
    }
    
    public testMethod static void testMassUploadBatch5(){
        ASI_MFM_Plan__c a = ASI_MFM_CAP_TestClassHelper.createPlan();    
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_CAP_TestClassHelper.createPlanLines(a);  
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Plan_Line_Item__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.emailNotification = true;
        controller.recordtypeName = 'CAP Plan';
        controller.fields = 'name,ASI_MFM_Total_Cost__c';
        controller.fieldsLabel = 'Plan Line Item ID,Plan Line Amount';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(planLine.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller.parentObjectAPIName = 'ASI_MFM_Plan_Line_Item__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_List_Item_Description__c';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('name,ASI_MFM_Total_Cost__c\rtest,200');
        controller.upsertMode = true;
        controller.uploadCSVByBatch();        
        
        test.stopTest();
    }
    
    public testMethod static void testMassUploadBatch6(){
        ASI_MFM_PO__c a = ASI_MFM_CAP_TestClassHelper.createPo();    
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(a);    
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_PO_Line_Item__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.emailNotification = true;
        controller.recordtypeName = 'CAP PO Line Item';
        controller.fields = 'name,ASI_MFM_Original_Amount__c,ASI_MFM_PO_Percentage__c';
        controller.fieldsLabel = 'PO Line Item ID,Original Amount,PO %';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(poLine.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller.parentObjectAPIName = 'ASI_MFM_PO_Line_Item__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_List_Item_Description__c';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('name,ASI_MFM_Original_Amount__c,ASI_MFM_PO_Percentage__c\rtest,200,3');
        controller.upsertMode = true;
        controller.uploadCSVByBatch();        
        
        test.stopTest();
    }
    
    public testMethod static void testMassUploadBatch7(){
        ASI_MFM_Budget__c a = ASI_MFM_CAP_TestClassHelper.createBudget();       
        
        test.startTest();
        ASI_MFM_CAP_MassUploadByBatchController controller = new ASI_MFM_CAP_MassUploadByBatchController();
        String[] testGetter = controller.StatusMsgs;
        controller.ObjAPIName = 'ASI_MFM_Budget__c';
        //controller.parentID = String.valueof(a.id);
        //controller.parentField = 'AccountID';
        controller.emailNotification = true;
        controller.recordtypeName = 'CAP Budget';
        controller.fields = 'ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_A_C_Code__c';
        controller.fieldsLabel = 'P1 Amount,P2 Amount,A/C Code';
        //controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_CAP_Mass_Upload_Budget_Template';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = false;
        controller.DefaultValues = 'AP Recordtype:CAP AP Code;BU Recordtype:CAP BU;Plan Recordtype:CAP Plan Read-Only;Plan Line Item Recordtype:CAP Plan Line Item';
        controller.parentObjectAPIName = 'ASI_MFM_Budget__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_Remarks__c';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_A_C_Code__c\r220,420,testestest');
        controller.upsertMode = true;
        controller.uploadCSVByBatch();        
        
        test.stopTest();
    }
    

}