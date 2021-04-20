/***********************************************************************************
* Name:ASI_TnE_KR_ClaimManageAllCtrl_TestV2 
* Description: Test Class for ASI_TnE_KR_ClaimManageAllCtrl
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -------------------------------------
* 20/7/2017         Laputa: Kevin Choi      Modified, splited into two testMethod
***********************************************************************************/
@isTest
public class ASI_TnE_KR_ClaimManageAllCtrl_TestV2 {
    
    private static ASI_eForm_HR_MDM__c tempMDM = new ASI_eForm_HR_MDM__c(Name='1234567', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                                         ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none', 
                                                                         ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                                         ASI_eForm_Employee_Work_Email__c='123.345@email.com', ASI_eForm_Employee_Eligible_PD__c = true,
                                                                         recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_HR_MDM__cASI_eForm_KR_HR_MDM'));
    
    private static ASI_eForm_HR_MDM__c tempMDM2 = new ASI_eForm_HR_MDM__c(Name='0000000', ASI_eForm_MDM_Department__c='tempHR',ASI_eForm_Employee_Company_Code__c = '222', 
                                                                          ASI_eForm_Employee_First_Name__c='ab', ASI_eForm_Employee_Last_Name__c='cd', ASI_eForm_Employee_Job_Title__c='none',
                                                                          ASI_eForm_Employee_Branch_Code__c='300-Management', ASI_eForm_Employee_Is_Salesman__c=True, ASI_eForm_Employee_Gender__c='M', 
                                                                          ASI_eForm_Employee_Work_Email__c='123.345@email.com', ASI_eForm_Employee_Eligible_PD__c = true,
                                                                          recordTypeId = Global_RecordTypeCache.getRtId('ASI_eForm_HR_MDM__cASI_eForm_KR_HR_MDM'));
    
    private static Profile tempP = [SELECT Id FROM Profile WHERE Name='Standard User'];
    
    Private static User tempU = [select id, Name, ASI_KOR_Commission_Code__c, ProfileId from user where id = :userInfo.getUserId()];
    
    private static User tempU2 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666@testorg.com', ASI_KOR_Commission_Code__c='1234567', ManagerId = tempU.id,
                                          CompanyName = 'testUserCompanyName', Country = 'Korea');
    
    private static User tempU3 = new User(Alias = '662', Email='standarduser6662@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing2', LastName='667', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser667@testorg.com', ASI_KOR_Commission_Code__c='0000000', ManagerId = tempU.id,
                                          CompanyName = 'testUserCompanyName', Country = 'Korea');
    
    static testMethod void testCtrl(){
        List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); //user list
        List<ASI_eForm_HR_MDM__c> tempMDMs = ASI_TnE_KR_TestClassHelper.createMDMRecords(); //MDM list
        List<ASI_TnE_Account_Mapping__c> tempACMaps = ASI_TnE_KR_TestClassHelper.createAcMapRecords(); //accounting mapping list
        List<ASI_JP_TnE_Expense_Category__c> tempCats = ASI_TnE_KR_TestClassHelper.createExCatRecords(); //expense category list
        List<ASI_JP_TnE_Expense_Classification__c> tempClasses = ASI_TnE_KR_TestClassHelper.createExClassRecords(tempCats,tempACMaps); //expense classficiation list
        List<ASI_KOR_Brand__c> tempBrands = ASI_TnE_KR_TestClassHelper.createBrandRecords(); //brand list
        List<ASI_KOR_Sub_Brand__c> tempSubBrands = ASI_TnE_KR_TestClassHelper.createSubBrandRecords(tempBrands); //sub-brand list
        String fiscalYear1  = ASI_TnE_KR_TestClassHelper.createFY();
        List<ASI_TnE_Employee_Budget__c> tempBudgets = ASI_TnE_KR_TestClassHelper.createBudgetRecords(tempUsers,fiscalYear1); //budget list
        List<ASI_MFM_Exchange_Rate__c> tempExRates = ASI_TnE_KR_TestClassHelper.createExRateRecords(fiscalYear1); //exchange rate list
        List<ASI_TnE_Branch_Channel__c> tempBraChas = ASI_TnE_KR_TestClassHelper.createBraChannelRecords(); //branch channel list
        List<ASI_CRM_AccountsAdditionalField__c> tempCustomers = ASI_TnE_KR_TestClassHelper.createCustomerRecords(tempUsers); //customer list
        
       
        
        List<ASI_GnH_Request__c> gnhRequestList = ASI_TnE_KR_TestClassHelper.createGnHRequest(tempUsers);
        List<ASI_GnH_Recipient_Master__c> tempRecipientMaster = ASI_TnE_KR_TestClassHelper.createRecipientMasterData();
        List<ASI_GnH_Request_Recipient__c> requestrecipientList = ASI_TnE_KR_TestClassHelper.createRequestrecipient(gnhRequestList,tempRecipientMaster);
        List<ASI_GnH_KR_Default_Setting__c> customsettingList = ASI_TnE_KR_TestClassHelper.createCustomSetting();
        
        List<ASI_TnE_ClaimHeader__c> tempHeaders = ASI_TnE_KR_TestClassHelper.createGeneralHeaderRecord(tempUsers); //claim header list
        List<ASI_TnE_ClaimDetail__c> tempDetails = ASI_TnE_KR_TestClassHelper.createGeneralDetailRecord(tempHeaders,tempSubBrands,tempCats,tempClasses,tempCustomers,tempUsers,gnhRequestList); //claim detail list        
        List<ASI_GnH_Actual_Recipient__c> tempActualRecipient = ASI_TnE_KR_TestClassHelper.createActualRecipientData(tempDetails,tempRecipientMaster);
        
         Test.startTest();
        
        Test.setCurrentPage(Page.ASI_TnE_KR_ManageAnPClaimPage);
        Apexpages.currentPage().getParameters().put('id', tempHeaders[1].id);
        Apexpages.standardController sc1 = new apexpages.standardController(tempHeaders[1]);
        ASI_TnE_KR_ClaimManageAllCtrl cx1 = new ASI_TnE_KR_ClaimManageAllCtrl(sc1);
        cx1.init();
        ASI_TnE_KR_ClaimManageAllCtrl.getClaimDetails(''+tempHeaders[1].id);
        ASI_TnE_KR_ClaimManageAllCtrl.getSelectedOptions('ASI_TnE_Dept_in_Charge__c');
        ASI_TnE_KR_ClaimManageAllCtrl.findList('User','Id,Name',' AND CompanyName = \'Pernod Ricard Korea\' AND ASI_KOR_Commission_Code__c != null');
        ASI_TnE_KR_ClaimManageAllCtrl.findList('ASI_GnH_Threshold__c','Id,Name',' AND CompanyName = \'Pernod Ricard Korea\' AND ASI_KOR_Commission_Code__c != null');
        ASI_TnE_KR_ClaimManageAllCtrl.findList('ASI_GnH_Threshold__c','Id,Name','');
        ASI_TnE_KR_ClaimManageAllCtrl.getTnEThresholdTolerance();
        ASI_TnE_KR_ClaimManageAllCtrl.getRecipientOptions('ASI_TnE_Dept_in_Charge__c');
        ASI_TnE_KR_ClaimManageAllCtrl.getGnhRecipient();
        ASI_TnE_KR_ClaimManageAllCtrl.getRecipientMaster();
        ASI_TnE_KR_ClaimManageAllCtrl.getGnHRequest();
        ASI_TnE_KR_ClaimManageAllCtrl.getGnHCheckedPlan();
        
        
        ASI_TnE_KR_ClaimManageAllCtrl.remoteActionResult rar = new ASI_TnE_KR_ClaimManageAllCtrl.remoteActionResult();
        ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail aacd = new ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail();
        aacd.claimDetail = tempDetails[2];
        Map<Integer, ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail> tempMap = new Map<Integer, ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail>();
        Map<Integer, ASI_GnH_Actual_Recipient__c> tempRecipientMap = new Map<Integer, ASI_GnH_Actual_Recipient__c>();
        tempRecipientMap.put(1,tempActualRecipient[0]);
        tempRecipientMap.put(2,tempActualRecipient[1]);
        tempMap.put(1,aacd);
        ASI_TnE_KR_ClaimManageAllCtrl.getClaimDetailsByApexMap(tempMap);
        ASI_TnE_KR_ClaimManageAllCtrl.doSave(tempMap,tempRecipientMap);
        aacd.claimDetail.Id = null;
        tempMap.put(1,aacd);
        ASI_TnE_KR_ClaimManageAllCtrl.doSave(tempMap,tempRecipientMap);
        
        String testgnhRequestMapJson = cx1.gnhRequestMapJson;
        String testTnEThresholdJson = cx1.TnEThresholdJson;
        String testcurrentRecipientMapJson = cx1.currentRecipientMapJson;
        String testrecipientbyRequestMapJson = cx1.recipientbyRequestMapJson;
        String testcheckedClassificationMapJson = cx1.checkedClassificationMapJson;
        String testpromotionCodeMapJson = cx1.promotionCodeMapJson;
        String testsupportItemForBrandJson = cx1.supportItemForBrandJson;
        
        
        Test.stopTest();
    }
    
    static testMethod void testCtrl2(){
        
        List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); //user list
        List<ASI_eForm_HR_MDM__c> tempMDMs = ASI_TnE_KR_TestClassHelper.createMDMRecords(); //MDM list
        List<ASI_TnE_Account_Mapping__c> tempACMaps = ASI_TnE_KR_TestClassHelper.createAcMapRecords(); //accounting mapping list
        List<ASI_JP_TnE_Expense_Category__c> tempCats = ASI_TnE_KR_TestClassHelper.createExCatRecords(); //expense category list
        List<ASI_JP_TnE_Expense_Classification__c> tempClasses = ASI_TnE_KR_TestClassHelper.createExClassRecords(tempCats,tempACMaps); //expense classficiation list
        List<ASI_KOR_Brand__c> tempBrands = ASI_TnE_KR_TestClassHelper.createBrandRecords(); //brand list
        List<ASI_KOR_Sub_Brand__c> tempSubBrands = ASI_TnE_KR_TestClassHelper.createSubBrandRecords(tempBrands); //sub-brand list
        String fiscalYear1  = ASI_TnE_KR_TestClassHelper.createFY();
        List<ASI_TnE_Employee_Budget__c> tempBudgets = ASI_TnE_KR_TestClassHelper.createBudgetRecords(tempUsers,fiscalYear1); //budget list
        List<ASI_MFM_Exchange_Rate__c> tempExRates = ASI_TnE_KR_TestClassHelper.createExRateRecords(fiscalYear1); //exchange rate list
        List<ASI_TnE_Branch_Channel__c> tempBraChas = ASI_TnE_KR_TestClassHelper.createBraChannelRecords(); //branch channel list
        List<ASI_CRM_AccountsAdditionalField__c> tempCustomers = ASI_TnE_KR_TestClassHelper.createCustomerRecords(tempUsers); //customer list
        
        
        
        List<ASI_GnH_Request__c> gnhRequestList = ASI_TnE_KR_TestClassHelper.createGnHRequest(tempUsers);
        List<ASI_GnH_Recipient_Master__c> tempRecipientMaster = ASI_TnE_KR_TestClassHelper.createRecipientMasterData();
        List<ASI_GnH_Request_Recipient__c> requestrecipientList = ASI_TnE_KR_TestClassHelper.createRequestrecipient(gnhRequestList,tempRecipientMaster);
        List<ASI_GnH_KR_Default_Setting__c> customsettingList = ASI_TnE_KR_TestClassHelper.createCustomSetting();
        
        List<ASI_TnE_ClaimHeader__c> tempHeaders = ASI_TnE_KR_TestClassHelper.createGeneralHeaderRecord(tempUsers); //claim header list
        List<ASI_TnE_ClaimDetail__c> tempDetails = ASI_TnE_KR_TestClassHelper.createGeneralDetailRecord(tempHeaders,tempSubBrands,tempCats,tempClasses,tempCustomers,tempUsers,gnhRequestList); //claim detail list        
        List<ASI_GnH_Actual_Recipient__c> tempActualRecipient = ASI_TnE_KR_TestClassHelper.createActualRecipientData(tempDetails,tempRecipientMaster);
        
        
        Test.startTest();
        
        
        Test.setCurrentPage(Page.ASI_TnE_KR_ManageTnEClaimPage);
        Apexpages.currentPage().getParameters().put('id', tempHeaders[2].id);
        Apexpages.standardController sc2 = new apexpages.standardController(tempHeaders[1]);
        ASI_TnE_KR_ClaimManageAllCtrl cx2 = new ASI_TnE_KR_ClaimManageAllCtrl(sc2);
        cx2.init();
        ASI_TnE_KR_ClaimManageAllCtrl.lookupFieldToSelectedOptions('ASI_TnE_Expense_Classification__c','ASI_TnE_Expense_Category__c');
        ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail aacd2 = new ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail();
        aacd2.claimDetail = tempDetails[0];
        aacd2.rdYear = Date.today().year();
        aacd2.rdMonth = Date.today().month();
        aacd2.rdDay = Date.today().day();
        Map<Integer, ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail> tempMap2 = new Map<Integer, ASI_TnE_KR_ClaimManageAllCtrl.AngularApexClaimDetail>();
        tempMap2.put(1,aacd2);
        
        //Create AngularApexActualRecipient 1 and 2
        ASI_TnE_KR_ClaimManageAllCtrl.AngularApexActualRecipient actualRecipient1 = new ASI_TnE_KR_ClaimManageAllCtrl.AngularApexActualRecipient();
        actualRecipient1.actualRecipient = tempActualRecipient[2];
        actualRecipient1.rowNo = 1;
        
        ASI_TnE_KR_ClaimManageAllCtrl.AngularApexActualRecipient actualRecipient2 = new ASI_TnE_KR_ClaimManageAllCtrl.AngularApexActualRecipient();
        actualRecipient2.actualRecipient = tempActualRecipient[3];
        actualRecipient2.rowNo = 2;
        
        Map<Integer, ASI_TnE_KR_ClaimManageAllCtrl.AngularApexActualRecipient> actualRecipientMap = new Map<Integer, ASI_TnE_KR_ClaimManageAllCtrl.AngularApexActualRecipient>();
        actualRecipientMap.put(1,actualRecipient1);
        actualRecipientMap.put(2,actualRecipient2);
        
        
        ASI_TnE_KR_ClaimManageAllCtrl.getCashClaimDetailsByApexMap(tempMap2);
        String tempD = '["'+tempDetails[0].Id+'"]';
        ASI_TnE_KR_ClaimManageAllCtrl.doCashSave(tempMap2, tempD, actualRecipientMap);
        aacd2.claimDetail.Id = null;
        tempMap2.put(1,aacd2);
        ASI_TnE_KR_ClaimManageAllCtrl.doCashSave(tempMap2, '',actualRecipientMap);
        
        Test.stopTest();
    }    
    
}