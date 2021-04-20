/**
 * @name GDT_User_Maintenance_Scheduler
 * @description
 * Scheduler class that executes the user's maintenance process.
 * At the moment executes the GDT_User_Maintenance_BMC_Client and GDT_User_Maintenance_User_Deactivation logics.
 * @author Bruno Vuono/ Sophie Ducatel
 */
global class GDT_User_Maintenance_Scheduler implements Schedulable {

	/**
     * Scheduler execute method. 
       Calls the scheduler logic method.
     */
	global void execute(SchedulableContext sc) {
		executionMethod();
	}

	/**
     * Scheduler execution method. 
       Checks on the custom settings to see what process have to be executed.
     */
	global void executionMethod() {
		if(canExecuteBatch(false)){
            
			String executeBMC = GDT_GeneralConfigDAO.getValueAsStringArray('BMC_RF_ServiceDesk_Client_isActive', ',',false)[0];
			String refreshSB = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_RefreshSandbox', ',',false)[0];
            String executeDeactivation = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_User_Deactivation_isActive', ',',false)[0];
			
            //Calls batchs processes.
            if(refreshSB == 'true'){
                GDT_Data_Backup.refreshTodaysSandbox();
                GDT_Data_Backup.updateBackupFields();
                GDT_Data_Backup.updateBackupObject();
            }
			if(executeBMC == 'true'){
				Database.executeBatch(new GDT_User_Maintenance_BMC_Client());
			}
			if(executeDeactivation == 'true'){
				Database.executeBatch(new GDT_User_Maintenance_User_Deactivation());
			}
		}
	}

	/**
     * Method to check is a new batch can be queued.
       Only 5 batches can be executed at the same time.
     */
	public boolean canExecuteBatch(Boolean skip){
		 List<AsyncApexJob> listAsyncApexJob = [SELECT id FROM AsyncApexJob 
                                                   WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
            //Checks the number of currents batch jobs. If there is more than 4, it schedules itself again.
            if (listAsyncApexJob == null || listAsyncApexJob != null && listAsyncApexJob.size() < 4 && !skip){
                return true;
            }else{                
                DateTime nowTime = datetime.now().addSeconds(65);
                String Seconds = '0';
                String Minutes = String.valueOf(nowTime.minute()).length() == 1 ? '0' + String.valueOf(nowTime.minute()) : String.valueOf(nowTime.minute());
                String Hours = String.valueOf(nowTime.hour()).length() == 1 ? '0' + String.valueOf(nowTime.hour()) : String.valueOf(nowTime.hour());
                String DayOfMonth = String.valueOf(nowTime.day());
                String Month = String.ValueOf(nowTime.month());
                String DayOfweek = '?';
                String optionalYear = String.valueOf(nowTime.year());
                String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
                
                GDT_User_Maintenance_Scheduler scheduleToRun = new GDT_User_Maintenance_Scheduler();
                String idjob = system.schedule('GDT_User_Maintenance_Scheduler '+system.now(), CronExpression, scheduleToRun);
            	return false;
            }
	}
    
    
    public static String prepareBody(String title, String body) {
        String msg = '<span style="font-family:monospace"><h1>' + title + '</h1>';  
        msg += '</span>';
        msg += body;
        msg += '<p style="font-family:monospace;font-size:small">Created on: '+ Datetime.now() + ' (GMT)</p>';
        return msg;
    }

    /* This method generates the HTML email based on the information. Modify this method to include new information */
    /* This method generates the HTML email based on the information. Modify this method to include new information */
    public static String prepareList (String listName, List<sObject> lst, List<String> fields) {

        String msg = '<h3>' + listName + '</h3>';
        msg += '<table>';
        for (String fil : fields) {
            msg += '<th>'+fil+'</th>';
        }
        for (sObject sobj : lst) {
            msg += '<tr>';
            for (String fil : fields) {
                msg += '<td style="font-weight:bold">' + sobj.get(fil) + '</td>';
            }
            msg += '</tr>'; 
        }
        msg += '</table>';
        return msg;
    }
    
    public Static String generateSummary(Map<String,Integer> summaryValues){
        String msg = '<span style="font-family:monospace">';
        for(String sKey : summaryValues.keySet()){
            msg += '<h4>' + sKey + ' : ' + summaryValues.get(sKey) + ' records.</h4>';
        }
        msg += '</span>';
        return msg;
    }
}