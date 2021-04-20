trigger RIC_ActeurBeforeInsert on RIC_Acteur__c (before insert) {

    RIC_AP01_Acteur.checkDuplicateActeur(trigger.new);
}