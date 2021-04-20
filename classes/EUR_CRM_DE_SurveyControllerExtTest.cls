@isTest
public class EUR_CRM_DE_SurveyControllerExtTest {
    
    @testSetUp static void ssetUpData(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntradeDE();
        EUR_CRM_DE_TestClassUtilityHelper.initData(); 
        
                
        EUR_CRM_Question__c question = new EUR_CRM_Question__c(EUR_CRM_Question_Statement__c='test question');
        insert question;

       
    }
    
    static testMethod void test1(){
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = [select Id,Name from EUR_CRM_Customer_Taxonomy__c where Name ='testtaxonomy' limit 1];
        
        List<EUR_CRM_Account__c> accountEUList = new List<EUR_CRM_Account__c>();
        
        EUR_CRM_Account__c accountEU = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '12345',
            recordtypeid=Global_RecordTypeCache.getRtId('EUR_CRM_Account__c'+ 'EUR_DE_OFF_STD'),
            name = 'testname',
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy.Id);
        
        EUR_CRM_Account__c accountEU2 = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '12345',
            recordtypeid=Global_RecordTypeCache.getRtId('EUR_CRM_Account__c'+ 'EUR_DE_OFF_STD'), 
            name = 'testname2',
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy.Id);
       
        accountEUList.add(accountEU);
        accountEUList.add(accountEU2);
        
        EUR_CRM_Survey_Header__c sheader = new EUR_CRM_Survey_Header__c(name='test survey header');
        insert sheader;
        
        Test.startTest();
        
        PageReference aPage = Page.EUR_CRM_DE_ConfigSurveyPage;
        aPage.getParameters().put('shid',sheader.Id);
        aPage.getParameters().put('rowIndex','0');
        test.setCurrentPage(aPage);
        Apexpages.StandardSetController sc = new Apexpages.StandardSetController(accountEUList);
        sc.setSelected(accountEUList);
        
        EUR_CRM_DE_SurveyControllerExt exCon = new EUR_CRM_DE_SurveyControllerExt(sc); 
        exCon.nextQuestionPage();
        exCon.previousQuestionPage();
        
        exCon.pageQuestionItems[0].IsSelected = true;
        exCon.getSelectedQuestions();
        exCon.doSelectQuestion();
        exCon.addSurveyQuestions();
        
        exCon.isAllSelected = true;
        exCon.selectAllQuestions();
        exCon.removeSurveyQuestion();
        
        List<EUR_CRM_Account__c> testFilteredAcctList = exCon.filteredAcctList;
        List<EUR_CRM_Survey_Question__c> testSurveyQuestions = exCon.surveyQuestions;
        Boolean testIsAllSelected = exCon.isAllSelected;
        Boolean testHasNextQuestionPage = exCon.hasNextQuestionPage;
        Boolean testHasPreviousQuestionPage = exCon.hasPreviousQuestionPage;
        
        Test.stopTest();
    } 
    
}