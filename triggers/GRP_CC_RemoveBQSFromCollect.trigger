/*
* Created Date: June 24, 2020
* Created By  : CGI
* Description : CCS-5042 : When a ContractBQS is removed from an existing contract, delete CollectBQ and CollectBQS for all active collects of this contract
*/
trigger GRP_CC_RemoveBQSFromCollect on GRP_CC_Contract_BQS_Link__c (after delete) {
    List<GRP_CC_Contract_BQS_Link__c> ctBQSList = new List<GRP_CC_Contract_BQS_Link__c> ();
    List<GRP_CC_Collect__c> collectList = new List<GRP_CC_Collect__c> ();
    List<GRP_CC_CollectBQS__c> collectBQSToDeleteList = new List<GRP_CC_CollectBQS__c> ();
    List<Id> coreBQSDeletedList = new List<Id> ();

    for(GRP_CC_Contract_BQS_Link__c ctBQS : trigger.old){
        ctBQSList.add(ctBQS);
        coreBQSDeletedList.add(ctBQS.GRP_CC_BrandQualitySize__c);
    }
	system.debug('GRP_CC_RemoveBQSFromCollect, ctBQSList:'+ctBQSList);
    system.debug('GRP_CC_RemoveBQSFromCollect, coreBQSDeletedList:'+coreBQSDeletedList);
    ID contract = ctBQSList[0].GRP_CC_Contract__c;

    collectList = [select Id from GRP_CC_Collect__c where GRP_CC_Collect__c.GRP_CC_Contract__c =: contract AND GRP_CC_Collect__c.GRP_CC_State__c IN ('New', 'Processing')];
	system.debug('GRP_CC_RemoveBQSFromCollect, collectList.size:'+collectList.size());
    
    if (Trigger.isDelete) { 
        if(collectList!=null && collectList.size()>0){
        	collectBQSToDeleteList.addAll([Select Id, GRP_CC_Collect__c, GRP_CC_BrandQualitySize__c from GRP_CC_CollectBQS__c where GRP_CC_Collect__c IN :collectList and GRP_CC_BrandQualitySize__c IN :coreBQSDeletedList]);
        }
		system.debug('GRP_CC_RemoveBQSFromCollect, collectBQSToDeleteList.size:'+collectBQSToDeleteList.size());
        system.debug('GRP_CC_RemoveBQSFromCollect, collectBQSToDeleteList:'+collectBQSToDeleteList);
        if(collectBQSToDeleteList.size()>0){
            delete collectBQSToDeleteList;
        }
    }

}