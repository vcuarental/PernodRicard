/**
 * GDT_CheckFileExtension_ContentVersion_AfterInsert
 * Event(s) - After Insert
 * Object   - ContentVersion
 */
trigger GDT_CheckFileExtension_ContentVersion_AfterInsert on ContentVersion (after insert) {
    System.debug('START Trigger GDT_CheckFileExtension_ContentVersion_AfterInsert'); 

    // isRunningTest()
    // Returns true if the currently executing code was called by code contained in a test method, false otherwise.    
    //if(!Test.isRunningTest()){
    // Check if there are restrictions (CustomSettings)
    if([SELECT count() FROM GDT_CheckFileExtension_Extension__c WHERE GDT_CheckFileExtension_ObjectAPIName__c = 'ContentVersion'] > 0) {
            
        /* Variables Declaration */
        List<ContentVersion> lstContentVersionToBeRestricted = trigger.New;
        //Trigger.new[0].addError('Dans le trigger ' + lstContentVersionToBeRestricted[0]);
        
        for(ContentVersion cv : lstContentVersionToBeRestricted){
        
            //ContentVersion contentVersionToBeRestricted  = [SELECT FileExtension,FileType,Id FROM ContentVersion WHERE Id = :docId];
            List<GDT_CheckFileExtension_Extension__c> lstCustomSettingsExtension = [SELECT GDT_CheckFileExtension_FileExtension__c, GDT_CheckFileExtension_FileType__c FROM GDT_CheckFileExtension_Extension__c WHERE GDT_CheckFileExtension_ObjectAPIName__c = 'ContentVersion'];

            for(GDT_CheckFileExtension_Extension__c cs : lstCustomSettingsExtension){
                
                // File Type 
                if(cv.FileType == cs.GDT_CheckFileExtension_FileType__c) { 
                    System.debug('ADD ERROR');
                    Trigger.new[0].addError(Label.GDT_CheckFileExtension_ErrorMessage + ' (.'+ cv.FileType +')');
                
                // File Extension
                } else if(cv.FileExtension == cs.GDT_CheckFileExtension_FileExtension__c) {
                    System.debug('ADD ERROR');
                    Trigger.new[0].addError(Label.GDT_CheckFileExtension_ErrorMessage + ' (.'+ cv.FileExtension +')');
                }
            }
        }
        
    //}
    }
    System.debug('END Trigger GDT_CheckFileExtension_ContentVersion_AfterInsert');
}