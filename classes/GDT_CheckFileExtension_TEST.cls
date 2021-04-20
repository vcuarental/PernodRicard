@isTest
private class GDT_CheckFileExtension_TEST {
	
	/**
	 * myMethod_Setup
	 * Creation of records for the test class
	 */
	@testSetup static void myMethod_Setup(){
		
		/* Variable Declaration */
		GDT_CheckFileExtension_Extension__c csfi = new GDT_CheckFileExtension_Extension__c();
			csfi.Name = 'Feeditem.exe';
			csfi.GDT_CheckFileExtension_FileExtension__c = 'exe';
			csfi.GDT_CheckFileExtension_ObjectAPIName__c = 'FeedItem';

		GDT_CheckFileExtension_Extension__c cscd = new GDT_CheckFileExtension_Extension__c();
			cscd.Name = 'ContentDocument.exe';
			cscd.GDT_CheckFileExtension_FileExtension__c = 'exe';
			cscd.GDT_CheckFileExtension_ObjectAPIName__c = 'ContentDocument';
		
		GDT_CheckFileExtension_Extension__c cscv = new GDT_CheckFileExtension_Extension__c();
			cscv.Name = 'ContentVersion.exe';
			cscv.GDT_CheckFileExtension_FileExtension__c = 'exe';
			cscv.GDT_CheckFileExtension_ObjectAPIName__c = 'ContentVersion';
		
		/* Insert Records */
		try { insert csfi; } catch (Exception e)  {System.debug(e.getMessage()); }
		try { insert cscd; } catch (Exception e)  {System.debug(e.getMessage()); }
		try { insert cscv; } catch (Exception e)  {System.debug(e.getMessage()); }
		
	}

	/**
	 * myUnitTest_FeedItem_ContentDocument
	 * Starts the Trigger (FeedItem - ContentDocument)
	 */
	@isTest static void myUnitTest_CheckFileExtension() {

		/* Variable Declatation */
		ContentVersion cvTxt = new ContentVersion();
		ContentVersion cvExe = new ContentVersion();
		ContentVersion cv = new ContentVersion();
		Feeditem fi = new FeedItem();

		try {
			cvTxt.Title = 'FileTEST Txt';
			cvTxt.PathOnClient = 'FileTEST.txt';
			cvTxt.VersionData =  Blob.valueOf('String To Blob');

			insert cvTxt;    

			try {
				fi.Body = 'This is content of my post';
				fi.RelatedRecordId = cvTxt.Id;
				fi.ParentId = UserInfo.getUserId();

				insert fi;

				List<Feeditem> lstFi = [SELECT Id, Body FROM Feeditem WHERE Id = :fi.Id];
				System.assertEquals(1, lstFi.size());
			}
			catch (Exception e) {
				System.debug(e.getMessage());
			} 
		}
		catch (Exception e) {
			System.debug(e.getMessage());
		}

		/* Exe Extension */
		try {
			cvExe.Title = 'FileTEST Exe';
			cvExe.PathOnClient = 'FileTEST.exe';
			cvExe.VersionData =  Blob.valueOf('String To Blob');

			insert cvExe;    
		}
		catch (Exception e) {
			System.debug(e.getMessage());
		}

		/* Empty Extension */
		try {
			cv.Title = 'FileTEST';
			cv.PathOnClient = 'FileTEST.exe';
			cv.VersionData =  Blob.valueOf('String To Blob');

			insert cv;    
		}
		catch (Exception e) {
			System.debug(e.getMessage());
		}
	}
	
}