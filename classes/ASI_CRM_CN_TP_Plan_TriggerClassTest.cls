@isTest
private class ASI_CRM_CN_TP_Plan_TriggerClassTest {

	@testSetup
    static void testDataPre() {
    	User admin = ASI_CRM_CN_TP_TestUtils.generateAdminUser('testAdmin@Pernod.com');
        System.runAs(admin){
	    	ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='North Region');
	        insert region;
	    	ASI_CRM_CN_Channel__c cnChannel = ASI_CRM_CN_TP_TestUtils.getChannel();
		    insert cnChannel;
		    ASI_CRM_Division__c division = ASI_CRM_CN_TP_TestUtils.getDivision();
		    division.ASI_CRM_Region__c = region.Id;
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
		    contract.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true;
		    insert contract;
		    ASI_TH_CRM_Contract__c contract2 = ASI_CRM_CN_TP_TestUtils.getContract(accountAddition);
		    contract2.ASI_CRM_CN_PO_No__c = '20190046';
		    insert contract2;
		    ASI_CRM_KA_Account__c kaAcc = ASI_CRM_CN_TP_TestUtils.getKaAccount();
		    insert kaAcc;
		    Test.startTest();
		    ASI_MFM_Prefix__c prefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
		    insert prefix;
		    ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
		    insert prefixRelationShip;
		    
		    ASI_MFM_Prefix__c approvalPrefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
		    approvalPrefix.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');
		    approvalPrefix.Name = 'CN TP Approval';
		    insert approvalPrefix;
		    ASI_MFM_Role_Prefix_Relationship__c approvalPrefixRelationShip = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(approvalPrefix);
		    insert approvalPrefixRelationShip;

		    ASI_MFM_Prefix__c bpprefix = new ASI_MFM_Prefix__c(Name = 'CN Budget Plan', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix'));
	        bpprefix.ASI_MFM_Module__c = 'Plan';
	        bpprefix.Plan_Type__c = 'Budget Plan';
	        bpprefix.ASI_MFM_Fiscal_year__c = 'FY1920';
	        insert bpprefix;

	        ASI_MFM_Role_Prefix_Relationship__c bpprefixRelationShip = new ASI_MFM_Role_Prefix_Relationship__c();
	        bpprefixRelationShip.ASI_MFM_Prefix__c = bpprefix.Id;
	        bpprefixRelationShip.ASI_MFM_Role_Name__c = 'ASI_CN';
	        insert bpprefixRelationShip;

		    ASI_MFM_Plan__c bp = new ASI_MFM_Plan__c();
		    bp.Name = 'test bp';
		    bp.ASI_MFM_Prefix__c = bpprefix.Id;
		    bp.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
		    bp.ASI_CRM_CN_TP_External_ID__c = 'BP' + kaAcc.Id + '-' + 'FY1920';
		    bp.ASI_MFM_Budget_Amount__c = 500000000;
		    insert bp;

		    ASI_MFM_Plan__c approvalPlan = ASI_CRM_CN_TP_TestUtils.getApprovalPlan(kaAcc,approvalPrefix);
		    insert approvalPlan;
		    ASI_MFM_Plan__c plan = ASI_CRM_CN_TP_TestUtils.getTradePlan(contract,prefix,cnChannel,kaAcc);
		    plan.ASI_CRM_CN_TP_Approval__c = approvalPlan.Id;
		    plan.ASI_CRM_CN_TP_Cover_City__c = city.ASI_CRM_Chinese_Name__c;
		    plan.ASI_MFM_Status__c = 'Draft';
		    plan.ASI_CRM_CN_TP_Budget_Plan__c = bp.Id;
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

		    ASI_MFM_Fix_Approval_Route__c appRoute = new ASI_MFM_Fix_Approval_Route__c();
		    appRoute.ASI_MFM_Team__c = 'North';
		    appRoute.ASI_MFM_Module__c = 'Trade Plan';
		    appRoute.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_CN_Fix_Approval_Route');
		    insert appRoute;
		}
    }
    static testMethod void testTPsubmitted() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
	        ASI_MFM_Plan__c tp = [SELECT Id FROM ASI_MFM_Plan__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan'];
	        tp.ASI_MFM_Status__c = 'Submitted';
	        update tp;
	        ASI_CRM_CN_TP_Plan_TriggerClass.setApproverByCount(tp, 10, admin.Id);
	    }
        Test.stopTest();
    }
    static testMethod void testTPApproval() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
	        ASI_MFM_Plan__c tp = [SELECT Id FROM ASI_MFM_Plan__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan'];
	        tp.ASI_MFM_Status__c = 'Final';
	        update tp;
	    }
        Test.stopTest();
    }
    static testMethod void testBPSummary() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
	        ASI_MFM_Plan__c tp = [SELECT Id FROM ASI_MFM_Plan__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan'];
	        tp.ASI_CRM_CN_TP_Cover_City__c = null;
	        tp.ASI_MFM_Status__c = 'Complete';
	        update tp;
	    }
        Test.stopTest();
    }

    static testMethod void testPOChanged() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
	        ASI_TH_CRM_Contract__c po = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_PO_No__c = '20190046'];
	        ASI_MFM_Plan__c tp = [SELECT Id FROM ASI_MFM_Plan__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_TP_Trade_Plan'];
	        tp.ASI_CRM_CN_TP_Contract__c = po.Id;
	        update tp;
	    }
        Test.stopTest();
    }
}