public with sharing class ASI_TH_CRM_Contract_TriggerClass {    
    
    public static void routineBeforeUpdate(Map<id, ASI_TH_CRM_Contract__c> trigger_newMap, Map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){     
        String userroleDeveloperName;
        if(userinfo.getUserRoleId()!=null)
            userRoleDeveloperName =[Select Id,DeveloperName from UserRole where Id=:userinfo.getUserRoleId()].DeveloperName;             
        Set<Id> contractIds = new Set<Id>();                                      
        
        for(ASI_TH_CRM_Contract__c newRecord: trigger_newMap.values())
        {  
            ASI_TH_CRM_Contract__c oldContract = trigger_oldMap.get(newRecord.id);

            if (oldContract.ASI_TH_CRM_Contract_Status__c != newRecord.ASI_TH_CRM_Contract_Status__c ){         
                if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Draft' && !(newRecord.ASI_TH_CRM_Contract_Status__c == 'Final')){
                    newRecord.addError('Contract status only allow change from Draft to Final');
                }else if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Final' && !(newRecord.ASI_TH_CRM_Contract_Status__c == 'Freeze')){
                    newRecord.addError('Contract status only allow change from Final to Freeze');
                }else if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Editing' && !(newRecord.ASI_TH_CRM_Contract_Status__c == 'Final')){
                    newRecord.addError('Contract status only allow change from Editing to Final');
                }else if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Freeze' && !(newRecord.ASI_TH_CRM_Contract_Status__c == 'Editing' 
                ||newRecord.ASI_TH_CRM_Contract_Status__c == 'Completed')){
                    newRecord.addError('Contract status only allow change from Freeze to Editing/Completed');
                }
            }
            
            //Added by William Yang (Introv) 20140408
            if (userRoleDeveloperName != null && userRoleDeveloperName.contains('On_Premise'))    
                    newRecord.addError('You are not allowed to edit Contract');
                    
            if (userRoleDeveloperName != null && userRoleDeveloperName == 'ASI_TH_CRM_Sales_Co'){
                if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Final' || oldContract.ASI_TH_CRM_Contract_Status__c == 'Freeze')          
                    newRecord.addError('Contract is not allow to modify when status in Final/Freeze');
                if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Completed')           
                    newRecord.addError('Contract is not allow to modify when status in Completed');
                if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Editing' && newRecord.ASI_TH_CRM_Start_Date__c != oldContract.ASI_TH_CRM_Start_Date__c)
                    newRecord.addError('Start Date is not allow to modify');                
            }         
            
            //Added by Twinkle Li (Introv) 20160119
            if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Final' && newRecord.ASI_TH_CRM_Contract_Status__c == 'Freeze' && newRecord.ASI_CRM_Frozen_Date__c == null)          
                newRecord.ASI_CRM_Frozen_Date__c = date.today();   
        }
        
        for(ASI_TH_CRM_Contract__c newRecord: trigger_newMap.values())
        { 
            ASI_TH_CRM_Contract__c oldContract = trigger_oldMap.get(newRecord.id);
            if (newRecord.ASI_TH_CRM_Contract_Status__c == 'Final') contractIds.add(newRecord.id);
        }        
        
        for (ASI_TH_CRM_Contract__c contract : [Select id, (Select id, ASI_TH_CRM_Fund_Advance__c, ASI_TH_CRM_Fund_Cash__c, ASI_TH_CRM_Fund_FOC__c,
        ASI_TH_CRM_Activity_Cash__c, ASI_TH_CRM_Activity_FOC__c
        From ASI_TH_CRM_CS_Contract__r) From  ASI_TH_CRM_Contract__c 
        WHERE id  in :contractIds]){
            Decimal fundAdvance = 0;
            Decimal fundCash = 0;
            Decimal fundFOC = 0;
            Decimal activityCash = 0;
            Decimal activityFOC = 0;
            for (ASI_TH_CRM_Contract_Spending__c contractSpending : contract.ASI_TH_CRM_CS_Contract__r){
                fundAdvance += contractSpending.ASI_TH_CRM_Fund_Advance__c != null? contractSpending.ASI_TH_CRM_Fund_Advance__c : 0;
                fundCash += contractSpending.ASI_TH_CRM_Fund_Cash__c != null?contractSpending.ASI_TH_CRM_Fund_Cash__c:0;
                fundFOC += contractSpending.ASI_TH_CRM_Fund_FOC__c != null?contractSpending.ASI_TH_CRM_Fund_FOC__c:0;
                activityCash += contractSpending.ASI_TH_CRM_Activity_Cash__c != null?contractSpending.ASI_TH_CRM_Activity_Cash__c:0;
                activityFOC += contractSpending.ASI_TH_CRM_Activity_FOC__c != null?contractSpending.ASI_TH_CRM_Activity_FOC__c:0;
            }
            
            Decimal contractTotalFundAdvance = (trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Fund_Advance__c == null) ? 0 : trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Fund_Advance__c;
            Decimal contractTotalFundCash = (trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Fund_Cash__c == null) ? 0 : trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Fund_Cash__c;
            Decimal contractTotalFundFOC = (trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Fund_FOC__c == null) ? 0 : trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Fund_FOC__c;
            Decimal contractTotalActivityCash = (trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Activity_Cash__c == null) ? 0 : trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Activity_Cash__c;
            Decimal contractTotalActivityFOC = (trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Activity_FOC__c == null) ? 0 : trigger_newMap.get(contract.id).ASI_TH_CRM_Total_Activity_FOC__c;
            
            if (fundAdvance != contractTotalFundAdvance){
                trigger_newMap.get(contract.id).addError('Total Contract Spending Fund - Advance not match with Total Fund - Advance in Contract');
            }           
            if (fundCash != contractTotalFundCash){
                trigger_newMap.get(contract.id).addError('Total Contract Spending Fund - Cash not match with Total Fund - Cash in Contract');
            }
            if (fundFOC != contractTotalFundFOC){
                trigger_newMap.get(contract.id).addError('Total Contract Spending Fund - FOC not match with Total Fund - FOC in Contract');
            }
            if (activityCash != contractTotalActivityCash){
                trigger_newMap.get(contract.id).addError('Total Contract Spending Activity - Cash not match with Total Activity - Cash in Contract');
            }
            if (activityFOC != contractTotalActivityFOC){
                trigger_newMap.get(contract.id).addError('Total Contract Spending Activity - FOC not match with Total Activity - FOC in Contract');
            }
            
        } 
    }

    public static void routineAfterAll(Map<id, ASI_TH_CRM_Contract__c> trigger_newMap, Map<id, ASI_TH_CRM_Contract__c> trigger_oldMap){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Set<Id> generateEstimatedSpendingContractIds = new Set<Id>();           
        List<ASI_TH_CRM_Contract_Spending__c> deleteContractSpendingList;
        List<ASI_TH_CRM_Contract_Spending__c> insertContractSpendingList = new List<ASI_TH_CRM_Contract_Spending__c>();
        List<ASI_TH_CRM_Estimated_Spending__c> insertEstimatedSpendingList = new List<ASI_TH_CRM_Estimated_Spending__c>();
        List<ASI_TH_CRM_Estimated_Spending__c> deleteEstimatedSpendingList = new List<ASI_TH_CRM_Estimated_Spending__c>();
        
        Map<id, Date> newContractEndDateMap = new Map<id, Date>();       
        
        for(ASI_TH_CRM_Contract__c newRecord: trigger_newMap.values()){            
            if (trigger_oldMap != null){
                ASI_TH_CRM_Contract__c oldContract = trigger_oldMap.get(newRecord.id);
                  
                 if (newRecord.ASI_TH_CRM_Start_Date__c != null && newRecord.ASI_TH_CRM_End_Date__c != null && 
                 (newRecord.ASI_TH_CRM_Contract_Status__c == 'Draft' && oldContract.ASI_TH_CRM_Contract_Status__c == 'Draft' )){
                    contractIds.add(newRecord.id);
                 }                           
                                        
                 if (newRecord.ASI_TH_CRM_Contract_Status__c == 'Freeze'){                    
                    if (oldContract.ASI_TH_CRM_Contract_Status__c == 'Final') generateEstimatedSpendingContractIds.add(newRecord.id);                
                    
                    Integer monthDiff = newRecord.ASI_TH_CRM_End_Date__c.monthsBetween(oldContract.ASI_TH_CRM_End_Date__c);
                    if (monthDiff != 0){
                        newContractEndDateMap.put(newRecord.id, newRecord.ASI_TH_CRM_End_Date__c);
                        contractIds.add(newRecord.id);
                    }
                 }  
            }else{
                if (newRecord.ASI_TH_CRM_Start_Date__c != null && newRecord.ASI_TH_CRM_End_Date__c != null && 
                 (newRecord.ASI_TH_CRM_Contract_Status__c == 'Draft' || newRecord.ASI_TH_CRM_Contract_Status__c == 'Final' )){
                    contractIds.add(newRecord.id);
                 }
            }
            accountIds.add(newRecord.ASI_TH_CRM_Outlet__c);
        }    
        
        //Added by Twinkle Li (Introv) 20160428 - update customer type by contract status & contract promotion type
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        Map<id, ASI_CRM_AccountsAdditionalField__c> mapAccountCustomer = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
        listCustomer = [SELECT id, ASI_CRM_Account__c, ASI_CRM_CN_Type__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN:accountIds];
        for(ASI_CRM_AccountsAdditionalField__c cust : listCustomer){
            mapAccountCustomer.put(cust.ASI_CRM_Account__c, cust);
        }
        
        //List<ASI_CRM_AccountsAdditionalField__c> listToUpdateCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        Map<id,ASI_CRM_AccountsAdditionalField__c> mapToUpdateCustomer = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_TH_CRM_Contract__c newRecord: trigger_newMap.values()){ 
            if (trigger_oldMap != null){
                ASI_TH_CRM_Contract__c oldContract = trigger_oldMap.get(newRecord.id);
                if ((oldContract.ASI_TH_CRM_Contract_Status__c != newRecord.ASI_TH_CRM_Contract_Status__c) && newRecord.ASI_TH_CRM_Contract_Status__c == 'Freeze'){          
                    ASI_CRM_AccountsAdditionalField__c customer = mapAccountCustomer.get(newRecord.ASI_TH_CRM_Outlet__c);
                    if(customer != null){
                        if(newRecord.ASI_TH_CRM_Promotion_Type__c == 'PRT - Contract')
                            customer.ASI_CRM_CN_Type__c = 'Contracted';
                        else if(newRecord.ASI_TH_CRM_Promotion_Type__c == 'BTHB-BDP')
                            customer.ASI_CRM_CN_Type__c = 'BDP';
                        //listToUpdateCustomer.add(customer);
                        if(mapToUpdateCustomer.get(customer.id) == null)
                            mapToUpdateCustomer.put(customer.id, customer);
                    }
                    
                }
                if ((oldContract.ASI_TH_CRM_Contract_Status__c != newRecord.ASI_TH_CRM_Contract_Status__c) && newRecord.ASI_TH_CRM_Contract_Status__c == 'Completed'){          
                    ASI_CRM_AccountsAdditionalField__c customer = mapAccountCustomer.get(newRecord.ASI_TH_CRM_Outlet__c);
                    if(customer != null){
                        customer.ASI_CRM_CN_Type__c = 'Potential';
                        //listToUpdateCustomer.add(customer);
                        if(mapToUpdateCustomer.get(customer.id) == null)
                        	mapToUpdateCustomer.put(customer.id, customer);
                    }
                }
            }  
        } 
        /*
        if(listToUpdateCustomer != null && listToUpdateCustomer.size() > 0)
            update listToUpdateCustomer;
		*/
        if(mapToUpdateCustomer.values() != null && mapToUpdateCustomer.values().size() > 0)
            update mapToUpdateCustomer.values();
        //Added by Twinkle Li (Introv) 20160428
        
        deleteContractSpendingList = [SELECT id FROM ASI_TH_CRM_Contract_Spending__c 
            WHERE ASI_TH_CRM_Contract__c in : contractIds];
        
        for(ASI_TH_CRM_Contract__c contract : [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_No_Of_Months__c,
            ASI_TH_CRM_Total_Fund_Advance__c, ASI_TH_CRM_Total_Fund_Cash__c, ASI_TH_CRM_Total_Fund_FOC__c, ASI_TH_CRM_Total_Activity_Cash__c,
            ASI_TH_CRM_Total_Activity_FOC__c
            FROM ASI_TH_CRM_Contract__c WHERE id in :contractIds ]){
            System.debug('Debug contract.ASI_TH_CRM_No_Of_Months__c: ' + contract.ASI_TH_CRM_No_Of_Months__c);
            
            Decimal avgFundAdvance = (contract.ASI_TH_CRM_Total_Fund_Advance__c != null) ? 
                (contract.ASI_TH_CRM_Total_Fund_Advance__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgFundCash =  (contract.ASI_TH_CRM_Total_Fund_Cash__c != null) ? 
                (contract.ASI_TH_CRM_Total_Fund_Cash__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgFundFOC =  (contract.ASI_TH_CRM_Total_Fund_FOC__c != null) ? 
                (contract.ASI_TH_CRM_Total_Fund_FOC__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgActivityCash =  (contract.ASI_TH_CRM_Total_Activity_Cash__c != null) ? 
                (contract.ASI_TH_CRM_Total_Activity_Cash__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgActivityFOC =  (contract.ASI_TH_CRM_Total_Activity_FOC__c != null) ? 
                (contract.ASI_TH_CRM_Total_Activity_FOC__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
                
            Integer i = 0;
            do{
                ASI_TH_CRM_Contract_Spending__c contractSpending = new ASI_TH_CRM_Contract_Spending__c();
                DateTime currentContractSpendingDateTime =  contract.ASI_TH_CRM_Start_Date__c.addMonths(i);
                Date currentContractSpendingDate =  contract.ASI_TH_CRM_Start_Date__c.addMonths(i);
                
                contractSpending.ASI_TH_CRM_Contract__c = contract.id;
                contractSpending.Name = currentContractSpendingDate.year() + ' - ' + currentContractSpendingDateTime.format('MMM'); 
                contractSpending.ASI_TH_CRM_Date__c = currentContractSpendingDate;                              
                
                if (newContractEndDateMap.get(contract.id) != null){
                    contractSpending.ASI_TH_CRM_Fund_Advance__c = 0;
                    contractSpending.ASI_TH_CRM_Fund_Cash__c = 0;
                    contractSpending.ASI_TH_CRM_Fund_FOC__c = 0;
                    contractSpending.ASI_TH_CRM_Activity_Cash__c = 0;
                    contractSpending.ASI_TH_CRM_Activity_FOC__c = 0;
                }else if (contract.ASI_TH_CRM_No_Of_Months__c == i + 1){
                    System.debug('Debug contract.ASI_TH_CRM_Total_Fund_Advance__c: ' + contract.ASI_TH_CRM_Total_Fund_Advance__c);
                    System.debug('Debug avgFundAdvance * i: ' + avgFundAdvance * i);
                    contractSpending.ASI_TH_CRM_Fund_Advance__c = 
                        (contract.ASI_TH_CRM_Total_Fund_Advance__c != null) ? contract.ASI_TH_CRM_Total_Fund_Advance__c - (avgFundAdvance * i) : 0 ;
                    contractSpending.ASI_TH_CRM_Fund_Cash__c = 
                        (contract.ASI_TH_CRM_Total_Fund_Cash__c != null) ? contract.ASI_TH_CRM_Total_Fund_Cash__c - (avgFundCash * i) : 0 ;
                    contractSpending.ASI_TH_CRM_Fund_FOC__c = 
                        (contract.ASI_TH_CRM_Total_Fund_FOC__c != null) ? contract.ASI_TH_CRM_Total_Fund_FOC__c - (avgFundFOC * i) : 0 ;
                    contractSpending.ASI_TH_CRM_Activity_Cash__c = 
                        (contract.ASI_TH_CRM_Total_Activity_Cash__c != null) ? contract.ASI_TH_CRM_Total_Activity_Cash__c - (avgActivityCash * i) : 0 ;
                    contractSpending.ASI_TH_CRM_Activity_FOC__c = 
                        (contract.ASI_TH_CRM_Total_Activity_FOC__c != null) ? contract.ASI_TH_CRM_Total_Activity_FOC__c - (avgActivityFOC * i) : 0 ;                 
                }else{
                    contractSpending.ASI_TH_CRM_Fund_Advance__c = avgFundAdvance;
                    contractSpending.ASI_TH_CRM_Fund_Cash__c = avgFundCash;
                    contractSpending.ASI_TH_CRM_Fund_FOC__c = avgFundFOC;
                    contractSpending.ASI_TH_CRM_Activity_Cash__c = avgActivityCash;
                    contractSpending.ASI_TH_CRM_Activity_FOC__c = avgActivityFOC;
                }
                
                i++;
                System.debug('Debug i: ' + i);
                insertContractSpendingList.add(contractSpending);
            }while(i <  contract.ASI_TH_CRM_No_Of_Months__c);
        }
        
        Map<id, Integer> contractEstimatedSpendingCount = new Map<id, Integer>();
        /*for (ASI_TH_CRM_Contract__c contract : [Select id, (Select id From ASI_TH_CRM_ES_Contract__r) From  ASI_TH_CRM_Contract__c 
        WHERE id in :generateEstimatedSpendingContractIds]){
            contractEstimatedSpendingCount.put(contract.id, contract.ASI_TH_CRM_ES_Contract__r.size());
        }*/
        System.debug('generateEstimatedSpendingContractIds.size():' + generateEstimatedSpendingContractIds.size());
        for (ASI_TH_CRM_Estimated_Spending__c estimatedSpending : [Select id, ASI_TH_CRM_Contract__c From ASI_TH_CRM_Estimated_Spending__c
        WHERE ASI_TH_CRM_Contract__c in :generateEstimatedSpendingContractIds]){
            
            Integer estimatedSpendingCount = contractEstimatedSpendingCount.get(estimatedSpending.ASI_TH_CRM_Contract__c);
            System.debug('estimatedSpendingCount:' + estimatedSpendingCount);
            if (estimatedSpendingCount == null) contractEstimatedSpendingCount.put(estimatedSpending.ASI_TH_CRM_Contract__c, 1);
            else contractEstimatedSpendingCount.put(estimatedSpending.ASI_TH_CRM_Contract__c, estimatedSpendingCount + 1);
        }        
        
        //Generate Estimated Spending when Contract status changed form Final to Freeze
        //Clone all value from Contract Spending to Estimated Spending
        for (ASI_TH_CRM_Contract_Spending__c contractSpending : [SELECT id, Name, ASI_TH_CRM_Date__c, ASI_TH_CRM_Contract__c,
        ASI_TH_CRM_Fund_Advance__c, ASI_TH_CRM_Fund_Cash__c, ASI_TH_CRM_Fund_FOC__c,
        ASI_TH_CRM_Activity_Cash__c, ASI_TH_CRM_Activity_FOC__c
        From ASI_TH_CRM_Contract_Spending__c WHERE ASI_TH_CRM_Contract__c in :generateEstimatedSpendingContractIds]){
            ASI_TH_CRM_Estimated_Spending__c estimatedSpending = new ASI_TH_CRM_Estimated_Spending__c();
            
            if (contractEstimatedSpendingCount.get(contractSpending.ASI_TH_CRM_Contract__c) == 0 || 
            contractEstimatedSpendingCount.get(contractSpending.ASI_TH_CRM_Contract__c) == null){            
                estimatedSpending.ASI_TH_CRM_Contract__c = contractSpending.ASI_TH_CRM_Contract__c;
                estimatedSpending.Name = contractSpending.Name; 
                estimatedSpending.ASI_TH_CRM_Date__c = contractSpending.ASI_TH_CRM_Date__c; 
                estimatedSpending.ASI_TH_CRM_Fund_Advance__c = contractSpending.ASI_TH_CRM_Fund_Advance__c;
                estimatedSpending.ASI_TH_CRM_Fund_Cash__c = contractSpending.ASI_TH_CRM_Fund_Cash__c;
                estimatedSpending.ASI_TH_CRM_Fund_FOC__c = contractSpending.ASI_TH_CRM_Fund_FOC__c;
                estimatedSpending.ASI_TH_CRM_Activity_Cash__c = contractSpending.ASI_TH_CRM_Activity_Cash__c;
                estimatedSpending.ASI_TH_CRM_Activity_FOC__c = contractSpending.ASI_TH_CRM_Activity_FOC__c;
                
                insertEstimatedSpendingList.add(estimatedSpending);
            }
        }
        
        /*
        Comment by Howard logic can't hit due to added new validation rule for freeze contract cannot modify 
        // Delete estimated Spending
        // Early Termination (change to shorter contract period): Remove extra Estimated Spending records, keep rest of records unchanged. 
        for(ASI_TH_CRM_Estimated_Spending__c estimatedSpending : [SELECT id, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Date__c FROM ASI_TH_CRM_Estimated_Spending__c 
        WHERE ASI_TH_CRM_Contract__c in :  newContractEndDateMap.keySet()] ){
            if (estimatedSpending.ASI_TH_CRM_Date__c  > newContractEndDateMap.get(estimatedSpending.ASI_TH_CRM_Contract__c))
                deleteEstimatedSpendingList.add(estimatedSpending );
        }
        
        // Insert Esimtated Spending
        // Contract Period Extension (change to longer contract period): Create additional Estimated Spending records, keep existing records unchanged.
        for(ASI_TH_CRM_Contract__c contract : [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_No_Of_Months__c,
            ASI_TH_CRM_Total_Fund_Advance__c, ASI_TH_CRM_Total_Fund_Cash__c, ASI_TH_CRM_Total_Fund_FOC__c, ASI_TH_CRM_Total_Activity_Cash__c,
            ASI_TH_CRM_Total_Activity_FOC__c
            FROM ASI_TH_CRM_Contract__c WHERE id in :newContractEndDateMap.keySet() ]){
            System.debug('Debug contract.ASI_TH_CRM_No_Of_Months__c: ' + contract.ASI_TH_CRM_No_Of_Months__c);
            
            Decimal avgFundAdvance = (contract.ASI_TH_CRM_Total_Fund_Advance__c != null) ? 
                (contract.ASI_TH_CRM_Total_Fund_Advance__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgFundCash =  (contract.ASI_TH_CRM_Total_Fund_Cash__c != null) ? 
                (contract.ASI_TH_CRM_Total_Fund_Cash__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgFundFOC =  (contract.ASI_TH_CRM_Total_Fund_FOC__c != null) ? 
                (contract.ASI_TH_CRM_Total_Fund_FOC__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgActivityCash =  (contract.ASI_TH_CRM_Total_Activity_Cash__c != null) ? 
                (contract.ASI_TH_CRM_Total_Activity_Cash__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;
            Decimal avgActivityFOC =  (contract.ASI_TH_CRM_Total_Activity_FOC__c != null) ? 
                (contract.ASI_TH_CRM_Total_Activity_FOC__c / contract.ASI_TH_CRM_No_Of_Months__c).setScale(2) : 0;                            
            
            if ((contract.ASI_TH_CRM_No_Of_Months__c - (trigger_oldMap.get(contract.id)).ASI_TH_CRM_No_Of_Months__c).intValue() > 0){
                Integer i =  (trigger_oldMap.get(contract.id)).ASI_TH_CRM_No_Of_Months__c.intValue();
                System.debug('Debug Insert Estimated Spending i: ' + i);
                do{
                    ASI_TH_CRM_Estimated_Spending__c estimatedSpending = new ASI_TH_CRM_Estimated_Spending__c();
                    DateTime currentContractSpendingDateTime =  contract.ASI_TH_CRM_Start_Date__c.addMonths(i);
                    Date currentContractSpendingDate =  contract.ASI_TH_CRM_Start_Date__c.addMonths(i);
                    
                    estimatedSpending.ASI_TH_CRM_Contract__c = contract.id;
                    estimatedSpending.Name = currentContractSpendingDate.year() + ' - ' + currentContractSpendingDateTime.format('MMM'); 
                    estimatedSpending.ASI_TH_CRM_Date__c = currentContractSpendingDate;                                                  
    
                    estimatedSpending.ASI_TH_CRM_Fund_Advance__c = 0;
                    estimatedSpending.ASI_TH_CRM_Fund_Cash__c = 0;
                    estimatedSpending.ASI_TH_CRM_Fund_FOC__c = 0;
                    estimatedSpending.ASI_TH_CRM_Activity_Cash__c = 0;
                    estimatedSpending.ASI_TH_CRM_Activity_FOC__c = 0;                    
                    
                    i++;
                    System.debug('Debug i: ' + i);
                    insertEstimatedSpendingList.add(estimatedSpending);
                }while(i <  contract.ASI_TH_CRM_No_Of_Months__c);
            }
        }*/
        
        
        if(deleteContractSpendingList!=null && deleteContractSpendingList.size()>0) delete deleteContractSpendingList;
        
        if(insertContractSpendingList!=null && insertContractSpendingList.size()>0) insert insertContractSpendingList;
        
        if(deleteEstimatedSpendingList!=null && deleteEstimatedSpendingList.size()>0) delete deleteEstimatedSpendingList;

        if(insertEstimatedSpendingList!=null && insertEstimatedSpendingList.size()>0) insert insertEstimatedSpendingList;
    }
}