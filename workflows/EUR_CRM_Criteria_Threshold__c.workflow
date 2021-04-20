<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_Update_isChanged_Status</fullName>
        <field>EUR_CRM_isChanged__c</field>
        <literalValue>1</literalValue>
        <name>EUR CRM Update isChanged Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR CRM Update isChanged Field</fullName>
        <actions>
            <name>EUR_CRM_Update_isChanged_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update isChanged field for mass update filter</description>
        <formula>AND( !ISNEW(), ISCHANGED( EUR_CRM_Weight__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
