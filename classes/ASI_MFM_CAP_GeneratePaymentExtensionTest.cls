@isTest
public class ASI_MFM_CAP_GeneratePaymentExtensionTest {
    private static ASI_MFM_Plan__c capexPlan {get; set;}
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

        List<ASI_MFM_Plan__c> plans = new List<ASI_MFM_Plan__c>();
        plans.add(capexPlan);
        
        prefix = ASI_MFM_CAP_TestClassHelper.createPrefixPlan();
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        //APCode
        apCapex = ASI_MFM_CAP_TestClassHelper.createCAPEXAPCode();
        //BUCode
        buCapex = ASI_MFM_CAP_TestClassHelper.createCAPEXBUCode();
        
       /* //ASI_MFM_Role_Prefix_Relationship__c
        List<ASI_MFM_Role_Prefix_Relationship__c> prs = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=prefix.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prs.add(pr2);
        insert prs;
       */ 
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
        ASI_MFM_Prefix__c px3 = new ASI_MFM_Prefix__c(name='test2', 
                                                      recordTypeId = rtPrefixCAPPlan,
                                                      ASI_MFM_Module__c='Payment', 
                                                      Plan_Type__c='test', 
                                                      ASI_MFM_Fiscal_year__c = ASI_MFM_CAP_TestClassHelper.getFiscalYear(), 
                                                      ASI_MFM_TR_Rec_Type__c=null,
                                                      ASI_MFM_Bypass_Approval__c = true,
                                                      ASI_MFM_Inactive__c = false);
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>();
        pxList.add(px1);
        pxList.add(px2);
        pxList.add(px3);
        insert pxList;
        
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px3.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        prList.add(pr1);
        prList.add(pr2);
        prList.add(pr3);
        insert prList;
		
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_CAP_Plan'), 
                                                 ASI_MFM_Prefix__c=px1.id, 
                                                 ASI_MFM_Start_Date__c=date.today(), 
                                                 ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', 
                                                 ASI_MFM_Plan_Name__c='testplanName11', 
                                                 ASI_MFM_Status__c = 'Final',
                                                 ASI_MFM_Plan_Type__c = 'CAPEX');
        
        insert p1;
        
        capexPlan = p1;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixRelationshipList = ASI_MFM_CAP_HK_POGeneration.getRolePrefixRelationship('PO', 'HK', 'ASI_MFM_CAP_Prefix');
        system.debug('rolePrefixRelationshipList:' + rolePrefixRelationshipList);
        
        ASI_MFM_CAP_HK_POGeneration.GenerateHKCAPEXPOFromPlan(new List<ASI_MFM_Plan__c> {p1});
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
        
        ASI_MFM_Plan__c plan = [SELECT Id, Name, ASI_MFM_Prefix__c 
                                FROM ASI_MFM_Plan__c
                                WHERE ASI_MFM_Plan_Name__c='testplanName11' LIMIT 1];
        
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
																ASI_MFM_Total_Cost__c,
                                                           		ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,
                                                          ASI_MFM_Plan__r.ASI_MFM_End_Date__c
														    FROM ASI_MFM_Plan_Line_Item__c
                                                         	WHERE ASI_MFM_Plan__c = :plan.Id];
        
     
        ASI_MFM_Prefix__c tempPrefix = [SELECT id, ASI_MFM_TR_Rec_Type__c FROM ASI_MFM_Prefix__c WHERE id = :plan.ASI_MFM_Prefix__c];
        tempPrefix.ASI_MFM_TR_Rec_Type__c = 'TEST';
        update tempPrefix;
        
        ASI_MFM_CAP_HK_POGeneration.GenerateHKPOFromPlanLine(capexPlanLines, 'CAPEX');
        
        plan.ASI_MFM_Status__c = 'Final';
        update plan;
    }
	static testMethod void testASI_MFM_CAP_GeneratePaymentExtension(){    
        system.debug('123');
        test.startTest();
        
        List<ASI_MFM_PO__c> pos= [select Id,ASI_MFM_PO_Type__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan__c,ASI_MFM_Supplier_Name__c,CurrencyIsoCode,ASI_MFM_Exchange_Rate__c,ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,ASI_MFM_Prefix__c , ASI_MFM_Supplier_Name__r.RecordTypeId from ASI_MFM_PO__c];
        po =pos[0];
        system.debug('POS:' + pos);
        
        Account acc = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
        po.ASI_MFM_Supplier_Name__c = acc.id;
		po.ASI_MFM_Status__c = 'Final';
        update po;
        
		ASI_MFM_CAP_GeneratePaymentExtension con = new ASI_MFM_CAP_GeneratePaymentExtension(new ApexPages.Standardcontroller(po));  
        system.debug(po.ASI_MFM_Supplier_Name__r.RecordTypeId);
        //system.debug('plan status::'+ p1.ASI_MFM_Status__c);
     	PageReference page =  con.generatePaymentFromPage();
        
      
       // po.ASI_MFM_Status__c = 'Submitted';
       // update po;
        test.stopTest();
    }
    
    static testMethod void testASI_MFM_CAP_GeneratePaymentReceipt(){
        test.startTest();
        
		List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixRelationshipListPayment = ASI_MFM_CAP_HK_PaymentGeneration.getRolePrefixRelationship('Payment', 'HK', 'ASI_MFM_CAP_Prefix');
       	String mfmPrefix=''; 
		
        for (ASI_MFM_Role_Prefix_Relationship__c rolePrefixRelationship : rolePrefixRelationshipListPayment){
	            mfmPrefix = rolePrefixRelationship.ASI_MFM_Prefix__c;	            	
	     }
        system.debug('rolePrefixRelationshipListPayment::'+ rolePrefixRelationshipListPayment);
        
		List<ASI_MFM_PO__c> pos= [select Id,ownerId,Name,ASI_MFM_Currency__c,ASI_MFM_PO_Type__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan__c,ASI_MFM_Supplier_Name__c,CurrencyIsoCode,ASI_MFM_Exchange_Rate__c,ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,ASI_MFM_Prefix__c from ASI_MFM_PO__c];
        po =pos[0];
        
		Account acc = ASI_MFM_CAP_TestClassHelper.createAccSupplier();
		
        po.ASI_MFM_Supplier_Name__c = acc.id;
		po.ASI_MFM_Status__c = 'Final';
        update po;
		
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Type__c = po.ASI_MFM_PO_Type__c,
		    															ASI_MFM_Plan__c = po.ASI_MFM_Plan__c,
		    															ASI_MFM_Supplier_Name__c = po.ASI_MFM_Supplier_Name__c,
                                                            			ASI_MFM_Invoice_Date__c = Date.today(),
                                                            			ASI_MFM_Invoice_Number__c = 'DummyPONumber',
		    															ASI_MFM_Status__c = 'Draft',
		    															ASI_MFM_CAP_PO__c = po.Id,
		    															ASI_MFM_Prefix__c = mfmPrefix,
		    															CurrencyIsoCode = po.CurrencyIsoCode,
		    															ASI_MFM_Exchange_Rate__c = po.ASI_MFM_Exchange_Rate__c,
		    															ASI_MFM_Payment_Date__c = Date.today(),
		    															ASI_MFM_Cashflow_Date__c = Date.today(),
		    															ASI_MFM_G_L_Date__c = Date.today(),
                                                            			OwnerId = u.id,
		    															recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__c'+'ASI_MFM_CAP_Payment'));
    	insert payment;
        system.debug('payment.ownerid::'+ payment.ownerId);
     //   po.ASI_MFM_Status__c = 'Submitted';
     //   update po;
        ASI_MFM_CAP_HK_POReceiptGeneration.GenerateHKPOReceiptFromPO(new List<ASI_MFM_Payment__c> {payment});
        test.stopTest();
    }
    
    static testMethod void testPlanlineItemTriggerClass_routineBeforeDelete(){
		test.startTest();
		
        list<ASI_MFM_Plan_Line_Item__c> pli = [select id,ASI_MFM_Plan__c, recordTypeId FROM ASI_MFM_Plan_Line_Item__c];
    	ASI_MFM_PlanLineItem_TriggerClass.routineBeforeDelete(pli);
		
		test.stopTest();
    }
}