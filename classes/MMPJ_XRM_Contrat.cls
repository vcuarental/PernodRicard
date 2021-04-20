public with sharing class MMPJ_XRM_Contrat {
	public static void createRelationship(List<MMPJ_Ext_Vign_Contrat__c> contrats) {
		Set<String> cles = new Set<String>();
		for(MMPJ_Ext_Vign_Contrat__c con:contrats)
		{
			if(con.MMPJ_Ext_Vign_Livreur__c != null && con.MMPJ_Ext_Vign_Courtier__c != null && con.MMPJ_Ext_Vign_Livreur__c != con.MMPJ_Ext_Vign_Courtier__c)
				cles.add(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_Ext_Vign_Courtier__c);

			if(con.MMPJ_Ext_Vign_Livreur__c != null && con.MMPJ_XRM_Pressoir__c != null && con.MMPJ_XRM_Pressoir__c != con.MMPJ_Ext_Vign_Livreur__c)
				cles.add(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_XRM_Pressoir__c);
		}

		//System.debug('Cles=' + cles);

		for(MMPJ_XRM_RelationSociete__c rel:[select MMPJ_XRM_Cle__c from MMPJ_XRM_RelationSociete__c where MMPJ_XRM_Cle__c IN:cles])
			if(cles.contains(rel.MMPJ_XRM_Cle__c))
				cles.remove(rel.MMPJ_XRM_Cle__c);

		//System.debug('Cles restantes=' + cles);
		List<MMPJ_XRM_RelationSociete__c> relations = new List<MMPJ_XRM_RelationSociete__c>();
		for(String c:cles)
			relations.add(new MMPJ_XRM_RelationSociete__c(MMPJ_XRM_Livreur__c=c.left(18),MMPJ_XRM_Societe_liee__c=c.right(18)));

		if(relations.size() > 0)
			insert relations;
	}
}