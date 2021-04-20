<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LAT_updateExternalId</fullName>
        <field>LAT_KeyUnica__c</field>
        <formula>LAT_Product__r.LAT_ExternalID__c + &apos;-&apos; + Origen__c + &apos;-&apos; + Destino__c</formula>
        <name>LAT_updateExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_UpdateExternalId</fullName>
        <actions>
            <name>LAT_updateExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
