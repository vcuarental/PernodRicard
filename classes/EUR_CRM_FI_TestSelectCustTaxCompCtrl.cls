@isTest
public class EUR_CRM_FI_TestSelectCustTaxCompCtrl {
    static User eurSysUser;
    static EUR_CRM_Size__c bqs;
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
    }
    
    /**
       EUR_CRM_FI_PublishObjectivePageCtrl
    */
    static testMethod  void testController(){
        setUser();
        System.runAs(eurSysUser){
            Id fiOnAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_FI_Direct_On_Trade'].id;
            Id fiOnObjPromoRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_ObjPromo__c' and developername ='EUR_FI_On_Trade_O_P'].id;
            Id fiCustomerTaxonomyRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_FI_ON_Trade_Customer_Taxonomy');
            
            Id bqsRecordTypeId= EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c','EUR_FI_Size');
            
            EUR_CRM_Customer_Taxonomy__c custTax= new EUR_CRM_Customer_Taxonomy__c(recordtypeid = fiCustomerTaxonomyRecordTypeId,
            name = 'test',
            EUR_CRM_Chain__c = 'test',
           EUR_CRM_Sub_Chain__c = 'test',
           EUR_CRM_Region__c = 'test' );
            insert custTax;
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(recordtypeid = fiOnAccountRecordTypeId,
            name = 'test',
            EUR_JB_Customer_Taxonomy__c = custTax.id);
            insert account;
            
            EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c(
                recordtypeid = fiOnObjPromoRecordTypeId,
                name = 'test op',
                EUR_CRM_Active_End_Date__c = system.today(),
                EUR_CRM_Active_Start_Date__c = system.today(),
                EUR_CRM_Status__c = 'Draft',
                eur_crm_product_hierarchy_Level__c = 'BQS',
                EUR_CRM_O_P_Type__c= 'Type 2',
                EUR_CRM_Account_Selection_Type__c = 'Customer Taxonomy'
            );
            insert op;
            
            Test.startTest();
            
            EUR_CRM_FI_SelectCustTaxComponentCtrl con = new EUR_CRM_FI_SelectCustTaxComponentCtrl();
            con.objPromoIdStr = op.id;
            con.init();
            con.getChainOptions();
            con.getSubChainOptions();
            con.getRegionOptions();
            con.chainValue = 'test';
            con.subChainValue = 'test';
            con.regionValue = 'test';
            con.filter();
            con.setCon1();
            con.getTaxList();
            
            Boolean hasNext = con.hasNext;
            Boolean hasPrevious = con.hasPrevious;
            con.first();
            con.last();
            con.previous();
            con.next();
            con.getPages();
            con.getRecordSize();
            con.getPageSize();

            con.quickSaveContinue();
            con.save();
            String managementTypeValue= con.managementTypeValue;
            List<EUR_CRM_Account__c> euAccountList = con.euAccountList;
            Boolean initDummyVar= con.initDummyVar;
            Boolean insertCustMappingBool= con.insertCustMappingBool;
            Boolean limitFieldsBool= con.limitFieldsBool;
            String custTaxRecordTypeStr= con.custTaxRecordTypeStr;
            String fieldsStr= con.fieldsStr;
            String custMappingRecordTypeStr= con.custMappingRecordTypeStr;
            Integer pageNumber = con.pageNumber;
            
            Test.stopTest();
        }
    }

}