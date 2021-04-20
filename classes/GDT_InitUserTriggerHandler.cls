/**
 * @name GDT_InitUserTriggerHandler
 * @description
 * Class that extends from GDT_TriggerHandler and overrides the methods for the desired actions.
 * Ex. beforeInsert, afterUpdate
 * @author Bruno Vuono
 */
 public with sharing class GDT_InitUserTriggerHandler extends GDT_TriggerHandler{
	
 	/**
     * Before Insert method. 
       Calls the GDT init user logic && ESN AssignChatterEmailSettings method.
     */
	public override void beforeInsert(){
		//Instanciate the GDT_InitUser class that contains the logic to process the users
		GDT_InitUser_Class initUserInstance = new GDT_InitUser_Class();
		//Method to init the class(instanciate lists, maps and populate with the custom settings records)
		initUserInstance.initTrigger();
		//Check the flag to execute or not the GDT init user process
	    if(!Test.isRunningTest()){
	    	System.debug('trigger GDT_InitUser_User_BeforeInsert'); 
	    	//Executes the GDT before insert logic that includes: AssignRole, AssignProfile
		    initUserInstance.InitUserBefore(trigger.new);
	    }  
		//Populate some ESN fields on the inserted users
		initUserInstance.AssignChatterEmailSettings(trigger.new);
	}

	/**
     * After Insert method. 
       Calls the After insert GDT init user logic && ESN Autofollow_User method.
     */
	public override void afterInsert(){
		//Instanciate the GDT_InitUser class that contains the logic to process the users
		GDT_InitUser_Class initUserInstance = new GDT_InitUser_Class();
		//Method to init the class(instanciate lists, maps and populate with the custom settings records)
		initUserInstance.initTrigger();
		//Check the flag to execute or not the GDT init user process
		if(!Test.isRunningTest()){
			System.debug('trigger GDT_InitUser_User_AfterInsert'); 
			//Executes the GDT after insert logic that includes: AssignChatterGroup, AssignPermissionSets, AssignPublicGroup
			initUserInstance.InitUserAfter(trigger.oldMap,trigger.newMap);
		}
		//Execute ESN autofollow logic
		initUserInstance.Autofollow_User(trigger.oldMap, trigger.newMap);
	}

	/**
     * Before Update method. 
       Calls the ESN Autofollow_User method.
       The GDT statemens are only for Staging
		To remove on PD.
     */
	public override void beforeUpdate(){
		GDT_InitUser_Class initUserInstance = new GDT_InitUser_Class();
		initUserInstance.initTrigger();

		//Execute ESN autofollow logic
		initUserInstance.Autofollow_User(trigger.oldMap, trigger.newMap);
		initUserInstance.autoFreeze(trigger.oldMap, trigger.newMap);

		initUserInstance.reInitUsers(trigger.oldMap, trigger.newMap);

	}

	/**
     * After Update method. 
       The GDT statemens are only for Staging
	   To remove on PD.
     */
	public override void afterUpdate(){
		
	}


}