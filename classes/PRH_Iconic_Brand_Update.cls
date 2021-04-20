public class PRH_Iconic_Brand_Update extends PRH_TriggerAbstract {
    public PRH_Iconic_Brand_Update() {
        super('PRH_Iconic_Brand_Update');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.AFTER_UPDATE) {
        	// Launch the batch to update Le Cercle collects values
        	Database.executeBatch(new PRH_UpdateCollectsCalculatedValues(), 50);
	    }
    }
}