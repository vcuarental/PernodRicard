<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>project_cloud__Timesheet_FU_Status_Active</fullName>
        <description>Change the status of the timesheet to active</description>
        <field>project_cloud__Status__c</field>
        <literalValue>Active</literalValue>
        <name>Time Sheet Active - Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>project_cloud__Timesheet_FU_Status_Approved</fullName>
        <description>Updates the status field on a time sheet to approved (on the time sheet object)</description>
        <field>project_cloud__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Time Sheet Approved - Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>project_cloud__Timesheet_FU_Status_Rejected</fullName>
        <description>Updates the status field on a time sheet to rejected (on the time sheet object)</description>
        <field>project_cloud__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Time Sheet Rejected - Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
