/*************************************************************************
*Company:Valuenet      Developers: Denis Aranda       Date:22/10/2013    *
*************************************************************************/

trigger LAT_LATAccountAfter on LAT_ACCOUNT__c (after insert,after update) {
    
    //Filtrado de RecordTypes
    LAT_Trigger trigger_LAT = new LAT_Trigger('LAT_ACCOUNT__c', new set<String>{'LAT_AR_LAC_Standard', 'LAT_UY_LAC_Standard', 'LAT_BR_LAC_Standard', 'LAT_MX_LAC_Standard'});
    


	LAT_Trigger trigger_LAT_BR = new LAT_Trigger('LAT_ACCOUNT__c', new set<String>{'LAT_BR_LAC_Standard'});
    Map<Id, LAT_ACCOUNT__c> latBRAccountOldMap = new Map<Id, LAT_ACCOUNT__c>(); 

    if(!trigger_LAT.getNew().IsEmpty()){
    	system.debug('test+++LAT_LATAccountAfter1');
        if(trigger.isInsert){
        	system.debug('test+++LAT_LATAccountAfter2');
            LAT_AP01_LATAccount.LATAccountCreateCWH(trigger_LAT.getNew());
        } else if (trigger.isUpdate){
        	system.debug('test+++LAT_LATAccountAfter3' );
        	 if (!trigger_LAT_BR.getNew().IsEmpty()) {
	            for(LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_BR.getOld()){
	                latBRAccountOldMap.put(lata.Id, lata);
	            }
	            List <Account> brAccountToUpdate = new List<Account>();
	            for (LAT_ACCOUNT__c lata : (List<LAT_ACCOUNT__c>) trigger_LAT_BR.getNew()){
	                if (lata.LAT_DirectSale__c != latBRAccountOldMap.get(lata.Id).LAT_DirectSale__c){
	                    brAccountToUpdate.add(new Account(Id=lata.LAT_Accountid__c));
	                }
	            }

	            if (!brAccountToUpdate.isEmpty()){
	                update brAccountToUpdate;
	            }
    		}
        }
    }
}