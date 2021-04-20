/**
 * Created by YuriyRudenko on 9/18/2020.
 */

public with sharing class EUR_CRM_AccGroupUserSharingQueueable implements Queueable{
    private Set<Id> aguIds;

    public EUR_CRM_AccGroupUserSharingQueueable(Set<Id> aguIds) {
        this.aguIds = aguIds;
    }

    public void execute(QueueableContext context) {
        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(aguIds), 200);
    }

}