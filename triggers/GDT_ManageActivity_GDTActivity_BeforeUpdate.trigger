/**
 * Name     :   GDT_ManageActivity_GDTActivity_BeforeUpdate.trigger
 *  Before update an Activity
 *
 * Author   :   Simon GAZIN
 * Date     :   18.11.2014
 *
 ********************************************************************/
trigger GDT_ManageActivity_GDTActivity_BeforeUpdate on GDT_Activity__c (before update) {
	
	if(!Test.isRunningTest()){

		GDT_ManageActivity recordAct = new GDT_ManageActivity();
		
		//Call UpdateIncident(), on ApexClass GDT_ManageActivity
		recordAct.UpdateIncident(trigger.new[0]);

		//Call CheckStatus(), on ApexClass GDT_ManageActivity
		recordAct.CheckStatus(trigger.new[0]);

		//Call RecordFormat(), on ApexClass GDT_ManageActivity
		recordAct.RecordFormat(trigger.new[0]);
	}
}