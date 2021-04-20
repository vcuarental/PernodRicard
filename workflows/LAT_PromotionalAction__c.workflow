<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_Final_UpdateStatus</fullName>
        <field>LAT_status__c</field>
        <literalValue>Ação aprovada</literalValue>
        <name>Final_UpdateStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_Final_UpdateType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Aprovada</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Final_UpdateType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_Initial_UpdateStatus</fullName>
        <field>LAT_status__c</field>
        <literalValue>Ação encaminhada a aprovação</literalValue>
        <name>Initial_UpdateStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_Reject_UpdateStatus</fullName>
        <field>LAT_status__c</field>
        <literalValue>Ação não aprovada</literalValue>
        <name>Reject_UpdateStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
