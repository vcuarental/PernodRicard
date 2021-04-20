<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Set_Employee_Attendess_Rec_Tp</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Employee_Attendee</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Employee Attendess Rec Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_JP_Set_Emplye_Atds_Rec_Tp_Plan</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_JP_Employee_Attendee_Planned</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Employee Attendess Rec Type Planned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_JP_Change_Attendee_Page</fullName>
        <actions>
            <name>ASI_CRM_JP_Set_Emplye_Atds_Rec_Tp_Plan</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Employee_Attendee__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>JP CRM Employee Attendee</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
