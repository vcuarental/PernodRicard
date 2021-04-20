<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_UpdateStatus01</fullName>
        <description>Update the status to &apos;En aprobacion&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>En aprobacion</literalValue>
        <name>LAT_UpdateStatus01</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_UpdateStatus02</fullName>
        <field>LAT_Status__c</field>
        <literalValue>En ejecucion</literalValue>
        <name>LAT_UpdateStatus02</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
