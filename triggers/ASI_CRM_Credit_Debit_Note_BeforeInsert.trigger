trigger ASI_CRM_Credit_Debit_Note_BeforeInsert on ASI_CRM_Credit_Debit_Note__c (before insert) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Contract_Margin_Credit_Note')
      || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Contract_Margin_Debit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Prompt_Payment_Credit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Prompt_Payment_Debit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Back_Rebate_Credit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Back_Rebate_Debit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Manual_Credit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Manual_Debit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Wholesaler_Credit_Note')
       || trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Wholesaler_Debit_Note')

      ){
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_AssignAutoNumber_CreditDebit()        
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
        }
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Manual'))
        ASI_CRM_SG_CreditNote_TriggerClass.retrieveExchangeRate(trigger.new, null);
    
    //2020-04-02 Created By: Ceterna - Update Month/Year of Wholesaler FWO Period record type before insert & Validate Previous Exist
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_FWO_Period')){
        ASI_CRM_SG_CreditNote_TriggerClass.UpdateMonthYearBeforeInsert(trigger.new);
        ASI_CRM_SG_CreditNote_TriggerClass.ValidatePreviousMonthCreditNote(trigger.new);
    }
    
    for(ASI_CRM_Credit_Debit_Note__c creditNote : trigger.new){
        creditNote.ASI_CRM_SG_Duplicate_Rule_Unique_Key__c = (creditNote.ASI_CRM_SG_FWO_Period__c==null?'':String.valueOf(creditNote.ASI_CRM_SG_FWO_Period__c) )
            												 + '_'
            												 + (creditNote.ASI_CRM_Wholesaler__c==null?'':String.valueOf(creditNote.ASI_CRM_Wholesaler__c));
        system.debug('@#34'+creditNote.ASI_CRM_SG_FWO_Period__c);
        if(creditNote.ASI_CRM_SG_Record_Type_Dev_Name__c != null){
            creditNote.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note__c'+creditNote.ASI_CRM_SG_Record_Type_Dev_Name__c);
            system.debug('@#'+creditNote.ASI_CRM_SG_Record_Type_Dev_Name__c);
            system.debug('@#@#'+creditNote.RecordTypeId);
        }
    }
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Credit_Note')){
        ASI_CRM_SG_CreditNote_TriggerClass.UpdateStartEndDateFWOBeforeInsert(trigger.new);
        //ASI_CRM_SG_CreditNote_TriggerClass.ValidatePreviousMonthCreditNote(trigger.new);
    }
}