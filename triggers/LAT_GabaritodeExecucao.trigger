/***************************************************************************
*   Company:Valuenet  Developers: Waldemar Mayo  Date:25/02/2014           *
***************************************************************************/
trigger LAT_GabaritodeExecucao on Gabarito_de_Execucao__c (before insert, before update, after insert, after update, after delete) {
    LAT_CTR_GabaritodeExecucao.runTriggers();
}