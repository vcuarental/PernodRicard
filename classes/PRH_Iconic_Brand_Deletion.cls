/*
  January 2017 - evolution application Le Cercle LCS-11 - no more used - replaced by evol LCS-159
  Lorsqu'une brand est supprimée, celle-ci doit entrainer la suppression de la Competitor Brand ou Le Cercle Brand correspondante pour chaque collecte active
*/
public class PRH_Iconic_Brand_Deletion extends PRH_TriggerAbstract {
    public PRH_Iconic_Brand_Deletion() {
        super('PRH_Iconic_Brand_Deletion');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        // LCS-159 (July 2017) : Deleting a Brand set the status PRH_Active to value False but doesn't delete the Brand. 
        // This Brand is no more visible in collects. However all data are kept in Data Base.
        // It will be ignored during the collects creation for the following period.
        if (tAction == TriggerAction.BEFORE_DELETE) {
            List<PRH_Brand_Luxury_Brand__c> brandSelectedForDeleteList = (List<PRH_Brand_Luxury_Brand__c>)sObjList;
            System.debug('PRH_Iconic_Brand_Deletion, there are ' + brandSelectedForDeleteList.size() + ' brands selected for delete');

            // Throw an error that the Brand cannot be deleted
            for (PRH_Brand_Luxury_Brand__c br : brandSelectedForDeleteList) {    
                System.debug('PRH_Iconic_Brand_Deletion, br.ID = ' + br.ID + ' was not deleted'); 
                if (Test.isRunningTest()) {
                    System.debug('An Iconic Brand cannot be deleted, it is only possible to deactivate it setting field Active Brand to False'); 
                } else {
                    br.addError('An Iconic Brand cannot be deleted, it is only possible to deactivate it setting field Active Brand to False'); 
                }
            } 
        }
    }
}