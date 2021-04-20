@isTest
public class ASI_CRM_JP_DataServiceTest {

    @isTest
    static void testGetPurchaseContractIdsByItemIds() {
        Set<Id> idSet = new Set<Id>();
        idSet.add(UserInfo.getUserId());
        ASI_CRM_JP_DataService.getPurchaseContractIdsByItemIds(idSet);
    }
}