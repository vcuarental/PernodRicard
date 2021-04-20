/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_ContractSubmitApproval_Ctrl
 * Description: For PH Contract Target validation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-03       LAPUTA: Calvin Chiu     Created
 * 2018-09-04       LAPUTA: Vincent Lam     Updated
 * 2018-09-06       LAPUTA: Calvin Chiu     Fixed price cost logic when assigning values in ConvertedSupportAmount wrapper
 *                                          Fixed logic to support multiple budget for the same subbrand + AC
 * 2018-09-09       LAPUTA: Vincent Lam     Fixed AC_CODE_MAPPING
 * 2018-10-18       LAPUTA: Calvin Chiu     Updated logic to get budget by type
 * 2018-12-13       LAPUTA: Calvin Chiu     Update logic to handle Payment Request and FOC Request under overlapped Completed contracts
 ****************************************************************************************************************************/
public class ASI_CRM_PH_ContractSubmitApproval_Ctrl {
    private class CustomException extends Exception{}
    
    private String recordId{get;set;}
    private ASI_TH_CRM_Contract__c contract {get;set;}
    
    private final Map<Integer, String> MONTH_MAPPING = new Map<Integer, String>{
        1=>'January', 2=>'Februrary', 3=>'March', 4=>'April', 5=>'May', 6=>'June',
        7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};
            
    private final Map<Integer, Integer> FISCAL_MONTH_INDEX_MAPPING = new Map<Integer, Integer>{
        1=>7, 2=>8, 3=>9, 4=>10, 5=>11, 6=>12, 7=>1, 8=>2, 9=>3, 10=>4, 11=>5,12=>6};   

    private final string AC_CODE_5724_DF = '5724';
    private final string AC_CODE_5724_DP = '5724.000000';
    private final string AC_CODE_5559_DF = '5559';
    private final string AC_CODE_5559_DP = '5559.000000';
    private final string AC_CODE_5275_DF = '5275';
    private final string AC_CODE_5275_DP = '5275.000000';
    private final string AC_CODE_5553_DF = '5553';
    private final string AC_CODE_5553_DP = '5553.000000';
    private final string AC_CODE_5235_DF = '5235.TARGET';
    private final string AC_CODE_5235_DP = '5235.010000';
    
    private final Map<String, Integer> budgetTypeOrder = new Map<String, Integer>{'LE3' => 1, 'LE2' => 2, 'LE1' => 3, 'Budget' => 4};
        
    private final Map<string, Map<String, String>> AC_CODE_MAPPING = new Map<string, Map<String, String>>{
        'Duty Free' => new Map<String, String>{
                AC_CODE_5724_DF => 'Merchandise',
                AC_CODE_5559_DF => 'Activation/Contract Fund',
                AC_CODE_5275_DF => 'Purchase Incentive',
                AC_CODE_5553_DF => 'Staff Incentive',
                AC_CODE_5235_DF => 'Target Incentive'            
        },
        'Duty Paid' => new Map<String, String>{
                AC_CODE_5724_DP => 'Merchandise',
                AC_CODE_5559_DP => 'Activation/Contract Fund',
                AC_CODE_5275_DP => 'Purchase Incentive',
                AC_CODE_5553_DP => 'Staff Incentive',
                AC_CODE_5235_DP => 'Bottle Rebate'
        }
    };
        
    private Map<Id, String> subbrandNameMap{get;set;} // subbrand id: subbrand name
    private List<Integer> monthList {get;set;}
        
    public ASI_CRM_PH_ContractSubmitApproval_Ctrl (ApexPages.StandardController controller) {        
        recordId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).Id; 
        contract = [select id, ownerId, ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_Contract_Fund_Amount__c, ASI_CRM_Marketing_Support_Fund_Amount__c, 
                                           ASI_CRM_Activation_Fund_Amount__c, ASI_CRM_Merchandise_Amount__c, ASI_CRM_Purchase_Incentive_Amount__c, ASI_CRM_Contract_Duty_Type__c, ASI_CRM_CN_Approval_Status__c
                                            from ASI_TH_CRM_Contract__c where id=: recordId];
        monthList = buildMonthSequence(contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c);
        subbrandNameMap = new Map<Id, String>();
    }
    
    public PageReference redirect(){      
        validate();
        return new PageReference('/'+recordId+'?retURL=%2F'+ recordId +'&nooverride=1');
    }
        
    private void validate(){        
        Integer numOfMonths = getNumOfMonths(contract.ASI_TH_CRM_End_Date__c, contract.ASI_TH_CRM_Start_Date__c);        
        system.debug('num of months: ' + numOfMonths);
        
        String FYString = getBudgetFYString(contract.ASI_TH_CRM_Start_Date__c);
        system.debug('Start Date Fiscal Year: ' + FYString);
        
        ASI_CRM_AccountsAdditionalField__c customer = [select ASI_CRM_Duty_Free__c from ASI_CRM_AccountsAdditionalField__c where Id =: contract.ASI_CRM_CN_Outlet_WS__c];
        String currencyCode = customer.ASI_CRM_Duty_Free__c ? 'USD':'PHP';
        
        // 1: Get converted amount for contract target
        Map<Id, ConvertedSupportAmount> convertedSupportMap = new Map<Id, ConvertedSupportAmount>(); // subbrand Id: ConvertedSupportAmount wrapper
        
        Map<Id, Set<ASI_CRM_ContractTarget__c>> contractTargetSKUMap = new Map<Id, Set<ASI_CRM_ContractTarget__c>>(); // sku id: ASI_CRM_ContractTarget__c
        Map<Id, Id> skuSubBrandMap = new Map<Id, Id>(); // sku id: subbrand id
        Set<Id> currentSubbrandSet = new Set<Id>();        
                
        for(ASI_CRM_ContractTarget__c target: [select ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SKU__c, ASI_CRM_Target_Total_Bottle__c, ASI_CRM_Contract__c,
                                                        ASI_CRM_Total_Bottle_Rebate__c, ASI_CRM_Total_Staff_Incentive__c, ASI_CRM_Target_Incentive__c
                                                                from ASI_CRM_ContractTarget__c 
                                                                    where ASI_CRM_Contract__c =: recordId]){
            contractTargetSKUMap.put(target.ASI_CRM_SKU__c, new Set<ASI_CRM_ContractTarget__c>{target});      
            skuSubBrandMap.put(target.ASI_CRM_SKU__c, target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c); 
            currentSubbrandSet.add(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);
            subbrandNameMap.put(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name);                        
            // 2. get subbrand subtotal bottle rebate and staff incentive
            if(!convertedSupportMap.containsKey(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c)){
                ConvertedSupportAmount support = new ConvertedSupportAmount();
                support.subbrand = target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                support.bottleRebate = customer.ASI_CRM_Duty_Free__c ? target.ASI_CRM_Target_Incentive__c : target.ASI_CRM_Total_Bottle_Rebate__c;
                support.staffIncentive = target.ASI_CRM_Total_Staff_Incentive__c;
                convertedSupportMap.put(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, support);
            }
            else{
                ConvertedSupportAmount support = convertedSupportMap.get(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);
                support.bottleRebate += customer.ASI_CRM_Duty_Free__c ? target.ASI_CRM_Target_Incentive__c : target.ASI_CRM_Total_Bottle_Rebate__c;
                support.staffIncentive += target.ASI_CRM_Total_Staff_Incentive__c;
                convertedSupportMap.put(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, support);                                                           
            }
        }
        
        // 5. Get all Submitted / Approved contract that has overlapping period with (3), and calculate the monthly support amount
        // merge to current contract target        
        
        for(ASI_CRM_ContractTarget__c target:[select ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SKU__c, ASI_CRM_Contract__c, ASI_CRM_Total_Bottle_Rebate__c, ASI_CRM_Total_Staff_Incentive__c 
                                                from ASI_CRM_ContractTarget__c 
                                                    where ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c >= :contract.ASI_TH_CRM_Start_Date__c and ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c <= :contract.ASI_TH_CRM_End_Date__c 
                                                    and ASI_CRM_Contract__r.OwnerId =: contract.ownerId and ASI_CRM_Contract__r.ASI_CRM_CN_Approval_Status__c in ('Submitted','Approved') 
                                                    and recordType.DeveloperName = 'ASI_CRM_PH_Contract_Target' and ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c In :currentSubbrandSet]){
            
            if(contractTargetSKUMap.containsKey(target.ASI_CRM_SKU__c)){
                contractTargetSKUMap.get(target.ASI_CRM_SKU__c).add(target);
            }
            else{
                contractTargetSKUMap.put(target.ASI_CRM_SKU__c, new Set<ASI_CRM_ContractTarget__c>{target});      
            }
            skuSubBrandMap.put(target.ASI_CRM_SKU__c, target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);            
                                                        
            if(convertedSupportMap.containsKey(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c)){
                ConvertedSupportAmount support = convertedSupportMap.get(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);
                support.bottleRebate += target.ASI_CRM_Total_Bottle_Rebate__c; 
                support.staffIncentive += target.ASI_CRM_Total_Staff_Incentive__c;
                convertedSupportMap.put(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, support);
            }
            else{
                ConvertedSupportAmount support = new ConvertedSupportAmount();
                support.subbrand = target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                support.bottleRebate = target.ASI_CRM_Total_Bottle_Rebate__c;
                support.staffIncentive = target.ASI_CRM_Total_Staff_Incentive__c;
                convertedSupportMap.put(target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, support);
            }
        }
        
        system.debug('contractTargetSKUMap: ' + contractTargetSKUMap);
        if(contractTargetSKUMap.isEmpty()){
            throw new CustomException('Contract Target missing.');
        }
                
        // calculate cost by total number of bottle in contract target * unit price from price cost        
        Map<Id, Decimal> convertedSKUPrice = new Map<Id, Decimal>();  // sku id: unit price * number of bottle
        for(ASI_CRM_MY_SKUPriceCost__c cost: [select ASI_CRM_Price__c, ASI_CRM_SKU__c
                                              from ASI_CRM_MY_SKUPriceCost__c 
                                                where /*ASI_CRM_Customer__c =: contract.ASI_CRM_CN_Outlet_WS__c and*/ ASI_CRM_SKU__c in: contractTargetSKUMap.keySet() 
                                                    and recordType.DeveloperName = 'ASI_CRM_PH_List_Price' and ASI_CRM_EffectiveDate__c <=:contract.ASI_TH_CRM_Start_Date__c Order by ASI_CRM_EffectiveDate__c DESC]){
             // only get the latest SKU Price
             system.debug('cost: ' + cost);
             if(!convertedSKUPrice.containsKey(cost.ASI_CRM_SKU__c)){
                 Decimal bottle = 0;
                 for(ASI_CRM_ContractTarget__c target: contractTargetSKUMap.get(cost.ASI_CRM_SKU__c)){
                    bottle += target.ASI_CRM_Target_Total_Bottle__c;
                 }
                 Decimal price = bottle * cost.ASI_CRM_Price__c;
                convertedSKUPrice.put(cost.ASI_CRM_SKU__c, price);                                                 
             }                            
        }
        system.debug('convertedSKUPrice: ' + convertedSKUPrice);
        
        // get payment request items
        Map<Id, ConvertedSupportAmount> additionalSupportAmount = new Map<Id, ConvertedSupportAmount>();
        for(ASI_TH_CRM_PaymentRequestLineItem__c item: [select ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c, ASI_TH_CRM_Amount__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name
                                                from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_TH_CRM_Start_Date__c >= :contract.ASI_TH_CRM_Start_Date__c and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_TH_CRM_End_Date__c <= :contract.ASI_TH_CRM_End_Date__c and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Approval_Status__c = 'Completed']){
            if(skuSubBrandMap.get(item.ASI_CRM_SKU__c) == null){
                skuSubBrandMap.put(item.ASI_CRM_SKU__c, item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);
            }
            if(subbrandNameMap.get(item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c) == null){
                subbrandNameMap.put(item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name);
            }
            
            ConvertedSupportAmount support = additionalSupportAmount.get(item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c);
            if(support == null){
                support = new ConvertedSupportAmount();
                support.subbrand = item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
            }
            switch on item.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c{
                when 'Contract Fund'{
                    support.contractFund += item.ASI_TH_CRM_Amount__c;
                }
                when 'Activation Fund'{
                    support.activationFund += item.ASI_TH_CRM_Amount__c;
                }
                when 'Merchandise'{
                    support.merchandise += item.ASI_TH_CRM_Amount__c;
                }
                when 'Purchase Incentive'{
                    support.purchaseIncentive += item.ASI_TH_CRM_Amount__c;
                }
                when 'Bottle Rebate'{
                    support.bottleRebate += item.ASI_TH_CRM_Amount__c;
                }
                when 'Staff Incentive'{
                    support.staffIncentive += item.ASI_TH_CRM_Amount__c;
                }
            }
            additionalSupportAmount.put(item.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, support);
        }
        
        // get foc request items
        // for marketing support fund
        for(ASI_FOC_Request_Item__c item: [select ASI_CRM_SG_Amount__c, ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c >= :contract.ASI_TH_CRM_Start_Date__c and ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c <= :contract.ASI_TH_CRM_End_Date__c and ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.ASI_CRM_CN_Approval_Status__c = 'Completed']){
            if(skuSubBrandMap.get(item.ASI_FOC_SKU__c) == null){
                skuSubBrandMap.put(item.ASI_FOC_SKU__c, item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c);
            }
            
            if(subbrandNameMap.get(item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c) == null){
                subbrandNameMap.put(item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c, item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name);
            }
            
            ConvertedSupportAmount support = additionalSupportAmount.get(item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c);
            if(support == null){
                support = new ConvertedSupportAmount();
                support.subbrand = item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c;
            }
            support.marketingSupport += item.ASI_CRM_SG_Amount__c;
            additionalSupportAmount.put(item.ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c, support);
        }
        
        system.debug('skuSubBrandMap: ' + skuSubBrandMap);
        // Subbrand subtotal
        Map<Id, Decimal> subbrandTotal = new Map<Id, Decimal>();  // subbrand ID: subbrand total amount
        Decimal contractTotal = 0;
        for(Id sku: skuSubBrandMap.keySet()){
            if(convertedSKUPrice.containsKey(sku)){
                Decimal price = convertedSKUPrice.get(sku);
                if(subbrandTotal.containsKey(skuSubBrandMap.get(sku))){
                    Decimal subtotal = subbrandTotal.get(skuSubBrandMap.get(sku));       
                    subtotal += price;
                    subbrandTotal.put(skuSubBrandMap.get(sku), subtotal);
                }
                else{
                    subbrandTotal.put(skuSubBrandMap.get(sku), price);
                }                
                contractTotal += price;
            }
        }
        system.debug('subbrandTotal: ' + subbrandTotal);
        
        // 2. Split the support amount into sub-brand based on Converted Amount proportion
        // 3. Evenly distribute the Contract Fund amount by month
        
        for(ConvertedSupportAmount support: convertedSupportMap.values()){
            if(convertedSupportMap.containsKey(support.subbrand)){
                if(subbrandTotal.containsKey(support.subbrand)){
                    Decimal proportion = subbrandTotal.get(support.subbrand) / contractTotal;

                    support.contractFund = (contract.ASI_CRM_Contract_Fund_Amount__c * proportion);
                    support.activationFund = (contract.ASI_CRM_Activation_Fund_Amount__c * proportion);
                    support.merchandise = (contract.ASI_CRM_Merchandise_Amount__c * proportion);
                    support.purchaseIncentive = (contract.ASI_CRM_Purchase_Incentive_Amount__c * proportion);     
                    support.marketingSupport = (contract.ASI_CRM_Purchase_Incentive_Amount__c * proportion);                  
                }                
            }
            else{ // set all funds to 0 except bottle rebate and staff incentive since no valid price cost is retrieved 
                support.contractFund = 0;
                support.activationFund = 0;
                support.merchandise = 0;
                support.purchaseIncentive = 0; 
                support.marketingSupport = 0; 
            }            
            
            if(additionalSupportAmount.get(support.subbrand) != null){
                support.bottleRebate += additionalSupportAmount.get(support.subbrand).bottleRebate;
                support.staffIncentive += additionalSupportAmount.get(support.subbrand).staffIncentive;
            }
            support.bottleRebate = support.bottleRebate;
            support.staffIncentive = support.staffIncentive;
        }
        
        for(ConvertedSupportAmount support: additionalSupportAmount.values()){
            ConvertedSupportAmount temp = convertedSupportMap.get(support.subbrand);
            if(temp == null){
                temp = new ConvertedSupportAmount();
                temp.subbrand = support.subbrand;
            }           
            temp.contractFund += support.contractFund;
            temp.activationFund += support.activationFund;
            temp.merchandise += support.merchandise;
            temp.purchaseIncentive += support.purchaseIncentive; 
            temp.marketingSupport += support.marketingSupport;
            temp.bottleRebate += support.bottleRebate;
            temp.staffIncentive += support.staffIncentive; 
            convertedSupportMap.put(support.subbrand, temp);
        }
        system.debug('ConvertedSupportMap: ' + convertedSupportMap);
                
        // 4. Get Budget amount per month across the FY within the Contract period      
        
        if(customer.ASI_CRM_Duty_Free__c){
            List<ASI_MFM_Exchange_Rate__c> exchangeRateList = [select ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c 
                                                            where ASI_MFM_Country__c = 'SG' and ASI_MFM_Application__c = 'MFM' and
                                                            ASI_MFM_Base_Currency__c = 'SGD' and ASI_MFM_Counter_Currency__c = 'USD' and 
                                                            ASI_MFM_Effective_Date__c <= :contract.ASI_TH_CRM_Start_Date__c Order by ASI_MFM_Effective_Date__c DESC Limit 1];
            system.debug('exchangeRateList: ' + exchangeRateList);
            if(!exchangeRateList.isEmpty()){
                contract.ASI_CRM_CN_Exchange_Rate__c = exchangeRateList[0].ASI_MFM_Exchange_Rate__c;
                for(ConvertedSupportAmount support: convertedSupportMap.values()){
                    support.contractFund = support.contractFund * contract.ASI_CRM_CN_Exchange_Rate__c;
                    support.activationFund = support.activationFund * contract.ASI_CRM_CN_Exchange_Rate__c;
                    support.merchandise = support.merchandise * contract.ASI_CRM_CN_Exchange_Rate__c;
                    support.purchaseIncentive = support.purchaseIncentive * contract.ASI_CRM_CN_Exchange_Rate__c; 
                    support.bottleRebate = support.bottleRebate * contract.ASI_CRM_CN_Exchange_Rate__c;
                    support.staffIncentive = support.staffIncentive * contract.ASI_CRM_CN_Exchange_Rate__c;
                }
            }
        }        
        
        string budgetRTId = customer.ASI_CRM_Duty_Free__c ? 
            Global_RecordTypeCache.getRTId('ASI_MFM_Budget__cASI_MFM_PH_DF_Budget'):
            Global_RecordTypeCache.getRTId('ASI_MFM_Budget__cASI_MFM_PH_DP_Budget');
        // get budget: a set of budgets
        
        
        Map<String, Set<ASI_MFM_Budget__c>> budgetMapping = new Map<String, Set<ASI_MFM_Budget__c>>();
        Map<String, BudgetWrapper> budgetWrapperMapping = new Map<String, BudgetWrapper>(); // key: sub brand + ac code + fiscal year
        for(ASI_MFM_Budget__c budget: [
            select ASI_MFM_Type__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_P1_Amount__c, ASI_MFM_P2_Amount__c, /*Added ASI_MFM_Type__c*/
                                              ASI_MFM_P3_Amount__c, ASI_MFM_P4_Amount__c, ASI_MFM_P5_Amount__c, ASI_MFM_P6_Amount__c,
                                              ASI_MFM_P7_Amount__c, ASI_MFM_P8_Amount__c, ASI_MFM_P9_Amount__c, ASI_MFM_P10_Amount__c,
                                              ASI_MFM_P11_Amount__c, ASI_MFM_P12_Amount__c, ASI_MFM_Fiscal_Year__c from ASI_MFM_Budget__c 
                                                where ASI_MFM_Sub_brand_Code__c in : skuSubBrandMap.values() and 
                                                    ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c in: AC_CODE_MAPPING.get(contract.ASI_CRM_Contract_Duty_Type__c).keySet() and
                                                    recordTypeId = :budgetRTId and 
                                                    ASI_CRM_Salesperson__c = :contract.ownerId and
                                                    ASI_MFM_Type__c in: budgetTypeOrder.keySet() and
                                                    ASI_MFM_PH_Effective_Date__c <=: contract.ASI_TH_CRM_End_Date__c
        ]){
            /*
            if(budgetMapping.containsKey(budget.ASI_MFM_Sub_brand_Code__c + budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c)){
                budgetMapping.get(budget.ASI_MFM_Sub_brand_Code__c + budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c).add(budget);
            }
            else{
                Set<ASI_MFM_Budget__c> temp = new Set<ASI_MFM_Budget__c>{budget};
                budgetMapping.put(budget.ASI_MFM_Sub_brand_Code__c + budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, temp);
            }*/
            
            // new implementation
            String key = budget.ASI_MFM_Sub_brand_Code__c + budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c + budget.ASI_MFM_Fiscal_Year__c;
            if(budgetMapping.containsKey(key)){
                BudgetWrapper bw = budgetWrapperMapping.get(key);
                if(isHigherOrder(budget.ASI_MFM_Type__c, bw.type)){
                    bw.budget = budget;
                    bw.type = budget.ASI_MFM_Type__c;
                    budgetWrapperMapping.put(key, bw);
                }
            }
            else{
                BudgetWrapper bw = new BudgetWrapper();
                bw.key = key;
                bw.budget = budget;
                bw.type = budget.ASI_MFM_Type__c;
                budgetWrapperMapping.put(key, bw);
            }
        }      
        
        for(BudgetWrapper bw: budgetWrapperMapping.values()){
            if(budgetMapping.containsKey(bw.budget.ASI_MFM_Sub_brand_Code__c + bw.budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c)){
                budgetMapping.get(bw.budget.ASI_MFM_Sub_brand_Code__c + bw.budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c).add(bw.budget);
            }
            else{
                Set<ASI_MFM_Budget__c> temp = new Set<ASI_MFM_Budget__c>{bw.budget};
                budgetMapping.put(bw.budget.ASI_MFM_Sub_brand_Code__c + bw.budget.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, temp);
            }
        }
        
        system.debug('budgetMapping: ' + budgetMapping);
        system.debug('ConvertedSupportAmount: ' + convertedSupportMap);
        // 6.Aggregate the total support amount by A/C Code, sub-brand and month
        Set<String> monthlyOutbudgetMessage = new Set<String>();
        Set<String> yearlyOutbudgetMessage = new Set<String>();
        for(ConvertedSupportAmount support: convertedSupportMap.values()){
            // get budget
            Set<ASI_MFM_Budget__c> merchandiseBudget = budgetMapping.get(support.subbrand + (customer.ASI_CRM_Duty_Free__c ? AC_CODE_5724_DF : AC_CODE_5724_DP));            
            Set<ASI_MFM_Budget__c> activationContractBudget = budgetMapping.get(support.subbrand + (customer.ASI_CRM_Duty_Free__c ? AC_CODE_5559_DF : AC_CODE_5559_DP));
            Set<ASI_MFM_Budget__c> purchaseBudget = budgetMapping.get(support.subbrand + (customer.ASI_CRM_Duty_Free__c ? AC_CODE_5275_DF : AC_CODE_5275_DP));
            Set<ASI_MFM_Budget__c> staffBudget = budgetMapping.get(support.subbrand + (customer.ASI_CRM_Duty_Free__c ? AC_CODE_5553_DF : AC_CODE_5553_DP));
            Set<ASI_MFM_Budget__c> bottleRebateBudget = budgetMapping.get(support.subbrand + (customer.ASI_CRM_Duty_Free__c ? AC_CODE_5235_DF : AC_CODE_5235_DP));
            
            // get monthly (not required yet)
            /*
            List<OverBudget> monthlyMerchandiseBudget = checkMonthlyBudget(merchandiseBudget, support.merchandise / numOfMonths, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Merchandise', currencyCode);
            if(!monthlyMerchandiseBudget.isEmpty()){
                monthlyOutbudgetMessage.addAll(createMonthlyOverBudgetMessage(monthlyMerchandiseBudget));
            }
            
            List<OverBudget> monthlyActivationBudget = checkMonthlyBudget(activationContractBudget, support.activationFund / numOfMonths, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Activation Fund', currencyCode);
            if(!monthlyActivationBudget.isEmpty()){
                monthlyOutbudgetMessage.addAll(createMonthlyOverBudgetMessage(monthlyActivationBudget));
            }
            
            List<OverBudget> monthlyContractBudget = checkMonthlyBudget(activationContractBudget, support.contractFund / numOfMonths, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Contract Fund', currencyCode);
            if(!monthlyContractBudget.isEmpty()){
                monthlyOutbudgetMessage.addAll(createMonthlyOverBudgetMessage(monthlyContractBudget));
            }
            
            List<OverBudget> monthlyPurchaseBudget = checkMonthlyBudget(purchaseBudget, support.purchaseIncentive / numOfMonths, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Purchase Incentive', currencyCode);
            if(!monthlyPurchaseBudget.isEmpty()){
                monthlyOutbudgetMessage.addAll(createMonthlyOverBudgetMessage(monthlyPurchaseBudget));
            }
            
            List<OverBudget> monthlyStaffBudget = checkMonthlyBudget(staffBudget, support.staffIncentive / numOfMonths, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Staff Incentive', currencyCode);
            if(!monthlyStaffBudget.isEmpty()){
                monthlyOutbudgetMessage.addAll(createMonthlyOverBudgetMessage(monthlyStaffBudget));
            }
            
            List<OverBudget> monthlyBottleRebateBudget = checkMonthlyBudget(bottleRebateBudget, support.bottleRebate / numOfMonths, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, (customer.ASI_CRM_Duty_Free__c ? 'Target Incentive' : 'Bottle Rebate'), currencyCode);
            if(!monthlyBottleRebateBudget.isEmpty()){
                monthlyOutbudgetMessage.addAll(createMonthlyOverBudgetMessage(monthlyBottleRebateBudget));
            }*/
            
            // get yearly
            /*
            List<OverBudget> yearlyOverMechandise = yearlyOverBudget(merchandiseBudget, support.merchandise , contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Merchandise', currencyCode);
            if(!yearlyOverMechandise.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverMechandise));
            }*/
            
            List<OverBudget> yearlyOverActivation = yearlyOverBudget(activationContractBudget, support.activationFund, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Activation Fund', currencyCode);
            if(!yearlyOverActivation.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverActivation));
            }
            
            List<OverBudget> yearlyOverMarketingSupport = yearlyOverBudget(activationContractBudget, support.marketingSupport, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Marketing Support Fund (FOC)', currencyCode);
            if(!yearlyOverMarketingSupport.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverMarketingSupport));
            }
            
            List<OverBudget> yearlyOverContract = yearlyOverBudget(activationContractBudget, support.contractFund, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Contract Fund', currencyCode);
            if(!yearlyOverActivation.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverActivation));
            }
            
            List<OverBudget> yearlyOverPurhcaseIncentive = yearlyOverBudget(purchaseBudget, support.purchaseIncentive, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Purchase Incentive', currencyCode);
            if(!yearlyOverPurhcaseIncentive.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverPurhcaseIncentive));
            }
            
            List<OverBudget> yearlyOverStaffIncentive = yearlyOverBudget(staffBudget, support.staffIncentive, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, 'Staff Incentive', currencyCode);
            if(!yearlyOverStaffIncentive.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverStaffIncentive));
            }

            List<OverBudget> yearlyOverBottleRebate = yearlyOverBudget(bottleRebateBudget, support.bottleRebate, contract.ASI_TH_CRM_Start_Date__c, contract.ASI_TH_CRM_End_Date__c, support.subbrand, (customer.ASI_CRM_Duty_Free__c ? 'Target Incentive' : 'Bottle Rebate'), currencyCode);
            if(!yearlyOverBottleRebate.isEmpty()){
                yearlyOutbudgetMessage.addAll(createYearlyOverBudgetMessage(yearlyOverBottleRebate));
            }
        }
        
        String allMessage = '';
        Boolean isOverBudget = false;
        /* monthly not required yet*/
        /*
        if(!monthlyOutbudgetMessage.isEmpty()){
            allMessage += 'MTD\n';
            for(String s: monthlyOutbudgetMessage){
                allMessage += s + '\n';
            } 
            isOverBudget = true;
        }*/   
        
        if(!yearlyOutbudgetMessage.isEmpty()){
            allMessage += 'YTD\n';
            for(String s: yearlyOutbudgetMessage){
                allMessage += s + '\n';
            }
            isOverBudget = true;
        }
        
        contract.ASI_CRM_Is_Over_Budget__c = isOverBudget;
        contract.ASI_CRM_Over_Budget_Details__c = allMessage;
        contract.ASI_CRM_Sys_Allow_Submit_Approval__c = true;
        update contract;
        
        // Create approval process for the contract
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(contract.id);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setSkipEntryCriteria(false);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    // monthly not required yet
//    private List<OverBudget> checkMonthlyBudget(Set<ASI_MFM_Budget__c> budgetSet, Decimal amount, Date contractStartDate, Date contractEndDate, String subbrand, String supportName, String currencyCode){
//        List<OverBudget> OverBudgetList = new List<OverBudget>();
//        if(amount > 0){
//            Date currentDate = contractStartDate;
//            if(budgetSet == null || budgetSet.isEmpty()){ // no budget is found
//                for(Integer i : monthList){
//                    OverBudget overbudget = new OverBudget();
//                    overBudget.month = i;
//                    overBudget.amount = amount;
//                    overBudget.subbrand = subbrand;
//                    overBudget.supportName = supportName;
//                    overBudget.currencyName = currencyCode;
//                    overBudget.fiscalYear = getBudgetFYString(currentDate);
//                    OverBudgetList.add(overBudget);
//                    currentDate = currentDate.addMonths(1);
//                }
//            }
//            else{
//                for(Integer i : monthList){
//                    String fiscalYear = getBudgetFYString(currentDate);
//                    ASI_MFM_Budget__c currentBudget;
//
//                    for(ASI_MFM_Budget__c budget: budgetSet){
//                        if(budget.ASI_MFM_Fiscal_Year__c == fiscalYear){
//                            currentBudget = budget;
//                            break;
//                        }
//                    }
//                    OverBudget overbudget = new OverBudget();
//                    overBudget.month = i;
//                    overBudget.subbrand = subbrand;
//                    overBudget.supportName = supportName;
//                    overBudget.currencyName = currencyCode;
//                    overBudget.fiscalYear = fiscalYear;
//                    overBudget.amount = amount;
//                    if(currentBudget != null){
//                        overBudget.amount -= (Decimal)currentBudget.get('ASI_MFM_P' + String.valueOf(FISCAL_MONTH_INDEX_MAPPING.get(i)) + '_Amount__c');
//                    }
//                    OverBudgetList.add(overBudget);
//                    currentDate = currentDate.addMonths(1);
//                }
//            }
//        }
//        return OverBudgetList;
//    }
//
//    private Set<String> createMonthlyOverBudgetMessage(List<OverBudget> outbudgetMonth){
//        Set<String> messages = new Set<String>();
//        for(OverBudget overbudget: outbudgetMonth){
//            if(overbudget.amount > 0){
//                String message = subbrandNameMap.get(overbudget.subbrand) + ' - ' + overbudget.supportName + ' over ' + overbudget.currencyName + ' ' + doFormatting(overbudget.amount.setScale(2, RoundingMode.HALF_UP), 2, ',', '.') + ' in ' + MONTH_MAPPING.get(overbudget.month) + ' (' + overbudget.fiscalYear + ')';
//                messages.add(message);
//            }
//        }
//        return messages;
//    }

    @TestVisible
    private List<OverBudget> yearlyOverBudget(Set<ASI_MFM_Budget__c> budgetSet, Decimal amount, Date contractStartDate, Date contractEndDate, String subbrand, String supportName, String currencyCode){
        /*
        List<OverBudget> outbudgetYear = new List<OverBudget>();
        Date currentDate = contractStartDate;
        
        // get numbers of fiscal year by rebasing to fiscal year start dates according to contract start and end date
        Integer numOfFY = getFYStartDate(contractEndDate).year() - getFYStartDate(contractStartDate).year();
        if(numOfFY == 0){
            numOfFY = 1;
        }
        else{ // e.g. 1989-1990 to 1990-1991 = across 2 FY
            numOfFY++;
        }        
        system.debug('numOfFY: ' + numOfFY);
        for(Integer i = 0; i < numOfFY; i++){
            String fiscalYear = getBudgetFYString(currentDate); 
            OverBudget overbudget = new OverBudget();
            overBudget.subbrand = subbrand;
            overBudget.supportName = supportName;
            overBudget.currencyName = currencyCode;
            overBudget.fiscalYear = fiscalYear;
            overBudget.amount = amount*12;
            if(budgetSet != null && !budgetSet.isEmpty()){ // no budget is found
                ASI_MFM_Budget__c currentBudget;        
                for(ASI_MFM_Budget__c budget: budgetSet){
                    if(budget.ASI_MFM_Fiscal_Year__c == fiscalYear){
                        currentBudget = budget;
                        break;
                    }
                }                   
                if(currentBudget != null){          
                    for(Integer j = 1; j <= 12; j++){
                        overBudget.amount -= (Decimal)currentBudget.get('ASI_MFM_P' + String.valueOf(FISCAL_MONTH_INDEX_MAPPING.get(j)) + '_Amount__c');    
                    }                   
                }                
            }
            outbudgetYear.add(overBudget);
            currentDate = currentDate.addYears(1);
        }
        return outbudgetYear;
        */
        
        system.debug(supportName);
        system.debug(subbrand);
        
        List<OverBudget> OverBudgetList = new List<OverBudget>();
        if(amount > 0){             
            Date currentDate = contractStartDate;       
            if(budgetSet == null || budgetSet.isEmpty()){ // no budget is found
                for(Integer i : monthList){
                    OverBudget overbudget = new OverBudget();
                    overBudget.month = i;
                    overBudget.amount = amount;
                    overBudget.subbrand = subbrand;
                    overBudget.supportName = supportName;
                    overBudget.currencyName = currencyCode;
                    //overBudget.fiscalYear = getBudgetFYString(currentDate);
                    OverBudgetList.add(overBudget);
                    currentDate = currentDate.addMonths(1);
                }
            }
            else{       
                decimal budgetAmount = 0;
                for(Integer i : monthList){
                    String fiscalYear = getBudgetFYString(currentDate); 
                    ASI_MFM_Budget__c currentBudget;
                    
                    for(ASI_MFM_Budget__c budget: budgetSet){
                        if(budget.ASI_MFM_Fiscal_Year__c == fiscalYear){
                            currentBudget = budget;
                            break;
                        }
                    }                   
                    if(currentBudget != null){                      
                        budgetAmount += (Decimal)currentBudget.get('ASI_MFM_P' + String.valueOf(FISCAL_MONTH_INDEX_MAPPING.get(i)) + '_Amount__c');                     
                    }
                    currentDate = currentDate.addMonths(1);
                }   
        system.debug(budgetAmount);
        system.debug(amount);
                OverBudget overbudget = new OverBudget();
                //overBudget.month = i;
                overBudget.subbrand = subbrand;
                overBudget.supportName = supportName;
                overBudget.currencyName = currencyCode;
                //overBudget.fiscalYear = fiscalYear;
                overBudget.amount = amount - budgetAmount;  
                OverBudgetList.add(overBudget); 
            }
        }
        return OverBudgetList; 
    }    
    
    private Set<String> createYearlyOverBudgetMessage(List<OverBudget> overbudgetYear){        
        Set<String> messages = new Set<String>();              
        for(OverBudget overbudget: overbudgetYear){
            if(overbudget.amount > 0){
                //String message = subbrandNameMap.get(overbudget.subbrand) + ' - ' + overbudget.supportName + ' over ' + overbudget.currencyName + ' ' + doFormatting(overbudget.amount.setScale(2, RoundingMode.HALF_UP), 2, ',', '.') + ' in ' + overbudget.fiscalYear;
                String message = subbrandNameMap.get(overbudget.subbrand) + ' - ' + overbudget.supportName + ' over ' + overbudget.currencyName + ' ' + doFormatting(overbudget.amount.setScale(2, RoundingMode.HALF_UP), 2, ',', '.');
                messages.add(message);
            }
        }
        return messages;
    }
    
    private Integer getNumOfMonths(Date endDate, Date startDate){
        Integer total = startDate.monthsBetween(endDate);
        if(total == 0){
            return 1;
        }
        return total + 1;
    }
    
    private String getBudgetFYString(Date startDate){
        String output = 'FY';
        Integer year = Integer.valueOf(String.valueOf(startDate.year()).right(2));
        Integer month = startDate.month();
        if(month >= 7){
            output += year;
            output += (year + 1);
        }
        else{
            output += (year - 1);
            output += year;
        }
        return output;
    }
    
    List<Integer> buildMonthSequence (Date contractStart, Date contractEnd){
        List<Integer> output = new List<Integer>();
        while(contractStart < contractEnd)
        {
            output.add(contractStart.Month());
            contractStart = contractStart.AddMonths(1);
        }
        return output;
    }
    
    private Date getFYStartDate(Date currentDate){
        Integer currentFY = 0;
        if (currentDate.month() >= 7) {
            currentFY = currentDate.year();
        } else {
            currentFY = currentDate.year() - 1;
        }
       return Date.newinstance(currentFY, 7, 1);
    }
    
    private class BudgetWrapper{
        String key;
        String type;
        ASI_MFM_Budget__c budget;
    }
    
    private class ConvertedSupportAmount{
        Id subbrand;
        Decimal contractFund;
        Decimal activationFund;
        Decimal merchandise;
        Decimal purchaseIncentive;
        Decimal bottleRebate;
        Decimal staffIncentive;
        Decimal marketingSupport;
        
        public ConvertedSupportAmount(){
            contractFund = 0;
            activationFund = 0;
            merchandise = 0;
            purchaseIncentive = 0;
            bottleRebate = 0;
            staffIncentive = 0;
            marketingSupport = 0;
        }
    }
    
    private class OverBudget{
        Integer month;
        String fiscalYear;
        Decimal amount;
        String subbrand;
        String supportName;
        String currencyName;
    }
    
    public static String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
        String s, tmp;
        Integer i = 4 + dec;
       
        // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
        if(dec==0){
          i--;
        }
       
        s = val.setScale(dec).toPlainString().replace(tSep, dSep);
        while(s.length() > i) {
          tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
          s = tmp;
          i += 4;
        }
       
        // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
        if (s.substring(0,1) == '-') {
          if (s.substring(1,2) == tSep) {
            s = '-' + s.substring(2);
          }
        }
       
        return s;
    }
    
    private Boolean isHigherOrder(String type1, String type2){
        Integer seq1 = budgetTypeOrder.get(type1);
        Integer seq2 = budgetTypeOrder.get(type2);
        return seq1 < seq2;
    }
}