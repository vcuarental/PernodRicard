<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ESN_BP_Vote_Unique_Update</fullName>
        <description>Update a vote unique field for a Best practice vote.</description>
        <field>ESN_BP_Vote_Unique__c</field>
        <formula>CreatedById &amp;  ESN_BP_Vote_Function__c</formula>
        <name>ESN_BP_Vote_Unique_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ESN_BP_Vote_Unique</fullName>
        <actions>
            <name>ESN_BP_Vote_Unique_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
