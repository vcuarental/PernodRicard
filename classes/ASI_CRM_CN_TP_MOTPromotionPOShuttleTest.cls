@isTest
public class ASI_CRM_CN_TP_MOTPromotionPOShuttleTest {
    @TestSetup
    static void makeData(){
      User userInstance = ASI_CRM_CN_TP_TestUtils.generateAdminUser('Ducatel_Sophie@Org.com');
      System.runAs(userInstance){
        ASI_CRM_Province__c province = ASI_CRM_CN_TP_TestUtils.getProvince();
        insert province;
        ASI_CRM_KA_Account__c kaAcc = ASI_CRM_CN_TP_TestUtils.getKaAccount();
        insert kaAcc;
        ASI_CRM_CN_Channel__c cnChannel = ASI_CRM_CN_TP_TestUtils.getChannel();
        insert cnChannel;
        ASI_CRM_City__c city = ASI_CRM_CN_TP_TestUtils.getCity(province);
        insert city;
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_CN_TP_TestUtils.getSubBrand();
        insert subBrand;

        Test.startTest();
        ASI_CRM_AccountsAdditionalField__c accountAddition = ASI_CRM_CN_TP_TestUtils.getAccountsAdditional(city,cnChannel);
        insert accountAddition;
        ASI_TH_CRM_Contract__c contract = ASI_CRM_CN_TP_TestUtils.getContract(accountAddition);
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_PO_No__c = '123456';
        insert contract;
        
        ASI_MFM_Prefix__c prefixBudget = ASI_CRM_CN_TP_TestUtils.getPrefix();
        prefixBudget.Name = 'CN Budget Plan';
        prefixBudget.Plan_Type__c = 'Budget Plan';
        insert prefixBudget;
        ASI_MFM_Prefix__c prefixTP = ASI_CRM_CN_TP_TestUtils.getPrefix();
        prefixTP.Name = 'CN Trade Plan';
        insert prefixTP;

        List<ASI_MFM_Role_Prefix_Relationship__c> prefixRelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c prefixRelationship1 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixBudget);
        prefixRelationshipList.add(prefixRelationship1);
        ASI_MFM_Role_Prefix_Relationship__c prefixRelationship2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixBudget);
        prefixRelationship2.ASI_MFM_Role_Name__c = 'GDT';
        prefixRelationshipList.add(prefixRelationship2);

        ASI_MFM_Role_Prefix_Relationship__c prefixRelationshipTp1 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
        prefixRelationshipList.add(prefixRelationshipTp1);
        ASI_MFM_Role_Prefix_Relationship__c prefixRelationshipTp2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefixTP);
        prefixRelationshipTp2.ASI_MFM_Role_Name__c = 'GDT';
        prefixRelationshipList.add(prefixRelationshipTp2);
        insert prefixRelationshipList; 

        ASI_MFM_Plan__c budgetPlan = ASI_CRM_CN_TP_TestUtils.getBudgetPlan(kaAcc,prefixBudget);
        insert budgetPlan; 
        ASI_MFM_Plan__c plan = ASI_CRM_CN_TP_TestUtils.getTradePlan(contract,prefixTP,cnChannel,kaAcc);
        plan.ASI_CRM_CN_TP_Budget_Plan__c = budgetPlan.id;
        insert plan;
        ASI_MFM_Plan_Line_Item__c pLItem = ASI_CRM_CN_TP_TestUtils.getPLItem(plan,subBrand);
        insert pLItem;
        ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfLItem = ASI_CRM_CN_TP_TestUtils.getBRSFLineItem(subBrand,contract);
        insert brsfLItem;
        Test.stopTest();
        ASI_CRM_Contract_Cost__c contractCost = ASI_CRM_CN_TP_TestUtils.getContractCost(contract);
        insert contractCost;
        contract.ASI_CRM_CN_Status__c = 'Approved';
        update contract;
      }
    }
    @isTest
    static void testPoVersionOne(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl poShuttleCtrl = new ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl();
        poShuttleCtrl.pageStyle ='pdf';
        poShuttleCtrl.dummyVar = true;
        ASI_TH_CRM_Contract__c contract = [SELECT id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        poShuttleCtrl.poId = contract.id;
        poShuttleCtrl.init();
      }
    }
    @isTest
    static void testPoVersionTwo(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_CRM_KA_Account__c kaAcc = [SELECT id FROM ASI_CRM_KA_Account__c LIMIT 1];
        ASI_MFM_Prefix__c prefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
        prefix.Name = 'CN TP Approval';
        prefix.Plan_Type__c = 'Trade Plan';
        insert prefix;
        List<ASI_MFM_Role_Prefix_Relationship__c> prefixRelationshipList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c prefixRelationshipTpApproval1 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
        prefixRelationshipList.add(prefixRelationshipTpApproval1);
        ASI_MFM_Role_Prefix_Relationship__c prefixRelationshipTpApproval2 = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
        prefixRelationshipTpApproval2.ASI_MFM_Role_Name__c = 'GDT';
        prefixRelationshipList.add(prefixRelationshipTpApproval2);

        insert prefixRelationshipList;

        ASI_MFM_Plan__c approvalTp = ASI_CRM_CN_TP_TestUtils.getApprovalPlan(kaAcc,prefix);
        insert approvalTp;

        ASI_MFM_Plan__c tpInstance = [SELECT id FROM ASI_MFM_Plan__c WHERE RecordType.developerName='ASI_CRM_CN_TP_Trade_Plan' LIMIT 1];
        ASI_MFM_Plan_Line_Item__c pLItem = [SELECT id,ASI_MFM_Plan__c,ASI_CRM_CN_TP_Estimated_Qty__c FROM ASI_MFM_Plan_Line_Item__c WHERE RecordType.developerName='ASI_CRM_CN_TP_Trade_Plan_Line_Item' AND ASI_MFM_Plan__c =:tpInstance.id LIMIT 1];
        pLItem.ASI_CRM_CN_TP_Estimated_Qty__c = 103;
        update pLItem;
        ASI_MFM_Plan__c tpInstance2 = [SELECT id FROM ASI_MFM_Plan__c WHERE RecordType.developerName='ASI_CRM_CN_TP_Trade_Plan' LIMIT 1];
        tpInstance2.ASI_MFM_Status__c = 'Final';
        tpInstance2.ASI_CRM_CN_TP_Approval__c = approvalTp.id;
        update tpInstance2;
        List<ASI_TH_CRM_Contract__c> contractV0 = [SELECT id,ASI_CRM_CN_PO_Version__c FROM ASI_TH_CRM_Contract__c];
        
        ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl poShuttleCtrl = new ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl();
        poShuttleCtrl.poId = contractV0[0].id;
        poShuttleCtrl.init();
      }
    }
    @isTest
    static void testPoVersionThree(){
      User userInstance = [SELECT id FROM USER WHERE username = 'Ducatel_Sophie@Org.com' LIMIT 1];
      System.runAs(userInstance){
        ASI_TH_CRM_Contract__c contractV0 = [SELECT id FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_PO_No__c = '123456' LIMIT 1];
        contractV0.ASI_CRM_CN_PO_Version__c='0.1';
        update contractV0;
        ASI_CRM_AccountsAdditionalField__c accountAddition =  [SELECT id FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];
        ASI_TH_CRM_Contract__c contract = ASI_CRM_CN_TP_TestUtils.getContract(accountAddition);
        contract.ASI_CRM_CN_PO_Version__c = '0.0';
        contract.ASI_CRM_CN_PO_No__c = '123456';
        insert contract;
        ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl poShuttleCtrl = new ASI_CRM_CN_TP_MOTPromotionPOShuttleCtrl();
        poShuttleCtrl.poId = contractV0.id;
        poShuttleCtrl.init();
      }
    }
}