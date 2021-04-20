trigger MMPJ_Ext_Vign_Facture_Before_Insert on MMPJ_Ext_Vign_Facture__c (before insert) {
	for(MMPJ_Ext_Vign_Facture__c doc:trigger.new)
	{
		if(!String.isEmpty(doc.MMPJ_Ext_Vign_Document__c) && doc.MMPJ_Ext_Vign_Document__c.contains('blob.core.windows.net'))
		{
			try{
				String milieux = doc.MMPJ_Ext_Vign_Document__c.substringAfter('blob.core.windows.net/').substringBefore('/');
				doc.MMPJ_Ext_Vign_BlobContainer__c = milieux;

				milieux = '/' + milieux + '/';
				doc.MMPJ_Ext_Vign_BlobAccount__c = doc.MMPJ_Ext_Vign_Document__c.substringBeforeLast(milieux);
				doc.MMPJ_Ext_Vign_BlobFile__c = doc.MMPJ_Ext_Vign_Document__c.substringAfterLast(milieux);
			} catch(Exception ex) {}
		}
	}
}