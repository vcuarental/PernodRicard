@isTest
private class ASI_CRM_CN_TP_Contract_TriggerClsTest {

	@testSetup
	static void testDataPre() {
		User admin = ASI_CRM_CN_TP_TestUtils.generateAdminUser('testAdmin@Pernod.com');
		admin.ASI_CRM_Sales_Team__c = 'Central-Others';
		update admin;
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
		    list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
	        fars.add(new ASI_CRM_Fix_Approval_Route__c(	ASI_CRM_Sales_Team__c = 'Central-Others', ASI_CRM_CN_Approver_1__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_2__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_3__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_4__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_5__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_6__c = admin.Id
	                                                   ,ASI_CRM_Commercial_Team__c = 'Prestige'
	                                                   , ASI_CRM_CN_Approval_Limit_1__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_2__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_3__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_4__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_5__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_6__c = -999999
	                                                   ,ASI_CRM_CN_Type__c = 'Contract 1st Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
	        fars.add(new ASI_CRM_Fix_Approval_Route__c(	ASI_CRM_Sales_Team__c = 'Central-Others', ASI_CRM_CN_Approver_1__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_2__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_3__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_4__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_5__c = admin.Id
	                                                   , ASI_CRM_CN_Approver_6__c = admin.Id
	                                                   , ASI_CRM_Commercial_Team__c = 'Prestige'
	                                                   , ASI_CRM_CN_Approval_Limit_1__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_2__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_3__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_4__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_5__c = -999999
	                                                   , ASI_CRM_CN_Approval_Limit_6__c = -999999
	                                                   , ASI_CRM_CN_Type__c = 'Contract 2nd Part',ASI_CRM_CN_Region_Area_Channel__c='TEST',ASI_CRM_CN_Entry_Limit__c=-999999));
	        insert fars; 
		   
		    ASI_TH_CRM_Contract__c contract = ASI_CRM_CN_TP_TestUtils.getContract(accountAddition);
		    contract.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true;
		    contract.ASI_CRM_CN_Outlet_WS__c = accountAddition.Id;
		    insert contract;

		    ASI_CRM_KA_Account__c kaAcc = ASI_CRM_CN_TP_TestUtils.getKaAccount();
		    insert kaAcc;
		    Test.startTest();
		    ASI_MFM_Prefix__c prefix = ASI_CRM_CN_TP_TestUtils.getPrefix();
		    insert prefix;
		    ASI_MFM_Role_Prefix_Relationship__c prefixRelationShip = ASI_CRM_CN_TP_TestUtils.getPrefixRelationShip(prefix);
		    insert prefixRelationShip;
		    ASI_MFM_Fix_Approval_Route__c appSetting = new ASI_MFM_Fix_Approval_Route__c();
		    appSetting.ASI_MFM_Module__c = 'Trade Plan';
		    appSetting.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_CN_Fix_Approval_Route');
		    appSetting.ASI_MFM_Team__c = 'North';
		    appSetting.ASI_MFM_Corporate_Approver_1__c = admin.Id;
		    insert appSetting;
		   
		    
		    ASI_MFM_Plan__c plan = ASI_CRM_CN_TP_TestUtils.getTradePlan(contract,prefix,cnChannel,kaAcc);
		    plan.ASI_CRM_CN_TP_Cover_City__c = city.ASI_CRM_Chinese_Name__c;
		    plan.ASI_MFM_Status__c = 'Final';
		    plan.ASI_CRM_CN_TP_Region__c = region.Id;
		    insert plan;

		    Test.stopTest();
		}
    }

    static testMethod void testMethod1() {
    	User admin = [SELECT Id FROM User WHERE Username = 'testAdmin@Pernod.com'];
    	Test.startTest();
    	System.runAs(admin){
	        // List<ASI_TH_CRM_Contract__c> polist = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Last_PO_version__c != null LIMIT 1];
	        List<ASI_MFM_Plan__c> plans = [SELECT Id, ASI_CRM_CN_TP_Contract__c,
	        									 ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Sys_Approver_1__c,
	        									 ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Sys_Approver_2__c,
	        									 ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Sys_Approver_3__c,
	        									 ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Sys_Approver_4__c,
	        									 ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Sys_Approver_5__c,
	        									 ASI_MFM_Approver_1__c 
	        							   FROM ASI_MFM_Plan__c WHERE ASI_MFM_Status__c = 'Final'];
	        List<ASI_TH_CRM_Contract__c> polist = new List<ASI_TH_CRM_Contract__c>();
	        for (ASI_MFM_Plan__c plan : plans) {
	        	 if (plan.ASI_CRM_CN_TP_Contract__c != null) {
		        	ASI_TH_CRM_Contract__c con = new ASI_TH_CRM_Contract__c(Id = plans[0].ASI_CRM_CN_TP_Contract__c);
		        	con.ASI_TH_CRM_Promotion_Type__c = 'Promotion';
		        	con.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true;
		        	polist.add(con);
		        }
	        }
	       System.debug(LoggingLevel.INFO, '*** polist: ' + polist);
	        update polist;
	        System.debug(LoggingLevel.INFO, '*** plans: ' + JSON.serialize(plans));
		}
        Test.stopTest();
    }
}