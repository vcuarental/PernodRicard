trigger MMPJ_Ext_Vign_Document_Before_Insert on MMPJ_Ext_Vign_Documents_Fournis__c (before insert) {
	for(MMPJ_Ext_Vign_Documents_Fournis__c doc:trigger.new)
	{
		/*if(doc.MMPJ_Ext_Vign_Document__c.contains('blob.core.windows.net') && doc.MMPJ_Ext_Vign_Document__c.contains('/spirit1/'))
		{
			try{
				doc.MMPJ_Ext_Vign_BlobAccount__c = doc.MMPJ_Ext_Vign_Document__c.substringBeforeLast('/spirit1/');
				doc.MMPJ_Ext_Vign_BlobContainer__c = 'spirit1';
				doc.MMPJ_Ext_Vign_BlobFile__c = doc.MMPJ_Ext_Vign_Document__c.substringAfterLast('/spirit1/');
			} catch(Exception ex) {}
		}*/

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