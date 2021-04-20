/*********************************************************************************
 * Name: ASI_CRM_VN_AccCreateProsSegHandlerTest
 * Description: Test Class for ASI_CRM_VN_AccCreateProsSegHandler
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 11/16/2015       Neha                    Created
 * 21/03/2018       Laputa: Hugo Cheung     Updated
 * 2018-04-04       Laputa: Jeffrey Cheung  Added ASI_CRM_Outlet_Sub_Type__c and ASI_CRM_Area__c to groupOutletType
 * 2018-01-09       Laputa: Andy Zhang      Insert Value outlet record
*********************************************************************************/

@isTest
public class ASI_CRM_VN_AccCreateProsSegHandlerTest{
 @testSetup
 static void setupTestData(){
  ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
          system.Label.ASI_CRM_VN_Customer_Code,
          1,
          'VN-{YYYY}',
          date.today().month() + 2,
          Date.today().year()
  );
  insert testRunningNumber;
 }

 public static testMethod void updateProsSegRecord(){
  List<ASI_TH_CRM_OutletType__c> outletTypeList2 = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);
  outletTypeList2[0].ASI_TH_CRM_Code__c = '4561';
  outletTypeList2[0].Name = 'TestOutletType2';
  insert outletTypeList2;

  //Create test record for Value Customers(ASI_CRM_AccountsAdditionalField__c)
  //Andy Zhang @ 20190109
  ASI_CRM_AccountsAdditionalField__c testCustomer2 = new ASI_CRM_AccountsAdditionalField__c();
  testCustomer2.Name = 'TestCustomer2';
  testCUstomer2.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet');
  //testCustomer2.ASI_CRM_Account__c = accountList2[0].Id;
  testCustomer2.ASI_TH_CRM_OutletType__c = outletTypeList2[0].Id;
  testCustomer2.ASI_CRM_VN_OutletType__c = 'Test';
  insert testCustomer2;
  testCustomer2.ASI_CRM_VN_OutletType__c = 'Test2';
  update testCustomer2;
 }

 public static testMethod void createProsSegTest(){

  //Create Test Account record
   List<ASI_CRM_Group_Outlet_Type__c> groupOutletTypes2 = new List<ASI_CRM_Group_Outlet_Type__c>();

   //Create Test Outlet Type record
   List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(2);
   outletTypeList[0].Name = 'TestOutletType';
   outletTypeList[1].Name = 'TestOutletType2';
   insert outletTypeList;
   test.startTest();
   //Create test record for Customers(ASI_CRM_AccountsAdditionalField__c)
   ASI_CRM_AccountsAdditionalField__c testCustomer = new ASI_CRM_AccountsAdditionalField__c();
   testCustomer.Name = 'TestCustomer';
   testCUstomer.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet_Inactive');
   //testCustomer.ASI_CRM_Account__c = accountList[0].Id;
   testCustomer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
   testCustomer.ASI_CRM_VN_OutletType__c = 'Test';
   insert testCustomer;

   List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
   customerList.add(testCustomer);

   //Create group outlet types for Value
   //Andy Zhang 20190109

   //Create Test Group Outlet Type record
   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithSubType2 = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithSubType2.ASI_CRM_SG_Name__c = 'RES (Casual Dining) (Value)';
   groupOutletTypeWithSubType2.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithSubType2.ASI_CRM_Outlet_Sub_Type__c = 'GO-00464';
   groupOutletTypeWithSubType2.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes2.add(groupOutletTypeWithSubType2);

   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithArea2 = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithArea2.ASI_CRM_SG_Name__c = 'Test2';
   groupOutletTypeWithArea2.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithArea2.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes2.add(groupOutletTypeWithArea2);
   insert  groupOutletTypes2;

   //Create test record for Value Customers(ASI_CRM_AccountsAdditionalField__c)
   //Andy Zhang @ 20190109
   ASI_CRM_AccountsAdditionalField__c testCustomer2 = new ASI_CRM_AccountsAdditionalField__c();
   testCustomer2.Name = 'TestCustomer2';
   testCUstomer2.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Value_On_Trade_Outlet');
   testCustomer2.ASI_TH_CRM_OutletType__c = outletTypeList[1].Id;
   testCustomer2.ASI_CRM_VN_OutletType__c = 'Test2';
   insert testCustomer2;
   testCustomer2.ASI_CRM_VN_OutletType__c = 'Test';
   update testCustomer2;
   List<ASI_CRM_AccountsAdditionalField__c> customerList2 = new List<ASI_CRM_AccountsAdditionalField__c>();
   customerList2.add(testCustomer2);

   Id recordTypeId = [SELECT Id FROM Recordtype WHERE Developername = :'ASI_CRM_VN_Group_Outlet_Type'][0].Id;
   List<ASI_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<ASI_CRM_Group_Outlet_Type__c>();
   //Create Test Group Outlet Type record
   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithSubType = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithSubType.ASI_CRM_SG_Name__c = 'Test';
   groupOutletTypeWithSubType.recordTypeId = recordTypeId;
   groupOutletTypeWithSubType.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithSubType.ASI_CRM_Outlet_Sub_Type__c = 'Family KTV; Asian Restaurant';
   groupOutletTypeWithSubType.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes.add(groupOutletTypeWithSubType);

   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithArea = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithArea.ASI_CRM_SG_Name__c = 'Test2';
   groupOutletTypeWithArea.recordTypeId = recordTypeId;
   groupOutletTypeWithArea.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithArea.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes.add(groupOutletTypeWithArea);

   insert groupOutletTypes;


   Id recordTypeId3 = [SELECT Id FROM Recordtype WHERE Developername = :'ASI_CRM_VN_Group_Outlet_Type'][0].Id;
   List<ASI_CRM_Group_Outlet_Type__c> groupOutletTypes3 = new List<ASI_CRM_Group_Outlet_Type__c>();
   //Create Test Group Outlet Type record
   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithSubType3 = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithSubType3.ASI_CRM_SG_Name__c = 'Test';
   groupOutletTypeWithSubType3.recordTypeId = recordTypeId3;
   groupOutletTypeWithSubType3.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithSubType3.ASI_CRM_Outlet_Sub_Type__c = 'Family KTV; Asian Restaurant';
   groupOutletTypeWithSubType3.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes3.add(groupOutletTypeWithSubType3);

   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithArea3 = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithArea3.ASI_CRM_SG_Name__c = 'Test2';
   groupOutletTypeWithArea3.recordTypeId = recordTypeId;
   groupOutletTypeWithArea3.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithArea3.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes3.add(groupOutletTypeWithArea3);

   insert groupOutletTypes3;

   Id recordTypeId4 = [SELECT Id FROM Recordtype WHERE Developername = :'ASI_CRM_VN_Group_Outlet_Type'][0].Id;
   List<ASI_CRM_Group_Outlet_Type__c> groupOutletTypes4 = new List<ASI_CRM_Group_Outlet_Type__c>();
   //Create Test Group Outlet Type record
   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithSubType4 = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithSubType4.ASI_CRM_SG_Name__c = 'Test';
   groupOutletTypeWithSubType4.recordTypeId = recordTypeId4;
   groupOutletTypeWithSubType4.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithSubType4.ASI_CRM_Outlet_Sub_Type__c = 'Family KTV; Asian Restaurant';
   groupOutletTypeWithSubType4.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes4.add(groupOutletTypeWithSubType4);

   ASI_CRM_Group_Outlet_Type__c groupOutletTypeWithArea4 = new ASI_CRM_Group_Outlet_Type__c();
   groupOutletTypeWithArea4.ASI_CRM_SG_Name__c = 'Test2';
   groupOutletTypeWithArea4.recordTypeId = recordTypeId4;
   groupOutletTypeWithArea4.ASI_CRM_SG_Group_Outlet_Name__c = 'Test';
   groupOutletTypeWithArea4.ASI_CRM_Area__c = 'HCMC; HANOI';
   groupOutletTypes4.add(groupOutletTypeWithArea4);

   insert groupOutletTypes4;


   ASI_CRM_VN_AccCreateProsSegHandler objCtrl = new ASI_CRM_VN_AccCreateProsSegHandler();
   objCtrl.createProsSegRecord(customerList);
   objCtrl.createProsSegRecordForValueSeg(customerList2);
   test.stopTest();

   List<ASI_CRM_Pros_Segmentation__c> prosSegList = new List<ASI_CRM_Pros_Segmentation__c>();
   prosSegList = [select Id from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Group_Outlet_Type__c = :groupOutletTypeWithSubType.Id];
 }
}