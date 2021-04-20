/***************************************************************************
*     Company:Valuenet    Developers: Denis Aranda    Date:19/03/2014      *
****************************************************************************/

trigger LAT_TerritoryPlanning on LAT_BR_TPL_TerritoryPlanning__c (before insert, before update) {
    LAT_CTR_TerritoryPlanning.runTriggers();
}