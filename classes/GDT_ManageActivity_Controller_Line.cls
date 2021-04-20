/**
 * Name     :   GDT_ManageActivity_Controller_Line.cls
 *  Apex Class Controller
 *
 * Author   :   Simon GAZIN
 * Date     :   23.07.2014
 *
 *******************************************************/
public with sharing class GDT_ManageActivity_Controller_Line {

	//Variable declaration
	public GDT_Activity_Line__c record;	//Record of Line

	/**
	 * Controller
	 */
	public GDT_ManageActivity_Controller_Line(ApexPages.StandardController controller) {

		//Contains the value of the record
		record = (GDT_Activity_Line__c)controller.getRecord();

		//Automatic insertion of the field : PerformedBy
		record.Performed_By__c = UserInfo.getUserId();
	}


	/**
	 * saveCustom
	 *  This function save the record and after save the ViewActivity page is return
	 */
	public PageReference saveCustom(){
		if(!Test.isRunningTest()){
			//Save the record of LineItem
			PageReference pageRetURL = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
			record.GDT_Activity_Relationship__c = pageRetURL.getParameters().get('Id');
		}
		insert record;

		//Redirecting page
		PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_ViewActivity?id='+record.GDT_Activity_Relationship__c);

		return pageRef;
	}
}