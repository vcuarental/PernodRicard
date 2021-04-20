@isTest
public class EUR_CRM_SurveyAccountSelectorCtrlTest {
    
    
    @testSetUp static void setUpData(){
        EUR_CRM_Survey_Header__c sheader = new EUR_CRM_Survey_Header__c(name='test survey header',
                                                                        RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Survey_Header__c','EUR_DE_OFF_Trade_Survey_Header'),
                                                                        EUR_CRM_Account_Filter_PROS__c = '(EUR_CRM_Image_Level_Name__c = \'Iconic\' AND EUR_CRM_Group_Outlet_Type_Name__c = \'Restaurant\')  OR (EUR_CRM_Image_Level_Name__c = \'Iconic\' AND EUR_CRM_Group_Outlet_Type_Name__c = \'Low Energy Bar\')',
                                                                        EUR_CRM_Active__c = True,
                                                                        EUR_CRM_Account_Filter_CustTax_Chain__c = 'test',
                                                                        EUR_CRM_Account_Filter_PRS_On__c = 'test',
                                                                        EUR_CRM_Account_Filter_ID__c = 'test'
                                                                        
                                                                       );
        insert sheader; 
        
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
    }
    
    static testMethod void test1(){
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        List<EUR_CRM_Customer_Taxonomy__c> cusTaxList = [select Id,Name from EUR_CRM_Customer_Taxonomy__c];
        Test.startTest();
        
        EUR_CRM_SurveyAccountSelectorCtrl con = new EUR_CRM_SurveyAccountSelectorCtrl();
        con.cTaxQuery = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c, EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
            ', EUR_CRM_Region__c, EUR_CRM_Street__c, EUR_CRM_Building_Number__c, EUR_CRM_Comp_Establishment_Name_legally__c, EUR_CRM_Status__c, EUR_CRM_Channel__c, EUR_CRM_Manager_of_Account_Owner__c ' +
            ', EUR_CRM_Key_Account_Manager__c, EUR_JB_Customer_Taxonomy__c, EUR_CRM_Epicenter__c, EUR_CRM_Model_Shop__c, EUR_CRM_Reason_for_deactivation__c ' +
            ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c '  + 
            'from EUR_CRM_Account__c';
        con.surveyHeader = sheader;
        con.customerTaxonomyList = cusTaxList;
        con.countryCode = 'DE';
        con.chainValue = 'Wholesalers';
        con.level1Value = 'Wholesalers';
        con.level2Value = 'Wholesalers';
        con.level3Value = 'Wholesalers';
        con.level4Value = 'Wholesalers';
        con.level5Value = 'Wholesalers';
        con.level6Value = 'Wholesalers';
        con.level7Value = 'Wholesalers';
        con.level8Value = 'Wholesalers';
        con.resetLevel = 'EUR_CRM_Chain__c';
        con.filterCTax();
        con.retrieveExistingCustomerTaxonomy();
        con.resetValue();
        con.getChainOptions();
        con.getLevel1Options();
        con.getLevel2Options();
        con.getLevel3Options();
        con.getLevel4Options();
        con.getLevel5Options();
        con.getLevel6Options();
        con.getLevel7Options();
        con.getLevel8Options();
        con.getTaxList();
        con.firstCTax();
        con.lastCTax();
        con.previousCTax();
        con.nextCTax();
        con.getPagesCTax();
        con.getRecordSizeCTax();
        con.getPageSizeCTax();
        con.getListViewOptions();
        con.resetFilter();
        con.retrieveAccounts();
        con.getWrapAccounts();
        con.sort();
        con.doNext();
        con.doPrevious();
        con.first();
        con.last();   
        con.getHasPrevious();
        con.getHasNext();
        con.getPageNumber();
        con.getTotalPages();
        con.getPageSize();
        con.getRecordSize();
        con.doSelectItem();
        con.getSelectedAccounts();
        con.doDeselectItem();
        con.getHasSelectedAccounts();
        con.selectAll();
        con.deSelectAll();
        con.validateAccounts();
        con.saveAccounts();
        con.cancel();
        con.publishSurvey();
        
        Boolean testHasNextCTax  = con.hasNextCTax;
        Boolean testHasPreviousCTax  = con.hasPreviousCTax;
        Integer testPageNumberCTax = con.pageNumberCTax;
        String 	testSurveyRtName = con.surveyRtName;
        String 	testCurrentURL = con.currentURL; 		
     	String 	testAccountFilter = con.accountFilter; 	
     	String  testAddFilterCTax = con.addFilterCTax;	
     	String  testAddFilterPROS = con.addFilterPROS;	
     	String  testAddFilterPRS = con.addFilterPRS;
        Boolean testIsAccListView = con.isAccListView;		
     	Boolean testIsCTax = con.isCTax;					
     	Boolean testIsPROS = con.isPROS;
        Boolean testIsRegional = con.isRegional;
        String testOpAccountMappingRecordTypeName =  con.opAccountMappingRecordTypeName;

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('{"query": "WHERE test query"}');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        con.getListviewFilter();

        Test.stopTest();
        
    }
    
}