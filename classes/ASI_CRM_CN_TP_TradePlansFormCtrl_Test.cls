@isTest
public class ASI_CRM_CN_TP_TradePlansFormCtrl_Test {
   @TestSetup
   static void makeData(){
    User userInstance = ASI_CRM_CN_TP_TestUtils.generateAdminUser('Ducatel_Sophie@Org.com');
    System.runAs(userInstance){
      ASI_CRM_CN_Channel__c cnChannel = ASI_CRM_CN_TP_TestUtils.getChannel();
      insert cnChannel;
      ASI_CRM_Division__c division = ASI_CRM_CN_TP_TestUtils.getDivision();
      insert division;
      ASI_CRM_CN_Area__c area = ASI_CRM_CN_TP_TestUtils.getArea(division);
      insert area;
      ASI_CRM_Province__c province = ASI_CRM_CN_TP_TestUtils.getProvince();
      insert province;
      ASI_CRM_City__c city = ASI_CRM_CN_TP_TestUtils.getCity(province);
      insert city;
      ASI_CRM_AccountsAdditionalField__c accountAddition = ASI_CRM_CN_TP_TestUtils.getAccountsAdditional(city,cnChannel);
      insert accountAddition;
      ASI_TH_CRM_Contract__c contract = ASI_CRM_CN_TP_TestUtils.getContract(accountAddition);
      insert contract;
      ASI_CRM_KA_Account__c kaAcc = ASI_CRM_CN_TP_TestUtils.getKaAccount();
      insert kaAcc;
      Test.startTest();

      ASI_MFM_Prefix__c prefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
      insert prefix;

      ASI_MFM_Prefix__c approvalPrefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
      approvalPrefix.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');
      approvalPrefix.Name = 'CN TP Approval';
      insert approvalPrefix;

      List<ASI_MFM_Role_Prefix_Relationship__c> prefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
      prefixRelationList.add(prefixRelationShip);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
      prefixRelationShip2.ASI_MFM_Role_Name__c = 'ASI_CN_Asst_Customer_Marketing_Manager_Premium';
      prefixRelationList.add(prefixRelationShip2);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip3 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
      prefixRelationShip3.ASI_MFM_Role_Name__c = 'ASI_CN_Asst_Sales_Manager';
      prefixRelationList.add(prefixRelationShip3);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip4 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
      prefixRelationShip4.ASI_MFM_Role_Name__c = 'ASI_CN_Team_Assistant';
      prefixRelationList.add(prefixRelationShip4);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip5 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
      prefixRelationShip5.ASI_MFM_Role_Name__c = 'GDT';
      prefixRelationList.add(prefixRelationShip5);


      ASI_MFM_Role_Prefix_Relationship__c approvalPrefixRelationShipApprovalTp = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(approvalPrefix);
      prefixRelationList.add(approvalPrefixRelationShipApprovalTp);
      ASI_MFM_Role_Prefix_Relationship__c approvalPrefixRelationShipApprovalTp2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(approvalPrefix);
      approvalPrefixRelationShipApprovalTp2.ASI_MFM_Role_Name__c = 'GDT';
      prefixRelationList.add(approvalPrefixRelationShipApprovalTp2);
      insert prefixRelationList;
      ASI_MFM_Plan__c plan = ASI_CRM_CN_TP_TestUtils.getTradePlan(contract,prefix,cnChannel,kaAcc);
      insert plan;
      ASI_MFM_Sub_brand__c sbrand = ASI_CRM_CN_TP_TestUtils.getSubBrand();
      insert sbrand;
      ASI_TH_CRM_PaymentRequest__c pRequest = ASI_CRM_CN_TP_TestUtils.getPaymentRequest(accountAddition,contract);
      insert pRequest;
      Test.stopTest();
      ASI_MFM_Plan_Line_Item__c pLItem = ASI_CRM_CN_TP_TestUtils.getPLItem(plan,sbrand);
      insert pLItem;
      ASI_TH_CRM_PaymentRequestLineItem__c pRLineItem = ASI_CRM_CN_TP_TestUtils.getPRequestLineItem(pRequest);
      insert pRLineItem;
      ASI_MFM_Plan__c approvalPlan = ASI_CRM_CN_TP_TestUtils.getApprovalPlan(kaAcc,approvalPrefix);
      insert approvalPlan;
    }
   }
    @IsTest
    static void testPO_TradePlanDetail(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
       Test.startTest();
       ASI_TH_CRM_Contract__c contract = [SELECT id FROM ASI_TH_CRM_Contract__c Limit 1];
       ASI_CRM_CN_TP_TradePlansFormCtrl tpFormCtrl = new ASI_CRM_CN_TP_TradePlansFormCtrl();
       tpFormCtrl.distinguishPageFlag = '0';
       tpFormCtrl.poId = contract.id;
       tpFormCtrl.init();
       Test.stopTest();
      }
    }
    @IsTest
    static void testPayment_TradePlanDetail(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_TH_CRM_PaymentRequest__c pRequest = [SELECT id FROM ASI_TH_CRM_PaymentRequest__c Limit 1];
        ASI_CRM_CN_TP_TradePlansFormCtrl tpFormCtrl = new ASI_CRM_CN_TP_TradePlansFormCtrl();
        tpFormCtrl.distinguishPageFlag = '0';
        tpFormCtrl.paymentId = pRequest.id;
        tpFormCtrl.init();
      }
    }
    @IsTest
    static void testPlan_TradePlanDetail(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_MFM_Plan__c plan = [SELECT id FROM ASI_MFM_Plan__c WHERE RecordType.developerName = 'ASI_CRM_CN_TP_Trade_Plan' LIMIT 1];
        ASI_CRM_CN_TP_TradePlansFormCtrl tpFormCtrl = new ASI_CRM_CN_TP_TradePlansFormCtrl();
        tpFormCtrl.distinguishPageFlag = '1';
        tpFormCtrl.tradePlanId = plan.id;
        tpFormCtrl.init();
      }
    }
    @IsTest
    static void testApprovalPlan_TradePlanDetail(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_MFM_Plan__c approvalPlan = [SELECT id FROM ASI_MFM_Plan__c WHERE RecordType.developerName = 'ASI_CRM_CN_TP_Approval' LIMIT 1];
        ASI_CRM_CN_TP_TradePlansFormCtrl tpFormCtrl = new ASI_CRM_CN_TP_TradePlansFormCtrl();
        tpFormCtrl.distinguishPageFlag = '1';
        tpFormCtrl.tradePlanId = approvalPlan.id;
        tpFormCtrl.init();
      }
    }
}