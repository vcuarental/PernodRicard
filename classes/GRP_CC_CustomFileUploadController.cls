public without sharing class GRP_CC_CustomFileUploadController {

	@AuraEnabled
	public static void renameFiles(List<String> idFiles, String prefix)
	{

		List<ContentDocument> fichiers = [SELECT Id, Title FROM ContentDocument WHERE id IN:idFiles];
		for (ContentDocument fichier : fichiers) {
			fichier.Title = prefix + fichier.Title;
		}

		update fichiers;
	}
}