/**
* Classe de test du Trigger de status de membre de campagne par défaut
**/
@isTest
public class MMPJ_XRM_defautCampaignStatusTriggerTest {
    static testMethod void defautCampaignStatusTest() {
        String rand = String.valueOf(Math.random());
        for (Recordtype recordTrigger : [SELECT ID FROM RECORDTYPE WHERE SobjectType = 'Campaign' AND DeveloperName = 'MMPJ_Ext_Vign_Campaign']) {
            Campaign camp = new Campaign (Name = 'Test status'+rand, RecordTypeId = recordTrigger.Id, type = '');
            insert camp;
            Campaign c1 = camp.clone(false, true);
            insert c1;
        }
    }
}