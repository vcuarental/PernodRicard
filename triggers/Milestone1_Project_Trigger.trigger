trigger Milestone1_Project_Trigger on Milestone1_Project__c (before update, before delete, before insert, after insert) {
    
    if(Trigger.isUpdate){
        
        RIC_AP01_Milestone1Project.checkProjectEditPermission(trigger.oldMap, trigger.new);
        //TODO can we delete this?
        Milestone1_Project_Trigger_Utility.handleProjectUpdateTrigger(trigger.new);
    } 
    else if(Trigger.isDelete) {
        /*if(Trigger.isBefore) {
            Schema.DescribeSObjectResult result = Milestone1_Project__c.SObjectType.getDescribe();
            String coordinateurId = trigger.old[0].RIC_Coordinateur__c;
            if(!UserInfo.getUserId().equals(coordinateurId)) {
                trigger.old[0].addError(Label.RIC_Project_Delete_Error);
            }
        }*/
        //cascades through milestones
        //Milestone1_Project_Trigger_Utility.handleProjectDeleteTrigger(trigger.old);
    }
    else if(Trigger.isInsert) {
        if(Trigger.isBefore) {
        	//checks for duplicate names
        	Milestone1_Project_Trigger_Utility.handleProjectInsertTrigger( trigger.new );
        }
        else if(Trigger.isAfter) {
            RIC_AP01_Milestone1Project.shareProjectWithCoordinator(null, trigger.newMap, false);
        }
    }

}