trigger RIC_ActeurAfterInsert on RIC_Acteur__c (after insert) {

    RIC_AP01_Acteur.shareProjectWithActeur(trigger.new);
}