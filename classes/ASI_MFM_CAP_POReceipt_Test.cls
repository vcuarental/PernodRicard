/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_POReceipt_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-21       Wilken Lee           	[WL 1.0] Created
 ****************************************************************************************************************************/
@isTest
public class ASI_MFM_CAP_POReceipt_Test {
	/*[WL 1.0] BEGIN*/
	static testMethod void testASI_MFM_CAP_POReceipt_TriggerClass(){
        ASI_MFM_Plan__c capexPlan = ASI_MFM_CAP_TestClassHelper.createPlan();//capex
		
		capexPlan.ASI_MFM_Status__c = 'Final';
		update capexPlan;
		
		ASI_MFM_PO__c capexPO = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', capexPlan);
		
		ASI_MFM_PO_Line_Item__c capexPOLine = ASI_MFM_CAP_TestClassHelper.createPoLines(capexPO);
		
		capexPO.ASI_MFM_Status__c = 'Final';
		update capexPO;		

		List<ASI_MFM_Prefix__c> prefixList = createPrefix();

        ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(ASI_MFM_Payment_Type__c = capexPO.ASI_MFM_PO_Type__c,
		    															ASI_MFM_Plan__c = capexPO.ASI_MFM_Plan__c,
		    															ASI_MFM_Supplier_Name__c = capexPO.ASI_MFM_Supplier_Name__c,
                                                            			ASI_MFM_Invoice_Date__c = Date.today(),
                                                            			ASI_MFM_Invoice_Number__c = 'DummyPONumber',
		    															ASI_MFM_Status__c = 'Draft',
		    															ASI_MFM_CAP_PO__c = capexPO.Id,
		    															ASI_MFM_Prefix__c = prefixList.get(2).Id,
		    															CurrencyIsoCode = capexPO.CurrencyIsoCode,
		    															ASI_MFM_Exchange_Rate__c = capexPO.ASI_MFM_Exchange_Rate__c,
		    															ASI_MFM_G_L_Date__c = Date.today(),
		    															recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__c'+'ASI_MFM_CAP_Payment'));
    	insert payment;
		
		test.startTest();
			
		ASI_MFM_PO_Receipt__c poReceipt = new ASI_MFM_PO_Receipt__c(
																	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CAP_PO_Receipt'),
																	ASI_MFM_Payment__c = payment.Id,
																	ASI_MFM_Status__c = 'Submitted');
		insert poReceipt;
				
		ASI_MFM_PO_Receipt_Item__c poReceiptItem = new ASI_MFM_PO_Receipt_Item__c(
																				recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_CAP_PO_Receipt_Item'),
																				ASI_MFM_PO_Receipt__c = poReceipt.Id,
																				ASI_MFM_PO_Line_Item__c = capexPOLine.Id,
																				ASI_MFM_Amount__c = 10
																				);
		insert poReceiptItem;
		
		poReceipt.ASI_MFM_Status__c = 'Final';
		update poReceipt;		
		
		//Test Gulf Record Type Trigger
		ASI_MFM_PO_Receipt__c poReceiptGulf = new ASI_MFM_PO_Receipt__c(
																	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'),
																	ASI_MFM_Status__c = 'Draft');
		insert poReceiptGulf;
		update poReceiptGulf;
		
		ASI_MFM_PO_Receipt__c poReceiptTR = new ASI_MFM_PO_Receipt__c(
																	recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_TR_PO_Receipt'),
																	ASI_MFM_Status__c = 'Draft');
		insert poReceiptTR;		
		update poReceiptTR;
		
		test.stopTest();
    }
	/*[WL 1.0] END*/
	
	private static List<ASI_MFM_Prefix__c> createPrefix(){
		ASI_MFM_Prefix__c px1 = new ASI_MFM_Prefix__c(name='test1', 
                                                      recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
                                                      ASI_MFM_Module__c='Plan', 
                                                      Plan_Type__c='test', 
                                                      ASI_MFM_Fiscal_year__c = getFiscalYear(), 
                                                      ASI_MFM_TR_Rec_Type__c=null,
                                                      ASI_MFM_Bypass_Approval__c = true,
                                                      ASI_MFM_Inactive__c = false);
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test2', 
                                                      recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
                                                      ASI_MFM_Module__c='PO', 
                                                      Plan_Type__c='test', 
                                                      ASI_MFM_Fiscal_year__c = getFiscalYear(), 
                                                      ASI_MFM_TR_Rec_Type__c=null,
                                                      ASI_MFM_Bypass_Approval__c = true,
                                                      ASI_MFM_Inactive__c = false);
        ASI_MFM_Prefix__c px3 = new ASI_MFM_Prefix__c(name='test2', 
                                                      recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_Prefix'),
                                                      ASI_MFM_Module__c='Payment', 
                                                      Plan_Type__c='test', 
                                                      ASI_MFM_Fiscal_year__c = getFiscalYear(), 
                                                      ASI_MFM_TR_Rec_Type__c=null,
                                                      ASI_MFM_Bypass_Approval__c = true,
                                                      ASI_MFM_Inactive__c = false);
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>();
        pxList.add(px1);
        pxList.add(px2);
        pxList.add(px3);
        insert pxList;
		
		user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
		
        ASI_MFM_Role_Prefix_Relationship__c pr1 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px1.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px3.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
		
		List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
		prList.add(pr1);
		prList.add(pr2);
		prList.add(pr3);
        insert prList;
		
		return pxList;
	}
	
	public static string getFiscalYear(){
        Integer orgFiscalMonth = 7;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
}