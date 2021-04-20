@isTest
public class ASI_CRM_CN_TP_MOTTradePlanListCtrlTest {
   @TestSetup
   static void makeData(){
     User userInstance = ASI_CRM_CN_TP_TestUtils.generateAdminUser('Ducatel_Sophie@Org.com');
     System.runAs(userInstance){

      ASI_CRM_CN_CustomSetting__c tpSetting = new ASI_CRM_CN_CustomSetting__c();
        tpSetting.ASI_CRM_CN_TP_BP_Table_Header__c = '客户,财年,CRM,预算所属人,预算总金额,去年促销销量,去年促销金额,去年海报/陈列费,去年Cont. Margin金额,去年Gross Sales金额,备注';
        tpSetting.ASI_CRM_CN_TP_BP_Table_Error_Header__c = '客户,财年,CRM,预算所属人,预算总金额,去年促销销量,去年促销金额,去年海报/陈列费,去年Cont Margin金额,去年Gross Sales金额,备注,错误信息';
        tpSetting.ASI_CRM_CN_TP_Table_Header__c = '活动编号,区域,客户类型,渠道,客户,财年,活动开始时间,活动结束时间,CRM,DM(Y/N),二次陈列,二次陈列门店数,海报费,陈列费,子品牌Code,尺寸(cl),促销方式,促销内容,产品零售价,促销单价/瓶,正常进价,促销进价/瓶,单瓶补贴,预计销量,Remark,备注';
        tpSetting.ASI_CRM_CN_TP_Table_Error_Header__c = '活动编号,区域,客户类型,渠道,客户,财年,活动开始时间,活动结束时间,CRM,DM(Y/N),二次陈列,二次陈列门店数,海报费,陈列费,子品牌Code,尺寸(cl),促销方式,促销内容,产品零售价,促销单价/瓶,正常进价,促销进价/瓶,单瓶补贴,预计销量,Remark,备注,错误信息';
        tpSetting.ASI_CRM_CN_TP_Sub_Brand_Header__c = '子品牌名称,子品牌 Code,中文名称';
        tpSetting.ASI_CRM_CN_TP_BP_Table_Body__c = '世纪联华,FY1920,ONSHA3629,Mousa SUN,10000,10000,10000,10000,100000,12000,备注内容';
        tpSetting.ASI_CRM_CN_TP_City_Header__c = '城市名称,中文名称';
        insert tpSetting;
       
      ASI_MFM_Prefix__c prefixApproval = ASI_CRM_CN_TP_TestUtils.getPrefix();
      prefixApproval.Name = 'CN TP Approval';
      insert prefixApproval;

      ASI_MFM_Prefix__c prefixBudget = ASI_CRM_CN_TP_TestUtils.getPrefix();
      prefixBudget.Name = 'CN Budget Plan';
      prefixBudget.Plan_Type__c = 'Budget Plan';
      insert prefixBudget;
      ASI_MFM_Prefix__c prefixTP = ASI_CRM_CN_TP_TestUtils.getPrefix();
      prefixTP.Name = 'CN Trade Plan';
      insert prefixTP;

      List<ASI_MFM_Role_Prefix_Relationship__c> prefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationApproval = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixApproval);
      prefixRelationList.add(prefixRelationApproval);

      ASI_MFM_Role_Prefix_Relationship__c prefixRelationbudget1 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixBudget);
      prefixRelationList.add(prefixRelationbudget1);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationbudget2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixBudget);
      prefixRelationbudget2.ASI_MFM_Role_Name__c = 'ASI_FOC_BA_Applier';
      prefixRelationList.add(prefixRelationbudget2);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationbudget3 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixBudget);
      prefixRelationbudget3.ASI_MFM_Role_Name__c = 'GDT';
      prefixRelationList.add(prefixRelationbudget3);

      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShipTp1 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
      prefixRelationList.add(prefixRelationShipTp1);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShipTp2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
      prefixRelationShipTp2.ASI_MFM_Role_Name__c = 'ASI_CN_Asst_Customer_Marketing_Manager_Premium';
      prefixRelationList.add(prefixRelationShipTp2);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShipTp3 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
      prefixRelationShipTp3.ASI_MFM_Role_Name__c = 'ASI_CN_Asst_Sales_Manager';
      prefixRelationList.add(prefixRelationShipTp3);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShipTp4 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
      prefixRelationShipTp4.ASI_MFM_Role_Name__c = 'ASI_CN_Team_Assistant';
      prefixRelationList.add(prefixRelationShipTp4);
      ASI_MFM_Role_Prefix_Relationship__c prefixRelationShipTp5 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
      prefixRelationShipTp5.ASI_MFM_Role_Name__c = 'GDT';
      prefixRelationList.add(prefixRelationShipTp5);
      insert prefixRelationList;

      ASI_CRM_CN_Channel__c cnChannel = ASI_CRM_CN_TP_TestUtils.getChannel();
      insert cnChannel;
      ASI_CRM_Province__c province = ASI_CRM_CN_TP_TestUtils.getProvince();
      insert province;
      ASI_CRM_City__c city = ASI_CRM_CN_TP_TestUtils.getCity(province);
      insert city;
      ASI_CRM_AccountsAdditionalField__c accountAdditionField = ASI_CRM_CN_TP_TestUtils.getAccountsAdditional(city,cnChannel);
      insert accountAdditionField;
      ASI_TH_CRM_Contract__c contract = ASI_CRM_CN_TP_TestUtils.getContract(accountAdditionField);
      insert contract;

      ASI_TH_CRM_PaymentRequest__c pRequest = ASI_CRM_CN_TP_TestUtils.getPaymentRequest(accountAdditionField,contract);
        insert pRequest;
      
      ASI_MFM_Sub_brand__c sbrand = ASI_CRM_CN_TP_TestUtils.getSubBrand();
      insert sbrand;
      ASI_MFM_Sub_brand__c sbrand2 = ASI_CRM_CN_TP_TestUtils.getSubBrand();
      sbrand2.Name = '999';
      sbrand2.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
      insert sbrand2;

      ASI_CRM_KA_Account__c kaAcc = ASI_CRM_CN_TP_TestUtils.getKaAccount();
      insert kaAcc;
      Test.startTest();
      ASI_MFM_Plan__c budgetPlan = ASI_CRM_CN_TP_TestUtils.getBudgetPlan(kaAcc,prefixBudget);
      insert budgetPlan;
      ASI_MFM_Plan__c tradePlan = ASI_CRM_CN_TP_TestUtils.getTradePlan(contract,prefixTP,cnChannel,kaAcc);
      tradePlan.ASI_MFM_Start_Date__c = Date.newInstance(2019,7,1);
      tradePlan.ASI_MFM_End_Date__c = Date.newInstance(2020,5,20);
      insert tradePlan;
      tradePlan.ASI_CRM_CN_TP_Budget_Plan__c = budgetPlan.id;
      update tradePlan;
      ASI_MFM_Event__c outlet = ASI_CRM_CN_TP_TestUtils.getOutLet(tradePlan,accountAdditionField);
      insert outlet;

      List<ASI_MFM_Plan_Line_Item__c> pLIList = new List<ASI_MFM_Plan_Line_Item__c>();
      ASI_MFM_Plan_Line_Item__c planLineItem = ASI_CRM_CN_TP_TestUtils.getPLItem(tradePlan,sbrand);
      pLIList.add(planLineItem);
      ASI_MFM_Plan_Line_Item__c planLineItem2 = ASI_CRM_CN_TP_TestUtils.getPLItem(tradePlan,sbrand2);
      pLIList.add(planLineItem2);
      insert pLIList;

      Test.stopTest();
      ASI_CRM_Contract_Cost__c contractCost = ASI_CRM_CN_TP_TestUtils.getContractCost(contract);
      insert contractCost;
     }
   }
   @IsTest
   static void generate999(){
     User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
     System.runAs(userInstance){
      List<Id> tpLItemIdList = ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryTpItemIds();
      String tpLItemId = tpLItemIdList[0];
      List<ASI_MFM_Plan_Line_Item__c> tpLItemList =  [SELECT id,ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE id in:tpLItemIdList];
      List<ASI_MFM_Sub_brand__c> subandList = [SELECT id FROM ASI_MFM_Sub_brand__c LIMIT 1];
      String subrangId = subandList[0].id;
      String tpPlanId = tpLItemList[0].ASI_MFM_Plan__c;
      ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryRecord(tpLItemIdList);
      String jsonData = '[{"TotalActualQty":40,"PlanLineItemId":\"'+tpLItemId+
                            '\","PromotionMode":"进价核销","Subsidies":3,"RetailPrice":2'+
                            ',"PromotionUnitPrice":5,"NormalPurchasePrice":4,"PromotionPurchasePrice":50,"EstimatedQty":60'+
                            ',"ThisFixedCost":1,"ThisPromotionAmount":1,"FixedCostPaymentAmount":1,"PromotionPaymentAmount":1'+
                            ',"PaymentAmount":1'+
                            ',"PostersFee":5,"DisplayFee":6,"ActualQty":20,"PaymentAmount":8'+
                            ',"PlanId":\"'+tpPlanId+
                        '\"}]';
      Test.startTest();
      ASI_CRM_CN_TP_MOTTradePlanListCtrl.generate999(jsonData);
      Test.stopTest();
     }
   }
   
   @isTest
   static void testConstructor(){
     User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
     System.runAs(userInstance){
      Test.startTest();
      // insert new ASI_CRM_CN_TP_Setting__c(ASI_CRM_CN_TP_Status__c='Draft,Submitted,Final,Complete');
      ASI_CRM_CN_TP_MOTTradePlanListCtrl sCtrl  = new ASI_CRM_CN_TP_MOTTradePlanListCtrl();
      sCtrl.taxRate = 0.2;
      Test.stopTest();
     }
   }
    @IsTest
    static void testSaveTpLItem(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        List<Id> tpLItemIdList = ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryTpItemIds();
        String tpLItemId = tpLItemIdList[0];
        List<ASI_MFM_Plan_Line_Item__c> prlines = [select id,ASI_MFM_Plan__c,ASI_CRM_CN_TP_Promotion_Mode__c from ASI_MFM_Plan_Line_Item__c limit 1];
        new ASI_CRM_CN_TP_MOTTradePlanListCtrl.PlanLineItem(prlines[0], '2020-10-01', '2020-11-01');
        new ASI_CRM_CN_TP_MOTTradePlanListCtrl.PlanLineItem(prlines[0]);
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryRecord(tpLItemIdList);
        String jsonData = '[{"TotalActualQty":40,"PlanLineItemId":\"'+tpLItemId+
                            '\","PromotionMode":"进价核销","Subsidies":3,"RetailPrice":2'+
                            ',"PromotionUnitPrice":5,"NormalPurchasePrice":4,"PromotionPurchasePrice":50,"EstimatedQty":60'+
                            ',"PostersFee":5,"DisplayFee":6,"ActualQty":20,"PaymentAmount":8'+
                          '}]';
        
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.save(jsonData);
      }
    }
    @IsTest
    static void testSubmitTpApproval(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        List<Id> tpLItemIdList = ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryTpItemIds();
        String tpLItemId = tpLItemIdList[0];
        List<ASI_MFM_Plan_Line_Item__c> tpLItemList =  [SELECT id,ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE id in:tpLItemIdList];
        List<ASI_MFM_Sub_brand__c> subandList = [SELECT id FROM ASI_MFM_Sub_brand__c LIMIT 1];
        String subrangId = subandList[0].id;
        String tpPlanId = tpLItemList[0].ASI_MFM_Plan__c;
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryRecord(tpLItemIdList);
        String jsonData = '[{"TotalActualQty":40,"PlanLineItemId":\"'+tpLItemId+
                            '\","PromotionMode":"进价核销","Subsidies":3,"RetailPrice":2'+
                            ',"PromotionUnitPrice":5,"NormalPurchasePrice":4,"PromotionPurchasePrice":50,"EstimatedQty":60'+
                            ',"PostersFee":5,"DisplayFee":6,"ActualQty":20,"PaymentAmount":8'+
                            ',"PlanId":\"'+tpPlanId+
                          '\"}]';
        Test.startTest();
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.submitApproval('',jsonData);
        Test.stopTest();
      }
    }
    @IsTest
    static void testGeneratePo(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        List<Id> tpLItemIdList = ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryTpItemIds();
        String tpLItemId = tpLItemIdList[0];
        List<ASI_MFM_Plan_Line_Item__c> tpLItemList =  [SELECT id,ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE id in:tpLItemIdList];
        List<ASI_MFM_Sub_brand__c> subandList = [SELECT id FROM ASI_MFM_Sub_brand__c LIMIT 1];
        String subrangId = subandList[0].id;
        String tpPlanId = tpLItemList[0].ASI_MFM_Plan__c;
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryRecord(tpLItemIdList);
        String jsonData = '[{"TotalActualQty":40,"PlanLineItemId":\"'+tpLItemId+
                            '\","PromotionMode":"进价核销","Subsidies":3,"RetailPrice":2'+
                            ',"PromotionUnitPrice":5,"NormalPurchasePrice":4,"PromotionPurchasePrice":50,"EstimatedQty":60'+
                            ',"PostersFee":5,"DisplayFee":6,"ActualQty":20,"PaymentAmount":8'+
                            ',"PlanId":\"'+tpPlanId+
                          '\"}]';
        Test.startTest();
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.generatePo(jsonData);
        Test.stopTest();
      }
    }
    @IsTest
    static void testGeneratePayment(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        List<Id> tpLItemIdList = ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryTpItemIds();
        String tpLItemId = tpLItemIdList[0];
        List<ASI_MFM_Plan_Line_Item__c> tpLItemList =  [SELECT id,ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE id in:tpLItemIdList];
        List<ASI_MFM_Sub_brand__c> subandList = [SELECT id FROM ASI_MFM_Sub_brand__c LIMIT 1];
        String subrangId = subandList[0].id;
        String tpPlanId = tpLItemList[0].ASI_MFM_Plan__c;
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryRecord(tpLItemIdList);
        String jsonData = '[{"TotalActualQty":40,"PlanLineItemId":\"'+tpLItemId+
                            '\","PromotionMode":"进价核销","Subsidies":3,"RetailPrice":2'+
                            ',"PromotionUnitPrice":5,"NormalPurchasePrice":4,"PromotionPurchasePrice":50,"EstimatedQty":60'+
                            ',"ThisFixedCost":1,"ThisPromotionAmount":1,"FixedCostPaymentAmount":1,"PromotionPaymentAmount":1'+
                            ',"PaymentAmount":1'+
                            ',"PostersFee":5,"DisplayFee":6,"ActualQty":20,"PaymentAmount":8'+
                            ',"PlanId":\"'+tpPlanId+
                          '\"}]';
        Test.startTest();
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.generatePayment(jsonData);
        Test.stopTest();
      }
    }
    @isTest
    static void testConstant(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        String digitformat = ASI_CRM_CN_TP_Utils.digit_formatting(5,25.5);
      }
    }

    @isTest
    static void testLastPmt(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_TH_CRM_PaymentRequest__c pmt = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c LIMIT 1 ];
        ASI_CRM_CN_TP_Utils.LastpaymentForm(pmt.Id);
      }
    }
    
    @isTest
    static void testdeletePmt(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        List<Id> tpLItemIdList = ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryTpItemIds();
        String tpLItemId = tpLItemIdList[0];
        List<ASI_MFM_Plan_Line_Item__c> tpLItemList =  [SELECT id,ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE id in:tpLItemIdList];
        List<ASI_MFM_Sub_brand__c> subandList = [SELECT id FROM ASI_MFM_Sub_brand__c LIMIT 1];
        String subrangId = subandList[0].id;
        String tpPlanId = tpLItemList[0].ASI_MFM_Plan__c;
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.queryRecord(tpLItemIdList);
        String jsonData = '[{"TotalActualQty":40,"PlanLineItemId":\"'+tpLItemId+
                            '\","PromotionMode":"进价核销","Subsidies":3,"RetailPrice":2'+
                            ',"PromotionUnitPrice":5,"NormalPurchasePrice":4,"PromotionPurchasePrice":50,"EstimatedQty":60'+
                            ',"ThisFixedCost":1,"ThisPromotionAmount":1,"FixedCostPaymentAmount":1,"PromotionPaymentAmount":1'+
                            ',"PaymentAmount":1'+
                            ',"PostersFee":5,"DisplayFee":6,"ActualQty":20,"PaymentAmount":8'+
                            ',"PlanId":\"'+tpPlanId+
                          '\"}]';
        Test.startTest();
        ASI_CRM_CN_TP_MOTTradePlanListCtrl.deleteItems(jsonData);
        Test.stopTest();
      }
    }
}