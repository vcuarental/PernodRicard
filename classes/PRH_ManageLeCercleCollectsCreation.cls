// Le Cercle application - evolution LCS-153 - July 2017
// Creation batch of Le Cercle collects
// 2 jobs are scheduled in order to create collects and their data :
// System.Schedule('Creation of Le Cercle collects', '0 13 11 * * ? *', new PRH_BatchLeCercleCollectsCreation());
// System.Schedule('Creation of Competitor and Le Cercle Brands for Le Cercle collects', '0 29 11 * * ? *', new PRH_BatchLeCercleCollectsDataCreation());

// ***** IMPORTANT INFORMATION *****
// These classes PRH_ManageLeCercleCollectsCreation and PRH_ManageLeCercleCollectsDataCreation replace previous one listed below that are kept 
// in case of an issue with this new implementation :
// - System.Schedule('Creation of Le Cercle collects', '0 13 17 * * ? *', new PRH_ManageCollectsForIconicAcc());
// - System.Schedule('Creation of Brands for collects', '0 03 11 * * ? *', new PRH_ScheduleBatchBRCreationForCollects());
global class PRH_ManageLeCercleCollectsCreation implements Database.Batchable<sObject>, Database.Stateful {

    public String Query;
   
    public Date todayDate = system.today();
	public Integer currentDay = todayDate.day();
	public Integer currentMonth = todayDate.month();
	public Integer currentYear = todayDate.year();
	public Date PRH_PeriodStartDate;
	public Date PRH_PeriodEndDate;
	public Date PRH_PeriodStartDatePreviousCollect;
	public Integer PRH_NbOfNewCollects;
	public List<PRH_Collect__c> listOfNewCollects;
	public List<PRH_Collect__c> listOfCollectsToDeactivate;
	public PRH_Collect__c newCollect;
	public Integer nextStep = 0;
    
    public void setNextStep(Integer val) {
        nextStep = val;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Retrieve current date
        System.debug('**************************** PRH_ManageLeCercleCollectsCreation Execution started ****************************');
		System.debug('=> PRH_ManageLeCercleCollectsCreation, start current date :' + system.today().format());
		
		// Define Start and End date for new collects to create regarding current date
		if (Test.isRunningTest()) {
			if (nextStep == 0) {
				currentDay = 07;
				currentMonth = 05;
				currentYear = 2017;
			} else if (nextStep == 1) {
				currentDay = 07;
				currentMonth = 09;
				currentYear = 2017;
			} else if (nextStep == 2) {
				currentDay = 07;
				currentMonth = 12;
				currentYear = 2017;
			} else if (nextStep == 3) {
				currentDay = 07;
				currentMonth = 01;
				currentYear = 2018;
			} 
		}
		if ((currentMonth >= 3) && (currentMonth <= 6)) {
			if (Test.isRunningTest()) {
				PRH_PeriodStartDate = date.newInstance(2017, 03, 01);
				PRH_PeriodEndDate = date.newInstance(2017, 06, 30);
				PRH_PeriodStartDatePreviousCollect = date.newInstance(2016, 11, 01);
			} else {
				PRH_PeriodStartDate = date.newInstance(currentYear, 03, 01);
				PRH_PeriodEndDate = date.newInstance(currentYear, 06, 30);
				PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear-1, 11, 01);
			}
		} else if ((currentMonth >= 7) && (currentMonth <= 10)) {
			if (Test.isRunningTest()) {
				PRH_PeriodStartDate = date.newInstance(2017, 07, 01);
				PRH_PeriodEndDate = date.newInstance(2017, 10, 31);
				PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 03, 01);
			} else {
				PRH_PeriodStartDate = date.newInstance(currentYear, 07, 01);
				PRH_PeriodEndDate = date.newInstance(currentYear, 10, 31);
				PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear, 03, 01);
			}
		} else if ((currentMonth == 11) || (currentMonth == 12)) {
			if (Test.isRunningTest()) {
				PRH_PeriodStartDate = date.newInstance(2017, 11, 01);
				PRH_PeriodEndDate = date.newInstance(2018, 02, 28);
				PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 07, 01);
			} else {
				if (Date.isLeapYear(currentYear+1) == true) { // next year is a leap year
					PRH_PeriodEndDate = date.newInstance(currentYear+1, 02, 29);
				} else {
					PRH_PeriodEndDate = date.newInstance(currentYear+1, 02, 28);
				}
				PRH_PeriodStartDate = date.newInstance(currentYear, 11, 01);  // year, month, day
				PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear, 07, 01);
			}
		} else if ((currentMonth == 1) || (currentMonth == 2)) {
			if (Test.isRunningTest()) {
				PRH_PeriodStartDate = date.newInstance(2017, 11, 01);
				PRH_PeriodEndDate = date.newInstance(2018, 02, 28);
				PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 07, 01);
			} else {
				if (Date.isLeapYear(currentYear) == true) { // this is a leap year
					PRH_PeriodEndDate = date.newInstance(currentYear, 02, 29);
				} else {
					PRH_PeriodEndDate = date.newInstance(currentYear, 02, 28);
				}
				PRH_PeriodStartDate = date.newInstance(currentYear-1, 11, 01);  // year, month, day
				PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear-1, 07, 01);
			}
		}
		System.debug('=> PRH_ManageLeCercleCollectsCreation, PRH_PeriodStartDate=' + PRH_PeriodStartDate + ', PRH_PeriodEndDate='  + PRH_PeriodEndDate);
		
		// Define query for retrieving the list of active collects linked to Iconic Accounts not in state suppress
		//this.Query = 'SELECT id, PRH_Iconic_Account__c, PRH_Full_Active_Le_Cercle_Portfolio__c, PRH_Number_of_Pernod_Ricard_products__c, PRH_Collect_Last_Modified_Date__c, PRH_Le_Cercle_Brand_Presence__c FROM PRH_Collect__c WHERE PRH_Active__c=true AND PRH_Period_Start__c = :PRH_PeriodStartDatePreviousCollect AND PRH_Iconic_Account__c IN (SELECT id FROM PRH_Luxury_Accounts__c WHERE PRH_Suppress_and_archive__c=false)';
		this.Query = 'SELECT id, PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c, PRH_Collect_Last_Modified_Date__c, PRH_Le_Cercle_Brand_Presence__c FROM PRH_Collect__c WHERE PRH_Active__c=true AND PRH_Period_Start__c = :PRH_PeriodStartDatePreviousCollect AND PRH_Iconic_Account__c IN (SELECT id FROM PRH_Luxury_Accounts__c WHERE PRH_Suppress_and_archive__c=false)';
		System.debug('=> PRH_ManageLeCercleCollectsCreation, Query=' + this.Query);

		return Database.getQueryLocator(this.Query);
    }

    public void execute(Database.BatchableContext BC, List<PRH_Collect__c> previousCollectsList){
        this.listOfNewCollects = new List<PRH_Collect__c >();
		this.listOfCollectsToDeactivate = new List<PRH_Collect__c >();
        
        try {
        	if (previousCollectsList.size() > 0) {
	            System.debug('PRH_ManageLeCercleCollectsCreation, previousCollectsList.size=' + previousCollectsList.size());

				for (PRH_Collect__c pc:previousCollectsList) {
					// Create new active collect with info of previous collect and date of collect
					newCollect = new PRH_Collect__c( 
													PRH_Active__c=true, 
													PRH_Iconic_Account__c=pc.PRH_Iconic_Account__c, 
													//PRH_Full_Active_Le_Cercle_Portfolio__c=pc.PRH_Full_Active_Le_Cercle_Portfolio__c,
													PRH_Number_of_Pernod_Ricard_products__c=pc.PRH_Number_of_Pernod_Ricard_products__c,
													PRH_Collect_Last_Modified_Date__c=pc.PRH_Collect_Last_Modified_Date__c,
													PRH_Le_Cercle_Brand_Presence__c=pc.PRH_Le_Cercle_Brand_Presence__c,
													PRH_Period_Start__c=PRH_PeriodStartDate, 
													PRH_Period_End__c=PRH_PeriodEndDate); 
					//System.debug('==> PRH_ManageLeCercleCollectsCreation, newCollect = ' + newCollect);	
					this.listOfNewCollects.add(newCollect);
				}

				if (this.listOfNewCollects.size() > 0) {
					insert listOfNewCollects; 
					this.PRH_NbOfNewCollects = this.listOfNewCollects.size();
					System.debug('==> PRH_ManageLeCercleCollectsCreation, ' + this.PRH_NbOfNewCollects + ' new collects have been created');
				}

				for (PRH_Collect__c c:previousCollectsList) {
					c.PRH_Active__c = false;
					this.listOfCollectsToDeactivate.add(c);
				}

				if (this.listOfCollectsToDeactivate.size() > 0) {
					update this.listOfCollectsToDeactivate; 
					System.debug('==> PRH_ManageLeCercleCollectsCreation, ' + this.listOfCollectsToDeactivate.size() + ' collects have been deactivated');
				}
			}
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
        }	
    }

    public void finish(Database.BatchableContext BC) {
       
    }
}