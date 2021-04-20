@isTest
public class ASI_MFM_CAP_HK_POGenerationTest {
 	private static ASI_MFM_Plan__c capexPlan,opexPlan;
    private static ASI_MFM_Plan_Line_Item__c capexPlanLine, opexPlanLine;
    private static ASI_MFM_PO__c po;
    private static ASI_MFM_PO_Line_Item__c poLineItem;
    private static ASI_MFM_Prefix__c prefix;
    private static ASI_MFM_AP_Code__c apCapex, apOpex;
    private static ASI_MFM_BU__c buCapex, buOpex;
    
    @testSetup static void testSetupMethod(){
        ASI_MFM_CAP_TestClassHelper.createRoutePlanType();
        
        capexPlan = ASI_MFM_CAP_TestClassHelper.createPlan();//capex
		capexPlan.Name = 'AP' + capexPlan.Name;
      	/*system.debug('Header ===============');
        system.debug(capexPlan.id);
        system.debug(capexPlan.ASI_MFM_Plan_Type__c);
        system.debug('===============');
		*/

        ASI_MFM_Plan_Line_Item__c lineItem = [
            select id, ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c
            from ASI_MFM_Plan_Line_Item__c
            where ASI_MFM_Plan__c = :capexPlan.id
            limit 1
        ];
/*
        system.debug('Line Items ===============');
        system.debug(lineItem.id);
        system.debug(lineItem.ASI_MFM_Plan__c);
        system.debug(lineItem.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c);
        system.debug('===============');
*/
        //ASI_MFM_Plan__c pl = [select id, ASI_MFM_Plan_Type__c from ASI_MFM_Plan__c where id =: capexPlan.id];
/*        system.debug('Double check ===============');
        system.debug(pl.id);
        system.debug(pl.ASI_MFM_Plan_Type__c);
        system.debug('===============');
*/            
        List<ASI_MFM_Plan__c> plans = new List<ASI_MFM_Plan__c>();
        plans.add(capexPlan);
        ASI_MFM_CAP_HK_POGeneration POGeneration = new ASI_MFM_CAP_HK_POGeneration();
        
        prefix = ASI_MFM_CAP_TestClassHelper.createPrefixPlan();
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        //APCode
        apCapex = ASI_MFM_CAP_TestClassHelper.createCAPEXAPCode();
        apOpex = ASI_MFM_CAP_TestClassHelper.createOPEXAPCode();
        
        //BUCode
        buCapex = ASI_MFM_CAP_TestClassHelper.createCAPEXBUCode();
        buOpex = ASI_MFM_CAP_TestClassHelper.createOPEXBUCode();
        
        //ASI_MFM_Role_Prefix_Relationship__c
        List<ASI_MFM_Role_Prefix_Relationship__c> prs = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        //ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefixOpex.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefix.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        //prs.add(pr1);
        prs.add(pr2);
        insert prs;
    }
    
     //laputa(fanny) @20181116
    static testMethod void testGenerateHKCAPEXPOFromPlan(){
        test.startTest();
        map<string, id> rtMapPrefix = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        id rtPrefixCAPPlan = rtMapPrefix.get('ASI_MFM_CAP_Prefix');
        ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test1', 
                                                      recordTypeId = rtPrefixCAPPlan,
                                                      ASI_MFM_Module__c='Plan', 
                                                      Plan_Type__c='test', 
                                                      ASI_MFM_Fiscal_year__c = ASI_MFM_CAP_TestClassHelper.getFiscalYear(), 
                                                      ASI_MFM_TR_Rec_Type__c=null,
                                                      ASI_MFM_Bypass_Approval__c = true,
                                                      ASI_MFM_Inactive__c = false);
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test2', 
                                                      recordTypeId = rtPrefixCAPPlan,
                                                      ASI_MFM_Module__c='PO', 
                                                      Plan_Type__c='test', 
                                                      ASI_MFM_Fiscal_year__c = ASI_MFM_CAP_TestClassHelper.getFiscalYear(), 
                                                      ASI_MFM_TR_Rec_Type__c=null,
                                                      ASI_MFM_Bypass_Approval__c = true,
                                                      ASI_MFM_Inactive__c = false);
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>();
        pxList.add(px1);
        pxList.add(px2);
        insert pxList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        prList.add(pr1);
        prList.add(pr2);
        insert prList;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_CAP_Plan'), 
                                                 ASI_MFM_Prefix__c=px1.id, 
                                                 ASI_MFM_Start_Date__c=date.today(), 
                                                 ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', 
                                                 ASI_MFM_Plan_Name__c='testplanName', 
                                                 ASI_MFM_Status__c = 'Final',
                                                 ASI_MFM_Plan_Type__c = 'CAPEX');
        
        insert p1;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixRelationshipList = ASI_MFM_CAP_HK_POGeneration.getRolePrefixRelationship('PO', 'HK', 'ASI_MFM_CAP_Prefix');
        system.debug('rolePrefixRelationshipList:' + rolePrefixRelationshipList);
        
        //List<ASI_MFM_Plan__c> opexPlan = [select id from ASI_MFM_Plan__c where ASI_MFM_Plan_Type__c ='OPEX' limit 1];
        ASI_MFM_CAP_HK_POGeneration.GenerateHKCAPEXPOFromPlan(new List<ASI_MFM_Plan__c> {p1});
        
         //APCode
        apCapex = ASI_MFM_CAP_TestClassHelper.createCAPEXAPCode();
        //BUCode
        buCapex = ASI_MFM_CAP_TestClassHelper.createCAPEXBUCode();
        
        ASI_MFM_Plan_Line_Item__c capexPlanLine = new ASI_MFM_Plan_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_Plan_Line_Item'),
                                                                                    ASI_MFM_List_Item_Description__c = 'test description',
                                                                                    ASI_MFM_Total_Cost__c = 1234,
                                                                                    ASI_MFM_Plan__c = p1.id,
                                                                                    ASI_MFM_AP_Code__c = apCapex.id,
                                                                                    ASI_MFM_BU_Code__c = buCapex.id,
                                                                                    ASI_MFM_Dummy_PO__c = true
                                                                                );
        capexPlanLine.ASI_MFM_AP_Code__c = ASI_MFM_CAP_TestClassHelper.createCAPEXAPCode().Id;
        capexPlanLine.ASI_MFM_BU_Code__c = ASI_MFM_CAP_TestClassHelper.createCAPEXBUCode().Id;
        insert capexPlanLine;
        
        List<ASI_MFM_Plan_Line_Item__c> capexPlanLines = [SELECT Id, Name, 
		    													ASI_MFM_AP_Code__c,
																ASI_MFM_A_C_Code__c,
																ASI_MFM_BU_Code__c,
																ASI_MFM_Currency__c,
																ASI_MFM_Dummy_PO__c,
																ASI_MFM_List_Item_Description__c,
																ASI_MFM_Plan__c,
																ASI_MFM_Plan__r.OwnerId,
																ASI_MFM_Plan__r.ASI_MFM_Exchange_Rate__c,
																ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c,
																ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,
																ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Bypass_Approval__c,
																ASI_MFM_Plan__r.CurrencyIsoCode,
																ASI_MFM_Supplier_Name__c,
																ASI_MFM_Supplier_Name__r.Fax,
																ASI_MFM_Supplier_Name__r.Phone,
																ASI_MFM_T_E__c,
																ASI_MFM_Total_Cost__c
														    FROM ASI_MFM_Plan_Line_Item__c];
        
        system.debug('capexPlanLine:' + capexPlanLines);
        ASI_MFM_Prefix__c tempPrefix = [SELECT id, ASI_MFM_TR_Rec_Type__c FROM ASI_MFM_Prefix__c WHERE id = :p1.ASI_MFM_Prefix__c];
        tempPrefix.ASI_MFM_TR_Rec_Type__c = 'TEST';
        update tempPrefix;
        system.debug('p1.ASI_MFM_Prefix__c,RecType:' + p1.ASI_MFM_Prefix__c + ':' +  p1.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c);
        system.debug('px1 Id,RecType:' + px1.Id + ':' + px1.ASI_MFM_TR_Rec_Type__c);
        
        ASI_MFM_CAP_HK_POGeneration.GenerateHKPOFromPlanLineByType(capexPlanLines);
        
        test.stopTest();
    }
    
     static testMethod void testGenerateHKOPEXPOFromPlan(){
        Test.startTest();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=ASI_MFM_CAP_TestClassHelper.getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_CAP_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final',ASI_MFM_Plan_Type__c = 'OPEX');
        insert p1;
            
        //List<ASI_MFM_Plan__c> opexPlan = [select id from ASI_MFM_Plan__c where ASI_MFM_Plan_Type__c ='OPEX' limit 1];
        ASI_MFM_CAP_HK_POGeneration.GenerateHKOPEXPOFromPlan(new List<ASI_MFM_Plan__c> {p1});
        test.stopTest();
    }
}