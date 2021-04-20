/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_CompletePOPageExtensionTest
 * Description: 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-06-24       Wilken Lee         		[WL 1.0] Test class coverage for generate accrual PO
 ****************************************************************************************************************************/
@isTest //(seealldata=true) [WL 1.0]
public class ASI_MFM_CAP_CompletePOPageExtensionTest {
    
     static testMethod void testASI_MFM_CAP_CompletePOPageExtension()
    {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',  LocaleSidKey='en_US', ProfileId = p.Id, 
							TimeZoneSidKey='America/Los_Angeles', UserName='ASI_MFM_CAP_User@testorg.com', ASI_MFM_Country__c = 'HK', UserRoleid =Role_Test.id, CompanyName = 'Pernod Ricard Hong Kong');
		
		insert u;
        
        System.runAs(u){ 
        
        System.Test.startTest();
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', plan);
        ASI_MFM_PO_Line_Item__c poLineItem = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
       

        ASI_MFM_CAP_CompletePOPageExtension con = new ASI_MFM_CAP_CompletePOPageExtension(new ApexPages.Standardcontroller(po));        
       PageReference completePO = con.CompletePO();
        }
    }
	
	/*[WL 1.0] BEGIN*/
	static testMethod void testGenerateAccrualPO(){
        
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		
		UserRole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',  LocaleSidKey='en_US', ProfileId = p.Id, 
							TimeZoneSidKey='America/Los_Angeles', UserName='ASI_MFM_CAP_User@testorg.com', ASI_MFM_Country__c = 'HK', UserRoleid =Role_Test.id, CompanyName = 'Pernod Ricard Hong Kong',
							BypassTriggers__c = 'ASI_MFM_HK_BypassTrigger');
		
		insert u;
        /*user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'HK';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;*/
        
        System.runAs(u){ 
			List<ASI_MFM_Prefix__c> prefixExisting = [SELECT ID FROM ASI_MFM_Prefix__c WHERE recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix')];
			delete prefixExisting;
			
			ASI_MFM_Prefix__c prefixAccrual = new ASI_MFM_Prefix__c (Name = '3419', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'), ASI_MFM_Module__c = 'PO', ASI_MFM_Fiscal_year__c = 'FY1819');
			insert prefixAccrual;
			
			ASI_MFM_Role_Prefix_Relationship__c rolePrefixRelation = new ASI_MFM_Role_Prefix_Relationship__c( ASI_MFM_Prefix__c = prefixAccrual.id, ASI_MFM_Role_Name__c = 'test');
			insert rolePrefixRelation;
			
			List<ASI_MFM_AP_Code__c> existingAPCode = [SELECT ID FROM ASI_MFM_AP_Code__c WHERE recordTypeID = :Global_recordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code')];
			delete existingAPCode;
			
			List<ASI_MFM_AP_Code__c> apCodeList = new List<ASI_MFM_AP_Code__c>();
			ASI_MFM_AP_Code__c apCodeCAPEX = new ASI_MFM_AP_Code__c(recordTypeId = Global_recordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code'), Name = '2216 - Receipt Not Vouchered', ASI_MFM_AP_Code__c='2216 - Receipt Not Vouchered');
			ASI_MFM_AP_Code__c apCodeOPEX = new ASI_MFM_AP_Code__c(recordTypeId = Global_recordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code'),  ASI_MFM_OPEX__c = true, Name = '2265 - Other Accrued Expenses', ASI_MFM_AP_Code__c='2265 - Other Accrued Expenses');
			apCodeList.add(apCodeCAPEX);
			apCodeList.add(apCodeOPEX);
			insert apCodeList;
			
			List<ASI_MFM_BU__c> existingBU = [SELECT ID FROM ASI_MFM_BU__c WHERE recordTypeID = :Global_recordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')];
			delete existingBU;
			
			List<ASI_MFM_BU__c> buList = new List<ASI_MFM_BU__c>();
			ASI_MFM_BU__c buCodeCAPEX = new ASI_MFM_BU__c(recordTypeId = Global_recordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'), Name = 'CAPEX BU', ASI_MFM_BU_Code__c = '331XXXXX', ASI_MFM_OPEX__c = false);
			ASI_MFM_BU__c buCodeOPEX = new ASI_MFM_BU__c(recordTypeId = Global_recordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'), Name = 'OPEX - SUSPENSE - 3319000001', ASI_MFM_BU_Code__c ='331MDMIS', ASI_MFM_OPEX__c = true);
			buList.add(buCodeCAPEX);
			buList.add(buCodeOPEX);
			insert buList;
			
			System.Test.startTest();
			ASI_MFM_CAP_TestClassHelper.createRoutePOType();
			ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
			ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', plan);
			ASI_MFM_PO_Line_Item__c poLineItem = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
		   

			ASI_MFM_CAP_CompletePOPageExtension con = new ASI_MFM_CAP_CompletePOPageExtension(new ApexPages.Standardcontroller(po));        
			PageReference completePO = con.generateAccrualPO();
        }
    }
	/*[WL 1.0] END*/
    
    static testMethod void testASI_MFM_CAP_CompletePOPageExtensionError()
    {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',  LocaleSidKey='en_US', ProfileId = p.Id, 
							TimeZoneSidKey='America/Los_Angeles', UserName='ASI_MFM_CAP_User@testorg.com', ASI_MFM_Country__c = 'HK', UserRoleid =Role_Test.id, CompanyName = 'Pernod Ricard Hong Kong');
		
		insert u;
        
        System.runAs(u){ 
        
        System.Test.startTest();
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlanFinal();
        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', plan);
                
        ASI_MFM_PO_Line_Item__c poLineItem = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        
        
        po.ASI_MFM_Status__c = 'Final';
        po.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO_Read_Only');
        update po;
        
        ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(
                                                            ASI_MFM_Payment_Type__c = 'OPEX',
                                                            ASI_MFM_Plan__c = PO.ASI_MFM_Plan__c,
                                                            ASI_MFM_CAP_PO__c = po.Id,
                                                            ASI_MFM_Currency__c = 'HKD',
                                                            ASI_MFM_Prefix__c= ASI_MFM_CAP_TestClassHelper.createPrefixPayment().id,
                                                            ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
                                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
                                                            ASI_MFM_Is_Direct_Payment__c = false,
                                                            ASI_MFM_Status__c = 'Draft',
                                                            ASI_MFM_Invoice_Date__c = date.today(),
                                                            ASI_MFM_Invoice_Number__c = '123Tesyt',
                                                            ASI_MFM_Exchange_Rate__c = 1,
                                                            ASI_MFM_Payment_Amount__c = 10
                                                            );
        insert payment;

        ASI_MFM_CAP_CompletePOPageExtension con = new ASI_MFM_CAP_CompletePOPageExtension(new ApexPages.Standardcontroller(po));        
        PageReference completePO = con.CompletePO();
        }
    }   
}