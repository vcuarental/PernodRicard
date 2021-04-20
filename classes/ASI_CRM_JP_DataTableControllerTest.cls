@isTest
public class ASI_CRM_JP_DataTableControllerTest{
	//public enum Operator {EQUALS}
    @isTest
    static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        String jsonInput = '{ "sObjectName": "Account" ,"selectFields":"Id" }';
        String jsonInput2 = Json.serialize(acc);
        String jsonInput3 = Json.serialize(lstacc);
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('pageRequest',jsonInput);
        pageRef.getParameters().put('recordId',acc.Id);
        pageRef.getParameters().put('record',jsonInput2);
        pageRef.getParameters().put('recordList',jsonInput3);
        pageRef.getParameters().put('clonedRecordList',jsonInput3);
        pageRef.getParameters().put('addedRecordList',jsonInput3);
        pageRef.getParameters().put('addedClonedRecordList',jsonInput3);
        ASI_CRM_JP_DataTableController records = new ASI_CRM_JP_DataTableController();
        //ApexPages.StandardController sc = new ApexPages.StandardController();
       // PageReference result = records.findRecords();
       // 
       //String getUnSavedRecordsJsonString = records.unSavedRecordsString();
       // records.findRecords();
       List<String> lstString = new List<String>();
        lstString.add('Test');
        
		String JsonString =  JSON.serialize(acc);
       	ASI_CRM_JP_DataTableService.PageRequest ap = new ASI_CRM_JP_DataTableService.PageRequest();
        ASI_CRM_JP_DataTableService.deserializePageRequest(JsonString,'Account',null);
        ASI_CRM_JP_DataTableService.Criteria criteria = new ASI_CRM_JP_DataTableService.Criteria();
        criteria.getFieldName();
        criteria.setFieldName('fieldName');
        criteria.getKeywords();
        criteria.getOperator();
        criteria.getType();
        criteria.setType('type');
        criteria.setKeywords(lstString);
        criteria.setOperator(ASI_CRM_JP_DataTableService.Operator.EQUALS);
        ap.setsObjectName('Account');
        ap.combine(ap);
        ap.getPageSize();
        ap.getPageNumber();
        ap.setSelectFields('Id');
        ap.getSelectFields();
        ap.setDefaultSortOrder('ASC');
        ap.setDefaultSortField('Id');
        ap.setSortOrder('DESC');
        ap.setSortField('Name');
        ASI_CRM_JP_DataTableService.clean(null);
        ASI_CRM_JP_DataTableService.clean('value');
        //records.pageRequestString = ap.pageRequestString();
        records.cloneRecord();
        /*
        records.pageRequestString  = 'pageRequest';
        records.deleteRecord();
        records.redirectToRecord();
        records.findRecords();
        
        records.updateRecords();
		*/
        //records.getResults();
    }
    
    @isTest
    static void testMethod2(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        String jsonInput = '{ "sObjectName": "Account" ,"selectFields":"Id" }';
        String jsonInput2 = Json.serialize(acc);
        String jsonInput3 = Json.serialize(lstacc);
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('pageRequest',jsonInput);
        pageRef.getParameters().put('recordId',acc.Id);
        pageRef.getParameters().put('record',jsonInput2);
        pageRef.getParameters().put('recordList',jsonInput3);
        pageRef.getParameters().put('clonedRecordList',jsonInput3);
        pageRef.getParameters().put('addedRecordList',jsonInput3);
        pageRef.getParameters().put('addedClonedRecordList',jsonInput3);
        ASI_CRM_JP_DataTableController records = new ASI_CRM_JP_DataTableController();

        records.pageRequestString  = 'pageRequest';
        records.deleteRecord();
    }
    
    @isTest
    static void testMethod3(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        String jsonInput = '{ "sObjectName": "Account" ,"selectFields":"Id" }';
        String jsonInput2 = Json.serialize(acc);
        String jsonInput3 = Json.serialize(lstacc);
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('pageRequest',jsonInput);
        pageRef.getParameters().put('recordId',acc.Id);
        pageRef.getParameters().put('record',jsonInput2);
        pageRef.getParameters().put('recordList',jsonInput3);
        //pageRef.getParameters().put('clonedRecordList',jsonInput3);
        //pageRef.getParameters().put('addedRecordList',jsonInput3);
        pageRef.getParameters().put('addedClonedRecordList',jsonInput3);
        ASI_CRM_JP_DataTableController records = new ASI_CRM_JP_DataTableController();
		records.deleteRecord();
        records.pageRequestString  = 'pageRequest';
        records.redirectToRecord();
    }


    @isTest
    static void testMethod4(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        List<Account> lstacc = new List<Account>();
        lstacc.add(acc);
        String jsonInput = '{ "sObjectName": "Account" ,"selectFields":"Id" }';
        String jsonInput2 = Json.serialize(acc);
        String jsonInput3 = Json.serialize(lstacc);
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('pageRequest',jsonInput);
        pageRef.getParameters().put('recordId',acc.Id);
        pageRef.getParameters().put('record',jsonInput2);
        pageRef.getParameters().put('recordList',jsonInput3);
        //pageRef.getParameters().put('clonedRecordList',jsonInput3);
        //pageRef.getParameters().put('addedRecordList',jsonInput3);
        pageRef.getParameters().put('addedClonedRecordList',jsonInput3);
        ASI_CRM_JP_DataTableController records = new ASI_CRM_JP_DataTableController();

        records.pageRequestString  = 'pageRequest';
        records.findRecords();
        // Wilson Chow
        /*
        records.updateRecords();
                    delete acc;
        */
        // Wilson Chow

    }
    
    @isTest
    static void testMethod5(){
        Lead l = 
            new Lead(
                RecordTypeId = Global_RecordTypeCache.getRtId('LeadASI_BRD_Generic_CRM_Lead'),
                LastName = 'test', 
                Status = 'Open', 
                LeadSource = 'Web', 
                Email = 'test1_brd_generic@laputa.com', 
                ASI_BRD_Primary_Market__c = 'Taiwan', 
                ASI_BRD_Acquired_By__c = 'Absolut');
		insert l;
        List<Lead> lList = new List<Lead>();
        lList.add(l);
        String jsonInput = '{ "sObjectName": "Lead" ,"selectFields":"Id" }';
        String jsonInput2 = Json.serialize(l);
        String jsonInput3 = Json.serialize(lList);
        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('pageRequest',jsonInput);
        pageRef.getParameters().put('recordId',l.Id);
        pageRef.getParameters().put('record',jsonInput2);
        pageRef.getParameters().put('recordList',jsonInput3);
        pageRef.getParameters().put('clonedRecordList',jsonInput3);
        pageRef.getParameters().put('addedRecordList',jsonInput3);
        pageRef.getParameters().put('addedClonedRecordList',jsonInput3);
        
        ASI_CRM_JP_DataTableController acd = new ASI_CRM_JP_DataTableController();
		List<Id> recordIds = new List<Id>();
        recordIds.add(l.Id);
        acd.pageRequestString  = 'pageRequest';
        acd.pageRequest.setsObjectName('Lead');
        acd.recordsJsonString = 'Test';
        acd.clonedRecordsJsonString= 'Test';
        acd.unSavedRecordsJsonString = 'Test';
        try{
        	acd.updateRecords();
            ASI_CRM_JP_DataTableController.deleteRecordByIds('Lead', recordIds);
        }
        catch(Exception e){
            
        }
    }

    // 20190624 Wilson Chow
    @isTest
    static void testMethodForDeleteRecords(){
        Lead l =
                new Lead(
                        RecordTypeId = Global_RecordTypeCache.getRtId('LeadASI_BRD_Generic_CRM_Lead'),
                        LastName = 'test',
                        Status = 'Open',
                        LeadSource = 'Web',
                        Email = 'test1_brd_generic@laputa.com',
                        ASI_BRD_Primary_Market__c = 'Taiwan',
                        ASI_BRD_Acquired_By__c = 'Absolut');
        insert l;

        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);

        ASI_CRM_JP_DataTableController ctrl = new ASI_CRM_JP_DataTableController();
        ctrl.pageRequestString  = 'pageRequest';
        ctrl.pageRequest.setsObjectName('Lead');
        ctrl.deleteRecords.add(l);
        try{
            ctrl.updateRecords();
        }
        catch(Exception e){

        }
    }

    @isTest
    static void testMethodForUpdateRecords(){
        Lead l =
                new Lead(
                        RecordTypeId = Global_RecordTypeCache.getRtId('LeadASI_BRD_Generic_CRM_Lead'),
                        LastName = 'test',
                        Status = 'Open',
                        LeadSource = 'Web',
                        Email = 'test1_brd_generic@laputa.com',
                        ASI_BRD_Primary_Market__c = 'Taiwan',
                        ASI_BRD_Acquired_By__c = 'Absolut');
        insert l;

        List<Lead> lList = new List<Lead>();
        lList.add(l);

        PageReference pageRef = Page.ASI_CRM_JP_InputPaymentItemsCashApp;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recordList',JSON.serialize(lList));

        ASI_CRM_JP_DataTableController ctrl = new ASI_CRM_JP_DataTableController();
        ctrl.pageRequestString  = 'pageRequest';
        ctrl.pageRequest.setsObjectName('Lead');

        try{
            ctrl.updateRecords();
        }
        catch(Exception e){

        }
    }
    // 20190624 Wilson Chow
}