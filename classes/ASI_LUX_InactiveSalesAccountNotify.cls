global class ASI_LUX_InactiveSalesAccountNotify implements Schedulable {
	
	//test run
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	
   	global void execute(SchedulableContext SC) {
   		/*ASI_LUX_AccountInactivity__c intervalMonth = [select Name, ASI_LUX_AccountInactivityTime_Inactivity__c from ASI_LUX_AccountInactivity__c limit 1];
		Integer convertedDecimalTime = intervalMonth.ASI_LUX_AccountInactivityTime_Inactivity__c.intValue();   		
		DateTime todayIndeductMonths = date.today().addDays(- convertedDecimalTime);
		
		String datestr = todayIndeductMonths.format('yyyy-MM-dd');*/
		map<string, id> rt_mapAcc = getRecordTypeId('Account');
		
		String Query = 'SELECT Name, ID, OwnerID, (SELECT ID, Name, ASI_HK_CRM_Order_Date__c FROM ASI_HK_CRM_Sales_Order_Histories__r )' + 
						' FROM Account WHERE (recordTypeID = \'' + rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked') +  '\'' +
						' OR recordTypeID = \'' +rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact') + '\') ' + 
						' AND ASI_LUX_Le_Cercle_Member__c = TRUE AND ASI_LUX_Le_Cercle_Member_Number__c != null';
						
		ASI_LUX_SendEmailNotifyInactiveAccount sendEmailNotifyInactiveluxAcct = new ASI_LUX_SendEmailNotifyInactiveAccount(Query);
		Database.executeBatch(sendEmailNotifyInactiveluxAcct, 10);
   }
   
    global static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }

}