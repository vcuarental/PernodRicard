<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>project_cloud__Work_FU_Status_Approved</fullName>
        <description>Updates the status field on a time entry to approved (on the work object)</description>
        <field>project_cloud__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Time Entry Approved - Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>project_cloud__Work_FU_Status_Rejected</fullName>
        <description>Updates the status field on a time entry to rejected (on the work object)</description>
        <field>project_cloud__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Time Entry Rejected - Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
