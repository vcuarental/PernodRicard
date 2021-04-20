/**********************************************************************************
 * Name : ASI_TnE_ClaimsDetailUpdatePlanTest
 * Created : DC @Created Time and Date
 * Revision History:
 * 1. 01/07/2015 - [DC 1.0] Created
 **********************************************************************************/

@isTest
public class ASI_TnE_ClaimsDetailUpdatePlanTest{ 

    @testSetup
    public static void setupTestData() {
        //Create User
        User testUser = ASI_TnE_TW_TestClassHelper.newUser('standt');
        insert testUser;
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();

        Account testAccount = ASI_TnE_TW_TestClassHelper.createTestAccount('test','AccountASI_MFM_HK_Supplier');
        insert testAccount ;
        ASI_MFM_Prefix__c testPrefix = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1516');
        testPrefix.name='test';
        testPrefix.ASI_MFM_Module__c='Plan';
        insert testPrefix;

        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code')
        );
        insert acCode;
        
        ASI_MFM_AP_Code__c apCode = new ASI_MFM_AP_Code__c(
            Name='testApCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code'),
            ASI_MFM_A_C_Code__c = acCode.id
        );
        insert apCode;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            ASI_MFM_BU_Code__c = 'BU12345678',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        //Create ASI_MFM_Role_Prefix_Relationship__c 
        ASI_MFM_Role_Prefix_Relationship__c testPrefixRole = new ASI_MFM_Role_Prefix_Relationship__c( );
        testPrefixRole.ASI_MFM_Prefix__c = testPrefix.id;
        testPrefixRole.ASI_MFM_Role_Name__c = testUser.userRole.developerName;
        insert testPrefixRole;
    }

    //Test method 
    public static testMethod void testUpdateClaimDetail(){
        User testUser = [SELECT Id FROM User WHERE UserName = 'standt@laputa.com' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'test']; 
        ASI_MFM_Prefix__c testPrefix = [SELECT Id FROM ASI_MFM_Prefix__c LIMIT 1];
        ASI_MFM_AP_Code__c apCode = [SELECT Id FROM ASI_MFM_AP_Code__c WHERE Name = 'testApCode' LIMIT 1];
        ASI_MFM_BU__c buCode = [SELECT Id FROM ASI_MFM_BU__c WHERE Name = 'testBUCode' LIMIT 1];

        system.runAs(testUser) {
            //Create Plan
            ASI_MFM_Plan__c testPlan = new ASI_MFM_Plan__c ();
            testPlan.ASI_MFM_Prefix__c = testPrefix.Id;
            testPlan.ASI_MFM_Status__c = 'Final';
            testPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan');
            insert testPlan;
    
            ASI_MFM_Plan_Line_Item__c plan_line = new ASI_MFM_Plan_Line_Item__c
            (
                ASI_MFM_Plan__c = testPlan.id,
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'),
                ASI_MFM_T_E__c = true,
                ASI_MFM_Total_Cost__c = 1000,
                ASI_MFM_AP_Code__c = apCode.id,
                ASI_MFM_List_Item_Description__c = 'test',
                ASI_MFM_BU_Code__c = buCode.id
            );
            insert plan_line;
                
            //Create ASI_TnE_ClaimHeader__c
            ASI_TnE_ClaimHeader__c testClaimHeader = ASI_TnE_TW_TestClassHelper.createClaimHeader('test','ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');
            insert testClaimHeader ;    

            test.startTest();     
            //Create ASI_TnE_ClaimDetail__c 
            ASI_TnE_ClaimDetail__c testClaimDetail = ASI_TnE_TW_TestClassHelper.createClaimDetail(testClaimHeader.Id,'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',null);
                
            testClaimDetail.ASI_TnE_CAP_Plan__c = testPlan.Id;
            testClaimDetail.ASI_TnE_Receipt_Amount__c = 100;
            testClaimDetail.ASI_TnE_FX_Rate__c = 1;
            testClaimDetail.ASI_TnE_Charge_To_Acc__c = testAccount.Id;
            insert testClaimDetail;
            test.stopTest();  
                   
            update testClaimDetail;
                       
            list<ASI_TnE_ClaimDetail__c> testClaimDetailList = [select Id,ASI_TnE_CAP_Plan__c  
                                                  from ASI_TnE_ClaimDetail__c where ASI_TnE_CAP_Plan__c = :testPlan.Id];
            System.assertEquals(1,testClaimDetailList.size());
         
        }
       
    } 
        
     //Test method 
    public static testMethod void testDeleteClaimDetail(){
        User testUser = [SELECT Id FROM User WHERE UserName = 'standt@laputa.com' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'test']; 
        ASI_MFM_Prefix__c testPrefix = [SELECT Id FROM ASI_MFM_Prefix__c LIMIT 1];
        ASI_MFM_AP_Code__c apCode = [SELECT Id FROM ASI_MFM_AP_Code__c WHERE Name = 'testApCode' LIMIT 1];
        ASI_MFM_BU__c buCode = [SELECT Id FROM ASI_MFM_BU__c WHERE Name = 'testBUCode' LIMIT 1];
        
        system.runAs(testUser) {
            //Create Plan
            ASI_MFM_Plan__c testPlan = new ASI_MFM_Plan__c ();
            testPlan.ASI_MFM_Prefix__c = testPrefix.Id;
            testPlan.ASI_MFM_Status__c = 'Final';
            testPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan');
            insert testPlan;
			
			ASI_MFM_Plan_Line_Item__c plan_line = new ASI_MFM_Plan_Line_Item__c
			(
				ASI_MFM_Plan__c = testPlan.id,
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_HK_Plan_Line_Item'),
				ASI_MFM_T_E__c = true,
				ASI_MFM_Total_Cost__c = 1000,
				ASI_MFM_AP_Code__c = apCode.id,
				ASI_MFM_List_Item_Description__c = 'test',
				ASI_MFM_BU_Code__c = buCode.id
			);
			insert plan_line;
			
            //Create ASI_TnE_ClaimHeader__c
            ASI_TnE_ClaimHeader__c testClaimHeader = ASI_TnE_TW_TestClassHelper.createClaimHeader('test','ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');
            insert testClaimHeader ;    
            
            test.startTest(); 
            //Create ASI_TnE_ClaimDetail__c 
            ASI_TnE_ClaimDetail__c testClaimDetail = ASI_TnE_TW_TestClassHelper.createClaimDetail(testClaimHeader.Id,'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail',null);
            
            testClaimDetail.ASI_TnE_CAP_Plan__c = testPlan.Id;
            testClaimDetail.ASI_TnE_Receipt_Amount__c = 100;
            testClaimDetail.ASI_TnE_FX_Rate__c = 1;
            testClaimDetail.ASI_TnE_Charge_To_Acc__c = testAccount.Id;
            insert testClaimDetail;
            test.stopTest(); 
          
            delete testClaimDetail;      

            list<ASI_TnE_ClaimDetail__c> testClaimDetailList = [select Id,ASI_TnE_CAP_Plan__c  
                                                                from ASI_TnE_ClaimDetail__c where ASI_TnE_CAP_Plan__c = :testPlan.Id];
            System.assertEquals(0,testClaimDetailList .size());
        }  
        
    } 
}