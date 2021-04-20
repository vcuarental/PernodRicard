trigger ASI_TH_CRM_Contract_BeforeInsert on ASI_TH_CRM_Contract__c (before insert) {
    // Modified by Michael Yip (Introv) 26Apr2014 Separate trigger class by recordtype, assume same record type for all records in trigger.new 
    
    if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Contract')){
            //if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract')){
            List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                trigger.new[0].ASI_TH_CRM_Promotion_Type__c.equalsIgnoreCase('BTHB-BDP')?
                    new ASI_TH_CRM_ContractAutoNumber('ASI_TH_CRM_BDP_Contract__c'):new ASI_TH_CRM_ContractAutoNumber()        
                        };
                            
                            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
                            }
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_Contract')){
            List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                new ASI_CRM_CN_ContractPONoAutoNumber()        
                    };
                        
                        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {if(!Test.isRunningTest()) triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
                                                                                       }
            if (Trigger.new[0].ASI_TH_CRM_Promotion_Type__c == 'Heavy Contract On') {
                /*
TODO: fix the bug in HCO
First create a HCO with overlap period, then correct the period.
Will see the Contract number become "Automated, Do not Change" and show no lines in BRSF
Add type in the overlap checking if clause should work
*/
                ASI_CRM_CN_Contract_TriggerClass.routineBeforeUpsert(Trigger.new, Trigger.oldMap);
            } else if (Trigger.new[0].ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract') {
                System.debug('TOT/MOT Contract ! ');
                System.debug('Calling routineBeforeUpsert! ');
                ASI_CRM_CN_HeavyContractOff_TriggerClass.routineBeforeUpsert(Trigger.new, Trigger.oldMap);
                ASI_CRM_CN_OffContractTriggerClass.routineBeforeInsert(Trigger.new);
            } else {
                ASI_CRM_CN_Contract_TriggerClass.routineBeforeUpsert(Trigger.new, null);
                ASI_CRM_CN_Contract_TriggerClass.routineBeforeInsert(Trigger.new);
            }           
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_PH_Contract')){
            ASI_CRM_PH_Contract_TriggerClass.routineBeforeInsert(trigger.new);          
            ASI_CRM_PH_Contract_TriggerClass.routineBeforeUpsert(trigger.new, null); 
        }    
        
        
        else if (trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract') || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal')) {
            ASI_CRM_MY_Contract_TriggerClass.routineBeforeInsert(trigger.new);
        } else if (trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract')) {
            ASI_CRM_MO_Contract_TriggerClass.routineBeforeInsert(trigger.new);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Contract')){
            // Vincent Lam - 4 Mar 2016
            // For revising contract, need not to check or update the contract
            // Vincent Lam - 13 Apr 2016
            // For converting proposal to contract, need not to check or update the contract
            if (
                // for SG P3, the snapshot contract is Approved status, so check the record type instead
                /*
				trigger.new[0].ASI_TH_CRM_Contract_Status__c != 'Archived' 
				*/
                //trigger.new[0].recordtypeid != Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Archived')
                trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract')
                && trigger.new[0].ASI_CRM_Converted_From__c == null
            ) {
                List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
                    new ASI_CRM_SG_SetTargetBenchmark(),
                        new ASI_CRM_SG_AssignApprover_Contract(),
                        new ASI_CRM_SG_AssignAutoNumber_Contract(),
                        new ASI_CRM_SG_ValidateOutletDate(),
                        // DC - 02/19/2016 - Added class for populating inflation rate and distribution rate.
                        new ASI_CRM_SG_PopulateInfl_Distr_Rate()
                        };
                            
                            for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {if(!Test.isRunningTest())triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
                                                                                           }
            }
        }
        // Vincent Lam - 8 Apr 2016
        // for SG CRM proposal
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Proposal')){
            if (
                // for SG P3, the snapshot contract is Approved status, so check the record type instead
                /*
				trigger.new[0].ASI_TH_CRM_Contract_Status__c != 'Archived' 
				*/
                //trigger.new[0].recordtypeid != Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Archived')
                trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal')
            ) {
                List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
                    new ASI_CRM_SG_SetTargetBenchmark(),
                        new ASI_CRM_SG_AssignApprover_Contract(),
                        new ASI_CRM_SG_AssignAutoNumber_Contract(),
                        new ASI_CRM_SG_ValidateOutletDate(),
                        new ASI_CRM_SG_PopulateInfl_Distr_Rate()
                        };
                            
                            for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {if(!Test.isRunningTest()) triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
                                                                                           }
            }
        }
        //Ceterna - 14 July 2020
        //for KH CRM Contract
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_KH_Contract')){
            ASI_CRM_KH_Contract_TriggerClass.routineBeforeInsert(trigger.new);
        }
    }
    
}