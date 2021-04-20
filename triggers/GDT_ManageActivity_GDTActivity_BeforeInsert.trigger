/**
 * Name     :   GDT_ManageActivity_GDTActivity_BeforeInsert.trigger
 *  Before insert an Activity
 *
 * Author   :   Simon GAZIN
 * Date     :   27.05.2014
 *
 ********************************************************************/
trigger GDT_ManageActivity_GDTActivity_BeforeInsert on GDT_Activity__c (before insert) {
	
	if(!Test.isRunningTest()){

		GDT_ManageActivity recordAct = new GDT_ManageActivity();
		
		//Call ResetCounter(), on ApexClass GDT_ManageActivity
		recordAct.ResetCounter(trigger.new[0]);
		
		//Call EditName(), on ApexClass GDT_ManageActivity
		recordAct.EditName(trigger.new[0]);

		//Call CreateIncident(), on ApexClass GDT_ManageActivity
		recordAct.CreateIncident(trigger.new[0]);

		//Call RecordFormat(), on ApexClass GDT_ManageActivity
		recordAct.RecordFormat(trigger.new[0]);
	}
}