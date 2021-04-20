/*
* Created Date: June 25, 2020
* Created By  : CGI
* Description : CCS-5042 : When a ContractBQ is removed from an existing contract, remove CollectBQ and CollectBQS for active collects (state New or Processing) of this contract
*/
trigger GRP_CC_RemoveBQFromCollect on GRP_CC_ContractBQ__c (after delete) {
    List<GRP_CC_ContractBQ__c> ctBQList = new List<GRP_CC_ContractBQ__c> ();
    List<GRP_CC_Collect__c> collectList = new List<GRP_CC_Collect__c> ();
    List<Id> coreBQDeletedList = new List<Id> ();
    List<GRP_CC_CollectBQ__c> collectBQToDeleteList = new List<GRP_CC_CollectBQ__c> ();

    for(GRP_CC_ContractBQ__c ctBQ : trigger.old){
        ctBQList.add(ctBQ);
        coreBQDeletedList.add(ctBQ.GRP_CC_BrandQuality__c);
    }
	system.debug('GRP_CC_RemoveBQFromCollect, ctBQList:'+ctBQList);
    system.debug('GRP_CC_RemoveBQFromCollect, coreBQDeletedList:'+coreBQDeletedList);
    ID contract = ctBQList[0].GRP_CC_Contract__c;

    collectList = [select Id from GRP_CC_Collect__c where GRP_CC_Collect__c.GRP_CC_Contract__c =: contract AND GRP_CC_Collect__c.GRP_CC_State__c IN ('New', 'Processing')];
    system.debug('GRP_CC_RemoveBQFromCollect, collectList.size:'+collectList.size());
    
    if (Trigger.isDelete) { 
        if(collectList!=null && collectList.size()>0){
            collectBQToDeleteList.addAll([Select Id, GRP_CC_Collect__c, GRP_CC_BrandQuality__c from GRP_CC_CollectBQ__c where GRP_CC_Collect__c IN :collectList and GRP_CC_BrandQuality__c IN :coreBQDeletedList]);
        }
        system.debug('GRP_CC_RemoveBQFromCollect, collectBQToDeleteList.size:'+collectBQToDeleteList.size());
        system.debug('GRP_CC_RemoveBQFromCollect, collectBQToDeleteList:'+collectBQToDeleteList);
        if(collectBQToDeleteList.size()>0){
            delete collectBQToDeleteList;
        }
    }
        	
}