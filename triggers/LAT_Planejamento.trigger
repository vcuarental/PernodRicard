/***************************************************************************
*     Company:Valuenet    Developers: Denis Aranda    Date:20/03/2014      *
****************************************************************************/

trigger LAT_Planejamento on Planejamento__c (before insert, after insert, before update, after update ) {
    LAT_CTR_Planejamento.runTriggers();
}