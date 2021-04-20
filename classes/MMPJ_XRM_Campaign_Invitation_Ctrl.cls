public with sharing class MMPJ_XRM_Campaign_Invitation_Ctrl {
	public Id campaignId{get;set;}
	public Boolean actionDone{get;set;}
	public String segmentation{get;set;}
	public String errorMessage{get;set;}
	public MMPJ_XRM_Campaign_Invitation_Ctrl() {
		this.campaignId = ApexPages.currentPage().getParameters().get('id');
		this.segmentation = ApexPages.currentPage().getParameters().get('segmentation');
		errorMessage = '';
		actionDone = false;
	}

	public void insertMembers() {
		if(!String.isBlank(campaignId) && !String.isBlank(segmentation))
		{
			List<Id> actualMembers = new List<Id>();
			for(CampaignMember cmb : [select ContactId from CampaignMember where CampaignId=:campaignId])
				actualMembers.add(cmb.ContactId);

			List<CampaignMember> members = new List<CampaignMember>();
			for(Contact ctc:[select Id from Contact where MMPJ_Ext_Vign_Contact_Segmentation__c=:segmentation and Id NOT IN:actualMembers])
				members.add(new CampaignMember(ContactId=ctc.Id, CampaignId=campaignId, Status='Sent'));

			if(members.size() > 0)
			{
				try {
					Database.SaveResult [] updateResult = Database.insert(members, false);
				} catch (Exception ex)
				{
					System.debug('Error inserting campaign Members : ' + ex.getMessage());
					errorMessage = ex.getMessage();
				}
			} else {
				 errorMessage = 'Aucun ajout';
			}

			
		} else {
			errorMessage = 'Paramètres manquants';
		}
		actionDone = true;
		System.debug('##### errorMessage : ' + errorMessage);
	}
}