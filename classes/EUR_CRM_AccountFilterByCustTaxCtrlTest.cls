@isTest
public class EUR_CRM_AccountFilterByCustTaxCtrlTest {
    
    @testSetUp static void testSetUp(){
        List<EUR_CRM_Customer_Taxonomy__c> CustomerTaxonomys = New List<EUR_CRM_Customer_Taxonomy__c>();
        Id deRtId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c','EUR_DE_WS_Customer_Taxonomy');
        
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy1 = New EUR_CRM_Customer_Taxonomy__c(Name = 'DE_Wholesalers',
                                                                                          EUR_CRM_External_ID__c = 'DE_Wholesalers',
                                                                                          RecordTypeId = deRtId, 
                                                                                          EUR_CRM_Level_1__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_2__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_3__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_4__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_5__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_6__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_7__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_8__c = 'Wholesalers');
        
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy2 = New EUR_CRM_Customer_Taxonomy__c(Name = 'DE_Traditional',
                                                                                          EUR_CRM_External_ID__c = 'DE_Traditional',
                                                                                          RecordTypeId = deRtId, 
                                                                                          EUR_CRM_Level_1__c = 'Traditional',
                                                                                          EUR_CRM_Level_2__c = 'Traditional',
                                                                                          EUR_CRM_Level_3__c = 'Traditional',
                                                                                          EUR_CRM_Level_4__c = 'Traditional',
                                                                                          EUR_CRM_Level_5__c = 'Traditional',
                                                                                          EUR_CRM_Level_6__c = 'Traditional',
                                                                                          EUR_CRM_Level_7__c = 'Traditional',
                                                                                          EUR_CRM_Level_8__c = 'Traditional');
        CustomerTaxonomys.add(CustomerTaxonomy1);
        CustomerTaxonomys.add(CustomerTaxonomy2);
        
        
        insert CustomerTaxonomys;
        
        EUR_CRM_Survey_Header__c sheader = new EUR_CRM_Survey_Header__c(name='test survey header');
        insert sheader;
    }
    
    static testMethod void testAllLevelValue(){
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        Test.startTest();
        
        EUR_CRM_AccountFilterByCustTaxController con = new EUR_CRM_AccountFilterByCustTaxController();
        con.custTaxRt = 'EUR_DE_WS_Customer_Taxonomy';
        con.chainValue = 'Wholesalers';
        con.level1Value = 'Wholesalers';
        con.level2Value = 'Wholesalers';
        con.level3Value = 'Wholesalers';
        con.level4Value = 'Wholesalers';
        con.level5Value = 'Wholesalers';
        con.level6Value = 'Wholesalers';
        con.level7Value = 'Wholesalers';
        con.level8Value = 'Wholesalers';
        con.currentURLStr = 'apex/EUR_CRM_DE_ConfigSurveyPage?id='+sheader.Id;
        con.isRegional = true;
        
        con.init();
        con.getChainOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.getLevel3Options();
        con.getLevel4Options();
        con.getLevel5Options();
        con.getLevel6Options();
        con.getLevel7Options();
        con.getLevel8Options();
        con.filter();
        con.getMgmtTypeOptions();
        con.retrieveAccount();
        con.getTaxList();
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer page = con.pageNumber;
        Boolean testInitDummyVar = con.initDummyVar;
        List<EUR_CRM_Account__c> testEUAccountList = con.euAccountList;
        
        Test.stopTest();
        
    }
    static testMethod void test7LevelValue(){
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        Test.startTest();
        
        EUR_CRM_AccountFilterByCustTaxController con = new EUR_CRM_AccountFilterByCustTaxController();
        con.custTaxRt = 'EUR_DE_WS_Customer_Taxonomy';
        con.chainValue = 'Wholesalers';
        con.level1Value = 'Wholesalers';
        con.level2Value = 'Wholesalers';
        con.level3Value = 'Wholesalers';
        con.level4Value = 'Wholesalers';
        con.level5Value = 'Wholesalers';
        con.level6Value = 'Wholesalers';
        con.currentURLStr = 'apex/EUR_CRM_DE_ConfigSurveyPage?id='+sheader.Id;
        con.isRegional = true;
        
        con.init();
        con.getChainOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.getLevel3Options();
        con.getLevel4Options();
        con.getLevel5Options();
        con.getLevel6Options();
        con.getLevel7Options();
        con.getLevel8Options();
        con.filter();
        con.getMgmtTypeOptions();
        con.retrieveAccount();
        con.getTaxList();
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer page = con.pageNumber;
        Boolean testInitDummyVar = con.initDummyVar;
        List<EUR_CRM_Account__c> testEUAccountList = con.euAccountList;
        
        Test.stopTest();
        
    }
    
    static testMethod void test6LevelValue(){
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        Test.startTest();
        
        EUR_CRM_AccountFilterByCustTaxController con = new EUR_CRM_AccountFilterByCustTaxController();
        con.custTaxRt = 'EUR_DE_WS_Customer_Taxonomy';
        con.chainValue = 'Wholesalers';
        con.level1Value = 'Wholesalers';
        con.level2Value = 'Wholesalers';
        con.level3Value = 'Wholesalers';
        con.level4Value = 'Wholesalers';
        con.level5Value = 'Wholesalers'; 
        con.currentURLStr = 'apex/EUR_CRM_DE_ConfigSurveyPage?id='+sheader.Id;
        con.isRegional = true;
        
        con.init();
        con.getChainOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.getLevel3Options();
        con.getLevel4Options();
        con.getLevel5Options();
        con.getLevel6Options();
        con.getLevel7Options();
        con.getLevel8Options();
        con.filter();
        con.getMgmtTypeOptions();
        con.retrieveAccount();
        con.getTaxList();
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer page = con.pageNumber;
        Boolean testInitDummyVar = con.initDummyVar;
        List<EUR_CRM_Account__c> testEUAccountList = con.euAccountList;
        
        Test.stopTest();
        
    }
     static testMethod void test5LevelValue(){
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        Test.startTest();
        
        EUR_CRM_AccountFilterByCustTaxController con = new EUR_CRM_AccountFilterByCustTaxController();
        con.custTaxRt = 'EUR_DE_WS_Customer_Taxonomy';
        con.chainValue = 'Wholesalers';
        con.level1Value = 'Wholesalers';
        con.level2Value = 'Wholesalers';
        con.level3Value = 'Wholesalers';
        con.level4Value = 'Wholesalers';
        con.currentURLStr = 'apex/EUR_CRM_DE_ConfigSurveyPage?id='+sheader.Id;
        con.isRegional = true;
        
        con.init();
        con.getChainOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.getLevel3Options();
        con.getLevel4Options();
        con.getLevel5Options();
        con.getLevel6Options();
        con.getLevel7Options();
        con.getLevel8Options();
        con.filter();
        con.getMgmtTypeOptions();
        con.retrieveAccount();
        con.getTaxList();
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer page = con.pageNumber;
        Boolean testInitDummyVar = con.initDummyVar;
        List<EUR_CRM_Account__c> testEUAccountList = con.euAccountList;
        
        Test.stopTest();
        
    }
     static testMethod void test4LevelValue(){
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        Test.startTest();
        
        EUR_CRM_AccountFilterByCustTaxController con = new EUR_CRM_AccountFilterByCustTaxController();
        con.custTaxRt = 'EUR_DE_WS_Customer_Taxonomy';
        con.chainValue = 'Wholesalers';
        con.level1Value = 'Wholesalers';
        con.level2Value = 'Wholesalers';
        con.level3Value = 'Wholesalers';
        con.currentURLStr = 'apex/EUR_CRM_DE_ConfigSurveyPage?id='+sheader.Id;
        con.isRegional = true;
        
        con.init();
        con.getChainOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.getLevel3Options();
        con.getLevel4Options();
        con.getLevel5Options();
        con.getLevel6Options();
        con.getLevel7Options();
        con.getLevel8Options();
        con.filter();
        con.getMgmtTypeOptions();
        con.retrieveAccount();
        con.getTaxList();
        con.first();
        con.last();
        con.previous();
        con.next();
        con.getPages();
        con.getRecordSize();
        con.getPageSize();
        
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer page = con.pageNumber;
        Boolean testInitDummyVar = con.initDummyVar;
        List<EUR_CRM_Account__c> testEUAccountList = con.euAccountList;
        
        Test.stopTest();
        
    }
    
}