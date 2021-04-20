/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_TestFactory
 * Description: Contains the test setup for PH test classes
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-25       Calvin Chiu (LAPUTA)    Created
 ****************************************************************************************************************************/
public class ASI_CRM_PH_TestFactory {
    public static ASI_MFM_Exchange_Rate__c createExchangeRate(Date effectiveDate){
        ASI_MFM_Exchange_Rate__c exRate = new ASI_MFM_Exchange_Rate__c();
        exRate.ASI_MFM_Country__c = 'SG';
        exRate.ASI_MFM_Base_Currency__c = 'SGD';
        exRate.ASI_MFM_Counter_Currency__c = 'USD';
        exRate.ASI_MFM_Application__c = 'MFM';
        exRate.ASI_MFM_Effective_Date__c = effectiveDate;
        exRate.ASI_MFM_Exchange_Rate__c = 2;
        return exRate;
    }
    
    public static ASI_HK_CRM_Running_Number__c createRunningNumber(Decimal fiscalYear){
        ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c();
        runningNumber.ASI_HK_CRM_Object_Name__c = 'ASI_CRM_PH_Contract';
        runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runningNumber.ASI_HK_CRM_Format__c = 'PRP-{OWNER}-{YY}-{0000}';
        runningNumber.ASI_HK_CRM_Fiscal_Year__c = fiscalYear;
        return runningNumber;
    }
    
    public static List<ASI_CRM_AccountsAdditionalField__c> createCustomers(String channel, Boolean isDF, Boolean isContracted, Integer numberOfRecords){
        List<ASI_CRM_AccountsAdditionalField__c> customers = new List<ASI_CRM_AccountsAdditionalField__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
            customer.Name = 'Test Customer ' + i;
            customer.ASI_CRM_MY_CustomerCode__c = 'CustomerCode' + i;
            customer.ASI_CRM_Active__c = true;
            customer.ASI_CRM_Contracted__c = isContracted;
            customer.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer');
            customer.ASI_CRM_SG_Local_Channel__c = channel;
            customer.ASI_CRM_Duty_Free__c = isDF;
            customers.add(customer);
        }
        return customers;
    }
    
    public static List<ASI_TH_CRM_Contract__c> createContracts(Id customerId, Date startDate, Date endDate, Integer numberOfRecords){
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c();
            contract.recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract');
            contract.ASI_CRM_CN_Approval_Status__c = 'Draft';
            contract.ASI_CRM_CN_Currency__c = 'PHP';
            contract.ASI_TH_CRM_Start_Date__c = startDate;
            contract.ASI_TH_CRM_End_Date__c = endDate;
            contract.ASI_CRM_SG_Net_Sales__c = 10000;
            contract.ASI_CRM_CN_Outlet_WS__c = customerId;
            contract.ASI_CRM_Marketing_Support_Fund_Amount__c = 10000;
            contract.ASI_CRM_Sales_Revenue_Target_Outlet__c = 10000;
            contractList.add(contract);
        }
        return contractList;
    }
    
    public static ASI_MFM_PO__c createPO(){
        ASI_MFM_PO__c po = new ASI_MFM_PO__c();
        return po;
    }
    
    public static ASI_CRM_ContractTarget__c createContractTarget(Id contractId, Id skuId){
        ASI_CRM_ContractTarget__c target = new ASI_CRM_ContractTarget__c();
        target.ASI_CRM_Contract__c = contractId;
        target.ASI_CRM_SKU__c = skuId;
        target.ASI_CRM_Target_Total_Sales__c = 100;
        target.ASI_CRM_Achieved_Amount__c = 100;
        target.ASI_CRM_Staff_Incentive__c = 100;
        target.ASI_CRM_Bottle_Rebate__c = 100;
        target.ASI_CRM_Till_Date_Sales_Bottle__c = 100;
        target.ASI_CRM_TargetCase__c = 10;
        target.ASI_CRM_SG_Target_Sales_Sub_B_Wine_Cat__c = 10;
        target.ASI_CRM_Target_Total_Bottle__c = 100;
        target.ASI_CRM_SG_Sales_Incentive__c = 100;   
        target.ASI_CRM_SG_Btls_Per_Case__c = 1;
        target.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = 10;
        target.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = 1;
        
        return target;
    }
    
    public static ASI_MFM_SKU_Code__c createSKU(Id subbrandId){
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c();
        sku.Name = 'Test SKU';
        sku.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_PH_DF_SKU');
        sku.ASI_MFM_Sub_brand__c = subbrandId;
        sku.ASI_HK_CRM_Inventory__c = 100;
        sku.ASI_HK_CRM_Packaging_Size__c = 10;
        return sku;
    }
    
    public static ASI_MFM_Sub_brand__c createSubBrand(){
        ASI_MFM_Sub_brand__c subbrand = new ASI_MFM_Sub_brand__c();
        subbrand.recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_MFM_PH_DF_Sub_brand');
        subbrand.name = 'Test Subbrand';
        subbrand.ASI_MFM_Sub_brand_Code__c = 'TES';
        return subbrand;
    }
    
    public static ASI_CRM_MY_SKUPriceCost__c createSKUPriceCost(Id skuId, Id customerId){
        ASI_CRM_MY_SKUPriceCost__c cost = new ASI_CRM_MY_SKUPriceCost__c();
        cost.ASI_CRM_Cost__c = 10;
        cost.ASI_CRM_Price__c = 10;
        cost.ASI_CRM_EffectiveDate__c = Date.today().addYears(-2);
        cost.ASI_CRM_SKU__c = skuId;
        cost.ASI_CRM_Customer__c = customerId;
        cost.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price');
        return cost;        
    }
    
    public static ASI_CRM_Payment_Schedule__c createPaymentSchedule(Id contractId, Id recordTypeId){
        ASI_CRM_Payment_Schedule__c schd = new ASI_CRM_Payment_Schedule__c();
        schd.ASI_CRM_Sys_Parent_Record__c = false;
        schd.ASI_CRM_Issuable__c = true;
        schd.ASI_CRM_Sponsorship__c = 100;
        schd.ASI_CRM_Payout_Amount__c = 1000;
        schd.ASI_CRM_Contract__c = contractId;
        schd.ASI_CRM_Target_Achievement_Amount__c = 10;
        schd.recordTypeId = recordTypeId;
        return schd;
    }
    
    public static ASI_FOC_Free_Goods_Request__c createFOCRequest(Id contractId, Id recordTypeId){
        ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
        foc.recordTypeId = recordTypeId;
        foc.ASI_CRM_Contract__c = contractId;
        foc.ASI_CRM_SG_Total_Amount__c = 10;
        foc.ASI_FOC_Request_Type__c = 'POSM';
        return foc;
    }
    
    public static ASI_FOC_Request_Item__c createFocItem(Id focId, Id recordTypeId){
        ASI_FOC_Request_Item__c item = new ASI_FOC_Request_Item__c();
        item.recordTypeId = recordTypeId;
        item.ASI_FOC_Request_Order__c = focId;
        return item;
    }
}