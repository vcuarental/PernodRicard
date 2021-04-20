trigger GDT_InitUser_User_Trigger on User (before insert, before update, before delete,
	after insert, after update, after delete, after undelete) {
	List<String> GDT_InitUser_isActiveFlags = GDT_GeneralConfigDAO.getValueAsStringArray('GDT_InitUser_isActive', ',');
	if(GDT_InitUser_isActiveFlags != null && GDT_InitUser_isActiveFlags.size() > 0 && GDT_InitUser_isActiveFlags[0] == 'true'){
		if(!Test.isRunningTest()){
			new GDT_InitUserTriggerHandler().run();
		}
	}
}