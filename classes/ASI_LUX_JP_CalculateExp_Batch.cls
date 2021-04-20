/*********************************************************************************
 * Name:ASI_LUX_JP_CalculateExp_Batch
 * Description: Calculate Expenditure Batch: call the same class that is been called by the trigger logic. Scheduler act as a trigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 27/01/2015       Laputa: Conrad          Created
*********************************************************************************/
global class ASI_LUX_JP_CalculateExp_Batch implements Database.Batchable<sObject>{

    global final String query;

    global ASI_LUX_JP_CalculateExp_Batch (String q){
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute (Database.Batchablecontext BC, List<sObject> scope){
        List<ASI_LUX_Campaign_Contribution__c> luxAccountList = (List<ASI_LUX_Campaign_Contribution__c>)scope;
        
        List<ASI_LUX_TriggerAbstract> triggerClasses = new List<ASI_LUX_TriggerAbstract>();
        triggerClasses.add(new ASI_LUX_JP_Calculate_Expenditure());
        
        for (ASI_LUX_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_LUX_TriggerAbstract.TriggerAction.AFTER_INSERT, luxAccountList, null, null);
        }  
    }
    
    global void finish(Database.BatchableContext BC) {   
        
    }

}