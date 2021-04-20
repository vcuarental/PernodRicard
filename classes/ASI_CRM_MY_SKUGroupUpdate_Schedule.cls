global class ASI_CRM_MY_SKUGroupUpdate_Schedule implements Schedulable {
    
    public ASI_CRM_MY_SKUGroupUpdate_Schedule(){
        updateSKUGroup();
    }
    
	global void execute(SchedulableContext sc) {
		updateSKUGroup();
	}
    
     public void updateSKUGroup(){
        database.executebatch(new ASI_CRM_MY_SKUGroupUpdate_Batch());
    }
    
}