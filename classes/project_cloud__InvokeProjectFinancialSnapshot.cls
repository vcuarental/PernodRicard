/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvokeProjectFinancialSnapshot {
    global InvokeProjectFinancialSnapshot() {

    }
    @InvocableMethod(label='Take Project Financial Snapshot' description='Take Project Financial Snapshot')
    global static List<project_cloud__Financial_Snapshot__c> takeSnapshot(List<project_cloud.InvokeProjectFinancialSnapshot.InvocableProjectFinancialSnapshotClone> invocables) {
        return null;
    }
global class InvocableProjectFinancialSnapshotClone {
    @InvocableVariable(label='Description' description='Description of the financial snapshot' required=false)
    global String description;
    @InvocableVariable(label='Project Id' description='Required. The id of the project to take a financial snapshot of.' required=true)
    global Id projectId;
    @InvocableVariable(label='Type' description='Type of / reasoning for financial snapshot, only provide values included on the Type field on Financial Snapshot' required=false)
    global String snapshotType;
    global InvocableProjectFinancialSnapshotClone() {

    }
}
}
