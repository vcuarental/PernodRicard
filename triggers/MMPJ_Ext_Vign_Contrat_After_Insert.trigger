trigger MMPJ_Ext_Vign_Contrat_After_Insert on MMPJ_Ext_Vign_Contrat__c (after insert) {
	List<MMPJ_Ext_Vign_Contrat__c> contrats = new List<MMPJ_Ext_Vign_Contrat__c>();
	for(MMPJ_Ext_Vign_Contrat__c con:trigger.new)
		if(con.MMPJ_XRM_Pressoir__c != null || con.MMPJ_Ext_Vign_Courtier__c != null)
			contrats.add(con);

	if(contrats.size() > 0)
		MMPJ_XRM_Contrat.createRelationship(contrats);
}