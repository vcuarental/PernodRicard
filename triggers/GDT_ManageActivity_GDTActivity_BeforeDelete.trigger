/**
 * Name     :   GDT_ManageActivity_GDTActivity_BeforeDelete.trigger
 *  Before delete an Activity
 *
 * Author   :   Simon GAZIN
 * Date     :   19.11.2014
 *
 ********************************************************************/
trigger GDT_ManageActivity_GDTActivity_BeforeDelete on GDT_Activity__c (before delete) {

	if(!Test.isRunningTest()){
		GDT_ManageActivity recordAct = new GDT_ManageActivity();
		//Call DeleteIncident(), on ApexClass GDT_ManageActivity
		recordAct.DeleteIncident(trigger.old[0]);
	}
}