/**
 * GDT_CheckFileExtension_ContentDocument_AfterUpdate
 * Event(s) - After Update
 * Object   - ContentDocument
 */
trigger GDT_CheckFileExtension_ContentDocument_AfterUpdate on ContentDocument (after update) {
	System.debug('START Trigger GDT_CheckFileExtension_ContentDocument_AfterUpdate'); 

	// isRunningTest()
	// Returns true if the currently executing code was called by code contained in a test method, false otherwise.    
	//if(!Test.isRunningTest()){

		// Check if there are restrictions (CustomSettings)
		if([SELECT count() FROM GDT_CheckFileExtension_Extension__c WHERE GDT_CheckFileExtension_ObjectAPIName__c = 'ContentDocument'] > 0) {


			/* Variables Declaration */
			System.debug('TRIIGER NEW[0] : ' + Trigger.new[0]);
			ContentDocument contentDocumentToBeRestricted  = Trigger.new[0];

			List<GDT_CheckFileExtension_Extension__c> lstCustomSettingsExtension = [SELECT GDT_CheckFileExtension_FileExtension__c, GDT_CheckFileExtension_FileType__c FROM GDT_CheckFileExtension_Extension__c WHERE GDT_CheckFileExtension_ObjectAPIName__c = 'ContentDocument'];
			System.debug('LIST CUSTOMSETTINGS EXTENSION: ' + lstCustomSettingsExtension);


			/* Restriction CustomSetting */
			for(GDT_CheckFileExtension_Extension__c cs : lstCustomSettingsExtension){ 
				System.debug('FOR CS: ' + cs);
				
				// File Extension
				if(contentDocumentToBeRestricted.FileExtension == cs.GDT_CheckFileExtension_FileExtension__c) {
					System.debug('ADD ERROR');
					Trigger.new[0].addError(Label.GDT_CheckFileExtension_ErrorMessage + ' (.'+ contentDocumentToBeRestricted.FileExtension +')');
				
				// File Type
				} else if (contentDocumentToBeRestricted.FileType == cs.GDT_CheckFileExtension_FileType__c) {
					System.debug('ADD ERROR');
					Trigger.new[0].addError(Label.GDT_CheckFileExtension_ErrorMessage + ' (.'+ contentDocumentToBeRestricted.FileType +')');
				}
			}
			
		}
		
	//}
	System.debug('END Trigger GDT_CheckFileExtension_ContentDocument_AfterUpdate');
}