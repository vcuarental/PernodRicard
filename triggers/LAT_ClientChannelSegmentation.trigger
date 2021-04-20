/***************************************************************************
*   Company:Valuenet  Developers: Denis Aranda   Date:27/05/2014           *
***************************************************************************/
trigger LAT_ClientChannelSegmentation on LAT_BR_ClientChannelSegmentation__c (before insert, before update, after insert, after update, before delete) {
    LAT_CTR_ClientChannelSegmentation.runTriggers();
}