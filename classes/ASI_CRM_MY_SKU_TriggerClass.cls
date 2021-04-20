public without sharing class ASI_CRM_MY_SKU_TriggerClass {
	public static void routineBeforeInsert(list<ASI_MFM_SKU_Code__c> trigger_new) {
		linkupSKUGrpBeforeTrigger(trigger_new);
	
	}



	public static void routineAfterInsert(list<ASI_MFM_SKU_Code__c> trigger_new) {
		updateSKUGrpAfterTrigger();
		
	}


	public static void routineBeforeUpdate(list<ASI_MFM_SKU_Code__c> trigger_new) {
		linkupSKUGrpBeforeTrigger(trigger_new);

	}

	public static void routineAfterUpdate(list<ASI_MFM_SKU_Code__c> trigger_new) {
		updateSKUGrpAfterTrigger();
		

	}



	public static  Map<String, ASI_CRM_SKU_Group__c> m_Name_SKUGrp = new Map<String,ASI_CRM_SKU_Group__c>();	//Vairable cross before trigger & after trigger (reduce the duplicate query)
	public static List<ASI_MFM_SKU_Code__c> l_NewMappedSKU = new  List<ASI_MFM_SKU_Code__c> ();		//Vairable cross before trigger & after trigger (reduce the duplicate query)
	
	public static void linkupSKUGrpBeforeTrigger (list<ASI_MFM_SKU_Code__c> trigger_new){
		//To check if the corresponding SKU Group exists or not. If yes, link with it (To update field "ASI_CRM_SKU_Group__c")；If not, create SKU Group and link with it;
		Set<String> s_SKUGrpCode = new Set<String>();
		List<ASI_MFM_SKU_Code__c> l_SKU_ToMapGrp = new List<ASI_MFM_SKU_Code__c>();
		List<ASI_MFM_SKU_Code__c> l_SKU_NewGrp = new List<ASI_MFM_SKU_Code__c>();

		for(ASI_MFM_SKU_Code__c sku : trigger_new){
			//If ASI_CRM_SKU_Group_Code__c = ASI_MFM_SKU_Code__c, it means this SKU is new and need to create new SKU Group
			if(sku.ASI_CRM_SKU_Group__c ==null && !String.isEmpty(sku.ASI_CRM_SKU_Group_Code__c) && sku.ASI_CRM_SKU_Group_Code__c==sku.ASI_MFM_SKU_Code__c ){
				l_SKU_NewGrp.add(sku);
				l_SKU_ToMapGrp.add(sku);
			}

			else if(sku.ASI_CRM_SKU_Group__c ==null && !String.isEmpty(sku.ASI_CRM_SKU_Group_Code__c) ){
				s_SKUGrpCode.add(sku.ASI_CRM_SKU_Group_Code__c);
				l_SKU_ToMapGrp.add(sku);
			}

			
		}
		system.debug('routineBeforeTrigger linkupSKUGrpBeforeTrigger s_SKUGrpCode:'+s_SKUGrpCode);

		//1.Create new "SkU Group" records first:
		if(l_SKU_NewGrp.size()>0){
			List<ASI_CRM_SKU_Group__c> l_NewGrps = new List<ASI_CRM_SKU_Group__c>();
			for(ASI_MFM_SKU_Code__c sku: l_SKU_NewGrp){
				ASI_CRM_SKU_Group__c newGrp = new ASI_CRM_SKU_Group__c(Name = sku.ASI_CRM_SKU_Group_Code__c, CurrencyIsoCode='MYR', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Group__cASI_CRM_MY_SKU_Group'));
				l_NewGrps.add(newGrp);
				m_Name_SKUGrp.put(newGrp.Name, newGrp);
			}
 
			system.debug('routineBeforeTrigger l_NewGrps:'+l_NewGrps);			
			insert l_NewGrps;
		}
		
		
		//2.Link with "SKU Group" (Update field "ASI_CRM_SKU_Group__c" on SKU):
		if(l_SKU_ToMapGrp.size()>0){
			if(s_SKUGrpCode.size()>0){
				for(ASI_CRM_SKU_Group__c grp: [SELECT Id, name, ASI_CRM_Effective_SKU__c, ASI_CRM_Related_SKU_Codes__c,ASI_CRM_Related_SKU_Ids__c,ASI_CRM_SKU_Effective_Date__c FROM ASI_CRM_SKU_Group__c WHERE Name in: s_SKUGrpCode Order BY CreatedDate DESC]){
					m_Name_SKUGrp.put(grp.name, grp);
				}
			}
			system.debug('routineBeforeInsert m_Name_SKUGrp:'+m_Name_SKUGrp);
			if(m_Name_SKUGrp.size()>0){
				for(ASI_MFM_SKU_Code__c sku : l_SKU_ToMapGrp){
					ASI_CRM_SKU_Group__c temp_Grp = m_Name_SKUGrp.get(sku.ASI_CRM_SKU_Group_Code__c);
					if(temp_Grp!=null && temp_Grp.Id!=null){
						sku.ASI_CRM_SKU_Group__c = temp_Grp.Id;
						l_NewMappedSKU.add(sku);
					}
				}
			}
			
		}
	}


	public static void updateSKUGrpAfterTrigger(){
		if(l_NewMappedSKU.size()>0 && m_Name_SKUGrp.size()>0){
			List<ASI_CRM_SKU_Group__c> l_SKUGrp_ToUpdate = new List<ASI_CRM_SKU_Group__c>();
			Map<Id,ASI_CRM_SKU_Group__c> m_IDSKUGrp_ToUpdate = new Map<Id,ASI_CRM_SKU_Group__c>();
			for(ASI_MFM_SKU_Code__c sku : l_NewMappedSKU){
				ASI_CRM_SKU_Group__c temp_Grp = m_Name_SKUGrp.get(sku.ASI_CRM_SKU_Group_Code__c);
				if(sku.ASI_CRM_SKU_Group__c !=null && temp_Grp!=null){
					if(String.isEmpty(temp_Grp.ASI_CRM_Related_SKU_Codes__c)){
						temp_Grp.ASI_CRM_Related_SKU_Codes__c='"'+sku.ASI_MFM_SKU_Code__c+'"';
					}else if (! temp_Grp.ASI_CRM_Related_SKU_Codes__c.contains('"'+sku.ASI_MFM_SKU_Code__c+'"')){
						temp_Grp.ASI_CRM_Related_SKU_Codes__c+=',"'+sku.ASI_MFM_SKU_Code__c+'"';
					}
					
					if(String.isEmpty(temp_Grp.ASI_CRM_Related_SKU_Ids__c)){
						temp_Grp.ASI_CRM_Related_SKU_Ids__c='"'+sku.Id+'"';
					}else if (! temp_Grp.ASI_CRM_Related_SKU_Ids__c.contains('"'+sku.Id+'"')){
						temp_Grp.ASI_CRM_Related_SKU_Ids__c+=',"'+sku.Id+'"';
					}
					m_IDSKUGrp_ToUpdate.put(temp_Grp.Id, temp_Grp);
				}
			}
			l_SKUGrp_ToUpdate.addAll(m_IDSKUGrp_ToUpdate.values());
			system.debug('routineAfterTrigger updateSKUGrpAfterTrigger l_SKUGrp_ToUpdate:'+l_SKUGrp_ToUpdate);
			if(l_SKUGrp_ToUpdate.size()>0){
				update l_SKUGrp_ToUpdate;
			}
		}

	}



}