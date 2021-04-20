@isTest
public class ASI_CRM_SG_Archive_Contract_Ctrl_Test {
    @testSetup
    
    Public static void testData(){
          Profile p1 = [Select Id from profile where Name = 'System Administrator' limit 1];
        User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p1.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com.ctr');
         insert u1;
        
    }
    
    public static void createTestContractData(){
        ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
        Date today =  Date.today();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
       ASI_CRM_Group_Outlet_Type__c   groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
                                                                                        ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
                                                                                        ASI_CRM_SG_Name__c='High Energy Bar'
                                                                                       
                                                                                        );
        insert groupOutletType;
        
       ASI_CRM_Image_Level__c imageLevel = new ASI_CRM_Image_Level__c(ASI_CRM_SG_Name__c = 'Mainstream',
                                                                        ASI_CRM_SG_Group_Outlet_Type__c=groupOutletType.id
                                                                        );
        insert imageLevel;
        ASI_CRM_AccountsAdditionalField__c customer  = new ASI_CRM_AccountsAdditionalField__c (
                                                                name = 'customer Test',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                ASI_CRM_IsParentAccount__c = true,
                                                                ASI_CRM_MY_CustomerCode__c = '123test',                                ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id,
                                                                ASI_CRM_SG_Image_Level__c  = imageLevel.id,
                                                                ASI_CRM_Business_Registration_Number__c = String.ValueOf(DateTime.now().millisecond()) + '123456'
                                                          );
        insert customer;
        insert new ASI_CRM_MY_Settings__c(SetupOwnerId = UserInfo.getProfileId());
        ASI_TH_CRM_Contract__c  contract = new ASI_TH_CRM_Contract__c (
                                                  name='PRS-XYZ-18-0302',
                                                  recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract'),
                                                  ASI_CRM_CN_Outlet_WS__c = customer.id,
                                                  ASI_TH_CRM_Contract_Status__c = 'Draft',
                                                  ASI_TH_CRM_Start_Date__c = date.today().adddays(-1),
                                                  ASI_TH_CRM_End_Date__c = date.today().adddays(7)
                                              );
        insert contract;
    }
    public static testMethod void test1(){
     
        test.startTest();
        createTestContractData();
       
        ASI_TH_CRM_Contract__c contract = [Select Id from ASI_TH_CRM_Contract__c limit 1];
            ASI_CRM_SG_Archive_Contract_Ctrl.getRecord(contract.Id);
            ASI_CRM_SG_Archive_Contract_Ctrl.updateRecord(contract.Id);
       // ASI_CRM_MO_TestClassHelper.createMOSetting();
        //  ASI_CRM_RedirectContractNew_lig.getExchangeRet();
        String userId = Userinfo.getUserId();
        User u1 = [Select Id from user where username = 'CaseAR@mail.com.ctr' limit 1];
        contract.ownerId = u1.Id;
        
        update contract;
        ASI_CRM_SG_Archive_Contract_Ctrl.getRecord(contract.Id);
        ASI_CRM_SG_Archive_Contract_Ctrl.getRecord(null);
        test.stopTest();
    }
}