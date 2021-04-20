@isTest
public class ASI_CRM_JP_DataTableServiceTest {
	@testSetup 
    static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;     
    }
    
    @isTest
    static void testMethod1() 
    {
        List<Account> lstacc = [SELECT Id,Name
                                FROM Account];
        Account accrec = [SELECT Id,Name
                          FROM Account
                          LIMIT 1];
        String jsonInput = '{\n' +
            ' "description" :"An appliance",\n' +
            ' "accessories" : [ "powerCord", ' + 
            '{ "right":"door handle1", ' + 
            '"left":"door handle2" } ],\n' +
            ' "dimensions" : ' + 
            '{ "height" : 5.5 , ' + 
            '"width" : 3.0 , ' + 
            '"depth" : 2.2 },\n' +
            ' "type" : null,\n' +
            ' "inventory" : 2000,\n' +
            ' "price" : 1023.45,\n' +
            ' "isShipped" : true,\n' +
            ' "modelNumber" : "123"\n' +
            '}';
        List<string> lstString = new List<String>();
        String stringrec1 = 'test1';
        lstString.add(stringrec1);
        ASI_CRM_JP_DataTableService record = new ASI_CRM_JP_DataTableService();
        Test.startTest();
        record.getInstance();
        ASI_CRM_JP_DataTableService.updateRecords(lstacc);
        ASI_CRM_JP_DataTableService.cloneRecord(accrec.Id);
        ASI_CRM_JP_DataTableService.deserializePageRequest('');
        ASI_CRM_JP_DataTableService.deserializePageRequest(jsonInput);
        ASI_CRM_JP_DataTableService.deserializePageRequest(jsonInput,'Account','');
        ASI_CRM_JP_DataTableService.getListForQuery(lstString);
		ASI_CRM_JP_DataTableService.PageRequest ap = new ASI_CRM_JP_DataTableService.PageRequest();
        ap.selectFields = 'test fields';
        ap.getSelectFieldsList(); 
        ap.combine(ap);
        ap.getCustomCriteria();
        ap.getCriterion();
        ap.getsObjectName();
        ap.getPageSize();
        ap.getPageNumber();
        ap.setsObjectName('Account');
        ap.setCustomCriteria('test');
        ap.getSortField();
        ap.setSortField('test');
        ap.getSortOrder();
        ap.setSortOrder('test');
        ap.getDefaultSortField();
        ap.setDefaultSortField('test');
        ap.getDefaultSortOrder();
        ap.setDefaultSortOrder('test');
        ap.getSelectFields();
        ASI_CRM_JP_DataTableService.getQueryString(ap);
        ASI_CRM_JP_DataTableService.getSelectFieldsQueryString(lstString);
        ASI_CRM_JP_DataTableService.createSortCriteriaString(ap);
        ASI_CRM_JP_DataTableService.createLimitCriteriaString(1);
        ASI_CRM_JP_DataTableService.createCriteriaString('criteria', 'customCriteria');
        ASI_CRM_JP_DataTableService.Criteria ac = new ASI_CRM_JP_DataTableService.Criteria();
        ac.getFieldName();
        ac.getKeywords();
        ac.getOperator();
        ac.getType();
        ASI_CRM_JP_DataTableService.clean('test string');
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() 
    {
		ASI_CRM_JP_DataTableService record = new ASI_CRM_JP_DataTableService();
        record.getInstance();
    }
    
    @isTest
    static void testMethod3() 
    {
        List<Account> lstacc = [SELECT Id,Name
                                FROM Account];
        Account accrec = [SELECT Id,Name
                          FROM Account
                          LIMIT 1];
        String jsonInput = '{\n' +
            ' "description" :"An appliance",\n' +
            ' "accessories" : [ "powerCord", ' + 
            '{ "right":"door handle1", ' + 
            '"left":"door handle2" } ],\n' +
            ' "dimensions" : ' + 
            '{ "height" : 5.5 , ' + 
            '"width" : 3.0 , ' + 
            '"depth" : 2.2 },\n' +
            ' "type" : null,\n' +
            ' "inventory" : 2000,\n' +
            ' "price" : 1023.45,\n' +
            ' "isShipped" : true,\n' +
            ' "modelNumber" : "123"\n' +
            '}';
        List<string> lstString = new List<String>();
        String stringrec1 = 'test1';
        lstString.add(stringrec1);
        ASI_CRM_JP_DataTableService record = new ASI_CRM_JP_DataTableService();
        Test.startTest();
        record.getInstance();
        ASI_CRM_JP_DataTableService.updateRecords(lstacc);
        ASI_CRM_JP_DataTableService.cloneRecord(accrec.Id);
        ASI_CRM_JP_DataTableService.deserializePageRequest('');
        ASI_CRM_JP_DataTableService.deserializePageRequest(jsonInput);
        ASI_CRM_JP_DataTableService.deserializePageRequest(jsonInput,'Account','');
        ASI_CRM_JP_DataTableService.getListForQuery(lstString);
		ASI_CRM_JP_DataTableService.PageRequest ap = new ASI_CRM_JP_DataTableService.PageRequest();
        ap.selectFields = 'test fields';
        ap.getSelectFieldsList(); 
        ap.combine(ap);
        ap.getCustomCriteria();
        ap.getCriterion();
        ap.getsObjectName();
        ap.getPageSize();
        ap.getPageNumber();
        ap.setsObjectName('Account');
        ap.setCustomCriteria('test');
        ap.getSortField();
        ap.setSortField('test');
        ap.getSortOrder();
        ap.setSortOrder('test');
        ap.getDefaultSortField();
        ap.setDefaultSortField('test');
        ap.getDefaultSortOrder();
        ap.setDefaultSortOrder('test');
        ap.getSelectFields();
        ASI_CRM_JP_DataTableService.getQueryString(ap);
        ASI_CRM_JP_DataTableService.getSelectFieldsQueryString(lstString);
        ASI_CRM_JP_DataTableService.createSortCriteriaString(ap);
        ASI_CRM_JP_DataTableService.createLimitCriteriaString(1);
        
        List<ASI_CRM_JP_DataTableService.Criteria> clist = new List<ASI_CRM_JP_DataTableService.Criteria>();
        ASI_CRM_JP_DataTableService.Criteria c = new ASI_CRM_JP_DataTableService.Criteria();
        c.setFieldName('test');
        c.setType('test');
        c.setOperator(ASI_CRM_JP_DataTableService.Operator.EQUALS);
        String kw = 'test';
        List<String> kwList = new List<String>();
        kwList.add(kw);
        c.setKeywords(kwList);
        
        clist.add(c);
        ASI_CRM_JP_DataTableService.createCriteriaString(clist);
        ASI_CRM_JP_DataTableService.Criteria ac = new ASI_CRM_JP_DataTableService.Criteria();
        ac.getFieldName();
        ac.getKeywords();
        ac.getOperator();
        ac.getType();
        ASI_CRM_JP_DataTableService.clean('test string');
        Test.stopTest();
    }
}