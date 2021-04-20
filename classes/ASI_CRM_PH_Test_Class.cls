@isTest
/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_Test_Class
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-25       Wilken Lee    Created
 ****************************************************************************************************************************/
public class ASI_CRM_PH_Test_Class {
    public static testmethod void testDailyRollupBatchClass() {     
        ASI_HK_CRM_Running_Number__c runningNumber = ASI_CRM_PH_Testfactory.createRunningNumber(Date.today().year() -1);        
        insert runningNumber;
        
        ASI_CRM_AccountsAdditionalField__c outlet = new ASI_CRM_AccountsAdditionalField__c(
                                                                                        Name = 'Test Outlet',
                                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer'),
                                                                                        ASI_CRM_Active__c = true
                                                                                    );
        insert outlet;      
            
        Date todaysDate = Date.today();
        Integer startYear;
        if (todaysDate.Month() >= 7)
            startYear = todaysDate.Year();
        else 
            startYear = todaysDate.Year()-1;
        
        Date startDate = Date.newInstance(startYear, 7, 1);
        Date endDate = Date.newInstance(startYear+1, 6, 30);
        
        system.debug('startDate: ' + startDate + ' endDate: ' + endDate);
        
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract'),
                                                                ASI_CRM_CN_Outlet_WS__c = outlet.Id,
                                                                ASI_CRM_CN_Approval_Status__c = 'Approved',
                                                                ASI_TH_CRM_Start_Date__c = startDate,
                                                                ASI_TH_CRM_End_Date__c = endDate                                                                
                                                                );
        
        insert contract;
        
        System.Test.startTest();
            Database.executeBatch(new ASI_CRM_PH_DailyRollUp_Batch());
        System.Test.stopTest();
    }    
    
    public static testmethod void testASI_CRM_PH_ContractSummaryCtrlClass() {       
        ASI_HK_CRM_Running_Number__c runningNumber = ASI_CRM_PH_Testfactory.createRunningNumber(Date.today().year() -1);        
        insert runningNumber;
        
        ASI_CRM_AccountsAdditionalField__c outlet = new ASI_CRM_AccountsAdditionalField__c(
                                                                                        Name = 'Test Outlet',
                                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer'),
                                                                                        ASI_CRM_Active__c = true
                                                                                    );
        insert outlet;      
            
        Date todaysDate = Date.today();
        Integer startYear;
        if (todaysDate.Month() >= 7)
            startYear = todaysDate.Year();
        else 
            startYear = todaysDate.Year()-1;
        
        Date startDate = Date.newInstance(startYear, 7, 1);
        Date endDate = Date.newInstance(startYear+1, 6, 30);
        
        system.debug('startDate: ' + startDate + ' endDate: ' + endDate);
        
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract'),
                                                                ASI_CRM_CN_Outlet_WS__c = outlet.Id,
                                                                ASI_CRM_CN_Approval_Status__c = 'Approved',
                                                                ASI_TH_CRM_Start_Date__c = startDate,
                                                                ASI_TH_CRM_End_Date__c = endDate,
                                                                ASI_CRM_Marketing_Support_Fund_Amount__c = 0, ASI_CRM_Activation_Fund_Amount__c = 0, ASI_CRM_Merchandise_Amount__c = 0, ASI_CRM_Contract_Fund_Amount__c = 0, 
                                                                ASI_CRM_Purchase_Incentive_Amount__c = 0, ASI_CRM_Bottle_Rebate_Amount__c = 0, ASI_CRM_Staff_Incentive_Amount__c = 0
                                                                );
        
        insert contract;
        
        final Id skuRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
                ASI_MFM_SKU_Code__c.sObjectType,
                ASI_CRM_RecordTypeApiName.SkuCode.ASI_CRM_PH_DP_SKU.name()
        );
        
        final List<ASI_MFM_SKU_Code__c> skus = new List<ASI_MFM_SKU_Code__c>();
        skus.add(new ASI_MFM_SKU_Code__c(
                Name = 'test sku1',
                RecordTypeId = skuRecordTypeId
        ));
        insert skus;

        final Id skuPriceCostRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
                ASI_CRM_MY_SKUPriceCost__c.sObjectType,
                ASI_CRM_RecordTypeApiName.ASI_CRM_MY_SKUPriceCost.ASI_CRM_PH_Outlet_Selling_Price.name()
        );

        final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = new List<ASI_CRM_MY_SKUPriceCost__c>();
        skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
                ASI_CRM_SKU__c = skus.get(0).Id,
                ASI_CRM_Cost__c = 90,
                ASI_CRM_Price__c = 100,
                ASI_CRM_EffectiveDate__c = Date.today().toStartOfMonth(),
                RecordTypeId = skuPriceCostRecordTypeId
        ));
        insert skuPriceCosts;

        ASI_CRM_ContractTarget__c target = new ASI_CRM_ContractTarget__c(ASI_CRM_Contract__c = contract.Id,
                                                                ASI_CRM_SKU__c = skus.get(0).Id,
																ASI_CRM_Bottle_Rebate__c = 1,
																ASI_CRM_Staff_Incentive__c = 1,
																recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target'),
                                                                ASI_CRM_Target_Total_Bottle__c = 10);
        insert target;
        
        List<ASI_CRM_Payment_Schedule__c> fundSchemeList = new List<ASI_CRM_Payment_Schedule__c>();
        ASI_CRM_Payment_Schedule__c cFundScheme = new ASI_CRM_Payment_Schedule__c(
                                                        ASI_CRM_Contract__c = contract.Id, 
                                                        recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Contract_Fund'),
                                                        ASI_CRM_Type__c = 'Bottle',
                                                        ASI_CRM_Issuable__c = true,
                                                        ASI_CRM_Sponsorship__c = 100
                                                        );
        fundSchemeList.add(cFundScheme);
        ASI_CRM_Payment_Schedule__c pFundScheme = new ASI_CRM_Payment_Schedule__c(
                                                        ASI_CRM_Contract__c = contract.Id, 
                                                        recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Purchase_Incentive'),
                                                        ASI_CRM_Issuable__c = true,
                                                        ASI_CRM_Sponsorship__c = 100,
                                                        ASI_CRM_Sys_Parent_Record__c = true
                                                        );                                          
        fundSchemeList.add(pFundScheme);
        insert fundSchemeList;
        
        
        List<ASI_TH_CRM_PaymentRequest__c> paymentList = new List<ASI_TH_CRM_PaymentRequest__c>();
        ASI_TH_CRM_PaymentRequest__c pay1 = new ASI_TH_CRM_PaymentRequest__c(
                                                                    ASI_TH_CRM_Contract__c = contract.Id, 
                                                                    ASI_CRM_Payment_Type__c = 'Contract Fund',
                                                                    ASI_CRM_Payment_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
                                                                    );
        paymentList.add(pay1);
        ASI_TH_CRM_PaymentRequest__c pay2 = new ASI_TH_CRM_PaymentRequest__c(
                                                                    ASI_TH_CRM_Contract__c = contract.Id, 
                                                                    ASI_CRM_Payment_Type__c = 'Activation Fund',
                                                                    ASI_CRM_Payment_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
                                                                    );
        paymentList.add(pay2);
        ASI_TH_CRM_PaymentRequest__c pay3 = new ASI_TH_CRM_PaymentRequest__c(
                                                                    ASI_TH_CRM_Contract__c = contract.Id, 
                                                                    ASI_CRM_Payment_Type__c = 'Merchandise',
                                                                    ASI_CRM_Payment_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
                                                                    );
        paymentList.add(pay3);      
        ASI_TH_CRM_PaymentRequest__c pay4 = new ASI_TH_CRM_PaymentRequest__c(
                                                                    ASI_TH_CRM_Contract__c = contract.Id, 
                                                                    ASI_CRM_Payment_Type__c = 'Purchase Incentive',
                                                                    ASI_CRM_Payment_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
                                                                    );
        paymentList.add(pay4);
        ASI_TH_CRM_PaymentRequest__c pay5 = new ASI_TH_CRM_PaymentRequest__c(
                                                                    ASI_TH_CRM_Contract__c = contract.Id, 
                                                                    ASI_CRM_Payment_Type__c = 'Bottle Rebate',
                                                                    ASI_CRM_Payment_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
                                                                    );
        paymentList.add(pay5);
        ASI_TH_CRM_PaymentRequest__c pay6 = new ASI_TH_CRM_PaymentRequest__c(
                                                                    ASI_TH_CRM_Contract__c = contract.Id, 
                                                                    ASI_CRM_Payment_Type__c = 'Staff Incentive',
                                                                    ASI_CRM_Payment_Amount__c = 100,
																	recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
                                                                    );
        paymentList.add(pay6);      
        insert paymentList;
        
        List<ASI_CRM_SG_AdhocOther__c> monthlyList = new List<ASI_CRM_SG_AdhocOther__c>();
        
        ASI_CRM_SG_AdhocOther__c mTarget1 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 1, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget2 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 2, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget3 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 3, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget4 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 4, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget5 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 5, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget6 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 6, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget7 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 7, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget8 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 8, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget9 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 9, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget10 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 10, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget11 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 11, ASI_CRM_Monthly_Target_Bottle__c = 10);
        ASI_CRM_SG_AdhocOther__c mTarget12 = new ASI_CRM_SG_AdhocOther__c(ASI_CRM_SG_Contract_Target__c = target.Id, ASI_CRM_Month__c = 12, ASI_CRM_Monthly_Target_Bottle__c = 10);
        
        monthlyList.add(mTarget1);
        monthlyList.add(mTarget2);
        monthlyList.add(mTarget3);
        monthlyList.add(mTarget4);
        monthlyList.add(mTarget5);
        monthlyList.add(mTarget6);
        monthlyList.add(mTarget7);
        monthlyList.add(mTarget8);
        monthlyList.add(mTarget9);
        monthlyList.add(mTarget10);
        monthlyList.add(mTarget11);
        monthlyList.add(mTarget12);
        insert monthlyList;     
        
        System.Test.startTest();

            ApexPages.currentPage().getParameters().put('Id', contract.Id);

            ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
            ASI_CRM_PH_ContractSummaryCtrl controller = new ASI_CRM_PH_ContractSummaryCtrl(standardController);
            
            controller.init();
            controller.getContractTarget();
            controller.calculcateSupportScheme();
            controller.calculcateSupportAmount();

			
        System.Test.stopTest();
    }    
    
    public static testmethod void testActualOfftakeTriggerClass(){
        ASI_CRM_AccountsAdditionalField__c outlet = new ASI_CRM_AccountsAdditionalField__c(
                                                                                        Name = 'Test Outlet',
                                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer'),
                                                                                        ASI_CRM_Active__c = true
                                                                                    );
        insert outlet;      
        
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c(
                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_PH_DP_SKU'),
                                                        Name = 'Test DP SKU',
                                                        ASI_MFM_SKU_Code__c = 'ABC123',
                                                        ASI_MFM_SKU_Description__c = 'Test DP SKU'
                                                        );
        insert sku;
                                                        
        ASI_CRM_MY_SKUPriceCost__c price1 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price'),
                                                                            ASI_CRM_Customer__c = outlet.Id,
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);
                                                                            
        ASI_CRM_MY_SKUPriceCost__c price2 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);                 

        ASI_CRM_MY_SKUPriceCost__c cost1 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);     
                                                                            
        ASI_CRM_MY_SKUPriceCost__c cost2 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);     
                                                                            
        ASI_CRM_MY_SKUPriceCost__c cost3 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);     

        ASI_CRM_MY_SKUPriceCost__c cost4 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);     

        ASI_CRM_MY_SKUPriceCost__c cost5= new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_DP_Distribution_Cost'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today(),
                                                                            ASI_CRM_Price__c = 10);     


        
        ASI_CRM_MY_SKUPriceCost__c price3 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price'),
                                                                            ASI_CRM_Customer__c = outlet.Id,
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);
                                                                            
        ASI_CRM_MY_SKUPriceCost__c price4 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);                 

        ASI_CRM_MY_SKUPriceCost__c cost6 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);     
                                                                            
        ASI_CRM_MY_SKUPriceCost__c cost7 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);     
                                                                            
        ASI_CRM_MY_SKUPriceCost__c cost8 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);     

        ASI_CRM_MY_SKUPriceCost__c cost9 = new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);     

        ASI_CRM_MY_SKUPriceCost__c cost10= new ASI_CRM_MY_SKUPriceCost__c(recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_DP_Distribution_Cost'),
                                                                            ASI_CRM_SKU__c = sku.Id,
                                                                            ASI_CRM_EffectiveDate__c = Date.Today().adddays(-5),
                                                                            ASI_CRM_Price__c = 10);     
        
        
        List<ASI_CRM_MY_SKUPriceCost__c> priceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
        priceCostList.add(price1);
        priceCostList.add(price2);
        priceCostList.add(cost1);
        priceCostList.add(cost2);
        priceCostList.add(cost3);
        priceCostList.add(cost4);
        priceCostList.add(cost5);
        
        priceCostList.add(price3);
        priceCostList.add(price4);
        priceCostList.add(cost6);
        priceCostList.add(cost7);
        priceCostList.add(cost8);
        priceCostList.add(cost9);
        priceCostList.add(cost10);
        insert priceCostList;
        
        ASI_TH_CRM_Actual_Offtake__c offtake = new ASI_TH_CRM_Actual_Offtake__c(
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_PH_Actual_Offtake'),
                                                                ASI_CRM_SKU__c = sku.Id,
                                                                ASI_TH_CRM_Offtake_G_L_Date__c = Date.Today()
                                                                );
                                                                
                                                                
        insert offtake;
        
        test.startTest();
		offtake.ASI_TH_CRM_Offtake_G_L_Date__c = Date.Today() +1;
        update offtake;
        test.stopTest();
    }
}