/*********************************************************************************
 * Name: ASI_KOR_RSDTriggerKeymanAllocation
 * Description: After RSD Payment Settlement is approved by NSD, trigger the keyman allocation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-08-24       Vincent Lam             Created          
*/
public class ASI_KOR_RSDTriggerKeymanAllocation extends ASI_KOR_TriggerAbstract {
    
    public ASI_KOR_RSDTriggerKeymanAllocation() {
        super('ASI_KOR_RSDTriggerKeymanAllocation');
    } 
	
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)  {
       	List<ASI_KOR_RSD_Payment_Settlement_Header__c> rsdPaySetList = (List<ASI_KOR_RSD_Payment_Settlement_Header__c>) sObjList;
        Map<Id, ASI_KOR_RSD_Payment_Settlement_Header__c> rsdPaySetMap = (Map<Id, ASI_KOR_RSD_Payment_Settlement_Header__c>) oldMap;
        List<ASI_KOR_RSD_Payment_Settlement_Header__c> rsdPaySetChanged = new List<ASI_KOR_RSD_Payment_Settlement_Header__c>();
        
        //Get all Payment Settlement that is approved by NSD
        
        for (ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaySet : rsdPaySetList ){
            if (rsdPaySetMap.get(rsdPaySet.id).ASI_KOR_Status__c == 'Submitted' &&
                rsdPaySet.ASI_KOR_Status__c =='Approved by NSD') {                    
                    rsdPaySetChanged.add(rsdPaySet);                                                           
                }
        }
        
			if (rsdPaySetChanged.size()>0){   
                
				List<ASI_KOR_BM_Payment_Settlement_Header__c> bmPaySets = [Select id, ownerId, ASI_KOR_RSD_Payment_Settlement__c, ASI_KOR_Branch__c From ASI_KOR_BM_Payment_Settlement_Header__c 
														  Where ASI_KOR_RSD_Payment_Settlement__c  in : rsdPaySetChanged
																  and ASI_KOR_Status__c = 'Approved by RSD'];

				List<ASI_KOR_SR_Payment_Settlement_Header__c> srPaySets = [Select id, ownerId, ASI_KOR_BM_Payment_Settlement_Header__c, ASI_KOR_Branch__c From ASI_KOR_SR_Payment_Settlement_Header__c 
														  Where ASI_KOR_BM_Payment_Settlement_Header__c in : bmPaySets
																  and ASI_KOR_Status__c = 'Approved by BM'];

				List<User> tmktUser = [select id from user where profileid in (select id from profile where name = 'ASI KOR Business Dev Admin')]; 
				
				//Create lookup relationship with BM and RSD, so BM and SR info could be retrieved by RSD ID
				Map<Id,Id> bmToRSDMap = new Map<Id,Id>();
				Map<Id, Set<String>> rsdPaySetSendMap = new Map<Id, Set<String>>();
				Set<Id> userId = new Set<Id>();
				 
				//loop all Payment Settlement to get the proposal owner Id 
				for(User tmkt : tmktUser){
					userId.add(tmkt.Id);
				}	
					
				for (ASI_KOR_RSD_Payment_Settlement_Header__c rsd : rsdPaySetChanged){
					userId.add(rsd.ownerId);    
				}

				for (ASI_KOR_BM_Payment_Settlement_Header__c bm : bmPaySets){   
					bmToRSDMap.put(bm.id, bm.ASI_KOR_RSD_Payment_Settlement__c); 
					userId.add(bm.ownerId);
				}

				for (ASI_KOR_SR_Payment_Settlement_Header__c sr : srPaySets){ 
					userId.add(sr.ownerId);
				}
				// get user email address by owner Id list 
				Map<Id, User> userIdtoEmail = new Map<Id, User> ([Select email from user where id in :userId]);

				//Map RSD Payment Settlement to all email address(RSD, BM, SR) related to the Payment Settlement
				for (ASI_KOR_RSD_Payment_Settlement_Header__c rsd : rsdPaySetChanged){
					String rsdEmail = userIdtoEmail.get(rsd.ownerId).Email;
					rsdPaySetSendMap = checkingSetElemt(rsdPaySetSendMap, rsd.id, rsdEmail);
				}

				for (ASI_KOR_BM_Payment_Settlement_Header__c bm : bmPaySets){   
					rsdPaySetSendMap = checkingSetElemt(rsdPaySetSendMap, bm.ASI_KOR_RSD_Payment_Settlement__c, userIdtoEmail.get(bm.ownerId).email);
				}

				for (ASI_KOR_SR_Payment_Settlement_Header__c sr : srPaySets){ 
					rsdPaySetSendMap = checkingSetElemt(rsdPaySetSendMap, bmToRSDMap.get(sr.ASI_KOR_BM_Payment_Settlement_Header__c), userIdtoEmail.get(sr.ownerId).email);
				}
				
				// add TMKT email list
				list<string> list_TMKTemail = new list<string>();
				for (User tmkt : tmktUser){
					list_TMKTemail.add(userIdtoEmail.get(tmkt.id).Email);
				}
				
				//send email by each Payment Settlement
				for (ASI_KOR_RSD_Payment_Settlement_Header__c rsdPS : rsdPaySetChanged){
					Database.executeBatch(new ASI_KOR_KeymanAllocationBatch(rsdPS.ASI_KOR_Year__c, rsdPS.ASI_KOR_Month__c, rsdPS.ASI_KOR_Region__c, rsdPS, rsdPaySetSendMap, list_TMKTemail),200);
				}
                
				updateCutoffDate(rsdPaySetChanged);
            }                  
        }                
      

	private Map<Id, Set<String>> checkingSetElemt (Map<Id, Set<String>> mp, Id paySetId, String userEmail) {
    
		Map<Id, Set<String>> convertedMap = mp;    
    
    	if (mp.get(paySetId) == null){
          Set<String> convertToSet = new Set<String>();
          convertToSet.add(userEmail);
          convertedMap.put(paySetId,convertToSet);
        
    	} else{
        convertedMap.get(paySetId).add(userEmail);        
    	}
    	return convertedMap;     
	}


//	private void sendNotificationEmail (String subject, String plainBody, List<String> sendList, List<String> tmktList)  {
//
//        sendList.add('prkr.sfdc.lpt@gmail.com');
//
//      Messaging.singleEmailMessage email = new Messaging.singleEmailMessage();
//      email.setToAddresses(sendList);
//      email.setCcAddresses(tmktList);
//      email.setSubject(subject);
//      email.setPlainTextBody(plainBody);
//      email.setSaveAsActivity(false);
//    //email.setTemplateId(templateId);
//
//		try {
//        	Messaging.sendEmail(new Messaging.singleEmailMessage[] {email});
//        	system.debug('Smail sent successfully :' + email);
//    		}
//		catch (Exception e) {apexpages.message err =
//								new apexpages.message(apexpages.severity.error, e.getMessage());
//								apexpages.addmessage(err);
//		}
//	}
	
	private void updateCutoffDate(List<ASI_KOR_RSD_Payment_Settlement_Header__c> list_RSD){
		List<string> list_rsdID = new List<string>();
		for (ASI_KOR_RSD_Payment_Settlement_Header__c rsdPS : list_RSD){
			list_rsdID.add(rsdPS.id);
		}
		List<ASI_KOR_RSD_Payment_Settlement_Header__c> list_RSDtoUpdate = [select id from ASI_KOR_RSD_Payment_Settlement_Header__c where id in :list_rsdID];
		for (ASI_KOR_RSD_Payment_Settlement_Header__c rsdPS : list_RSDtoUpdate){
			rsdPS.ASI_KOR_Keyman_Allocation_Date__c = Date.today();
		}
		update list_RSDtoUpdate;
	}
}