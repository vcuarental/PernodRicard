global class LAT_CTY_B2B_ProcessBlock_Schedulable implements Schedulable {    
	global void execute(SchedulableContext objSchedulableContext) {
    	System.debug('LAT_CTY_B2B_ProcessBlock_Schedulable.execute [] ->');
        
        updateSiteStatus();

        System.debug('LAT_CTY_B2B_ProcessBlock_Schedulable.execute [] <-');
    }

    @future(callout=true)
    public static void updateSiteStatus() {
        Boolean boolIsExternalSystemUp = null;
        LAT_GeneralConfig__c objMinutes = null;
        DateTime datNextRun = null;

    	System.debug('updateSiteStatus [] ->');

        boolIsExternalSystemUp = LAT_Utils.isJDEUp();

        //Si no esta activo, agrego x minutos y reescheduleo.
        //si esta activo, no hago nada.
        if(!boolIsExternalSystemUp) {
            objMinutes = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_ExternalSite_Retry');
            if(objMinutes == NULL) {
               objMinutes = LAT_Utils.createSettings('LAT_CTY_B2B_AR_ExternalSite_Retry', '15', 'Cantidad de minutos a esperar para volver a checkear si JDE esta activo');
            }

            datNextRun = DateTime.now().addMinutes(Integer.valueOf(objMinutes.LAT_Value__c));
            scheduleRetryJob(datNextRun);
            updateCurrentBlock(datNextRun);
        }

        System.debug('updateSiteStatus [] <-');
    }

    public static void scheduleRetryJob(DateTime datTime) {
        LAT_CTY_B2B_ProcessBlock_Schedulable objSchedule = null;
        String strScheduleName = null;
        String strCRON = null;

    	System.debug('scheduleRetryJob [datTime : ' + datTime + '] ->');

        strScheduleName = String.format('LAT_CTY_B2B_ProcessBlock_Schedulable_{0}', new String[] { datTime.format('yyyyMMddHHmm') } );
        objSchedule = new LAT_CTY_B2B_ProcessBlock_Schedulable();

        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        strCRON = String.format('0 {0} {1} {2} {3} ? {4}', new String[] {String.valueOf(datTime.minute()), String.valueOf(datTime.hour()), String.valueOf(datTime.day()),String.valueOf(datTime.month()), String.valueOf(datTime.year()) });
        System.debug('scheduleRetryJob [strScheduleName : ' + strScheduleName + ']');
        System.debug('scheduleRetryJob [strCRON : ' + strCRON + ']');
 
        if([SELECT Id FROM CronJobDetail WHERE Name =:strScheduleName].isEmpty()) {
	        System.schedule(strScheduleName, strCRON, objSchedule);           
        } else {
            LAT_Utils.handleException('scheduleRetryJob', 'Ya se ha registrado una tarea para esa hora');
        }
 
        System.debug('scheduleRetryJob [] <-');
    }

    private static void updateCurrentBlock(DateTime datTime) {
        List<LAT_CTY_B2B_Settings__c> lstSettings = null;
        DateTime datFrom = null;
        DateTime datTo = null;

        System.debug('updateCurrentBlock [datTime : ' + datTime + '] ->');

        datTo = DateTime.now();
        datFrom = datTo.addMinutes(-5);

        lstSettings = [SELECT Id, LAT_CTY_B2B_Blocked_To__c
                        FROM LAT_CTY_B2B_Settings__c
                        WHERE LAT_CTY_B2B_Blocked_To__c >= :datFrom
                        AND LAT_CTY_B2B_Blocked_To__c <= :datTo
                        AND LAT_CTY_B2B_Active__c = TRUE];

        System.debug('updateCurrentBlock [NextRun : ' + datTime + ']');
        System.debug('updateCurrentBlock [RangoFrom : ' + datFrom + ']');
        System.debug('updateCurrentBlock [RangeTo : ' + datTo + ']');
        
        for(LAT_CTY_B2B_Settings__c objSettings : lstSettings) {
            objSettings.LAT_CTY_B2B_Blocked_To__c = datTime;
        }

        //todos los bloqueos que hayan finalizado en los ultimos 5 minutos 
        //los extiendo x minutos mas
        update lstSettings;

        System.debug('updateCurrentBlock [] <-');
    }
}