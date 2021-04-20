/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_ActualOfftake_Confirm_Ctrl
 * Description: Contains method to calculate achievement
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-31       Calvin Chiu (LAPUTA)    Created 
 * 2018-11-12		Calvin Chiu (LAPUTA)	Fixed retriveal of sum of offtake amount for purchase incentive
 * 2018-11-27		Vincent Lam (LAPUTA)	Also populate quantity achieved into contract target
 ****************************************************************************************************************************/
public class ASI_CRM_PH_ActualOfftake_Confirm_Ctrl {
    private class CustomException extends Exception{}
    private Id recordId {get;set;}
    private List<ASI_TH_CRM_Actual_Offtake__c> actualOfftake {get;set;}
    
	public ASI_CRM_PH_ActualOfftake_Confirm_Ctrl (ApexPages.StandardController controller) {   
        recordId = ((ASI_CRM_ActualOfftakeHeader__c)controller.getRecord()).Id;           
        actualOfftake = [select ASI_CRM_SG_Customer__c, ASI_TH_CRM_Offtake_G_L_Date__c, ASI_CRM_Original_Quantity__c, ASI_CRM_SKU__c, ASI_CRM_Outlet_Selling_Price__c 
                         	from ASI_TH_CRM_Actual_Offtake__c where ASI_CRM_ActualOfftakeHeader__c =: recordId Order by ASI_TH_CRM_Offtake_G_L_Date__c ASC];
    }
    
    public PageReference redirect(){
        calculate();
        return new PageReference('/'+recordId+'?retURL=%2F'+ recordId +'&nooverride=1');
    }
    
    private void calculate(){
        
        Savepoint sp = Database.setSavepoint();
        try{
            Id outletSellingPriceRTId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price');
            Id readOnlyContractRtId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract_Read_Only');
            
            // 1. Populate the total achievement into each contract
            Integer offtakeSize = actualOfftake.size();         
            
            Map<Id, ASI_TH_CRM_Contract__c> contractMap = new Map<Id, ASI_TH_CRM_Contract__c>([select ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c from ASI_TH_CRM_Contract__c 
                                                            where ASI_CRM_CN_Outlet_WS__c =: actualOfftake[0].ASI_CRM_SG_Customer__c and recordTypeId =: readOnlyContractRtId
                                                            and ASI_TH_CRM_Start_Date__c <=: actualOfftake[0].ASI_TH_CRM_Offtake_G_L_Date__c 
                                                            and ASI_TH_CRM_End_Date__c >=: actualOfftake[offtakeSize-1].ASI_TH_CRM_Offtake_G_L_Date__c]);
            
            if(!contractMap.isEmpty()){
            	Set<Id> offtakeSKUSet = new Set<Id>(); // offtakeId : SKUID
                Map<Id, ASI_TH_CRM_Contract__c> contractPendingUpdate = new Map<Id, ASI_TH_CRM_Contract__c>();
                Map<Id, List<ASI_TH_CRM_Actual_Offtake__c>> contractOfftakeMap = new Map<Id, List<ASI_TH_CRM_Actual_Offtake__c>>();
                Map<Id, Decimal> contractOfftakeQuantity = new Map<Id, Decimal>();
                
                for(ASI_TH_CRM_Contract__c contract: contractMap.values()){
                    Boolean isValidContract = false;
                    Decimal total = 0;
                    Decimal totalQuantity = 0;
                    for(ASI_TH_CRM_Actual_Offtake__c offtake: actualOfftake){                	
                        // filter out invalid contract                
                        if(contract.ASI_CRM_CN_Outlet_WS__c == offtake.ASI_CRM_SG_Customer__c && contract.ASI_TH_CRM_Start_Date__c <= offtake.ASI_TH_CRM_Offtake_G_L_Date__c && contract.ASI_TH_CRM_End_Date__c >= offtake.ASI_TH_CRM_Offtake_G_L_Date__c){
                            isValidContract = true;
                            totalQuantity += offtake.ASI_CRM_Original_Quantity__c;
                            total += (offtake.ASI_CRM_Original_Quantity__c * offtake.ASI_CRM_Outlet_Selling_Price__c);
                            offtakeSKUSet.add(offtake.ASI_CRM_SKU__c);
                            
                            if(contractOfftakeMap.get(contract.id) != null){
                                contractOfftakeMap.get(contract.id).add(offtake);
                            }
                            else{
                                contractOfftakeMap.put(contract.id, new List<ASI_TH_CRM_Actual_Offtake__c>{offtake});
                            }
                        }                	
                    }  
                    if(isValidContract){
                    	contract.ASI_CRM_SG_Net_Sales__c = total;
                        contractPendingUpdate.put(contract.Id, contract);
                        contractOfftakeQuantity.put(contract.Id, totalQuantity);
                    }
            	}
                
                system.debug('contractPendingUpdate:: ' + contractPendingUpdate);
                system.debug('contractPendingUpdate.size():: ' + contractPendingUpdate.size());
                system.debug('contractOfftakeQuantity:: ' + contractOfftakeQuantity);
                
                if(!contractPendingUpdate.isEmpty()){
                	update contractPendingUpdate.values();
                    
                    // 2. Populate achievement into contract target level for Bottle Rebate and Staff Incentive
                    List<ASI_CRM_ContractTarget__c> contractTargetPendingUpdate = new List<ASI_CRM_ContractTarget__c>();
                    for(ASI_CRM_ContractTarget__c target: [select ASI_CRM_Contract__c, ASI_CRM_SKU__c from ASI_CRM_ContractTarget__c 
                                                                          	where ASI_CRM_Contract__c in: contractPendingUpdate.keySet() AND ASI_CRM_SKU__c in: offtakeSKUSet]){
                        Boolean isValidContractTarget = false;
                        Decimal totalAmount = 0;                        
                        Decimal totalQuantity = 0;                
                        for(ASI_TH_CRM_Actual_Offtake__c offtake: contractOfftakeMap.get(target.ASI_CRM_Contract__c)){
                            if(offtake.ASI_CRM_SKU__c == target.ASI_CRM_SKU__c){
                                totalAmount += (offtake.ASI_CRM_Original_Quantity__c * offtake.ASI_CRM_Outlet_Selling_Price__c);
                                totalQuantity += offtake.ASI_CRM_Original_Quantity__c;
                                isValidContractTarget = true;
                            }
                        }
                        if(isValidContractTarget){
                            target.ASI_CRM_Achieved_Amount__c = totalAmount;
                            target.ASI_CRM_Till_Date_Sales_Bottle__c = totalQuantity;
                            contractTargetPendingUpdate.add(target);                                                        
                        }
                    }                    
                    
                    if(!contractTargetPendingUpdate.isEmpty()){
                        system.debug('contractTargetPendingUpdate:: ' + contractTargetPendingUpdate);
                        system.debug('contractTargetPendingUpdate.size():: ' + contractTargetPendingUpdate.size());
                        update contractTargetPendingUpdate;
                    }
                    
                    // 3. Populate achievement into Purchase Incentive scheme (by fixed period)
                    Id purchaseIncentiveRtId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Purchase_Incentive');
                    Id contractFundRtId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Contract_Fund');
                    
                    List<ASI_CRM_Payment_Schedule__c> paymentSchdPendingUpdate = new List<ASI_CRM_Payment_Schedule__c>();
                    // maintain a map with the issuable payment schedule for counter check
                    Map<Id, List<ASI_CRM_Payment_Schedule__c>> childPaymentSchdMap = new Map<Id, List<ASI_CRM_Payment_Schedule__c>>(); // contractId: List of Payment Schedule
                    
                    for(ASI_CRM_Payment_Schedule__c schd: [select ASI_CRM_Target_Achievement_Amount__c, ASI_CRM_Issuable__c, ASI_CRM_Type__c, ASI_CRM_Target_Bottle__c, ASI_CRM_Schedule_Date__c, ASI_CRM_Target_Purchase_Amount_From__c, ASI_CRM_Sys_Parent_record__c, 
                                                           ASI_CRM_Contract__c, ASI_CRM_Target_Start_Date__c, ASI_CRM_Target_End_Date__c, RecordTypeId
                                                           	from ASI_CRM_Payment_Schedule__c where ASI_CRM_Contract__c in: contractPendingUpdate.keySet() 
                                                           	and (recordTypeId =:purchaseIncentiveRtId OR recordTypeId =: contractFundRtId)
                                                           	ORDER BY ASI_CRM_Contract__c, ASI_CRM_Target_Start_Date__c, ASI_CRM_Target_End_Date__c, ASI_CRM_Target_Purchase_Amount_From__c DESC]){
                        Decimal total = contractPendingUpdate.get(schd.ASI_CRM_Contract__c).ASI_CRM_SG_Net_Sales__c;                                                                                
                        if(schd.recordTypeId == purchaseIncentiveRtId){
                            // calculate the period total offtake amount
                            Decimal periodTotal = 0;
                            for(ASI_TH_CRM_Actual_Offtake__c offtake: actualOfftake){
                               if(schd.ASI_CRM_Target_Start_Date__c <= offtake.ASI_TH_CRM_Offtake_G_L_Date__c && schd.ASI_CRM_Target_End_Date__c >= offtake.ASI_TH_CRM_Offtake_G_L_Date__c){
                                  periodTotal += (offtake.ASI_CRM_Original_Quantity__c * offtake.ASI_CRM_Outlet_Selling_Price__c);
                               }
                            }        
                            if(schd.ASI_CRM_Sys_Parent_record__c){                                
                                schd.ASI_CRM_Achieved_Amount__c = periodTotal;                            
                                paymentSchdPendingUpdate.add(schd);
                            }
                            else{
                                // set issuable to true on child record
                                List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = childPaymentSchdMap.get(schd.ASI_CRM_Contract__c);
                                if(schd.ASI_CRM_Target_Purchase_Amount_From__c < periodTotal){
                                    if(paymentScheduleList == null){
                                        schd.ASI_CRM_Issuable__c = true;
                                        childPaymentSchdMap.put(schd.ASI_CRM_Contract__c, new List<ASI_CRM_Payment_Schedule__c>{schd});
                                        paymentSchdPendingUpdate.add(schd);
                                    }
                                    else{
                                        Boolean found = false;
                                        // if found, the largest purchase amount from is already added to the map
                                        for(ASI_CRM_Payment_Schedule__c existingSchd: paymentScheduleList){
                                            if(existingSchd.ASI_CRM_Target_Start_Date__c == schd.ASI_CRM_Target_Start_Date__c && existingSchd.ASI_CRM_Target_End_Date__c == schd.ASI_CRM_Target_End_Date__c){
                                                found = true;
                                                break;
                                            }
                                        }
                                        if(!found){
                                            schd.ASI_CRM_Issuable__c = true;
                                            childPaymentSchdMap.get(schd.ASI_CRM_Contract__c).add(schd);
                                            paymentSchdPendingUpdate.add(schd);
                                        }
                                        // set any other to false if issuable is true
                                        else if (schd.ASI_CRM_Issuable__c){
                                            schd.ASI_CRM_Issuable__c = false;
                                            childPaymentSchdMap.get(schd.ASI_CRM_Contract__c).add(schd);
                                            paymentSchdPendingUpdate.add(schd);
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            switch on schd.ASI_CRM_Type__c{
                                when 'Value'{
                                    if(total >= schd.ASI_CRM_Target_Achievement_Amount__c){
                                        schd.ASI_CRM_Issuable__c = true;
                                        paymentSchdPendingUpdate.add(schd);
                                    } 
                                }
                                when 'Bottle'{
                                    if(contractOfftakeQuantity.get(schd.ASI_CRM_Contract__c) >= schd.ASI_CRM_Target_Bottle__c){
                                        schd.ASI_CRM_Issuable__c = true;
                                        paymentSchdPendingUpdate.add(schd);
                                    }
                                }
                                when 'Date'{
                                    if(Date.today() >= schd.ASI_CRM_Schedule_Date__c){
                                        schd.ASI_CRM_Issuable__c = true;
                                        paymentSchdPendingUpdate.add(schd);
                                    }
                                }
                            }
                        }
                    }                    
                    
                    if(!paymentSchdPendingUpdate.isEmpty()){
                        system.debug('paymentSchdPendingUpdate:: ' + paymentSchdPendingUpdate);
                        system.debug('paymentSchdPendingUpdate.size():: ' + paymentSchdPendingUpdate.size());
                    	update paymentSchdPendingUpdate;                        
                    }
                    // update header confirmation flag
                    ASI_CRM_ActualOfftakeHeader__c header = [select ASI_CRM_Confirmed__c from ASI_CRM_ActualOfftakeHeader__c where id =:recordId];
                    header.ASI_CRM_Confirmed__c = true;
                    update header;
                }
            }
            else{
                throw new CustomException('Related contract not found.');
            }       
        }catch(Exception e){
            Database.rollback(sp);
            throw new CustomException(e.getMessage());
        }
    }
    
    private static Decimal checkNullDecimal(Decimal input){
        if(input == null)
            return 0;
        else
            return input;
    }
}