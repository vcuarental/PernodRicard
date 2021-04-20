/*
* Created Date: March 05, 2020
* Created By : Corentin FRANCOIS - CGI
* Description: CC-4954 : When a ContractBQS is added to a existing contract, create CollectBQ and CollectBQS for all active collects of this contract
*
*/
trigger GRP_CC_AddNewCollectBQSToCollects on GRP_CC_Contract_BQS_Link__c (after insert) {
    List<GRP_CC_Contract_BQS_Link__c> ctBQSList = new List<GRP_CC_Contract_BQS_Link__c> ();
    List<GRP_CC_Collect__c> collectList = new List<GRP_CC_Collect__c> ();
    List<GRP_CC_CollectBQS__c> collectBQSList = new List<GRP_CC_CollectBQS__c> ();


    for(GRP_CC_Contract_BQS_Link__c ctBQS : trigger.new){
        ctBQSList.add(ctBQS);
    }

    ID contract = ctBQSList[0].GRP_CC_Contract__c;

    collectList = [select Id from GRP_CC_Collect__c where GRP_CC_Collect__c.GRP_CC_Contract__c =: contract AND GRP_CC_Collect__c.GRP_CC_State__c IN ('New', 'Processing')];

    if(collectList!=null && collectList.size()>0){
        for(GRP_CC_Collect__c col : collectList){
            for(GRP_CC_Contract_BQS_Link__c ctBQS : ctBQSList){
                GRP_CC_CollectBQS__c newCollectBQS = new GRP_CC_CollectBQS__c(
                    GRP_CC_Collect__c = col.Id,
                    GRP_CC_BrandQualitySize__c = ctBQS.GRP_CC_BrandQualitySize__c,
                    GRP_CC_Quantity__c = 0
                );

                collectBQSList.add(newCollectBQS);
            }
        }
        if(collectBQSList.size()>0) {
        	insert collectBQSList;
        }
    }
}