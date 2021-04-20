@isTest
public class EUR_CRM_AccFilterByPROSSegmentCtrlTest {
    
    @testSetUp static void setUpData(){
        
        EUR_CRM_Survey_Header__c sheader = new EUR_CRM_Survey_Header__c(name='test survey header',
                                                                        EUR_CRM_Account_Filter_PROS__c = '(EUR_CRM_Image_Level_Name__c = \'Iconic\' AND EUR_CRM_Group_Outlet_Type_Name__c = \'Restaurant\')  OR (EUR_CRM_Image_Level_Name__c = \'Iconic\' AND EUR_CRM_Group_Outlet_Type_Name__c = \'Low Energy Bar\')' 
                                                                        
                                                                       );
        insert sheader;
        
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('testDE_OFF_ALT_Leaflet_Campaign','DE_OFF_ALT_Leaflet_Campaign' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        
    }
    
    static testMethod void test1(){
        
        EUR_CRM_Survey_Header__c sheader = [select Id, Name from EUR_CRM_Survey_Header__c where Name = 'test survey header' limit 1];
        
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today().addDays(1);
        insert objPromo;
        
        Test.startTest();
        
        //ApexPages.StandardSetController sc = new ApexPages.StandardSetController;
        EUR_CRM_AccountFilterByPROSSegmentCtrl con = new EUR_CRM_AccountFilterByPROSSegmentCtrl();
        con.currentURLStr = 'apex/EUR_CRM_DE_ConfigSurveyPage?id='+sheader.Id;
        con.con = null;
        con.objPromo = objPromo;
        con.init();
        con.filter();
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
        con.getHasSelectedAccounts();
        con.selectAll();
        con.deSelectAll();
        con.getIsDeactivated();
        con.saveAccounts();
        con.quickSaveContinue();
        con.cancel();
        con.refresh();
        
        Test.stopTest();
    }
    
}