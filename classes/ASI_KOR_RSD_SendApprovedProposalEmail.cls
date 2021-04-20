/**********************************************************************************
 * Name : ASI_KOR_RSD_SendApprovedProposalEmail 
 * Created : Kevin Choi
 * Revision History:
 * 1. 2017-02-08 - [KC] Created, send notification email to SR, BM, RSD and TMKT 
  						after the region proposal is approved by NSD
 **********************************************************************************/
public class ASI_KOR_RSD_SendApprovedProposalEmail extends ASI_KOR_TriggerAbstract {
    
     public ASI_KOR_RSD_SendApprovedProposalEmail() {
        super('ASI_KOR_RSD_SendApprovedProposalEmail');
    } 
	
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)  {
       	List<ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderList = (List<ASI_KOR_RSD_Proposal_Header__c>) sObjList;
        Map<Id, ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderMap = (Map<Id, ASI_KOR_RSD_Proposal_Header__c>) oldMap;
        List<ASI_KOR_RSD_Proposal_Header__c> rsdProposalChanged = new List<ASI_KOR_RSD_Proposal_Header__c>();
        
        //Get all proposal that is approved by NSD
        
        for (ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader : rsdProposalHeaderList ){
            if (rsdProposalHeaderMap.get(rsdProposalHeader.id).ASI_KOR_Status__c == 'Submitted' &&
                rsdProposalHeader.ASI_KOR_Status__c =='Approved by NSD') {                    
                    rsdProposalChanged.add(rsdProposalHeader);                                                           
                }
        }
        
			if (rsdProposalChanged.size()>0){   
                
			List<ASI_KOR_BM_Proposal_Header__c> bmProposals = [Select id, ownerId, ASI_KOR_RSD_Proposal_Header__c, ASI_KOR_Branch__c From ASI_KOR_BM_Proposal_Header__c 
                                                      Where ASI_KOR_RSD_Proposal_Header__c  in : rsdProposalChanged
                                                              and ASI_KOR_Status__c = 'Approved by RSD'];

			List<ASI_KOR_SR_Proposal_Header__c> srProposals = [Select id, ownerId, ASI_KOR_BM_Proposal_Header__c, ASI_KOR_Branch__c From ASI_KOR_SR_Proposal_Header__c 
                                                      Where ASI_KOR_BM_Proposal_Header__c in : bmProposals
                                                              and ASI_KOR_Status__c = 'Approved by BM'];

			List<User> tmktUser = [select id from user where profileid in (select id from profile where name = 'ASI KOR Business Dev Admin')]; 
                                     
			EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where developername ='ASI_KOR_RSD_Proposal_Approved_To_All'];
            
            //Create lookup relationship with BM and RSD, so BM and SR info could be retrieved by RSD ID
			Map<Id,Id> bmToRSDMap = new Map<Id,Id>();
			Map<Id, Set<String>> rsdPropSendMap = new Map<Id, Set<String>>();
			Set<Id> userId = new Set<Id>();
             
             // loop all proposal to get the proposal owner Id 
			for(User tmkt : tmktUser){
				userId.add(tmkt.Id);
			}	
                
			for (ASI_KOR_RSD_Proposal_Header__c rsd : rsdProposalChanged){
				userId.add(rsd.ownerId);    
 			}

			for (ASI_KOR_BM_Proposal_Header__c bm : bmProposals){   
    			bmToRSDMap.put(bm.id, bm.ASI_KOR_RSD_Proposal_Header__c); 
    			userId.add(bm.ownerId);
  			}

 			for (ASI_KOR_SR_Proposal_Header__c sr : srProposals){ 
      			userId.add(sr.ownerId);
  			}
			// get user email address by owner Id list 
			Map<Id, User> userIdtoEmail = new Map<Id, User> ([Select email from user where id in :userId]);

			//Map RSD proposal to all email address(RSD, BM, SR) related to the proposal
			for (ASI_KOR_RSD_Proposal_Header__c rsd : rsdProposalChanged){
    			String rsdEmail = userIdtoEmail.get(rsd.ownerId).Email;
    			rsdPropSendMap = checkingSetElemt(rsdPropSendMap, rsd.id, rsdEmail);
			}

			for (ASI_KOR_BM_Proposal_Header__c bm : bmProposals){   
    			rsdPropSendMap = checkingSetElemt(rsdPropSendMap, bm.ASI_KOR_RSD_Proposal_Header__c, userIdtoEmail.get(bm.ownerId).email);
			}

			for (ASI_KOR_SR_Proposal_Header__c sr : srProposals){ 
				rsdPropSendMap = checkingSetElemt(rsdPropSendMap, bmToRSDMap.get(sr.ASI_KOR_BM_Proposal_Header__c), userIdtoEmail.get(sr.ownerId).email);
			}
                
                // add TMKT email list
                list<string> list_TMKTemail = new list<string>();
                for (User tmkt : tmktUser){
                    list_TMKTemail.add(userIdtoEmail.get(tmkt.id).Email);
                }
			
            //send email by each proposal
			for (ASI_KOR_RSD_Proposal_Header__c rsdProp : rsdProposalChanged){
                
                String subject = emailTemplate.Subject;
                String plainBody = emailTemplate.Body;
    			plainBody = plainBody.replace('{!ASI_KOR_RSD_Proposal_Header__c.ASI_KOR_Region__c}', rsdProp.ASI_KOR_Region__c);
    			plainBody = plainBody.replace('{!ASI_KOR_RSD_Proposal_Header__c.ASI_KOR_Year__c}', rsdProp.ASI_KOR_Year__c);
    			plainBody = plainBody.replace('{!ASI_KOR_RSD_Proposal_Header__c.ASI_KOR_Month__c}', rsdProp.ASI_KOR_Month__c);
    			plainBody = plainBody.replace('{!ASI_KOR_RSD_Proposal_Header__c.ASI_KOR_Status__c}', rsdProp.ASI_KOR_Status__c);
                
                sendNotificationEmail(subject, plainBody, new list<String>(rsdPropSendMap.get(rsdProp.Id)), list_TMKTemail);
                } 
                
            }else {
                return;
				}                    
        }                
      

	private Map<Id, Set<String>> checkingSetElemt (Map<Id, Set<String>> mp, Id proposalId, String userEmail) {
    
		Map<Id, Set<String>> convertedMap = mp;    
    
    	if (mp.get(proposalId) == null){
          Set<String> convertToSet = new Set<String>();
          convertToSet.add(userEmail);
          convertedMap.put(proposalId,convertToSet);
        
    	} else{
        convertedMap.get(proposalId).add(userEmail);        
    	}
    	return convertedMap;     
	}


	private void sendNotificationEmail (String subject, String plainBody, List<String> sendList, List<String> tmktList)  {

        sendList.add('prkr.sfdc.lpt@gmail.com');
        
      Messaging.singleEmailMessage email = new Messaging.singleEmailMessage();	  
      email.setToAddresses(sendList);      
      email.setCcAddresses(tmktList);      
      email.setSubject(subject);
      email.setPlainTextBody(plainBody);
      email.setSaveAsActivity(false);   
    //email.setTemplateId(templateId);
    
		try {
        	Messaging.sendEmail(new Messaging.singleEmailMessage[] {email});
        	system.debug('Smail sent successfully :' + email);
    		}
		catch (Exception e) {apexpages.message err = 
								new apexpages.message(apexpages.severity.error, e.getMessage());
								apexpages.addmessage(err); 
		}           
	}
}