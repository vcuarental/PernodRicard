/*
* Created Date: March 05, 2020
* Created By : Corentin FRANCOIS - CGI
* Description: CC-4954 : When a ContractBQ is added to a existing contract, create CollectBQ and CollectBQS for all active collects of this contract
* Modified By : MCH, June 23 2020
*/
trigger GRP_CC_AddNewProductToCollect on GRP_CC_ContractBQ__c (after insert) {
    List<GRP_CC_ContractBQ__c> ctBQList = new List<GRP_CC_ContractBQ__c> ();
    List<GRP_CC_Collect__c> collectList = new List<GRP_CC_Collect__c> ();
    List<GRP_CC_CollectBQ__c> collectBQList = new List<GRP_CC_CollectBQ__c> ();
    List<GRP_CC_CollectBQ__c> collectBQToUpdateList = new List<GRP_CC_CollectBQ__c> ();
    Map<Id, GRP_CC_ContractBQ__c> contractBQMap = new Map<Id, GRP_CC_ContractBQ__c> ();

    for(GRP_CC_ContractBQ__c ctBQ : trigger.new){
        ctBQList.add(ctBQ);
    }
	system.debug('GRP_CC_AddNewProductToCollect, ctBQList:'+ctBQList);
    ID contract = ctBQList[0].GRP_CC_Contract__c;

    collectList = [select Id from GRP_CC_Collect__c where GRP_CC_Collect__c.GRP_CC_Contract__c =: contract AND GRP_CC_Collect__c.GRP_CC_State__c IN ('New', 'Processing')];
    system.debug('GRP_CC_AddNewProductToCollect, isInsert, collectList.size:'+collectList.size());
    system.debug('GRP_CC_AddNewProductToCollect, collectList:'+collectList);
    
    if (Trigger.isInsert){
        if(collectList!=null && collectList.size()>0){
            for(GRP_CC_Collect__c col : collectList){
                for(GRP_CC_ContractBQ__c ctBQ : ctBQList){
                    //system.debug('GRP_CC_AddNewProductToCollect, isInsert, ctBQ:'+ctBQ);
                    GRP_CC_CollectBQ__c newCollectBQ = new GRP_CC_CollectBQ__c(
                        GRP_CC_Collect__c = col.Id,
                        GRP_CC_BrandQuality__c = ctBQ.GRP_CC_BrandQuality__c,
                        //GRP_CC_IsOnMenu__c = ctBQ.GRP_CC_OnMenu__c,
                        //GRP_CC_IsRoomsMinibar__c = ctBQ.GRP_CC_Rooms_Minibar__c,
                        //GRP_CC_IsPouring__c = ctBQ.GRP_CC_Pouring__c,
                        //GRP_CC_IsMeetingsEvents__c = ctBQ.GRP_CC_Meetings_Events__c,
                        GRP_CC_IsOptionalAdditions__c = ctBQ.GRP_CC_Optional_Additions__c,
                        GRP_CC_No_volume__c = true
                    );
    
                    collectBQList.add(newCollectBQ);
                }
            }
            if(collectBQList.size()>0){
                system.debug('GRP_CC_AddNewProductToCollect, isInsert, collectBQList.size:'+collectBQList.size());
                insert collectBQList;
            }
        }
    }

}