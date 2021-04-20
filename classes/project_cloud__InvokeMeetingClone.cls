/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvokeMeetingClone {
    global InvokeMeetingClone() {

    }
    @InvocableMethod(label='Clone a Meeting' description='Clones a Meeting.')
    global static List<Id> cloneMeetings(List<project_cloud.InvokeMeetingClone.InvocableMeetingClone> invocables) {
        return null;
    }
global class InvocableMeetingClone {
    @InvocableVariable(label='Meeting Name' description='Optional. The name to give to the created Meeting. If empty, will use [ClonedMeeting.Name] - [RelatedRecord.Name].' required=false)
    global String meetingName;
    @InvocableVariable(label='Meeting Start Time' description='Optional. The time the meeting should start. Defaults to tomorrow at noon.' required=false)
    global Datetime meetingStartTime;
    @InvocableVariable(label='Omit Minutes from Template' description='Optional. If true the Minutes from the Agenda Items will not be included. Defaults to false.' required=false)
    global Boolean omitMinutes;
    @InvocableVariable(label='Related Record Id' description='Optional. The Id of the record to related to.' required=false)
    global String relatedRecordId;
    @InvocableVariable(label='Meeting Id' description='Required. The Id of the meeting to clone.' required=true)
    global String templateId;
    @InvocableVariable(label='Copy Related Record Ownership' description='Optional. If true the specified related record's owner becomes the created meeting's owner. Only User Owners supported.' required=false)
    global Boolean transferOwnership;
    global InvocableMeetingClone() {

    }
}
}
