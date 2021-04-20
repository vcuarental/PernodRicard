<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Update_Channel_Map</fullName>
        <description>Update ASI_HK_CRM_Channel_Map_Unique_ID__c with Channel picklist value</description>
        <field>ASI_HK_CRM_Channel_Map_Unique_ID__c</field>
        <formula>TEXT( ASI_HK_CRM_Channel__c )</formula>
        <name>ASI HK CRM - Update Channel Map</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI HK CRM Populate Channel Map Unique ID</fullName>
        <actions>
            <name>ASI_HK_CRM_Update_Channel_Map</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates ASI_HK_CRM_Channel_Map_Unique_ID__c with the value of Channel picklist</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
