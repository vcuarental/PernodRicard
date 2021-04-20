public virtual class GDT_TriggerHandler {
    


    // main method that will be called during execution
    public void run() {
        // dispatch to the correct handler method
        if(Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) {
          beforeInsert();
        } else if(Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) {
          beforeUpdate();
        } else if(Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) {
          beforeDelete();
        } else if(Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) {
          afterInsert();
        } else if(Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) {
          afterUpdate();
        } else if(Trigger.isExecuting  && Trigger.isAfter && Trigger.isDelete) {
          afterDelete();
        } else if(Trigger.isExecuting && Trigger.isUndelete) {
          afterUndelete();
        }
        andFinally();
    }

    // context-specific methods for override
    @TestVisible
    public virtual void beforeInsert(){}
    @TestVisible
    public virtual void beforeUpdate(){}
    @TestVisible
    public virtual void beforeDelete(){}
    @TestVisible
    public virtual void afterInsert(){}
    @TestVisible
    public virtual void afterUpdate(){}
    @TestVisible
    public virtual void afterDelete(){}
    @TestVisible
    public virtual void afterUndelete(){}
    @TestVisible
    public virtual void andFinally(){}


    // main method that will be called during execution
    public void runAllActions() {
        beforeInsert();
        beforeUpdate();
        beforeDelete();
        afterInsert();
        afterUpdate();
        afterDelete();
        afterUndelete();
        andFinally();
    }


}