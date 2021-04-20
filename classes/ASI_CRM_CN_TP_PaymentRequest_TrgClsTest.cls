@isTest
private class ASI_CRM_CN_TP_PaymentRequest_TrgClsTest {

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
		    // ASI_TH_CRM_Contract__c contract2 = ASI_CRM_CN_TP_TestUtils.getContract(accountAddition);
		    // contract2.ASI_CRM_CN_PO_No__c = '20190046';
		    // insert contract2;
		    ASI_CRM_KA_Account__c kaAcc = ASI_CRM_CN_TP_TestUtils.getKaAccount();
		    insert kaAcc;
		    
		    ASI_MFM_Prefix__c prefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
		    insert prefix;
		    ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
		    insert prefixRelationShip;
		    

		    // ASI_MFM_Prefix__c bpprefix = new ASI_MFM_Prefix__c(Name = 'CN Budget Plan', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix'));
	     //    bpprefix.ASI_MFM_Module__c = 'Plan';
	     //    bpprefix.Plan_Type__c = 'Budget Plan';
	     //    bpprefix.ASI_MFM_Fiscal_year__c = 'FY1920';
	     //    insert bpprefix;

	     //    ASI_MFM_Role_Prefix_Relationship__c bpprefixRelationShip = new ASI_MFM_Role_Prefix_Relationship__c();
	     //    bpprefixRelationShip.ASI_MFM_Prefix__c = bpprefix.Id;
	     //    bpprefixRelationShip.ASI_MFM_Role_Name__c = 'ASI_CN';
	     //    insert bpprefixRelationShip;
	        Test.startTest();
		    // ASI_MFM_Plan__c bp = new ASI_MFM_Plan__c();
		    // bp.Name = 'test bp';
		    // bp.ASI_MFM_Prefix__c = bpprefix.Id;
		    // bp.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
		    // bp.ASI_CRM_CN_TP_External_ID__c = 'BP' + kaAcc.Id + '-' + 'FY1920';
		    // insert bp;

		   
		    ASI_MFM_Plan__c plan = ASI_CRM_CN_TP_TestUtils.getTradePlan(contract,prefix,cnChannel,kaAcc);
		    plan.ASI_CRM_CN_TP_Cover_City__c = city.ASI_CRM_Chinese_Name__c;
		    plan.ASI_MFM_Status__c = 'Draft';
		    insert plan;

		    
		    ASI_TH_CRM_PaymentRequest__c pRequest = ASI_CRM_CN_TP_TestUtils.getPaymentRequest(accountAddition,contract);
		    pRequest.ASI_TH_CRM_Status__c = 'Draft';
		    pRequest.ASI_CRM_CN_Last_Payment__c = true;
		    insert pRequest;
		    Test.stopTest();
		   

		}
	    
    }
    static testMethod void testMethod1() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
	        ASI_TH_CRM_PaymentRequest__c pmt = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Last_Payment__c = true LIMIT 1 ];
	        pmt.ASI_TH_CRM_Status__c = 'Approved';
	        update pmt;
	    }
        Test.stopTest();
    }
    static testMethod void testMethod2() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
        Test.startTest();
        System.runAs(admin){
	        ASI_TH_CRM_PaymentRequest__c pmt = [SELECT Id, ASI_CRM_CN_Last_Payment__c,ASI_TH_CRM_Contract__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Last_Payment__c = true LIMIT 1 ];
	        pmt.ASI_TH_CRM_Status__c = 'Approved';

	        ASI_TH_CRM_PaymentRequest__c pmt2 = [SELECT Id,ASI_CRM_CN_Last_Payment__c,ASI_TH_CRM_Contract__c FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_CN_Last_Payment__c = true LIMIT 1 ];
	        pmt2.ASI_TH_CRM_Status__c = 'Draft';
	        Map<Id, ASI_TH_CRM_PaymentRequest__c> oldMap = new Map<Id, ASI_TH_CRM_PaymentRequest__c>();
	        oldMap.put(pmt.Id, pmt2);
	        
	        ASI_CRM_CN_TP_PaymentRequest_TriggerCls.routineAfterUpsert(new List<ASI_TH_CRM_PaymentRequest__c>{pmt}, oldMap);
	    }
        Test.stopTest();
    }
}