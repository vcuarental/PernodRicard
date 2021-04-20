@isTest
public class ASI_MFM_CN_MassUploadCtrl_TestClass {
 
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1; 
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    
    
        @isTest
    public static void ASI_MFM_MassUploadByBatch_Test(){
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test');
        insert c;
        
        
        test.startTest();
        ASI_MFM_CN_MassUploadByBatchController controller = new ASI_MFM_CN_MassUploadByBatchController();
        
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
        //controller.fields = 'name,NumberOfEmployees,AnnualRevenue,PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fields = 'PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fieldsLabel = 'DoNotCall,Birthdate,mobile';
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
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
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
        controller.upsertMode = true;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        String[] testGetter = controller.StatusMsgs;
        
        test.stopTest();
    }

    // 20190702 Wilson Chow
    @isTest
    static void testUploadItemGroupAllocationLookupIgnored() {
        ASI_MFM_CN_MassUploadByBatchController controller = new ASI_MFM_CN_MassUploadByBatchController();
        controller.ObjAPIName = 'ASI_CRM_Item_Group_Allocation__c';
        controller.recordtypeName = 'CN Item Group Allocation';
        controller.fields = 'ASI_CRM_Item_Group__c,ASI_CRM_Allocation_Quantity__c,ASI_CRM_Commercial_Team__c,ASI_CRM_Effective_Date__c,ASI_CRM_Region__c,ASI_CRM_Customer__c,ASI_CRM_Channel__c,ASI_CRM_UOM__c';
        controller.fieldsLabel = 'Item Group(External ID),Allocation Qty,Commercial Team,Effective Date(Month),Region,Customer,Channel,UOM';
        controller.lookupEXID = 'ASI_MFM_Item_Group__c/ASI_CRM_Item_Group__c:Item Group Recordtype&RecordTypeid,Item Group(External ID)&ASI_MFM_Item_Group_External_ID__c;ASI_CRM_Region__c/ASI_CRM_Region__c:Region Recordtype&RecordTypeid,Region&Name;ASI_CRM_AccountsAdditionalField__c/ASI_CRM_Customer__c:Customer&ASI_CRM_CN_CRM_Code__c:ignored;ASI_CRM_CN_Channel__c/ASI_CRM_Channel__c:Channel Recordtype&RecordTypeid,Channel&Name:ignored;';
        controller.inlineVF = false;
        controller.defaultValues = 'Item Group Allocation Recordtype:CN Item Group Allocation;Item Group Recordtype:CN CRM Item Group;Region Recordtype:CN Region;Channel Recordtype:CN New Channel';
        controller.parentObjectAPIName = 'ASI_MFM_Mass_Upload_Log__c';
        controller.ParentObjectUploadMsg = 'ASI_MFM_Error_Message__c';
        controller.upsertmode = false;
        controller.batchMode = true;
        controller.emailNotification = false;
        controller.opt_allOrNone = true;

        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('Item Group(External ID),Allocation Qty,Commercial Team,Effective Date(Month),Region,Customer,Channel,UOM\rCN_AB1206,100,Premium,2019-05-21,Central Region,WSSHA228,Channel New Test,CA\rCN_AB1206,1000,Premium,2019-05-21,Central Region,,Channel New Test,CA\rCN_AB1206,2000,Premium,2019-05-21,Central Region,,,CA');
        controller.uploadCSVByBatch();
    }
    // 20190702 Wilson Chow
}