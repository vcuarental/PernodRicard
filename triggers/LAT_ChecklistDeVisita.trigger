/***************************************************************************
*   Company:Valuenet  Developers: Elena J. Schwarzböck  Date:07/05/2014    *
****************************************************************************/
trigger LAT_ChecklistDeVisita on Checklist_de_visita__c (after update) {
    LAT_CTR_ChecklistDeVisita.runTriggers();
}