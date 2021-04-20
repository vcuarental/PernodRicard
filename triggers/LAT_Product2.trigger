/***************************************************************************
*   Company:Valuenet   Developers: Elena Schwarzböck   Date:26/02/2014     *
****************************************************************************/

trigger LAT_Product2 on Product2 (before insert, after insert, after update) {
    LAT_CTR_Product2.runTriggers();
}