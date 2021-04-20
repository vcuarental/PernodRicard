/**
 * GDT_CheckFileExtension_FeedItem_BeforeAfterInsert
 * Event(s) - Before Insert - After Insert
 * Object   - FeedItem
 */
trigger GDT_CheckFileExtension_FeedItem_BeforeAfterInsert on FeedItem (before insert, after insert) {
	System.debug('START Trigger GDT_CheckFileExtension_FeedItem_BeforeAfterInsert');

	// isRunningTest()
	// Returns true if the currently executing code was called by code contained in a test method, false otherwise.    
	//if(!Test.isRunningTest()){

		// Check if there are restrictions (CustomSettings)
		if([SELECT count() FROM GDT_CheckFileExtension_Extension__c WHERE GDT_CheckFileExtension_ObjectAPIName__c = 'FeedItem'] > 0) {
		 
			/* Variables Declaration */
			List<FeedItem> lstFeedItemToBeRestricted = trigger.New;
			List<GDT_CheckFileExtension_Extension__c> lstCustomSettingsExtension = [SELECT GDT_CheckFileExtension_FileExtension__c FROM GDT_CheckFileExtension_Extension__c WHERE GDT_CheckFileExtension_ObjectAPIName__c = 'FeedItem'];
			
			System.debug('LIST FEEDITEM: ' + trigger.new);
			System.debug('LIST CUSTOMSETTINGS EXTENSION: ' + lstCustomSettingsExtension);
			
			/* Object FeedItem */
			for(FeedItem fi : lstFeedItemToBeRestricted){ 
				
				List<ContentVersion> lstContentVersion = [SELECT Id, fileExtension FROM ContentVersion WHERE Id =: fi.RelatedRecordId];
				System.debug('LIST CONTENT VERSION: ' + lstContentVersion);

				/* Restriction CustomSetting */
				for(ContentVersion cv : lstContentVersion){
					for(GDT_CheckFileExtension_Extension__c cs : lstCustomSettingsExtension){ 
						System.debug('FOR CS: ' + cs);
						
						// File Extension
						if(cv.FileExtension == cs.GDT_CheckFileExtension_FileExtension__c) {
							System.debug('ADD ERROR');
							Trigger.new[0].addError(Label.GDT_CheckFileExtension_ErrorMessage + ' (.'+ cv.FileExtension +')');
						}
					}
				}
			}
		}
		
	//}
	
	System.debug('END Trigger GDT_CheckFileExtension_FeedItem_BeforeAfterInsert');
}