trigger MMPJ_Ext_Vign_VolumeBF_Before_Update on MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c (before update) {
	for(MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c doc:trigger.new)
	{
		if(!String.isEmpty(doc.MMPJ_Ext_Vign_Document__c) && doc.MMPJ_Ext_Vign_Document__c.contains('blob.core.windows.net') && doc.MMPJ_Ext_Vign_Document__c != Trigger.oldMap.get(doc.Id).MMPJ_Ext_Vign_Document__c)
		{
			try{
				String milieux = doc.MMPJ_Ext_Vign_Document__c.substringAfter('blob.core.windows.net/').substringBefore('/');
				doc.MMPJ_Ext_Vign_BlobContainer__c = milieux;

				milieux = '/' + milieux + '/';
				doc.MMPJ_Ext_Vign_BlobAccount__c = doc.MMPJ_Ext_Vign_Document__c.substringBeforeLast(milieux);
				doc.MMPJ_Ext_Vign_BlobFile__c = doc.MMPJ_Ext_Vign_Document__c.substringAfterLast(milieux);
			} catch(Exception ex) {}
		} else if(String.isEmpty(doc.MMPJ_Ext_Vign_Document__c))
		{
			doc.MMPJ_Ext_Vign_BlobContainer__c = '';
			doc.MMPJ_Ext_Vign_BlobAccount__c = '';
			doc.MMPJ_Ext_Vign_BlobFile__c = '';
		}
	}
}