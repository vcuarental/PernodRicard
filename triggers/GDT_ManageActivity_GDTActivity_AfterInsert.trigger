/**
 * Name     :   GDT_ManageActivity_GDTActivity_AfterInsert.trigger
 *  After insert an Activity
 *
 * Author   :   Simon GAZIN
 * Date     :   27.05.2014
 *
 ********************************************************************/
trigger GDT_ManageActivity_GDTActivity_AfterInsert on GDT_Activity__c (after insert) {

	if(!Test.isRunningTest()){
		GDT_ManageActivity recordAct = new GDT_ManageActivity();
		//Call UpdateCounter(), on ApexClass GDT_ManageActivity
		recordAct.UpdateCounter(trigger.new[0]);
	}
}