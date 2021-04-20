global class EUR_CRM_PT_AssignOPTargetActualNoBatch implements Database.Batchable<sObject> {
	
	private final static String VISIT_ACTION_PT_RT_DEVNAME = 'EUR_PT_Off_Trade_SR_To_Check_No_of_Display';
    private final static String OP_Target_PT_PER_BRAND_RT_DEVNAME = 'EUR_PT_Off_Trade_OP_Target_per_Brand';
    private final static String OP_Target_PT_PER_ACCOUNT_RT_DEVNAME = 'EUR_PT_Off_Trade_OP_Target_per_Account';
    
    private final static Set<String> OP_Target_PT_RT_DEVNAME_SET = new Set<String> {OP_Target_PT_PER_BRAND_RT_DEVNAME, OP_Target_PT_PER_ACCOUNT_RT_DEVNAME};
    
	global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        String query = 'SELECT Id, Name, EUR_CRM_Account__c, EUR_CRM_ObjPromo__c, EUR_CRM_Brand__c, EUR_CRM_Actual_No_of_Display__c ' + 
                       'FROM EUR_CRM_Visit_Action__c ' + 
                       'WHERE RecordType.DeveloperName = \'' + VISIT_ACTION_PT_RT_DEVNAME + '\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext contextInstance, List<sObject> sObjList) {
        List<EUR_CRM_Visit_Action__c> visitActionList = (List<EUR_CRM_Visit_Action__c>) sObjList;
        
        Map<String, Decimal> actualNoPerAccount = new Map<String, Decimal>();
        for(EUR_CRM_Visit_Action__c visitAction : visitActionList) {
            String key = visitAction.EUR_CRM_Account__c + '' + visitAction.EUR_CRM_ObjPromo__c + '' + visitAction.EUR_CRM_Brand__c;
            actualNoPerAccount.put(key, visitAction.EUR_CRM_Actual_No_of_Display__c);
        }
        
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = [SELECT Id, EUR_CRM_ObjPromo__c, EUR_CRM_Account__c, EUR_CRM_Brand__c, 
                                                                EUR_CRM_Actual_No_of_Display__c, EUR_CRM_Actual_No_of_Display_per_Brand__c, RecordType.DeveloperName
                                                         FROM EUR_CRM_ObjPromo_Target__c
                                                         WHERE RecordType.DeveloperName in :OP_Target_PT_RT_DEVNAME_SET];
        
        Map<String, Decimal> brandTotalActualNoMap = new Map<String, Decimal>();
        List<EUR_CRM_ObjPromo_Target__c> updateOPTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
        List<EUR_CRM_ObjPromo_Target__c> brandOPTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
        
        //Update the actual no of display of each O/P Target
        for(EUR_CRM_ObjPromo_Target__c opTarget : opTargetList) {
            String keyForAccount = opTarget.EUR_CRM_Account__c + '' + opTarget.EUR_CRM_ObjPromo__c + '' + opTarget.EUR_CRM_Brand__c;
            String keyForBrand = opTarget.EUR_CRM_ObjPromo__c + '' + opTarget.EUR_CRM_Brand__c;
            
            if(actualNoPerAccount.containsKey(keyForAccount) && opTarget.RecordType.DeveloperName.equalsIgnoreCase(OP_Target_PT_PER_ACCOUNT_RT_DEVNAME)) {
                opTarget.EUR_CRM_Actual_No_of_Display__c = actualNoPerAccount.get(keyForAccount);
                
                Decimal totalActualNo = 0;
                if(brandTotalActualNoMap.containsKey(keyForBrand)) {
                    totalActualNo = brandTotalActualNoMap.get(keyForBrand);
                }
                totalActualNo += actualNoPerAccount.get(keyForAccount);
                brandTotalActualNoMap.put(keyForBrand, totalActualNo);
                
                updateOPTargetList.add(opTarget);
            } else if(opTarget.RecordType.DeveloperName.equalsIgnoreCase(OP_Target_PT_PER_BRAND_RT_DEVNAME)) {
                brandOPTargetList.add(opTarget);
            }
            
        }
        
        //Update the total actual no of display of Brand O/P Target
        for(EUR_CRM_ObjPromo_Target__c opTarget : brandOPTargetList) {
        	String keyForBrand = opTarget.EUR_CRM_ObjPromo__c + '' + opTarget.EUR_CRM_Brand__c;
            if(brandTotalActualNoMap.containsKey(keyForBrand)) {
            	opTarget.EUR_CRM_Actual_No_of_Display_per_Brand__c = brandTotalActualNoMap.get(keyForBrand);
               	updateOPTargetList.add(opTarget);
           	}
        }
        
        if(updateOPTargetList.size() > 0) {
            update updateOPTargetList;
        }
    }
    
    global void finish(Database.BatchableContext contextInstance) {
    }
}