@IsTest
public class EUR_CRM_TestListingTemplateAssignHndlr {

	static User eurSysUser;
	static void setUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
		UserRole r = [select id from UserRole where Developername = 'EMEA'];
		eurSysUser = new User(Alias = 'standt', Email = 'userEmail1234aoke@test.com', userroleid = r.id,
			EmailEncodingKey = 'UTF-8', LastName = 'userEmail1234aokelastName', LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US', ProfileId = p.Id,
			TimeZoneSidKey = 'America/Los_Angeles', UserName = 'userEmail1234aoke@test.com');
		insert eurSysUser;

	}

	private static Set<String> customerTaxonomyRecordTypes = new Set<String>{
		'EUR_FI_Direct_Off_Trade'
		,   'EUR_FI_Indirect_Off_Trade'
		,   'EUR_IDL_Off_Trade_Account'
		,   'EUR_DB_Off_Trade_Account'
		,   'EUR_NL_Off_Trade'
		,   'EUR_IT_Off_Trade_Account'

		,   'EUR_BG_Modern_Off_Trade'
		,   'EUR_BG_Traditional_Off_Trade'

//        ,   'EUR_DE_Off_Trade_Retail'
		,   'EUR_DK_OFF_Trade'
//        ,   'EUR_MA_Off_Trade'
	};

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_ListingTemplateAssignmentHandler', 'customerTaxonomyRecordTypes', customerTaxonomyRecordTypes));
	}

	@IsTest
	private static void testTerritoryHandler() {
		initCMT();

		setUser();
		System.runAs(eurSysUser) {

			Id aoAccountRecordTypeId = [select id from RecordType where sobjecttype = 'eur_crm_account__C' and developername = 'EUR_AO_Off_Trade'].id;
			Id aoOnAccountRecordTypeId = [select id from RecordType where sobjecttype = 'eur_crm_account__C' and developername = 'EUR_AO_On_Trade'].id;
			Id aoOffTradeTemplateRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_JB_Template__c' and developername = 'EUR_AO_Off_Trade_Template'].id;
			Id aoOnTradeTemplateRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_JB_Template__c' and developername = 'EUR_AO_On_Trade_Template'].id;
			Id aoOffTradeTemplateCriteriaRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_JB_Template_Criteria__c' and developername = 'EUR_AO_Off_Trade_Template_Criteria'].id;
			Id aoOnTradeTemplateCriteriaRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_JB_Template_Criteria__c' and developername = 'EUR_AO_On_Trade_Template_Criteria'].id;

			Id aoGroupOutletRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_Group_Outlet_Type__c' and developername = 'EUR_AO_Group_Outlet_Type'].id;
			Id aoOutletRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_Outlet_Type__c' and developername = 'EUR_AO_Outlet_Type'].id;
			Id aoImageLevelRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_Image_Level__c' and developername = 'EUR_AO_Image_Level'].id;
			Id aoVolumePotentialRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_Volume_Potential__c' and developername = 'EUR_AO_Volume_Potential'].id;

			EUR_CRM_JB_Template__c aoOffTemplate = new EUR_CRM_JB_Template__c(name = 'test', recordtypeid = aoOffTradeTemplateRecordTypeId);
			insert aoOffTemplate;
			EUR_CRM_JB_Template_Criteria__c aoOffTemplateCriteria = new EUR_CRM_JB_Template_Criteria__c(EUR_JB_Template__c = aoOffTemplate.id, recordtypeid = aoOffTradeTemplateCriteriaRecordTypeId, EUR_CRM_Outlet_Classification__c = 'Counter service', EUR_CRM_Outlet_Classification_Type__c = 'Wine & Spirits');
			insert aoOffTemplateCriteria ;


			EUR_CRM_Group_Outlet_Type__c groupOutletType = new EUR_CRM_Group_Outlet_Type__c(recordtypeid = aoGroupOutletRecordTypeId, EUR_CRM_Name__c = 'test');
			insert groupOutletType;
			EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c(EUR_CRM_Group_Outlet_Type__c = groupOutletType.id, recordtypeid = aoOutletRecordTypeId, EUR_CRM_Name__c = 'test');
			insert outletType ;
			EUR_CRM_Image_Level__c imageLevel = new EUR_CRM_Image_Level__c (recordtypeid = aoImageLevelRecordTypeId, EUR_CRM_Name__c = 'test');
			insert imageLevel;
			EUR_CRM_Volume_Potential__c volumePotential = new EUR_CRM_Volume_Potential__c(recordtypeid = aoVolumePotentialRecordTypeId, EUR_CRM_Name__c = 'test');
			insert volumePotential;

			EUR_CRM_JB_Template__c aoOnTemplate = new EUR_CRM_JB_Template__c(name = 'test', recordtypeid = aoOnTradeTemplateRecordTypeId);
			insert aoOnTemplate ;
			EUR_CRM_JB_Template_Criteria__c aoOnTemplateCriteria = new EUR_CRM_JB_Template_Criteria__c(EUR_JB_Template__c = aoOnTemplate.id, recordtypeid = aoOnTradeTemplateCriteriaRecordTypeId,
				EUR_JB_Group_Outlet_Type__c = groupOutletType.id,
				EUR_JB_Outlet_Type__c = outletType.id,
				EUR_JB_Image_Level__c = imageLevel.id,
				EUR_JB_Volume_Potential__c = volumePotential.id);
			insert aoOnTemplateCriteria ;


			Test.startTest();
			eur_crm_account__C account = new eur_crm_account__C(name = 'test account',
				recordtypeid = aoAccountRecordTypeId,
//				EUR_CRM_Outlet_Classification__c = 'Counter service',
				EUR_CRM_Outlet_Classification_Type__c = 'Wine & Spirits',
				EUR_CRM_Postal_Code__c = '12345'
			);

//			insert account;
			eur_crm_account__C account2 = new eur_crm_account__C(name = 'test account',
				recordtypeid = aoOnAccountRecordTypeId,
				EUR_CRM_Group_Outlet_Type__c = groupOutletType.id,
				EUR_CRM_Outlet_Type__c = outletType.id,
				EUR_CRM_Image_Level__c = imageLevel.id,
//				EUR_CRM_Volume_Potential__c = volumePotential.id,
				EUR_CRM_Postal_Code__c = '12345'
			);

			insert new List<EUR_CRM_Account__c>{ account, account2 };

			account.EUR_CRM_Outlet_Classification__c = 'Counter service';
			account2.EUR_CRM_Volume_Potential__c = volumePotential.id;
			update new List<EUR_CRM_Account__c>{ account, account2 };

			account = [select EUR_CRM_Listing_Template__c from EUR_CRM_Account__c where id = :account.id];

			account2 = [select EUR_CRM_Listing_Template__c from EUR_CRM_Account__c where id = :account2.id];
			system.assert(account.EUR_CRM_Listing_Template__c == aoOffTemplate.id, '' + account.EUR_CRM_Listing_Template__c + ' ' + aoOffTemplate.id);
			system.assert(account2.EUR_CRM_Listing_Template__c == aoOnTemplate.id, '' + account2.EUR_CRM_Listing_Template__c + ' ' + aoOnTemplate.id);
			Test.stopTest();

		}
	}
}