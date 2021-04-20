trigger ESNProjectTrigger on ESNProject__c (before insert, before update) {

    ESNProjectTriggerHandler handler = new ESNProjectTriggerHandler(Trigger.isExecuting, Trigger.size);
    ESNProject__c projectLastVersion = trigger.new.get(Trigger.new.size()-1);
    
    /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        /* Trigger Sync */
        Database.SaveResult[] lsr = handler.OnAfterInsert(Trigger.new);
    
        // Create counter
        Integer i=0;        
        // Process the save results
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error     
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level Access levels equal or more permissive than the object's default      
                // access level are not allowed.      
                // These sharing records are not required and thus an insert exception is acceptable.      
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.     
                    trigger.newMap.get(projectLastVersion.Id).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }
    }
    
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){          
        Database.SaveResult[] listResults;          
        // Get the list of the project share already existing
        List<ESNProject__Share> listProjectShares = [SELECT Id FROM ESNProject__Share WHERE ParentId = :projectLastVersion.Id];
        
        if(listProjectShares.size() == 1){
            listResults = handler.OnAfterInsert(Trigger.new);
        }else{
            system.debug('#### before update');
            listResults = handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap); 
        }   
        // Create counter
        Integer i=0;        
        // Process the save results
        for(Database.SaveResult result : listResults){
            if(!result.isSuccess()){ 
                Database.Error err = result.getErrors()[0];     
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                    trigger.newMap.get(projectLastVersion.Id).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }
    }
}